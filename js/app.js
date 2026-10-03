import { parseParameters, setParameter } from "./scad-parameters.js";
import { mountViewer } from "./viewer.js";
import { icons } from "./icons.js";

let models = [];

const state = {
  active: 0,
  name: "",
  source: "",
  stl: null,
  status: "Ready to render",
  busy: false,
  error: "",
  resetKey: 0,
  edited: false,
  codeOpen: false,
};

let worker = null;
let lastRender = 0;
let lastParamSource = null;
const viewer = mountViewer(document.getElementById("viewer"));

const els = {
  openTop: document.getElementById("open-file-top"),
  openShelf: document.getElementById("open-file-shelf"),
  fileInput: document.getElementById("file-input"),
  modelCount: document.getElementById("model-count"),
  modelList: document.getElementById("model-list"),
  filePill: document.getElementById("file-pill"),
  fileName: document.getElementById("file-name"),
  editDot: document.getElementById("edit-dot"),
  parameterContent: document.getElementById("parameter-content"),
  codeToggle: document.getElementById("code-toggle"),
  codeWrap: document.getElementById("code-wrap"),
  sourceEditor: document.getElementById("source-editor"),
  previewTitle: document.getElementById("preview-title"),
  renderButton: document.getElementById("render-button"),
  downloadButton: document.getElementById("download-button"),
  resetView: document.getElementById("reset-view"),
  viewportMessage: document.getElementById("viewport-message"),
  viewportHeading: document.getElementById("viewport-heading"),
  viewportDetail: document.getElementById("viewport-detail"),
  statusIndicator: document.getElementById("status-indicator"),
  statusText: document.getElementById("status-text"),
  errorPanel: document.getElementById("error-panel"),
  errorText: document.getElementById("error-text"),
  dismissError: document.getElementById("dismiss-error"),
};

function unitFor(name) {
  if (name.endsWith("_inches")) return "in";
  if (name.endsWith("_angle")) return "°";
  if (/width|height|depth|diameter|wall|base|corner|length|clearance|chamfer/i.test(name)) return "mm";
  return "";
}

function readableValue(parameter) {
  if (parameter.kind !== "text") return parameter.value;
  try { return JSON.parse(parameter.value); } catch { return parameter.value.slice(1, -1); }
}

function changeSource(next) {
  worker?.terminate();
  lastRender += 1;
  state.busy = false;
  state.source = next;
  state.edited = true;
  state.stl = null;
  state.error = "";
  state.status = "Changes ready to render";
  sync();
}

function caption(parameter) {
  return parameter.description || parameter.label;
}

function numberInput(parameter, value, onCommit) {
  const wrap = document.createElement("div");
  wrap.className = "param-input-wrap";
  const input = document.createElement("input");
  input.type = "number";
  input.step = parameter.step === undefined ? "any" : String(parameter.step);
  if (parameter.min !== undefined) input.min = String(parameter.min);
  if (parameter.max !== undefined) input.max = String(parameter.max);
  input.value = String(value);
  input.addEventListener("blur", () => onCommit(input.value));
  input.addEventListener("keydown", (e) => { if (e.key === "Enter") e.currentTarget.blur(); });
  wrap.appendChild(input);
  return { wrap, input };
}

function commitParameter(parameter, draft) {
  if (parameter.kind === "text") {
    changeSource(setParameter(state.source, parameter, JSON.stringify(draft)));
    return;
  }
  const n = Number(draft);
  if (!draft.trim() || !Number.isFinite(n) || (parameter.min !== undefined && n < parameter.min) || (parameter.max !== undefined && n > parameter.max)) {
    syncParameters();
    return;
  }
  changeSource(setParameter(state.source, parameter, String(n)));
}

function parameterRow(parameter) {
  const title = caption(parameter);
  if (parameter.options?.length) {
    const row = document.createElement("div");
    row.className = "param-row param-select";
    const id = `param-${parameter.name}`;
    const label = document.createElement("label");
    label.htmlFor = id;
    label.textContent = title;
    label.title = parameter.name;
    const select = document.createElement("select");
    select.id = id;
    select.setAttribute("aria-label", title);
    for (const option of parameter.options) {
      const item = document.createElement("option");
      item.value = option.value;
      item.textContent = option.label;
      select.appendChild(item);
    }
    select.value = parameter.kind === "text" ? readableValue(parameter) : parameter.value;
    select.addEventListener("change", () => {
      const next = parameter.kind === "text" ? JSON.stringify(select.value) : select.value;
      changeSource(setParameter(state.source, parameter, next));
    });
    row.append(label, select);
    return row;
  }

  if (parameter.kind === "boolean") {
    const label = document.createElement("label");
    label.className = "param-row param-toggle";
    label.title = parameter.name;
    const name = document.createElement("span");
    name.textContent = title;
    label.appendChild(name);
    const input = document.createElement("input");
    input.type = "checkbox";
    input.checked = parameter.value === "true";
    input.addEventListener("change", () => changeSource(setParameter(state.source, parameter, String(input.checked))));
    label.appendChild(input);
    return label;
  }

  if (parameter.kind === "vector") {
    const row = document.createElement("div");
    row.className = "param-row param-vector-row";
    const label = document.createElement("label");
    label.textContent = title;
    label.title = parameter.name;
    const fields = document.createElement("div");
    fields.className = "param-vector";
    const inputs = parameter.components.map((n, i) => {
      const { wrap, input } = numberInput(parameter, n, () => {
        const next = inputs.map((el) => Number(el.value));
        if (next.some((v) => !Number.isFinite(v) || (parameter.min !== undefined && v < parameter.min) || (parameter.max !== undefined && v > parameter.max))) {
          syncParameters();
          return;
        }
        changeSource(setParameter(state.source, parameter, `[${next.join(", ")}]`));
      });
      input.setAttribute("aria-label", `${title} ${i + 1}`);
      fields.appendChild(wrap);
      return input;
    });
    row.append(label, fields);
    return row;
  }

  const row = document.createElement("div");
  row.className = "param-row";
  const id = `param-${parameter.name}`;
  const unit = parameter.kind === "number" ? unitFor(parameter.name) : "";
  const label = document.createElement("label");
  label.htmlFor = id;
  label.textContent = title;
  label.title = parameter.name;
  if (parameter.kind === "text") {
    const wrap = document.createElement("div");
    wrap.className = "param-input-wrap";
    const input = document.createElement("input");
    input.id = id;
    input.type = "text";
    if (parameter.maxLength) input.maxLength = parameter.maxLength;
    input.value = readableValue(parameter);
    input.addEventListener("blur", () => commitParameter(parameter, input.value));
    input.addEventListener("keydown", (e) => { if (e.key === "Enter") e.currentTarget.blur(); });
    wrap.appendChild(input);
    row.append(label, wrap);
    return row;
  }
  const { wrap, input } = numberInput(parameter, parameter.value, (draft) => commitParameter(parameter, draft));
  input.id = id;
  if (unit) {
    const span = document.createElement("span");
    span.className = "param-unit";
    span.textContent = unit;
    wrap.appendChild(span);
  }
  row.append(label, wrap);
  if (parameter.min !== undefined && parameter.max !== undefined && parameter.max > parameter.min) {
    const range = document.createElement("input");
    range.className = "param-range";
    range.type = "range";
    range.min = String(parameter.min);
    range.max = String(parameter.max);
    range.step = parameter.step === undefined ? "any" : String(parameter.step);
    range.value = parameter.value;
    range.setAttribute("aria-label", `Adjust ${title}`);
    range.addEventListener("input", () => {
      worker?.terminate();
      lastRender += 1;
      state.busy = false;
      state.source = setParameter(state.source, parameter, range.value);
      lastParamSource = state.source;
      input.value = range.value;
      state.edited = true;
      state.stl = null;
      state.error = "";
      state.status = "Changes ready to render";
      sync({ skipParameters: true });
    });
    row.appendChild(range);
  }
  return row;
}

function groupHeading(name) {
  const heading = document.createElement("h3");
  heading.className = "param-group";
  heading.textContent = name.replace(/:+$/, "");
  return heading;
}

function syncParameters() {
  const parameters = parseParameters(state.source);
  els.parameterContent.replaceChildren();
  if (!parameters.length) {
    const empty = document.createElement("div");
    empty.className = "parameter-empty";
    empty.innerHTML = `${icons.sliders(22)}<strong>No Customizer parameters found</strong><p>Top-level assignments before the first <code>{</code> appear here. Use <code>// [min:step:max]</code>, dropdown lists, and <code>/* [Group] */</code> tabs as in OpenSCAD.</p>`;
    els.parameterContent.appendChild(empty);
    return;
  }
  const intro = document.createElement("p");
  intro.className = "parameter-intro";
  intro.textContent = "Adjust dimensions, then render to update the model.";
  const list = document.createElement("div");
  list.className = "parameter-list";
  const showGroups = parameters.some((parameter) => parameter.group);
  let lastGroup = null;
  for (const parameter of parameters) {
    if (showGroups && parameter.group !== lastGroup) {
      lastGroup = parameter.group;
      if (parameter.group) list.appendChild(groupHeading(parameter.group));
    }
    list.appendChild(parameterRow(parameter));
  }
  els.parameterContent.append(intro, list);
}

function fileLabel() {
  return state.name.endsWith(".scad") ? state.name : `${state.name.toLowerCase().replaceAll(" ", "-")}.scad`;
}

function sync({ skipParameters = false } = {}) {
  els.filePill.textContent = state.active < 0 ? "LOCAL FILE" : "LIBRARY FILE";
  els.fileName.textContent = fileLabel();
  els.editDot.hidden = !state.edited;
  els.previewTitle.textContent = state.name.replace(/\.scad$/i, "");
  els.codeToggle.setAttribute("aria-expanded", String(state.codeOpen));
  els.codeToggle.innerHTML = `${icons.code()} ${state.codeOpen ? "Hide code" : "Show code"}<span>${state.source.split("\n").length} lines</span>`;
  els.codeWrap.hidden = !state.codeOpen;
  if (document.activeElement !== els.sourceEditor && els.sourceEditor.value !== state.source) els.sourceEditor.value = state.source;
  els.renderButton.disabled = state.busy || !state.source;
  els.renderButton.innerHTML = `${icons.play()} ${state.busy ? "Rendering…" : "Render model"}`;
  els.downloadButton.disabled = !state.stl;
  els.downloadButton.innerHTML = `${icons.download()} STL`;
  els.viewportMessage.hidden = Boolean(state.stl);
  els.viewportHeading.textContent = state.busy ? "Building mesh…" : "No preview yet";
  els.viewportDetail.textContent = state.busy ? "Complex models can take a moment." : "Render the source to inspect the model.";
  els.statusText.textContent = state.status;
  els.statusIndicator.className = `status-indicator ${state.busy ? "pulsing" : state.error ? "failed" : state.stl ? "done" : ""}`;
  els.errorPanel.hidden = !state.error;
  els.errorText.textContent = state.error;
  for (const button of els.modelList.querySelectorAll(".model-row")) {
    button.classList.toggle("selected", Number(button.dataset.index) === state.active);
  }
  if (!skipParameters && lastParamSource !== state.source) {
    lastParamSource = state.source;
    syncParameters();
  }
  viewer.set(state.stl, state.resetKey);
}

async function loadModel(index) {
  try {
    const response = await fetch(models[index].path);
    if (!response.ok) throw new Error("Could not load this model.");
    worker?.terminate();
    lastRender += 1;
    state.busy = false;
    state.source = await response.text();
    state.name = models[index].name;
    state.active = index;
    state.edited = false;
    state.codeOpen = false;
    state.stl = null;
    state.error = "";
    state.status = "Ready to render";
    sync();
  } catch (e) {
    state.error = String(e);
    sync();
  }
}

function renderModel() {
  if (!state.source.trim() || state.busy) return;
  worker?.terminate();
  let next;
  try {
    next = new Worker(new URL("./render-worker.js", import.meta.url), { type: "module" });
  } catch (cause) {
    state.error = cause instanceof Error ? cause.message : "The rendering engine could not start.";
    state.status = "Render failed";
    sync();
    return;
  }
  worker = next;
  const job = ++lastRender;
  state.busy = true;
  state.error = "";
  state.status = "Rendering geometry…";
  state.stl = null;
  sync();
  next.onmessage = (event) => {
    if (job !== lastRender) return;
    if (event.data.type === "success" && event.data.buffer) {
      state.stl = event.data.buffer;
      state.status = "Render complete";
      state.busy = false;
      next.terminate();
      sync();
    } else if (event.data.type === "error") {
      state.error = event.data.message || "OpenSCAD could not render this file.";
      state.status = "Render failed";
      state.busy = false;
      next.terminate();
      sync();
    }
  };
  next.onerror = (event) => {
    state.error = event.message || "The rendering engine could not start.";
    state.busy = false;
    state.status = "Render failed";
    next.terminate();
    sync();
  };
  next.postMessage({ source: state.source });
}

async function openLocal(file) {
  if (!file) return;
  if (!file.name.toLowerCase().endsWith(".scad")) {
    state.error = "Choose a .scad file.";
    sync();
    return;
  }
  worker?.terminate();
  lastRender += 1;
  state.busy = false;
  state.stl = null;
  state.source = await file.text();
  state.name = file.name;
  state.active = -1;
  state.edited = false;
  state.codeOpen = false;
  state.error = "";
  state.status = "Ready to render";
  sync();
}

function download() {
  if (!state.stl) return;
  const url = URL.createObjectURL(new Blob([state.stl], { type: "model/stl" }));
  const a = document.createElement("a");
  a.href = url;
  a.download = state.name.replace(/\.scad$/i, "").replace(/[^a-z0-9_-]+/gi, "-").toLowerCase() + ".stl";
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

function pickFile() {
  els.fileInput.click();
}

function paintChrome() {
  document.querySelector('[data-icon="box-mark"]').innerHTML = icons.box(20, 2.1);
  document.querySelector('[data-icon="folder"]').innerHTML = icons.folderOpen(19);
  document.querySelector('[data-icon="sliders"]').innerHTML = icons.sliders(16);
  document.querySelector('[data-icon="box-empty"]').innerHTML = icons.box(30, 1.3);
  els.openTop.innerHTML = `${icons.upload()} Open local file`;
  document.getElementById("source-link").innerHTML = `${icons.github()} Source`;
  els.resetView.innerHTML = `${icons.rotateCcw()} <span>Reset view</span>`;
  els.dismissError.innerHTML = icons.x();
  els.modelCount.textContent = String(models.length).padStart(2, "0");
  els.modelList.replaceChildren();
  models.forEach((model, i) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `model-row ${state.active === i ? "selected" : ""}`;
    button.dataset.index = String(i);
    button.innerHTML = `<span class="model-icon">${icons.fileCode(19, 1.7)}</span><span class="model-copy"><strong></strong><small></small></span><span class="row-index">${String(i + 1).padStart(2, "0")}</span>`;
    button.querySelector("strong").textContent = model.name;
    button.querySelector("small").textContent = model.description;
    button.addEventListener("click", () => void loadModel(i));
    els.modelList.appendChild(button);
  });
}

els.openTop.addEventListener("click", pickFile);
els.openShelf.addEventListener("click", pickFile);
els.fileInput.addEventListener("change", (e) => {
  void openLocal(e.target.files?.[0]);
  e.target.value = "";
});
els.codeToggle.addEventListener("click", () => {
  state.codeOpen = !state.codeOpen;
  sync();
});
els.sourceEditor.addEventListener("input", () => changeSource(els.sourceEditor.value));
els.renderButton.addEventListener("click", renderModel);
els.downloadButton.addEventListener("click", download);
els.resetView.addEventListener("click", () => {
  state.resetKey += 1;
  viewer.set(state.stl, state.resetKey);
});
els.dismissError.addEventListener("click", () => {
  state.error = "";
  sync();
});
window.addEventListener("beforeunload", () => worker?.terminate());

function registerHostTool() {
  const context = document.modelContext;
  if (!context?.registerTool || !models.length) return;
  const lifecycle = new AbortController();
  const last = models.length - 1;
  try {
    void Promise.resolve(context.registerTool({
      name: "select_library_model",
      title: "Select library model",
      description: "Load one bundled OpenSCAD model into the source editor.",
      inputSchema: { type: "object", properties: { index: { type: "integer", minimum: 0, maximum: last } }, required: ["index"], additionalProperties: false },
      annotations: { readOnlyHint: false, untrustedContentHint: false },
      async execute(input) {
        const index = input?.index;
        if (!Number.isInteger(index) || index < 0 || index >= models.length) throw new Error(`Choose a model index from 0 to ${last}.`);
        await loadModel(index);
        return { selected: models[index].name };
      },
    }, { signal: lifecycle.signal })).catch(console.error);
  } catch (error) {
    console.error(error);
  }
  window.addEventListener("pagehide", () => lifecycle.abort(), { once: true });
}

async function init() {
  try {
    const response = await fetch("./models/catalog.json");
    if (!response.ok) throw new Error("Could not load the model catalog. Run `make catalog`.");
    const loaded = await response.json();
    if (!Array.isArray(loaded)) throw new Error("The model catalog is invalid.");
    models = loaded.filter((model) => model && typeof model.path === "string");
  } catch (error) {
    state.error = error instanceof Error ? error.message : String(error);
    state.status = "Catalog missing";
    paintChrome();
    sync();
    return;
  }
  paintChrome();
  registerHostTool();
  sync();
  if (models.length) await loadModel(0);
  else {
    state.status = "No library models";
    sync();
  }
}

void init();
