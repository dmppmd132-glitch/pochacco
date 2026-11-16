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

test('chapter three graybox declares data-driven gear routes and a five-second brake', () => {
  const source = read('scripts/chapter_three.gd');
  assert.match(source, /const GEAR_SPECS := \[/);
  assert.match(source, /\{"id": "廣場齒輪"/);
  assert.match(source, /\{"id": "工坊齒輪"/);
  assert.match(source, /\{"id": "工坊高位齒輪"/);
  assert.match(source, /\{"id": "鐘樓外環"/);
  assert.match(source, /const INTERACTION_SPECS := \[/);
  assert.match(source, /\{"id": "鐘樓黃銅鈴", "action": "reverse", "gear_id": "鐘樓外環"/);
  assert.match(source, /_gear_by_id\(String\(node\["gear_id"\]\)\)/);
  assert.match(source, /_reverse_linked_group\(gear\.linked_group_id\)/);
  assert.match(source, /var brake_remaining := 0\.0/);
  assert.match(source, /var motion_delta := Vector2\.ZERO/);
  assert.match(source, /sync_to_physics = true/);
  assert.match(source, /const STANDARD_BRAKE_SECONDS := 5\.0/);
  assert.match(source, /gear\.brake_for\(brake_duration\)/);
  assert.match(source, /func reverse_direction\(\)/);
  assert.doesNotMatch(source, /return reverse_near\(1090\.0\)/);
  assert.doesNotMatch(source, /return reverse_near\(2670\.0\)/);
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

test('chapter three workshop exposes a high-gear landing platform and recovery checkpoint', () => {
  const game = read('scripts/snackisle_game.gd');
  assert.match(game, /_add_platform\(2280, 350, 150, 24, "chiffon"\)/);
  assert.match(game, /checkpoint_x = 2240\.0/);
  assert.match(game, /雙齒輪高位落點已記下/);
});

test('chapter three previews automatic turns, teaches the longer first brake, and runs the real route smoke', () => {
  const chapter = read('scripts/chapter_three.gd');
  const audio = read('scripts/audio_catalog.gd');
  const game = read('scripts/snackisle_game.gd');
  assert.match(chapter, /const TURN_WARNING_SECONDS := 0\.5/);
  assert.match(chapter, /turn_warning_active/);
  assert.match(chapter, /gear_turn_warning/);
  assert.match(chapter, /const FIRST_BRAKE_TUTORIAL_SECONDS := 6\.5/);
  assert.match(chapter, /const STANDARD_BRAKE_SECONDS := 5\.0/);
  assert.match(chapter, /func has_active_brake\(\)/);
  assert.match(game, /chapter_three\.has_active_brake\(\)/);
  assert.match(game, /chapter_three\.last_brake_duration/);
  assert.match(audio, /&"gear_turn_warning": "res:\/\/assets\/template\/audio\/land\.ogg"/);
  const result = spawnSync('godot', ['--headless', '--audio-driver', 'Dummy', '--path', '.', '--script', 'test/chapter_three_route_smoke.gd'], {
    cwd: root,
    encoding: 'utf8',
    timeout: 60000,
  });
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  assert.match(result.stdout, /CHAPTER_THREE_ROUTE_SMOKE_PASS/);
});
