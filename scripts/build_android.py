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
parser.add_argument('--renderer', choices=['mobile','gl_compatibility'], help='Android renderer for this export; project.godot is restored afterward')
parser.add_argument('--abi', choices=['universal','arm64-v8a','armeabi-v7a'], help='Build an ABI-specific APK; universal keeps the configured architectures')
args = parser.parse_args()
output = args.output.resolve()
project_renderer = re.search(r'^renderer/rendering_method.mobile="([^"]+)"', (ROOT/'project.godot').read_text(), re.M).group(1)
expected_renderer = args.renderer or project_renderer
expected_architectures = [name for name in ['arm64-v8a','armeabi-v7a'] if f'architectures/{name}=true' in PRESET] if args.abi in [None,'universal'] else [args.abi]
if args.verify_only and not args.renderer and output.with_suffix('.apk.json').exists():
    prior_report=json.loads(output.with_suffix('.apk.json').read_text())
    expected_renderer = prior_report.get('android_renderer',project_renderer)
    if args.abi is None:expected_architectures=prior_report.get('architectures',expected_architectures)

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
    subprocess.run([sys.executable, ROOT / 'scripts/bake_runtime.py','--verify-only'],check=True)
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
    project_file = ROOT/'project.godot'
    original_project = project_file.read_bytes()
    export_project = original_project
    if args.renderer:
        export_project = re.sub(rb'^renderer/rendering_method.mobile="[^"\n]+"',
            ('renderer/rendering_method.mobile='+json.dumps(args.renderer)).encode(),original_project,flags=re.M)
        if export_project==original_project and expected_renderer!=project_renderer:
            raise RuntimeError('Android renderer setting was not found for the explicit export override.')
    preset_file=ROOT/'export_presets.cfg'
    original_preset=preset_file.read_bytes()
    export_preset=original_preset
    if args.abi not in [None,'universal']:
        for name in ['arm64-v8a','armeabi-v7a']:
            export_preset=re.sub(('^architectures/'+name+'=(true|false)').encode(),('architectures/'+name+'='+('true' if name==args.abi else 'false')).encode(),export_preset,flags=re.M)
    try:
        if export_preset!=original_preset:preset_file.write_bytes(export_preset)
        if export_project!=original_project: project_file.write_bytes(export_project)
        for label, commands in [('import',['--headless','--editor','--import','--quit']),
                                ('export',['--headless','--export-debug','Android Test',output])]:
            log = run(['bash',ROOT/'scripts/godot.sh',*commands], cwd=ROOT, env=env)
            (RUNTIME/('android-'+label+'.log')).write_text(log)
            if re.search(r'^(SCRIPT ERROR|ERROR):',log,re.M): raise RuntimeError(log[-5000:])
            print(label,'completed',flush=True)
    finally:
        changed=[]
        for path,original,exported in [(project_file,original_project,export_project),(preset_file,original_preset,export_preset)]:
            if exported==original:continue
            if path.read_bytes()!=exported:
                changed.append(path.name);continue
            path.write_bytes(original)
        if changed:raise RuntimeError('External changes during export preserved for review: '+', '.join(changed))

signature = run([TOOLS/'apksigner','verify','--verbose','--print-certs',output])
assert 'Verified using v2 scheme (APK Signature Scheme v2): true' in signature
actual_signer = re.search(r'Signer #1 certificate SHA-256 digest: ([0-9a-f]+)',signature).group(1)
if actual_signer != EXPECTED_SIGNER:
    raise RuntimeError('Signing certificate differs from the installed 0.23 line; refusing an incompatible update.')
run([TOOLS/'zipalign','-c','-P','16','4',output])
# aapt2 understands Godot 4.6's generated Vulkan feature attributes.
manifest = run([TOOLS/'aapt2','dump','badging',output])
permissions = run([TOOLS/'aapt','dump','permissions',output])
xml = run([TOOLS/'aapt','dump','xmltree',output,'AndroidManifest.xml'])
for required in [f"package: name='{PACKAGE}'", f"versionName='{VERSION_NAME}'", f"versionCode='{VERSION_CODE}'", "minSdkVersion:'24'", "native-code: "+" ".join(repr(name) for name in expected_architectures)]:
    assert required in manifest, required
permission_names = re.findall(r"uses-permission: name='([^']+)'",permissions)
assert permission_names == ['android.permission.VIBRATE'], permission_names
if expected_renderer=='mobile':
    assert 'mobile' in xml and 'android.hardware.vulkan.version' in xml
else:
    assert 'gl_compatibility' in xml and 'android.hardware.vulkan' not in xml
assert re.search(r'android:isGame[^\n]*0x1\b',xml)
assert re.search(r'screenOrientation[^\n]*0x1\b',xml)
with zipfile.ZipFile(output) as apk:
    assert apk.testzip() is None
    names = apk.namelist()
    assert 'assets/project.binary' in names
    assert 'assets/override.cfg' not in names
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
    'android_min_api':24,'architectures':expected_architectures,
    'signer_sha256':re.search(r'Signer #1 certificate SHA-256 digest: ([0-9a-f]+)',signature).group(1),
    'android_renderer':expected_renderer,'android_vulkan_hardware_required':expected_renderer=='mobile','debug_signed':True,'zipalign_16k':True,'permissions':['android.permission.VIBRATE'],
    'source_commit':source_commit,
    'device_install_or_launch_tested':False}
output.with_suffix('.apk.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
