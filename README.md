# SCAD Workbench — self-hostable source

This is the source for the SCAD Workbench site: a browser-based OpenSCAD editor with a parameter panel, 3D STL preview, local `.scad` import, and STL download. The bundled library contains the mast antenna clip.

## Quick deployment

The `dist/` folder in this archive is already built. Serve its contents from any static HTTP(S) web server. Keep `index.html`, `assets/`, `models/`, and `favicon.svg` together. The app can be hosted at the domain root or under a subdirectory.

Do **not** open `index.html` with a `file://` URL; browser workers and WebAssembly require an HTTP(S) origin.

For a local check:

```bash
python3 -m http.server 8000 --directory dist
```

Then open `http://localhost:8000/`.

## Build from source

Requires Node.js 20.19 or newer and npm.

```bash
npm ci
npm run dev       # development server
npm run build     # outputs dist/
```

For a local production preview, run `npm run preview` and open the address it prints. To publish, serve the new `dist/` folder through your static web server. No backend, database, or API key is needed. The OpenSCAD engine and model rendering run in the visitor's browser.

## Main files

- `src/App.tsx` — interface, local file loading, render actions, and 3D viewer
- `src/render-worker.ts` — OpenSCAD WebAssembly rendering worker
- `src/scad-parameters.ts` — parameter detection and source updates
- `src/style.css` — layout and visual styling
- `public/models/mast-antenna-clip.scad` — bundled parametric model

To add library models, place `.scad` files in `public/models/` and add entries to the `models` array in `src/App.tsx`.

## Hosting notes

Serve `.wasm` assets with `application/wasm` when configuring a server manually. Keep the built asset paths intact. A browser with WebAssembly and WebGL support is required for rendering and 3D preview. The initial OpenSCAD engine download is several megabytes.

The project depends on `@lofcz/openscad-wasm`, which includes OpenSCAD under GPL-2.0-only. Review that package's license when redistributing the built site. Other dependency licenses are available through their npm packages.
