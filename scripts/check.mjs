// A finite smoke check; long-running Preview belongs to npm run dev.
import { dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { runGodotCheck, runGodotImport } from './godot-check.mjs'

const root = dirname(dirname(fileURLToPath(import.meta.url)))
const godot = process.env.GODOT_BIN || 'godot'
runGodotImport(godot, root)
runGodotCheck(godot,
  ['--headless', '--audio-driver', 'Dummy', '--path', root, '--scene', 'test/smoke_runner.tscn'],
  '[SNACKISLE_SMOKE_PASS]', root)
