"""Read-only source audit. This is not a Google Play compliance certificate.

Default exit 0 means the report was generated; --strict exits 2 while any gate
remains unresolved. Never reads signing credentials or player's app data.
"""
import argparse
import configparser
import json
from pathlib import Path


def config(path):
    parser = configparser.ConfigParser(interpolation=None, strict=True)
    # Godot permits top-level keys before its first INI-style section.
    parser.read_string("[_header]\n" + path.read_text())
    return parser


def value(section, key, default=""):
    return section.get(key, default).strip('"')


def audit(root):
    project = config(root / "project.godot")
    presets = config(root / "export_presets.cfg")
    version = value(project["application"], "config/version")
    checks = []

    def add(key, status, detail):
        checks.append(dict(id=key, status=status, detail=detail))

    android = []
    for name in presets.sections():
        if name.endswith(".options") or value(presets[name], "platform") != "Android":
            continue
        android.append((presets[name], presets[name + ".options"]))
    add("android_preset", "pass" if android else "blocked", f"{len(android)} Android preset(s)")
    for index, (preset, options) in enumerate(android):
        prefix = f"android_{index}_"
        label = value(preset, "name")
        add(prefix + "version", "pass" if value(options, "version/name") == version else "blocked",
            f"{label}: app {version}, export {value(options, 'version/name')}")
        add(prefix + "arm64", "pass" if value(options, "architectures/arm64-v8a") == "true" else "blocked",
            f"{label}: ARM64 export flag (not an artifact ABI verification)")
        excluded = value(preset, "exclude_filter").split(",")
        add(prefix + "export_scope", "pass" if all(p in excluded for p in ("Tests/*", "releases/*", "exports/*")) else "blocked",
            f"{label}: tests and previous builds excluded")
        enabled = sorted(k.removeprefix("permissions/") for k, v in options.items()
                         if k.startswith("permissions/") and v == "true")
        add(prefix + "offline_permissions", "pass" if set(enabled) <= {"vibrate"} else "blocked",
            f"{label}: explicitly enabled permissions: {', '.join(enabled) or 'none'}; final merged manifest still needs review")
    bundles = [o for _, o in android if value(o, "gradle_build/use_gradle_build") == "true"
               and value(o, "gradle_build/export_format") == "1"]
    add("aab_configuration", "pass" if bundles else "blocked",
        "AAB/Gradle preset configured" if bundles else "Only test APK export configured; no production AAB preset")
    # These cannot be inferred from export flags, software rendering, or seeded
    # economy fixtures. Keep them explicit even if all source checks are green.
    for key, detail in [
        ("release_artifact", "Build and verify a release AAB: package, versionCode, non-debuggable manifest, intended upload certificate; never reuse the debug key as a production decision"),
        ("android_compatibility", "Inspect actual native ELF LOAD alignment and APK split ZIP alignment; test a 16-KiB Android environment and supported ABIs/SDKs. zipalign alone is insufficient"),
        ("device_performance", "Same candidate on physical Android hardware: sustained play, camera, long stalls, loading, background/resume. Software-GPU results do not establish 30 FPS"),
        ("fresh_progression", "Human balance acceptance remains open; Tests/JourneyPlaythrough.gd now simulates fresh saves through Rathaus 10 using earned resources. See docs/journey-1-10; this is not device or human QA"),
        ("save_upgrade", "Install over the current signed test app without uninstalling; verify inventory, deliveries and one-time offline rewards. Plan production migration if signing/package changes"),
        ("public_privacy", "Publish policy with real operator/contact and reviewed Data Safety answers; in-game local-data help is not the public policy"),
        ("content_rights", "Document redistribution/commercial rights for graphics, fonts and supplied music; receipt of a file is not a licence"),
        ("play_console", "Verify current target API, account-specific testing/access requirements, app content, age rating, listing and Play App Signing in Play Console before submission"),
    ]:
        add(key, "manual", detail)
    return {"schema": 1, "version": version, "store_ready": all(c["status"] == "pass" for c in checks),
            "scope": "Source configuration only; no device, AAB or current Google policy verification", "checks": checks}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    report = audit(args.root)
    text = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(text)
    else:
        print(text, end="")
    return 2 if args.strict and not report["store_ready"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
