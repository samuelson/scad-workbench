const numberLiteral = String.raw`-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?`;
const stringLiteral = String.raw`"(?:[^"\\]|\\.)*"`;
const vectorLiteral = String.raw`\[\s*${numberLiteral}\s*(?:,\s*${numberLiteral}\s*){0,3}\]`;
const assignment = new RegExp(
  String.raw`^(\s*)([A-Za-z_][A-Za-z_0-9]*)\s*=\s*(${numberLiteral}|true|false|${stringLiteral}|${vectorLiteral})\s*;(\s*(?://.*)?)`
);
const groupLine = /^\s*\/\*\s*\[([^\]]+)\]\s*\*\//;
const descriptionLine = /^\/\/(?![\/\*])\s*(.*)$/;

function isNumeric(part) {
  return part !== "" && Number.isFinite(Number(part));
}

function prettyName(name) {
  return name.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

function parseValue(raw) {
  if (raw === "true" || raw === "false") return { kind: "boolean", value: raw };
  if (raw.startsWith('"')) return { kind: "text", value: raw };
  if (raw.startsWith("[")) {
    const components = raw.slice(1, -1).split(",").map((part) => Number(part.trim()));
    return { kind: "vector", value: raw, components };
  }
  return { kind: "number", value: raw };
}

function labeledOption(part) {
  const colon = part.indexOf(":");
  if (colon <= 0) return { value: part, label: part };
  return {
    value: part.slice(0, colon).trim(),
    label: part.slice(colon + 1).trim() || part,
  };
}

function parseBracket(inner) {
  if (inner.includes(",")) {
    return {
      options: inner.split(",").map((part) => part.trim()).filter(Boolean).map(labeledOption),
    };
  }
  const bits = inner.split(":").map((part) => part.trim());
  if (bits.length >= 1 && bits.length <= 3 && bits.every(isNumeric)) {
    if (bits.length === 1) return { min: 0, max: Number(bits[0]), step: 1 };
    if (bits.length === 2) return { min: Number(bits[0]), max: Number(bits[1]), step: 1 };
    return { min: Number(bits[0]), step: Number(bits[1]), max: Number(bits[2]) };
  }
  return { options: [labeledOption(inner)] };
}

function parseWidget(suffix, kind) {
  const comment = suffix.replace(/^\s*\/\//, "").trim();
  if (!comment) return {};
  const bracket = comment.match(/\[([^\]]*)\]/);
  if (bracket) return parseBracket(bracket[1].trim());
  if (kind === "number" && /^[.]?\d+(?:\.\d+)?$/.test(comment)) return { step: Number(comment) };
  if (kind === "text" && /^\d+$/.test(comment)) return { maxLength: Number(comment) };
  return {};
}

function stripComments(line, blockComment) {
  let active = "";
  for (let i = 0; i < line.length; i++) {
    if (blockComment) {
      if (line.slice(i, i + 2) === "*/") { blockComment = false; i++; }
    } else if (line.slice(i, i + 2) === "/*") { blockComment = true; i++; }
    else if (line.slice(i, i + 2) === "//") break;
    else active += line[i];
  }
  return { active, blockComment };
}

export function parseParameters(source) {
  const result = [];
  let blockComment = false;
  let stopped = false;
  let group = "";
  let hidden = false;
  let pendingDescription = "";
  source.split("\n").forEach((line, index) => {
    if (stopped) return;
    const grouped = line.match(groupLine);
    if (grouped && !blockComment) {
      group = grouped[1].trim();
      hidden = group.toLowerCase() === "hidden";
      pendingDescription = "";
      ({ blockComment } = stripComments(line, blockComment));
      return;
    }
    const { active, blockComment: nextBlock } = stripComments(line, blockComment);
    blockComment = nextBlock;
    const desc = line.match(descriptionLine);
    const match = line.match(assignment);
    if (desc && !match) {
      pendingDescription = desc[1].trim();
      if (active.includes("{")) stopped = true;
      return;
    }
    if (match && active.includes("=") && !match[2].startsWith("$") && !hidden) {
      const parsed = parseValue(match[3]);
      const widget = parseWidget(match[4], parsed.kind);
      result.push({
        name: match[2],
        label: prettyName(match[2]),
        description: pendingDescription,
        group: group.toLowerCase() === "global" ? "" : group,
        kind: parsed.kind,
        value: parsed.value,
        line: index,
        ...(parsed.components ? { components: parsed.components } : {}),
        ...widget,
      });
    }
    pendingDescription = "";
    if (active.includes("{")) stopped = true;
  });
  return result;
}

export function setParameter(source, parameter, value) {
  const lines = source.split("\n");
  const match = lines[parameter.line]?.match(assignment);
  if (!match || match[2] !== parameter.name) return source;
  lines[parameter.line] = `${match[1]}${parameter.name} = ${value};${match[4]}`;
  return lines.join("\n");
}
