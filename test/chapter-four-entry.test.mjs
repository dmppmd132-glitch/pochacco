import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const titleSource = readFileSync(new URL('../scripts/snackisle_title.gd', import.meta.url), 'utf8');
const gameSource = readFileSync(new URL('../scripts/snackisle_game.gd', import.meta.url), 'utf8');

test('chapter four has a Traditional Chinese playable title-screen entry', () => {
  assert.match(titleSource, /chapter_four_button\.name\s*=\s*"StartChapterFour"/);
  assert.match(titleSource, /遊玩第四章｜月潮玻璃海/);
  assert.match(titleSource, /chapter_four_button\.size_flags_horizontal\s*=\s*Control\.SIZE_EXPAND_FILL/);
  assert.match(titleSource, /chapter_four_button\.text\s*=\s*_l10n\("第四章"\) if compact else _l10n\("遊玩第四章｜月潮玻璃海"\)/);
  assert.match(titleSource, /chapter_four_width\s*:=\s*title_panel\.custom_minimum_size\.x/);
  assert.match(titleSource, /func _start_chapter_four\(\)[\s\S]*?set_meta\("snackisle_chapter", 4\)/);
  assert.match(titleSource, /func _start_chapter_four\(\)[\s\S]*?change_scene_to_file\("res:\/\/scenes\/game\.tscn"\)/);
  assert.match(gameSource, /get_meta\("snackisle_chapter", 1\)\), 1, 4\)/);
  assert.match(gameSource, /func play_chapter_four_tone\(tone_index: int\)[\s\S]*?\[&"jump", &"coin", &"stomp"\]/);
  assert.match(readFileSync(new URL('../scripts/chapter_four.gd', import.meta.url), 'utf8'), /_play_echo_tone\(ECHO_SEQUENCE\[echo_listen_cursor\]\)/);
});
