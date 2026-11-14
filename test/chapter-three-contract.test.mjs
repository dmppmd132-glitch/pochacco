import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import test from 'node:test';

const root = new URL('../', import.meta.url);
const read = (file) => fs.readFileSync(new URL(file, root), 'utf8');

test('chapter three gear controller parses in Godot', () => {
  const result = spawnSync('godot', ['--headless', '--path', '.', '--check-only', '--script', 'scripts/chapter_three.gd'], {
    cwd: root,
    encoding: 'utf8',
    timeout: 45000,
  });
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
});

test('chapter three graybox declares three fixed gear routes and a five-second brake', () => {
  const source = read('scripts/chapter_three.gd');
  assert.match(source, /_add_gear\("廣場齒輪"/);
  assert.match(source, /_add_gear\("工坊齒輪"/);
  assert.match(source, /_add_gear\("鐘樓外環"/);
  assert.match(source, /gear\.brake_for\(5\.0\)/);
  assert.match(source, /func reverse_direction\(\)/);
});

test('chapter three is reachable from the title and main game flow', () => {
  const title = read('scripts/snackisle_title.gd');
  const game = read('scripts/snackisle_game.gd');
  assert.match(title, /StartChapterThree/);
  assert.match(title, /set_meta\("snackisle_chapter", 3\)/);
  assert.match(game, /第三章｜糖霜齒輪城/);
  assert.match(game, /chapter_index == 3/);
});

test('chapter three steam vents cycle and support sniff / pound interactions', () => {
  const result = spawnSync('godot', ['--headless', '--audio-driver', 'Dummy', '--path', '.', '--script', 'test/chapter_three_mechanics.gd'], {
    cwd: root,
    encoding: 'utf8',
    timeout: 45000,
  });
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  assert.match(result.stdout, /CHAPTER_THREE_MECHANICS_PASS/);
});

test('gear candy guardian alternates telegraphed attacks and needs three core stomps', () => {
  const result = spawnSync('godot', ['--headless', '--audio-driver', 'Dummy', '--path', '.', '--script', 'test/gear_guardian_mechanics.gd'], {
    cwd: root,
    encoding: 'utf8',
    timeout: 45000,
  });
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  assert.match(result.stdout, /GEAR_GUARDIAN_MECHANICS_PASS/);
});

test('gear guardian unblocks the real chapter-three core and touching it ends the run', () => {
  const result = spawnSync('godot', ['--headless', '--audio-driver', 'Dummy', '--path', '.', '--script', 'test/gear_guardian_integration.gd'], {
    cwd: root,
    encoding: 'utf8',
    timeout: 45000,
  });
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  assert.match(result.stdout, /GEAR_GUARDIAN_INTEGRATION_PASS/);
});

test('chapter three keeps the optional high-risk route and three-star bonus distinct', () => {
  const game = read('scripts/snackisle_game.gd');
  assert.match(game, /risk_entry\.set_meta\("route_id", "high_risk"\)/);
  assert.match(game, /safe_a = _add_platform/);
  assert.match(game, /route_merge\.set_meta\("route_id", "merge"\)/);
  assert.equal([...game.matchAll(/_add_star\(Vector2\(\d+, \d+\), "high_risk"\)/g)].length, 5);
  assert.equal([...game.matchAll(/_add_star\(Vector2\(\d+, \d+\), "safe"\)/g)].length, 2);
  assert.match(game, /checkpoint_x = 3940\.0/);
});
