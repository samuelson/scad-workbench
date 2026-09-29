export type ScadParameter = {
  name: string;
  label: string;
  kind: "number" | "boolean" | "text";
  value: string;
  line: number;
  min?: number;
  max?: number;
  step?: number;
};

const assignment = /^(\s*)([A-Za-z_][A-Za-z_0-9]*)\s*=\s*(-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?|true|false|"(?:[^"\\]|\\.)*")\s*;(\s*(?:\/\/.*)?)$/;

export function parseParameters(source: string): ScadParameter[] {
  const result: ScadParameter[] = [];
  let depth = 0;
  let blockComment = false;
  source.split("\n").forEach((line, index) => {
    let active = "";
    for (let i = 0; i < line.length; i++) {
      if (blockComment) {
        if (line.slice(i, i + 2) === "*/") { blockComment = false; i++; }
      } else if (line.slice(i, i + 2) === "/*") { blockComment = true; i++; }
      else if (line.slice(i, i + 2) === "//") break;
      else active += line[i];
    }
    if (depth === 0) {
      const match = line.match(assignment);
      if (match && active.includes("=")) {
        const [, , name, value, suffix] = match;
        if (!name.startsWith("$")) {
          const kind = value === "true" || value === "false" ? "boolean" : value.startsWith('"') ? "text" : "number";
          const range = suffix.match(/\[\s*(-?\d+(?:\.\d+)?)\s*:\s*(?:(-?\d+(?:\.\d+)?)\s*:\s*)?(-?\d+(?:\.\d+)?)\s*\]/);
          result.push({ name, label: name.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase()), kind, value, line: index,
            ...(range ? { min: Number(range[1]), max: Number(range[3]), step: range[2] === undefined ? undefined : Number(range[2]) } : {}) });
        }
      }
    }
    depth = Math.max(0, depth + (active.match(/\{/g) || []).length - (active.match(/\}/g) || []).length);
  });
  return result;
}

export function setParameter(source: string, parameter: ScadParameter, value: string): string {
  const lines = source.split("\n");
  const match = lines[parameter.line]?.match(assignment);
  if (!match || match[2] !== parameter.name) return source;
  lines[parameter.line] = `${match[1]}${parameter.name} = ${value};${match[4]}`;
  return lines.join("\n");
}
