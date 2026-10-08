import { parseParameters, setParameter } from "./scad-parameters.js";

const SKIP_PARTS = new Set(["assembly", "layout", "fit_test"]);

function formatParamValue(parameter, value) {
  if (parameter.kind === "text") return JSON.stringify(String(value));
  if (parameter.kind === "boolean") {
    return value === true || value === "true" ? "true" : "false";
  }
  return String(value);
}

export function applyParameters(source, updates) {
  let next = source;
  for (const [name, value] of Object.entries(updates)) {
    const parameter = parseParameters(next).find((item) => item.name === name);
    if (!parameter) continue;
    next = setParameter(next, parameter, formatParamValue(parameter, value));
  }
  return next;
}

export function partParameter(parameters) {
  return parameters.find((parameter) => parameter.name === "part" && parameter.options?.some((option) => option.value === "assembly"));
}

export function hasAssemblyKit(source) {
  return Boolean(partParameter(parseParameters(source)));
}

function fileStem(part, extra) {
  const bits = [part];
  for (const [name, value] of Object.entries(extra)) bits.push(`${name}-${value}`);
  return bits.join("_").replace(/[^a-z0-9._-]+/gi, "-");
}

function parseKitToken(token) {
  const [part, ...rest] = token.split(";");
  if (!part || SKIP_PARTS.has(part)) return null;
  const extra = {};
  for (const bit of rest) {
    const eq = bit.indexOf("=");
    if (eq <= 0) continue;
    extra[bit.slice(0, eq)] = bit.slice(eq + 1);
  }
  return { part, extra, file: `${fileStem(part, extra)}.stl` };
}

export function kitFromLogs(logs) {
  const line = (logs || []).find((entry) => /assembly_kit\s*=/.test(entry));
  if (!line) return null;
  const tokens = [];
  const quoted = /"([^"]*)"/g;
  let match;
  while ((match = quoted.exec(line))) tokens.push(match[1]);
  const jobs = tokens.map(parseKitToken).filter(Boolean);
  return jobs.length ? jobs : null;
}

export function kitFromParameters(parameters) {
  const part = partParameter(parameters);
  if (!part) return [];
  return part.options
    .filter((option) => !SKIP_PARTS.has(option.value))
    .map((option) => ({ part: option.value, extra: {}, file: `${option.value}.stl` }));
}

export function probeSource(source, parameters) {
  const part = partParameter(parameters);
  const options = part?.options?.map((option) => option.value) || [];
  const probePart = options.includes("gasket") ? "gasket" : options.find((value) => !SKIP_PARTS.has(value));
  const updates = { fast_preview: true };
  if (probePart) updates.part = probePart;
  return applyParameters(source, updates);
}

export function jobSource(source, job) {
  return applyParameters(source, { fast_preview: false, part: job.part, ...job.extra });
}
