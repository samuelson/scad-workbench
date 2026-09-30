# SCAD Workbench — self-hostable source

This is the source for the SCAD Workbench site: a browser-based OpenSCAD editor with a parameter panel, 3D STL preview, local `.scad` import, and STL download. The bundled library contains the mast antenna clip.

This project is licensed under **GPL-2.0-only**. See `LICENSE`. Third-party code and fonts are listed in `THIRD_PARTY.md`.

## Quick deployment

Clone the repository, then fetch the OpenSCAD WASM engine and Three.js:

```bash
make
```

That writes `vendor/` (gitignored) and `models/catalog.json`. Serve the tree from any static HTTP(S) web server. Keep `index.html`, `css/`, `js/`, `vendor/`, `models/`, `fonts/`, and `favicon.svg` together. The app can be hosted at the domain root or under a subdirectory.

Do **not** open `index.html` with a `file://` URL; browser workers and WebAssembly require an HTTP(S) origin.

For a local check:

```bash
make serve
```

Then open `http://localhost:8000/`. Override the port with `make serve PORT=8080`.

`make catalog` scans `models/*.scad` and writes `models/catalog.json`. Node.js is not required. Python 3 is used for the catalog script, vendor download, and the optional local server. The first `make` needs network access to download pinned packages from the npm registry.

## Main files

- `js/app.js` — interface, local file loading, render actions, and parameter panel
- `js/render-worker.js` — OpenSCAD WebAssembly rendering worker
- `js/scad-parameters.js` — parameter detection and source updates
- `js/viewer.js` — Three.js STL preview
- `css/style.css` — layout and visual styling
- `models/*.scad` — bundled parametric models
- `fonts/` — Liberation and DejaVu fonts used by engraved labels
- `Makefile` — vendor fetch, catalog generation, local server, and asset checks

To add library models, place `.scad` files in `models/` and run `make`. The library name comes from the file name; the sidebar subtitle is the first `//` comment. Optional overrides at the top of a file:

```
// name: Mast antenna clip
// description: 25.4–76.2 mm tubing · zip tie eyelet
```

## GitHub Pages

Pushes to `main` run `.github/workflows/pages.yml`: `make site` fetches vendors, rebuilds `models/catalog.json` from every `models/*.scad` file, and deploys `_site/`. Adding or changing a model on `main` therefore updates the live library. You can also run the workflow by hand from the Actions tab.

In the GitHub repo, set **Settings → Pages → Source** to **GitHub Actions** once. The site URL is `https://<user>.github.io/scad-workbench/` for a project repo.

## Hosting notes

Serve `.wasm` assets with `application/wasm` when configuring a server manually. Keep the relative asset paths intact. A browser with WebAssembly and WebGL support is required for rendering and 3D preview. The initial OpenSCAD engine download is several megabytes.
