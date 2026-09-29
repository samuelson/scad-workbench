import createOpenSCAD from "@lofcz/openscad-wasm";

self.onmessage = async (event: MessageEvent<{ source: string }>) => {
  const logs: string[] = [];
  try {
    const instance = await createOpenSCAD({ noInitialRun: true, print: (s: string) => logs.push(s), printErr: (s: string) => logs.push(s) });
    instance.FS.writeFile("/input.scad", event.data.source);
    const exit = instance.callMain(["/input.scad", "--backend", "Manifold", "--export-format", "binstl", "-o", "/out.stl"]);
    if (exit !== 0) throw new Error(logs.slice(-8).join("\n") || `OpenSCAD exited with code ${exit}.`);
    const bytes = instance.FS.readFile("/out.stl") as Uint8Array;
    if (!bytes.length) throw new Error("The model produced an empty STL.");
    const buffer = bytes.slice().buffer;
    self.postMessage({ type: "success", buffer }, { transfer: [buffer] });
  } catch (e) {
    self.postMessage({ type: "error", message: (e instanceof Error ? e.message : String(e)) + (logs.length ? `\n${logs.slice(-5).join("\n")}` : "") });
  }
};
