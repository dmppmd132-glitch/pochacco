import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const shell = readFileSync(new URL('../web/loading.html', import.meta.url), 'utf8')
const runtime = readFileSync(new URL('../autoload/i18n.gd', import.meta.url), 'utf8')

test('PWA loader is fixed to Traditional Chinese', () => {
  assert.match(shell, /document\.documentElement\.lang\s*=\s*'zh-TW'/)
  assert.match(shell, /const zh = true/)
  assert.doesNotMatch(shell, /navigator\.languages|navigator\.language/)
})

test('Godot locale service only accepts and returns zh-TW', () => {
  assert.match(runtime, /const SUPPORTED_LOCALES := \["zh-TW"\]/)
  assert.match(runtime, /static func locale_for_system\(system_locale: String\) -> String:[\s\S]*?return "zh-TW"/)
  assert.match(runtime, /res:\/\/localization\/%s\.json/)
  assert.doesNotMatch(runtime, /SUPPORTED_LOCALES := \["en", "zh-CN"\]/)
})
