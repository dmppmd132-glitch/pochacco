import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { runGodotCheck, runGodotImport } from './godot-check.mjs'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const godot = process.env.GODOT_BIN || 'godot'
runGodotImport(godot, root)
runGodotCheck(
  godot,
  ['--headless', '--path', root, '--script', 'test/audio_idle_regression.gd'],
  '[AUDIO_IDLE_PASS]',
  root,
)
