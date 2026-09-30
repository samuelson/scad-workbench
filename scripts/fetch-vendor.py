#!/usr/bin/env python3
"""Download pinned OpenSCAD WASM and Three.js files into vendor/."""

from __future__ import annotations

import hashlib
import io
import tarfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VENDOR = ROOT / "vendor"
STAMP = VENDOR / ".stamp"
USER_AGENT = "scad-workbench-vendor-fetch/1.0"

OPENSCAD_WASM = "0.0.2"
THREE = "0.186.0"

OPENSCAD_TGZ = f"https://registry.npmjs.org/@lofcz/openscad-wasm/-/openscad-wasm-{OPENSCAD_WASM}.tgz"
THREE_TGZ = f"https://registry.npmjs.org/three/-/three-{THREE}.tgz"

OPENSCAD_FILES = {
    "package/COPYING": "openscad-wasm/COPYING",
    "package/openscad.js": "openscad-wasm/openscad.js",
    "package/openscad.wasm.js": "openscad-wasm/openscad.wasm.js",
    "package/openscad.wasm": "openscad-wasm/openscad.wasm",
}
THREE_FILES = {
    "package/LICENSE": "three/LICENSE",
    "package/build/three.module.js": "three/three.module.js",
    "package/build/three.core.js": "three/three.core.js",
    "package/examples/jsm/controls/OrbitControls.js": "three/addons/controls/OrbitControls.js",
    "package/examples/jsm/loaders/STLLoader.js": "three/addons/loaders/STLLoader.js",
}

WASM_SHA256 = "729c5436bb938ec0ecb5f0a6cb8871b3580476f608daaa15d94803d8990a2b85"


def fetch(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request) as response:
        return response.read()


def write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    print(f"  {path.relative_to(ROOT)} ({len(data)} bytes)")


def present(mapping: dict[str, str]) -> bool:
    return all((VENDOR / dest).is_file() and (VENDOR / dest).stat().st_size > 0 for dest in mapping.values())


def extract_tarball(url: str, mapping: dict[str, str], label: str) -> None:
    print(f"fetching {label}")
    archive = fetch(url)
    with tarfile.open(fileobj=io.BytesIO(archive), mode="r:gz") as tarball:
        for member, dest in mapping.items():
            file = tarball.extractfile(member)
            if file is None:
                raise SystemExit(f"missing {member} in {label} tarball")
            write(VENDOR / dest, file.read())


def verify_wasm() -> None:
    digest = hashlib.sha256((VENDOR / "openscad-wasm/openscad.wasm").read_bytes()).hexdigest()
    if digest != WASM_SHA256:
        raise SystemExit(f"openscad.wasm checksum mismatch: {digest}")


def write_stamp() -> None:
    STAMP.write_text(f"openscad-wasm {OPENSCAD_WASM}\nthree {THREE}\n", encoding="utf-8")


def main() -> None:
    VENDOR.mkdir(parents=True, exist_ok=True)
    if not present(OPENSCAD_FILES):
        extract_tarball(OPENSCAD_TGZ, OPENSCAD_FILES, f"@lofcz/openscad-wasm@{OPENSCAD_WASM}")
    if not present(THREE_FILES):
        extract_tarball(THREE_TGZ, THREE_FILES, f"three@{THREE}")
    if not present(OPENSCAD_FILES) or not present(THREE_FILES):
        raise SystemExit("vendor fetch finished but required files are missing")
    verify_wasm()
    write_stamp()
    print("vendor assets ready")


if __name__ == "__main__":
    main()
