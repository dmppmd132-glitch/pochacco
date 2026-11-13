import { createHash } from 'node:crypto'
import { mkdir, readFile, rename, rm, stat, writeFile } from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const lockPath = path.join(projectRoot, 'assets.lock.json')
const lock = JSON.parse(await readFile(lockPath, 'utf8'))
const entries = Object.entries(lock.assets ?? {})

if (lock.version !== 2 || entries.length === 0) {
  throw new Error('Unsupported or empty assets.lock.json')
}

function resolveAssetPath(relativePath) {
  if (path.isAbsolute(relativePath)) throw new Error(`Absolute asset path is not allowed: ${relativePath}`)
  const target = path.resolve(projectRoot, relativePath)
  if (target !== projectRoot && !target.startsWith(`${projectRoot}${path.sep}`)) {
    throw new Error(`Asset path escapes project root: ${relativePath}`)
  }
  return target
}

function digest(buffer) {
  return `sha256:${createHash('sha256').update(buffer).digest('hex')}`
}

async function verifyFile(filePath, metadata, relativePath) {
  const buffer = await readFile(filePath)
  const actualDigest = digest(buffer)
  if (metadata.sha256 && actualDigest !== metadata.sha256) {
    throw new Error(`SHA-256 mismatch for ${relativePath}: expected ${metadata.sha256}, got ${actualDigest}`)
  }
  if (metadata.size !== undefined && buffer.length !== metadata.size) {
    throw new Error(`Size mismatch for ${relativePath}: expected ${metadata.size}, got ${buffer.length}`)
  }
}

let restored = 0
for (const [relativePath, metadata] of entries) {
  const target = resolveAssetPath(relativePath)
  try {
    const info = await stat(target)
    if (!info.isFile()) throw new Error(`Locked asset is not a regular file: ${relativePath}`)
    await verifyFile(target, metadata, relativePath)
    continue
  } catch (error) {
    if (error.code !== 'ENOENT') throw error
  }

  const url = metadata.path
  if (typeof url !== 'string' || !/^https:\/\//i.test(url)) {
    throw new Error(`Missing locked asset has no HTTPS source: ${relativePath}`)
  }
  await mkdir(path.dirname(target), { recursive: true })
  const temporaryPath = `${target}.ci-download-${process.pid}`
  try {
    const response = await fetch(url, { signal: AbortSignal.timeout(60_000) })
    if (!response.ok) throw new Error(`HTTP ${response.status} while downloading ${relativePath}`)
    const buffer = Buffer.from(await response.arrayBuffer())
    await verifyFileBuffer(buffer, metadata, relativePath)
    await writeFile(temporaryPath, buffer, { flag: 'wx' })
    await rename(temporaryPath, target)
    restored += 1
    console.log(`Restored ${relativePath}`)
  } finally {
    await rm(temporaryPath, { force: true })
  }
}
console.log(`Asset lock verified: ${entries.length} files; restored ${restored} missing assets.`)

async function verifyFileBuffer(buffer, metadata, relativePath) {
  const actualDigest = digest(buffer)
  if (metadata.sha256 && actualDigest !== metadata.sha256) {
    throw new Error(`Downloaded SHA-256 mismatch for ${relativePath}: expected ${metadata.sha256}, got ${actualDigest}`)
  }
  if (metadata.size !== undefined && buffer.length !== metadata.size) {
    throw new Error(`Downloaded size mismatch for ${relativePath}: expected ${metadata.size}, got ${buffer.length}`)
  }
}
