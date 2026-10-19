"""Install pinned, checksum-verified official Godot and Android export packages."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import hashlib
import json
import os
import shutil
import urllib.request
import zipfile

RUNTIME = Path(os.environ.get('TIMBER_RUNTIME', '/workspace/.timber-runtime'))
DATA = Path(os.environ.get('XDG_DATA_HOME', RUNTIME / 'data'))
CACHE = RUNTIME / 'downloads'
SDK = RUNTIME / 'android-sdk'
PACKAGES = [
    ('Godot_v4.6.3-stable_export_templates.tpz',
     'https://github.com/godotengine/godot-builds/releases/download/4.6.3-stable/',
     'sha512', 'da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68',
     DATA / 'godot/export_templates/4.6.3.stable', 'templates'),
    ('build-tools_r36_linux.zip', 'https://dl.google.com/android/repository/',
     'sha1', 'b0b6376977657e8ad9b969bacf4093601da2c6fb', SDK / 'build-tools/36.0.0', 'android-16'),
    ('platform-36_r02.zip', 'https://dl.google.com/android/repository/',
     'sha1', '2c1a80dd4d9f7d0e6dd336ec603d9b5c55a6f576', SDK / 'platforms/android-36', 'android-36'),
    ('platform-tools_r37.0.1-linux.zip', 'https://dl.google.com/android/repository/',
     'sha1', '477254aa5f903c15cf51001717bdf347fb6b53e0', SDK / 'platform-tools', 'platform-tools'),
]

def install(item):
    name, base, algorithm, expected, target, prefix = item
    marker = target / '.timber-package.json'
    if marker.exists() and json.loads(marker.read_text()).get('digest') == expected:
        print('READY', target, flush=True)
        return
    CACHE.mkdir(parents=True, exist_ok=True)
    archive = CACHE / name
    digest = lambda p: hashlib.file_digest(p.open('rb'), algorithm).hexdigest()
    if not archive.exists() or digest(archive) != expected:
        temporary = archive.with_suffix('.partial')
        print('Downloading', name, flush=True)
        with urllib.request.urlopen(base + name, timeout=90) as response, temporary.open('wb') as out:
            shutil.copyfileobj(response, out, length=1024 * 1024)
        if digest(temporary) != expected:
            raise RuntimeError('Official package checksum mismatch: ' + name)
        temporary.replace(archive)
    target.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as source:
        for entry in source.infolist():
            relative = Path(entry.filename)
            if relative.parts[0] != prefix:
                continue
            relative = Path(*relative.parts[1:])
            if not relative.parts or entry.is_dir():
                continue
            if '..' in relative.parts or relative.is_absolute():
                raise RuntimeError('Unsafe archive entry')
            if name.endswith('.tpz') and str(relative) not in {'android_debug.apk', 'android_release.apk'}:
                continue
            destination = target / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            with source.open(entry) as src, destination.open('wb') as out:
                shutil.copyfileobj(src, out)
            mode = entry.external_attr >> 16
            destination.chmod((mode & 0o777) or 0o644)
    marker.write_text(json.dumps({'source':base+name, 'algorithm':algorithm, 'digest':expected})+'\n')
    print('Installed', target, flush=True)

if __name__ == '__main__':
    with ThreadPoolExecutor(max_workers=4) as pool:
        list(pool.map(install, PACKAGES))
