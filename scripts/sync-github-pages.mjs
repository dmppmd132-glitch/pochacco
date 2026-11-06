import { cp, lstat, mkdir, readdir, readFile, rm, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const sourceDir = path.join(projectRoot, 'dist', 'standalone');
const destinationDir = path.join(projectRoot, 'github-pages');
const requiredFiles = [
  'index.html',
  'index.js',
  'index.wasm',
  'index.pck',
  'index.manifest.json',
  'index.service.worker.js',
  'index.offline.html',
  'index.apple-touch-icon.png',
  'index.512x512.png',
];
const generatedMetadata = new Set(['.build-files.json', '.build-fingerprint']);

for (const filename of requiredFiles) {
  const filePath = path.join(sourceDir, filename);
  try {
    const info = await stat(filePath);
    if (!info.isFile() || info.size === 0) throw new Error('empty or not a file');
  } catch {
    console.error(`缺少 portable PWA 檔案：${filePath}\n請先執行 npm run build。`);
    process.exit(1);
  }
}

const html = await readFile(path.join(sourceDir, 'index.html'), 'utf8');
if (html.includes('/manus-storage/')) {
  console.error('拒絕同步：portable HTML 仍包含 Manus Storage 路徑。');
  process.exit(1);
}

try {
  const destinationInfo = await lstat(destinationDir);
  if (destinationInfo.isSymbolicLink() || !destinationInfo.isDirectory()) {
    throw new Error(`拒絕覆寫非預期目錄：${destinationDir}`);
  }
  const existing = await readdir(destinationDir);
  if (existing.length > 0) {
    const hasPwaSignature = await Promise.all(['index.html', 'index.pck', 'index.wasm'].map(async (name) => {
      try {
        return (await stat(path.join(destinationDir, name))).isFile();
      } catch {
        return false;
      }
    }));
    if (!hasPwaSignature.every(Boolean)) {
      throw new Error(`拒絕覆寫非預期目錄：${destinationDir}`);
    }
  }
} catch (error) {
  if (error.code !== 'ENOENT') throw error;
}

await rm(destinationDir, { recursive: true, force: true });
await mkdir(destinationDir, { recursive: true });
for (const filename of await readdir(sourceDir)) {
  if (generatedMetadata.has(filename)) continue;
  await cp(path.join(sourceDir, filename), path.join(destinationDir, filename), {
    recursive: true,
    force: true,
    preserveTimestamps: true,
  });
}

const wasmSize = (await stat(path.join(destinationDir, 'index.wasm'))).size;
const pckSize = (await stat(path.join(destinationDir, 'index.pck'))).size;
console.log(`GitHub Pages PWA 已更新：${destinationDir}`);
console.log(`WASM：${wasmSize} bytes；PCK：${pckSize} bytes`);
