import { mkdir, readFile, writeFile } from 'node:fs/promises'
import path from 'node:path'
import { spawnSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const projectSettingsPath = path.join(projectRoot, 'project.godot')
const exportPath = path.join(projectRoot, 'dist', 'standalone', 'index.html')
const godot = process.env.GODOT_BIN || 'godot'
const originalSettings = await readFile(projectSettingsPath, 'utf8')
const releaseSettings = originalSettings.replace(/^TuningBridge=.*(?:\r?\n|$)/m, '')

if (releaseSettings === originalSettings) {
  throw new Error('Expected Manus preview TuningBridge autoload was not found; refusing an unverified release export.')
}

await mkdir(path.dirname(exportPath), { recursive: true })
await writeFile(projectSettingsPath, releaseSettings)
try {
  const result = spawnSync(godot, [
    '--headless',
    '--path', projectRoot,
    '--export-release',
    'Web Release',
    exportPath,
  ], { cwd: projectRoot, stdio: 'inherit', env: process.env })
  if (result.error) throw result.error
  if (result.status !== 0) throw new Error(`Godot release export exited with status ${result.status}`)
} finally {
  await writeFile(projectSettingsPath, originalSettings)
}
