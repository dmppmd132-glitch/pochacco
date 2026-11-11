import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises'
import os from 'node:os'
import path from 'node:path'
import test from 'node:test'
import { restoreLockedAssets } from '../scripts/restore-locked-assets.mjs'

const cdn = 'https://d1oupeiobkpcny.cloudfront.net/locked/'

function record(bytes, assetType = 'audio', overrides = {}) {
  return {
    path: `${cdn}${assetType}`,
    sha256: `sha256:${createHash('sha256').update(bytes).digest('hex')}`,
    size: bytes.length,
    assetType,
    used: true,
    ...overrides,
  }
}

async function makeFixture(t, assets) {
  const root = await mkdtemp(path.join(os.tmpdir(), 'pochacco-assets-test-'))
  t.after(() => rm(root, { recursive: true, force: true }))
  await writeFile(path.join(root, 'assets.lock.json'), JSON.stringify({ version: 2, assets }))
  return root
}

function response(bytes, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    arrayBuffer: async () => bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength),
  }
}

test('restores only used locked audio/fonts, verifies bytes, and skips valid local assets', async (t) => {
  const audio = Buffer.from('test ogg bytes')
  const font = Buffer.from('test font bytes')
  const root = await makeFixture(t, {
    'assets/template/audio/jump.ogg': record(audio),
    'assets/template/fonts/ui.woff2': record(font, 'font'),
    'assets/template/cat/unused.webp': record(Buffer.from('unused'), 'image'),
  })
  const calls = []
  const fetchImpl = async (url) => {
    calls.push(String(url))
    return response(String(url).endsWith('/audio') ? audio : font)
  }

  const first = await restoreLockedAssets({ root, fetchImpl, log: () => {} })
  assert.deepEqual(first, { downloaded: 2, skipped: 0, checked: 2 })
  assert.equal(calls.length, 2)
  assert.deepEqual(await readFile(path.join(root, 'assets/template/audio/jump.ogg')), audio)

  const second = await restoreLockedAssets({ root, checkOnly: true, fetchImpl: () => { throw new Error('must not download') } })
  assert.deepEqual(second, { downloaded: 0, skipped: 2, checked: 2 })
})

test('rejects bad downloaded bytes without writing them', async (t) => {
  const expected = Buffer.from('expected audio')
  const root = await makeFixture(t, { 'assets/template/audio/bgm.ogg': record(expected) })
  await assert.rejects(
    restoreLockedAssets({ root, fetchImpl: async () => response(Buffer.from('wrong bytes')), log: () => {} }),
    /failed size\/SHA-256 verification/,
  )
  await assert.rejects(readFile(path.join(root, 'assets/template/audio/bgm.ogg')), { code: 'ENOENT' })
})

test('refuses non-allowlisted download hosts and path traversal', async (t) => {
  const bytes = Buffer.from('audio')
  const untrustedRoot = await makeFixture(t, {
    'assets/template/audio/effect.ogg': record(bytes, 'audio', { path: 'https://example.com/effect.ogg' }),
  })
  await assert.rejects(restoreLockedAssets({ root: untrustedRoot, fetchImpl: async () => response(bytes) }), /untrusted asset URL/)

  const traversalRoot = await makeFixture(t, { '../outside.ogg': record(bytes) })
  await assert.rejects(restoreLockedAssets({ root: traversalRoot, fetchImpl: async () => response(bytes) }), /Unsafe asset destination/)
})

test('check-only reports absent locked media without network access', async (t) => {
  const root = await makeFixture(t, { 'assets/template/fonts/ui.woff2': record(Buffer.from('font'), 'font') })
  await assert.rejects(
    restoreLockedAssets({ root, checkOnly: true, fetchImpl: async () => { throw new Error('must not download') } }),
    /Missing locked media.*npm run assets:restore/,
  )
})
