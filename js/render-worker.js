import createOpenSCAD from "../vendor/openscad-wasm/openscad.js";

const FONT_FILES = [
  "LiberationSans-Regular.ttf",
  "LiberationSans-Bold.ttf",
  "LiberationSerif-Regular.ttf",
  "LiberationMono-Regular.ttf",
  "DejaVuSans.ttf",
];

let fontBytes;

async function loadFonts() {
  if (fontBytes) return fontBytes;
  fontBytes = await Promise.all(FONT_FILES.map(async (name) => {
    const response = await fetch(new URL(`../fonts/${name}`, import.meta.url));
    if (!response.ok) throw new Error(`Could not load font ${name}.`);
    return { name, data: new Uint8Array(await response.arrayBuffer()) };
  }));
  return fontBytes;
}

function ensureDir(fs, path) {
  try { fs.mkdir(path); } catch { /* exists */ }
}

self.onmessage = async (event) => {
  const logs = [];
  try {
    const fonts = await loadFonts();
    const instance = await createOpenSCAD({ noInitialRun: true, print: (s) => logs.push(s), printErr: (s) => logs.push(s) });
    ensureDir(instance.FS, "/fonts");
    for (const font of fonts) instance.FS.writeFile(`/fonts/${font.name}`, font.data);
    const uses = FONT_FILES.map((name) => `use <fonts/${name}>`).join("\n");
    instance.FS.writeFile("/input.scad", `${uses}\n${event.data.source}`);
    const exit = instance.callMain(["/input.scad", "--backend", "Manifold", "--export-format", "binstl", "-o", "/out.stl"]);
    if (exit !== 0) throw new Error(logs.slice(-8).join("\n") || `OpenSCAD exited with code ${exit}.`);
    const bytes = instance.FS.readFile("/out.stl");
    if (!bytes.length) throw new Error("The model produced an empty STL.");
    const buffer = bytes.slice().buffer;
    self.postMessage({ type: "success", buffer }, { transfer: [buffer] });
  } catch (e) {
    self.postMessage({ type: "error", message: (e instanceof Error ? e.message : String(e)) + (logs.length ? `\n${logs.slice(-5).join("\n")}` : "") });
  }
};
