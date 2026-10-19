"""Create a source ZIP and complete Git bundle, each with a SHA256 manifest."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

root = Path(__file__).resolve().parents[1]
target = root.parent / 'timber-backups'
target.mkdir(exist_ok=True)
head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=root).decode().split('\0')
archive = target / f'Timber-Loot-Tycoon-{head[:10]}.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as out:
    for relative in files:
        if not relative:
            continue
        path = root / relative
        if path.name == '.export_credentials.cfg' or path.suffix in {'.keystore', '.jks'}:
            raise RuntimeError('Refusing to package a signing credential')
        out.write(path, Path('Timber-Loot-Tycoon') / relative)
bundle = target / f'Timber-Loot-Tycoon-{head[:10]}.bundle'
if not bundle.exists():
    subprocess.run(['git', 'bundle', 'create', str(bundle), '--all'], cwd=root, check=True)
subprocess.run(['git', 'bundle', 'verify', str(bundle)], cwd=root, check=True)
manifest = {'commit': head, 'files': {p.name: {'bytes':p.stat().st_size,
    'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in [archive,bundle]}}
archive.with_suffix('.manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
print(json.dumps(manifest, indent=2))
