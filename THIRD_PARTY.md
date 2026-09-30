# Third-party components

SCAD Workbench is GPL-2.0-only. Some files come from other projects and keep
their original licenses. Runtime copies of OpenSCAD WASM and Three.js are
downloaded into `vendor/` by `make vendor` and are not stored in git.

## OpenSCAD (WebAssembly)

- Package: [`@lofcz/openscad-wasm`](https://github.com/lofcz/openscad-wasm) 0.0.2
- License: GPL-2.0-only
- Upstream CAD system: [OpenSCAD](https://github.com/openscad/openscad)
- Corresponding source: the npm package above and the OpenSCAD git repository
  it was built from
- Fetched files: `vendor/openscad-wasm/openscad.js`, `openscad.wasm.js`,
  `openscad.wasm`, and `COPYING`

## Three.js

- Package: [`three`](https://github.com/mrdoob/three.js) r186 (`three@0.186.0`)
- License: MIT
- License text: [`third_party/three-LICENSE.txt`](third_party/three-LICENSE.txt)
- Fetched files: `vendor/three/three.module.js`, `three.core.js`,
  `addons/controls/OrbitControls.js`, and `addons/loaders/STLLoader.js`

## Liberation fonts

- Files: `fonts/LiberationSans-*.ttf`, `LiberationSerif-Regular.ttf`,
  `LiberationMono-Regular.ttf`
- License: SIL Open Font License 1.1
- License text: [`fonts/LICENSE-Liberation.txt`](fonts/LICENSE-Liberation.txt)
- Copyright: Red Hat, Inc. (Reserved Font Name Liberation); digitized data
  copyright Google Corporation (Reserved Font Names Arimo, Tinos, Cousine)

## DejaVu fonts

- File: `fonts/DejaVuSans.ttf`
- License: Bitstream Vera / DejaVu fonts license
- License text: [`fonts/LICENSE-DejaVu.txt`](fonts/LICENSE-DejaVu.txt)
