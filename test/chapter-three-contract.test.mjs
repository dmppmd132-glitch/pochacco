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
