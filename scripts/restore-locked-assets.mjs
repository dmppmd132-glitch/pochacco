import { createHash } from 'node:crypto'
import { mkdir, readFile, rename, rm, writeFile } from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const projectRoot = fileURLToPath(new URL('../', import.meta.url))
const allowedHosts = new Set(['d1oupeiobkpcny.cloudfront.net'])
const mediaTypes = new Set(['audio', 'font'])

function matchesLock(bytes, asset) {
  const actualHash = `sha256:${createHash('sha256').update(bytes).digest('hex')}`
  return bytes.length === asset.size && actualHash === asset.sha256
}

function getRestoreRecords(lock) {
  if (!lock || typeof lock.assets !== 'object' || lock.assets === null || Array.isArray(lock.assets)) {
    throw new Error('assets.lock.json has no valid assets map')
  }
  return Object.entries(lock.assets).filter(([, asset]) =>
    asset?.used === true && mediaTypes.has(asset.assetType) && typeof asset.path === 'string' && /^https:\/\//i.test(asset.path),
  )
}

function resolveAssetPath(root, relativePath) {
  if (typeof relativePath !== 'string' || relativePath.includes('\\') || path.posix.isAbsolute(relativePath)) {
    throw new Error(`Unsafe asset destination: ${relativePath}`)
  }
  const normalized = path.posix.normalize(relativePath)
  if (normalized === '..' || normalized.startsWith('../') || normalized !== relativePath) {
    throw new Error(`Unsafe asset destination: ${relativePath}`)
  }
  const absolute = path.resolve(root, ...normalized.split('/'))
  const relative = path.relative(root, absolute)
  if (!relative || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) {
    throw new Error(`Asset destination escapes project root: ${relativePath}`)
  }
  return absolute
}

function validateRecord(relativePath, asset) {
  const url = new URL(asset.path)
  if (url.protocol !== 'https:' || !allowedHosts.has(url.hostname)) {
    throw new Error(`Refusing untrusted asset URL for ${relativePath}: ${url.origin}`)
  }
  if (!Number.isSafeInteger(asset.size) || asset.size < 0 || !/^sha256:[a-f0-9]{64}$/i.test(asset.sha256 ?? '')) {
    throw new Error(`Invalid size or SHA-256 lock for ${relativePath}`)
  }
  return url
}

export async function restoreLockedAssets({
  root = projectRoot,
  fetchImpl = globalThis.fetch,
  checkOnly = false,
  force = false,
  log = () => {},
} = {}) {
  const absoluteRoot = path.resolve(root)
  const lock = JSON.parse(await readFile(path.join(absoluteRoot, 'assets.lock.json'), 'utf8'))
  const records = getRestoreRecords(lock)
  const missing = []
  let downloaded = 0
  let skipped = 0

  for (const [relativePath, asset] of records) {
    const destination = resolveAssetPath(absoluteRoot, relativePath)
    const url = validateRecord(relativePath, asset)
    let current
    try {
      current = await readFile(destination)
    } catch (error) {
      if (error.code !== 'ENOENT') throw error
    }

    if (current && matchesLock(current, asset)) {
      skipped += 1
      log(`verified ${relativePath}`)
      continue
    }
    if (current && !force) {
      throw new Error(`Existing asset does not match lock; refusing to overwrite ${relativePath} (use --force after review)`)
    }
    if (checkOnly) {
      missing.push(relativePath)
      continue
    }
    if (typeof fetchImpl !== 'function') throw new Error('This Node.js runtime does not provide fetch')

    const response = await fetchImpl(url)
    if (!response.ok) throw new Error(`Download failed for ${relativePath}: HTTP ${response.status}`)
    const bytes = Buffer.from(await response.arrayBuffer())
    if (!matchesLock(bytes, asset)) {
      throw new Error(`Downloaded bytes failed size/SHA-256 verification for ${relativePath}`)
    }

    await mkdir(path.dirname(destination), { recursive: true })
    const temporary = `${destination}.${process.pid}.tmp`
    try {
      await writeFile(temporary, bytes, { flag: 'wx' })
      await rename(temporary, destination)
    } finally {
      await rm(temporary, { force: true })
    }
    downloaded += 1
    log(`restored ${relativePath}`)
  }

  if (missing.length) {
    throw new Error(`Missing locked media: ${missing.join(', ')}. Run npm run assets:restore.`)
  }
  return { downloaded, skipped, checked: records.length }
}

async function main() {
  const args = new Set(process.argv.slice(2))
  for (const arg of args) {
    if (arg !== '--check' && arg !== '--force') throw new Error(`Unknown option: ${arg}`)
  }
  if (args.has('--check') && args.has('--force')) throw new Error('--check and --force cannot be combined')
  const result = await restoreLockedAssets({ checkOnly: args.has('--check'), force: args.has('--force'), log: console.log })
  if (args.has('--check')) console.log(`All ${result.checked} locked font/audio assets are present and verified.`)
  else console.log(`Asset restore complete: ${result.downloaded} downloaded; ${result.skipped} already verified.`)
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main().catch((error) => {
    console.error(error.message)
    process.exitCode = 1
  })
}
