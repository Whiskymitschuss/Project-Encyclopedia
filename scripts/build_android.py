"""Build a signed test APK and check Android packaging without a connected device."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = Path(os.environ.get('TIMBER_RUNTIME', '/workspace/.timber-runtime'))
SDK = RUNTIME / 'android-sdk'
TOOLS = SDK / 'build-tools/36.0.0'
# Public certificate fingerprint of the user-tested 0.23 line; not a private key.
EXPECTED_SIGNER = 'a49068da04643fb31c8d142035aaecaade43061142d7bd4571117890abbd41e9'
PRESET = (ROOT / 'export_presets.cfg').read_text()
VERSION_NAME = re.search(r'^version/name="([^"]+)"', PRESET, re.M).group(1)
VERSION_CODE = re.search(r'^version/code=(\d+)', PRESET, re.M).group(1)
PACKAGE = re.search(r'^package/unique_name="([^"]+)"', PRESET, re.M).group(1)
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, default=ROOT / f'exports/Timber-Loot-Tycoon-v{VERSION_NAME}.apk')
parser.add_argument('--verify-only', action='store_true')
args = parser.parse_args()
output = args.output.resolve()

def run(command, **kwargs):
    return subprocess.check_output([str(x) for x in command], text=True, stderr=subprocess.STDOUT, **kwargs)

source_commit = None
if not args.verify_only:
    source_commit = run(['git','rev-parse','HEAD'],cwd=ROOT).strip()
elif output.with_suffix('.apk.json').exists():
    source_commit = json.loads(output.with_suffix('.apk.json').read_text()).get('source_commit')

if not args.verify_only:
    key = RUNTIME / 'android/TimberLoot-Reborn-debug.keystore'
    if not key.exists():
        raise SystemExit('New-line signing key is missing: restore TimberLoot-Reborn-debug.keystore securely outside Git. Never regenerate a key for an already distributed package.')
    subprocess.run([sys.executable, ROOT / 'scripts/setup_android.py'], check=True)
    java = Path(os.environ.get('JAVA_HOME', Path(shutil.which('java')).resolve().parents[1]))
    env = os.environ.copy()
    env.update(JAVA_HOME=str(java), ANDROID_HOME=str(SDK),
        XDG_DATA_HOME=os.environ.get('XDG_DATA_HOME',str(RUNTIME/'data')),
        XDG_CONFIG_HOME=os.environ.get('XDG_CONFIG_HOME',str(RUNTIME/'config')),
        XDG_CACHE_HOME=os.environ.get('XDG_CACHE_HOME',str(RUNTIME/'cache')))
    settings = Path(env['XDG_CONFIG_HOME']) / 'godot/editor_settings-4.6.tres'
    settings.parent.mkdir(parents=True, exist_ok=True)
    previous = settings.read_text() if settings.exists() else '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
    values = {'export/android/java_sdk_path': str(java), 'export/android/android_sdk_path': str(SDK),
              'export/android/debug_keystore': str(key), 'export/android/debug_keystore_user':'timberreborn',
              'export/android/debug_keystore_pass':'android'}
    lines = [line for line in previous.splitlines() if line.split(' = ',1)[0] not in values]
    lines.extend(k+' = '+json.dumps(v) for k,v in values.items())
    settings.write_text('\n'.join(lines)+'\n')
    output.parent.mkdir(parents=True, exist_ok=True)
    for label, commands in [('import',['--headless','--editor','--import','--quit']),
                            ('export',['--headless','--export-debug','Android Test',output])]:
        log = run(['bash',ROOT/'scripts/godot.sh',*commands], cwd=ROOT, env=env)
        (RUNTIME/('android-'+label+'.log')).write_text(log)
        if re.search(r'^(SCRIPT ERROR|ERROR):',log,re.M): raise RuntimeError(log[-5000:])
        print(label,'completed',flush=True)

signature = run([TOOLS/'apksigner','verify','--verbose','--print-certs',output])
assert 'Verified using v2 scheme (APK Signature Scheme v2): true' in signature
actual_signer = re.search(r'Signer #1 certificate SHA-256 digest: ([0-9a-f]+)',signature).group(1)
if actual_signer != EXPECTED_SIGNER:
    raise RuntimeError('Signing certificate differs from the installed 0.23 line; refusing an incompatible update.')
run([TOOLS/'zipalign','-c','-P','16','4',output])
manifest = run([TOOLS/'aapt','dump','badging',output])
permissions = run([TOOLS/'aapt','dump','permissions',output])
xml = run([TOOLS/'aapt','dump','xmltree',output,'AndroidManifest.xml'])
for required in [f"package: name='{PACKAGE}'", f"versionName='{VERSION_NAME}'", f"versionCode='{VERSION_CODE}'", "sdkVersion:'24'", "native-code: 'arm64-v8a' 'armeabi-v7a'", 'application-isGame']:
    assert required in manifest, required
permission_names = re.findall(r"uses-permission: name='([^']+)'",permissions)
assert permission_names == ['android.permission.VIBRATE'], permission_names
assert 'gl_compatibility' in xml and 'android.hardware.vulkan' not in xml
assert re.search(r'screenOrientation[^\n]*0x1\b',xml)
with zipfile.ZipFile(output) as apk:
    assert apk.testzip() is None
    names = apk.namelist()
    assert 'assets/project.binary' in names
    assert b'res://Scenes/Boot.tscn' in apk.read('assets/project.binary')
    assert 'assets/Economy/stone_industry.json' in names
    data=json.loads(apk.read('assets/Economy/stone_industry.json'))
    assert data['recipes']['blocks']['in']['rock']==3 and data['recipes']['blocks']['out']['stone']==5
    assert any('Scenes/Main.tscn' in x for x in names)
    assert any('Scenes/Boot.tscn' in x for x in names)
    assert any('Brand/timber-icon' in x for x in names)
    assert any('UI/Startup.gd' in x for x in names)
    assert any('Brand/timber-loading' in x for x in names)
    assert any('UI/LoadingArtwork.gd' in x for x in names)
    assert b'SIL OPEN FONT LICENSE' in apk.read('assets/Assets/Fonts/Anton-OFL.txt')
    assert any('Economy/FireSafety.gd' in x for x in names)
    assert not any(x.startswith(('assets/Tests/','assets/scripts/','assets/releases/','assets/exports/')) for x in names)
report = {'file':output.name,'bytes':output.stat().st_size,
    'sha256':hashlib.sha256(output.read_bytes()).hexdigest(),
    'version':VERSION_NAME,'package':PACKAGE,
    'android_min_api':24,'architectures':['arm64-v8a','armeabi-v7a'],
    'signer_sha256':re.search(r'Signer #1 certificate SHA-256 digest: ([0-9a-f]+)',signature).group(1),
    'debug_signed':True,'zipalign_16k':True,'permissions':['android.permission.VIBRATE'],
    'source_commit':source_commit,
    'device_install_or_launch_tested':False}
output.with_suffix('.apk.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
