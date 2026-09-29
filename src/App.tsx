import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Box, Download, FileCode2, FolderOpen, RotateCcw, Play, Upload, X, SlidersHorizontal, Code2 } from "lucide-react";
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { STLLoader } from "three/addons/loaders/STLLoader.js";
import renderWorkerUrl from "./render-worker.ts?worker&url";
import { parseParameters, setParameter, type ScadParameter } from "./scad-parameters";

const models = [
  { name: "Mast antenna clip", description: "25.4–76.2 mm tubing · zip tie eyelet", path: `${import.meta.env.BASE_URL}models/mast-antenna-clip.scad` },
];
function Viewer({ stl, resetKey }: { stl: ArrayBuffer | null; resetKey: number }) {
  const mount = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = mount.current; if (!el) return;
    const scene = new THREE.Scene(); scene.background = new THREE.Color("#e8e9e8");
    const camera = new THREE.PerspectiveCamera(42, 1, 0.1, 2000); camera.position.set(72, 62, 85);
    const renderer = new THREE.WebGLRenderer({ antialias: true }); renderer.setPixelRatio(Math.min(devicePixelRatio, 2)); renderer.outputColorSpace = THREE.SRGBColorSpace; el.appendChild(renderer.domElement);
    const controls = new OrbitControls(camera, renderer.domElement); controls.enableDamping = true;
    scene.add(new THREE.HemisphereLight("#ffffff", "#9da5a6", 2.1));
    const light = new THREE.DirectionalLight("#ffffff", 2.6); light.position.set(40, 80, 60); scene.add(light);
    const grid = new THREE.GridHelper(240, 24, "#c0c5c6", "#d7dada"); scene.add(grid);
    let mesh: THREE.Mesh | undefined;
    if (stl) {
      try {
        const geometry = new STLLoader().parse(stl); geometry.computeVertexNormals(); geometry.computeBoundingBox();
        const bounds = geometry.boundingBox!; const center = new THREE.Vector3(); bounds.getCenter(center);
        geometry.translate(-center.x, -center.y, -bounds.min.z); geometry.rotateX(-Math.PI / 2);
        mesh = new THREE.Mesh(geometry, new THREE.MeshStandardMaterial({ color: "#d65a34", metalness: 0.08, roughness: 0.72, side: THREE.DoubleSide })); scene.add(mesh);
        const size = new THREE.Vector3(); bounds.getSize(size); const span = Math.max(size.x, size.y, size.z, 10);
        camera.position.set(span * 1.7, span * 1.3, span * 1.9); camera.near = Math.max(span / 1000, 0.01); camera.far = span * 100; camera.updateProjectionMatrix();
        controls.target.set(0, size.z * 0.42, 0); grid.position.y = -0.1; grid.scale.setScalar(Math.max(span / 60, 0.25));
      } catch (error) { console.error("STL preview failed", error); }
    }
    const resize = () => { const w = el.clientWidth, h = el.clientHeight; renderer.setSize(w, h); camera.aspect = w / Math.max(h, 1); camera.updateProjectionMatrix(); };
    const observer = new ResizeObserver(resize); observer.observe(el);
    let frame = 0; const animate = () => { frame = requestAnimationFrame(animate); controls.update(); renderer.render(scene, camera); }; animate();
    return () => { cancelAnimationFrame(frame); observer.disconnect(); controls.dispose(); mesh?.geometry.dispose(); (mesh?.material as THREE.Material | undefined)?.dispose(); renderer.dispose(); el.removeChild(renderer.domElement); };
  }, [stl, resetKey]);
  return <div ref={mount} className="viewer-canvas" aria-label="Interactive 3D model viewport" />;
}
function ParameterField({ parameter, onChange }: { parameter: ScadParameter; onChange: (value: string) => void }) {
  const readable = parameter.kind === "text" ? (() => { try { return JSON.parse(parameter.value) as string; } catch { return parameter.value.slice(1, -1); } })() : parameter.value;
  const [draft, setDraft] = useState(readable);
  useEffect(() => { setDraft(readable); }, [readable]);
  const commit = () => {
    if (parameter.kind === "text") { onChange(JSON.stringify(draft)); return; }
    const n = Number(draft);
    if (!draft.trim() || !Number.isFinite(n) || (parameter.min !== undefined && n < parameter.min) || (parameter.max !== undefined && n > parameter.max)) {
      setDraft(readable); return;
    }
    onChange(String(n));
  };
  if (parameter.kind === "boolean") return <label className="param-row param-toggle"><span>{parameter.label}</span><input type="checkbox" checked={parameter.value === "true"} onChange={e => onChange(String(e.target.checked))} /></label>;
  return <div className="param-row"><label htmlFor={`param-${parameter.name}`}>{parameter.label}</label><div className="param-input-wrap"><input id={`param-${parameter.name}`} type={parameter.kind === "number" ? "number" : "text"} step="any" min={parameter.min} max={parameter.max} value={draft} onChange={e => setDraft(e.target.value)} onBlur={commit} onKeyDown={e => { if (e.key === "Enter") e.currentTarget.blur(); }} />{parameter.kind === "number" && (parameter.name.endsWith("_inches") ? <span className="param-unit">in</span> : parameter.name.endsWith("_angle") ? <span className="param-unit">°</span> : /width|height|depth|diameter|wall|base|corner|length|clearance|chamfer/i.test(parameter.name) ? <span className="param-unit">mm</span> : null)}</div>{parameter.kind === "number" && parameter.min !== undefined && parameter.max !== undefined && parameter.max > parameter.min && <input className="param-range" type="range" min={parameter.min} max={parameter.max} step={parameter.step ?? "any"} value={parameter.value} onChange={e => onChange(e.target.value)} aria-label={`Adjust ${parameter.label}`} />}</div>;
}
export default function Home() {
  const [active, setActive] = useState(0), [name, setName] = useState(models[0].name), [source, setSource] = useState(""), [stl, setStl] = useState<ArrayBuffer | null>(null);
  const [status, setStatus] = useState("Ready to render"), [busy, setBusy] = useState(false), [error, setError] = useState(""), [resetKey, setResetKey] = useState(0), [edited, setEdited] = useState(false), [codeOpen, setCodeOpen] = useState(false);
  const worker = useRef<Worker | null>(null), fileInput = useRef<HTMLInputElement>(null), lastRender = useRef(0);
  const parameters = useMemo(() => parseParameters(source), [source]);
  const changeSource = (next: string) => {
    worker.current?.terminate(); lastRender.current++; setBusy(false);
    setSource(next); setEdited(true); setStl(null); setError(""); setStatus("Changes ready to render");
  };
  const loadModel = useCallback(async (index: number) => {
    try { const response = await fetch(models[index].path); if (!response.ok) throw new Error("Could not load this model."); worker.current?.terminate(); lastRender.current++; setBusy(false); setSource(await response.text()); setName(models[index].name); setActive(index); setEdited(false); setCodeOpen(false); setStl(null); setError(""); setStatus("Ready to render"); }
    catch (e) { setError(String(e)); }
  }, []);
  useEffect(() => { void loadModel(0); }, [loadModel]);
  useEffect(() => () => worker.current?.terminate(), []);
  useEffect(() => {
    type Context = { registerTool: (tool: object, options: { signal: AbortSignal }) => void | Promise<void> };
    const context = (document as Document & { modelContext?: Context }).modelContext;
    if (!context?.registerTool) return;
    const lifecycle = new AbortController();
    try {
      void Promise.resolve(context.registerTool({
        name: "select_library_model", title: "Select library model",
        description: "Load one bundled OpenSCAD model into the source editor.",
        inputSchema: { type: "object", properties: { index: { type: "integer", minimum: 0, maximum: 0 } }, required: ["index"], additionalProperties: false },
        annotations: { readOnlyHint: false, untrustedContentHint: false },
        async execute(input: unknown) {
          const index = (input as { index?: number })?.index;
          if (!Number.isInteger(index) || index! < 0 || index! >= models.length) throw new Error("Choose a model index only index 0.");
          await loadModel(index!);
          return { selected: models[index!].name };
        }
      }, { signal: lifecycle.signal })).catch(console.error);
    } catch (error) { console.error(error); }
    return () => lifecycle.abort();
  }, [loadModel]);
  const render = () => {
    if (!source.trim() || busy) return;
    worker.current?.terminate();
    // The bundler emits the worker asset URL; resolve it against this page's origin.
    let next: Worker;
    try {
      next = new Worker(new URL(renderWorkerUrl, document.baseURI), { type: "module" });
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "The rendering engine could not start.");
      setStatus("Render failed");
      return;
    }
    worker.current = next;
    const job = ++lastRender.current; setBusy(true); setError(""); setStatus("Rendering geometry…"); setStl(null);
    next.onmessage = (event: MessageEvent<{ type: string; buffer?: ArrayBuffer; message?: string }>) => {
      if (job !== lastRender.current) return;
      if (event.data.type === "success" && event.data.buffer) { setStl(event.data.buffer); setStatus("Render complete"); setBusy(false); next.terminate(); }
      else if (event.data.type === "error") { setError(event.data.message || "OpenSCAD could not render this file."); setStatus("Render failed"); setBusy(false); next.terminate(); }
    };
    next.onerror = (event) => { setError(event.message || "The rendering engine could not start."); setBusy(false); setStatus("Render failed"); next.terminate(); };
    next.postMessage({ source });
  };
  const openLocal = async (file?: File) => {
    if (!file) return; if (!file.name.toLowerCase().endsWith(".scad")) { setError("Choose a .scad file."); return; }
    worker.current?.terminate(); lastRender.current++; setBusy(false); setStl(null); setSource(await file.text()); setName(file.name); setActive(-1); setEdited(false); setCodeOpen(false); setError(""); setStatus("Ready to render");
  };
  const download = () => {
    if (!stl) return; const url = URL.createObjectURL(new Blob([stl], { type: "model/stl" })); const a = document.createElement("a");
    a.href = url; a.download = name.replace(/\.scad$/i, "").replace(/[^a-z0-9_-]+/gi, "-").toLowerCase() + ".stl"; a.click(); setTimeout(() => URL.revokeObjectURL(url), 1000);
  };
  return <main className="app-shell">
    <header className="topbar"><div className="brand"><span className="brand-mark"><Box size={20} strokeWidth={2.1} /></span><strong>SCAD<span>WORKBENCH</span></strong></div><div className="topbar-right"><span className="local-note">Rendered in your browser</span><button className="button button-outline" onClick={() => fileInput.current?.click()}><Upload size={16} /> Open local file</button><input ref={fileInput} type="file" accept=".scad" hidden onChange={(e) => { void openLocal(e.target.files?.[0]); e.target.value = ""; }} /></div></header>
    <div className="workspace"><aside className="shelf"><div className="panel-heading"><span>MODEL LIBRARY</span><span className="count">{String(models.length).padStart(2, "0")}</span></div><p className="shelf-intro">Adjust the mast clip and render a printable mesh.</p><div className="model-list">{models.map((model, i) => <button key={model.path} className={`model-row ${active === i ? "selected" : ""}`} onClick={() => void loadModel(i)}><span className="model-icon"><FileCode2 size={19} strokeWidth={1.7} /></span><span className="model-copy"><strong>{model.name}</strong><small>{model.description}</small></span><span className="row-index">0{i + 1}</span></button>)}</div><div className="shelf-bottom"><FolderOpen size={19} /><div><strong>Your own model?</strong><span>Open a .scad file from your device.</span><button onClick={() => fileInput.current?.click()}>Choose file <span aria-hidden>↗</span></button></div></div></aside>
    <section className="editor-panel" aria-label="Model parameters">
      <div className="panel-heading editor-heading"><span>PARAMETERS</span><span className="file-pill">{active < 0 ? "LOCAL FILE" : "LIBRARY FILE"}</span></div>
      <div className="file-bar"><SlidersHorizontal size={16} /><strong>{name.endsWith(".scad") ? name : name.toLowerCase().replaceAll(" ", "-") + ".scad"}</strong>{edited && <span className="edit-dot" title="Changed parameters" />}</div>
      <div className="parameter-content">
        {parameters.length ? <><p className="parameter-intro">Adjust dimensions, then render to update the model.</p><div className="parameter-list">{parameters.map(parameter => <ParameterField key={parameter.name} parameter={parameter} onChange={value => changeSource(setParameter(source, parameter, value))} />)}</div></> : <div className="parameter-empty"><SlidersHorizontal size={22} /><strong>No simple parameters found</strong><p>Edit the code to change this model. Numeric, text, and boolean assignments at the top level appear here.</p></div>}
      </div>
      <div className="code-section"><button className="code-toggle" aria-expanded={codeOpen} onClick={() => setCodeOpen(v => !v)}><Code2 size={16} /> {codeOpen ? "Hide code" : "Show code"}<span>{source.split("\n").length} lines</span></button>{codeOpen && <div className="code-wrap"><textarea aria-label="OpenSCAD source code" spellCheck={false} value={source} onChange={e => changeSource(e.target.value)} /></div>}</div>
    </section>
    <section className="preview-panel" aria-label="3D preview"><div className="preview-header"><div><div className="panel-heading">3D PREVIEW</div><h1>{name.replace(/\.scad$/i, "")}</h1></div><div className="actions"><button className="button button-primary" disabled={busy || !source} onClick={render}><Play size={16} fill="currentColor" /> {busy ? "Rendering…" : "Render model"}</button><button className="button button-outline" disabled={!stl} onClick={download}><Download size={16} /> STL</button></div></div><div className="viewport"><Viewer stl={stl} resetKey={resetKey} /><div className="axis-label">PERSPECTIVE <span>·</span> MM</div><button className="reset-view" onClick={() => setResetKey(v => v + 1)} title="Reset camera"><RotateCcw size={17} /> <span>Reset view</span></button>{!stl && <div className="viewport-message"><div className="viewport-symbol"><Box size={30} strokeWidth={1.3} /></div><strong>{busy ? "Building mesh…" : "No preview yet"}</strong><span>{busy ? "Complex models can take a moment." : "Render the source to inspect the model."}</span></div>}</div><div className="status-bar"><div className="status-left"><span className={`status-indicator ${busy ? "pulsing" : error ? "failed" : stl ? "done" : ""}`} /><span>{status}</span></div><span className="view-hint">Drag to orbit · Scroll to zoom · Right-drag to pan</span></div>{error && <div className="error-panel" role="alert"><span>{error}</span><button onClick={() => setError("")} aria-label="Dismiss error"><X size={16} /></button></div>}</section></div>
  </main>;
}
