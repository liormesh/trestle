// Trestle tools - shared helpers (no dependencies, Node 18+, macOS / Linux / Windows).
// Used by secret-guard.mjs, link-guard.mjs and kb-check.mjs.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const TOOLS_DIR = path.dirname(fileURLToPath(import.meta.url));
export const CONFIG_PATH = path.join(os.homedir(), ".claude", "trestle", "config.json");

// ---------- config ----------
// Written by /onboard: { kb_path, memory_path, workspace_version, installed }
export function loadConfig() {
  let cfg = {};
  try { cfg = JSON.parse(fs.readFileSync(CONFIG_PATH, "utf8")); } catch { /* pre-1.8 workspace or not onboarded */ }
  const kb = process.env.TRESTLE_KB || cfg.kb_path || path.join(os.homedir(), "Documents", "knowledge-base");
  const memory = cfg.memory_path || path.join(kb, "claude-memory");
  return { ...cfg, kb_path: expand(kb), memory_path: expand(memory), hasConfig: Object.keys(cfg).length > 0 };
}

export function toolsVersion() {
  try { return fs.readFileSync(path.join(TOOLS_DIR, "VERSION"), "utf8").trim(); } catch { return "unknown"; }
}

export function expand(p) {
  if (!p) return p;
  return p.startsWith("~") ? path.join(os.homedir(), p.slice(1)) : p;
}

// realpath that also works for a file that does not exist yet (a hook sees the path
// before the write): resolve the deepest existing parent, then re-append the rest.
export function real(p) {
  let cur = path.resolve(p);
  const tail = [];
  for (;;) {
    try { return path.join(fs.realpathSync(cur), ...tail.reverse()); } catch { /* walk up */ }
    const parent = path.dirname(cur);
    if (parent === cur) return path.resolve(p);
    tail.push(path.basename(cur));
    cur = parent;
  }
}

// Is `file` inside `dir`? (both resolved through symlinks)
export function inside(file, dir) {
  if (!dir) return false;
  const rel = path.relative(real(dir), real(file));
  return rel === "" || (!rel.startsWith("..") && !path.isAbsolute(rel));
}

// ---------- secrets ----------
// Shapes of live credentials. Matching is deliberately conservative: a false positive
// blocks a write (annoying), a false negative leaks a key into git history (expensive).
export const SECRET_RE = new RegExp(
  [
    "sk-ant-[A-Za-z0-9_-]{20,}",            // Anthropic
    "sk-(?:proj-)?[A-Za-z0-9_-]{32,}",       // OpenAI
    "ghp_[A-Za-z0-9]{30,}", "github_pat_[A-Za-z0-9_]{30,}", "glpat-[A-Za-z0-9_-]{20,}",
    "xox[baprs]-[A-Za-z0-9-]{10,}",          // Slack
    "AKIA[0-9A-Z]{16}",                      // AWS access key id
    "AIza[0-9A-Za-z_-]{30,}",                // Google API key
    "eyJ[A-Za-z0-9_-]{30,}\\.[A-Za-z0-9_-]{20,}\\.[A-Za-z0-9_-]{10,}", // JWT (e.g. Supabase service key)
    "whsec_[A-Za-z0-9]{20,}", "[sr]k_live_[A-Za-z0-9]{20,}",         // Stripe
    "sbp_[A-Za-z0-9]{20,}", "npm_[A-Za-z0-9]{30,}",
    "postgres(?:ql)?://[^:/\\s]+:[^@\\s]{6,}@", // connection string with a password
    "\\b[0-9]{8,10}:AA[A-Za-z0-9_-]{30,}",   // Telegram bot token
    "-----BEGIN [A-Z ]*PRIVATE KEY-----",
  ].join("|"),
  "g"
);

export function findSecrets(text) {
  return [...String(text || "").matchAll(SECRET_RE)].map((m) => m[0]);
}

export function mask(v) {
  return `${v.slice(0, 6)}...(${v.length} chars)`;
}

// ---------- markdown ----------
export function stripCode(text) {
  // drop fenced blocks and inline code so example links in code are not checked
  return text.replace(/```[\s\S]*?```/g, "").replace(/~~~[\s\S]*?~~~/g, "").replace(/`[^`\n]*`/g, "");
}

// Returns [{kind: "md"|"wiki", target, raw}]
export function extractLinks(text) {
  const out = [];
  const t = stripCode(text);
  for (const m of t.matchAll(/!?\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)) {
    const target = m[1];
    if (/^(https?:|mailto:|tel:|#|data:|\/|[A-Za-z]:\\)/.test(target)) continue;
    if (/[{}$<>]/.test(target)) continue; // template placeholders
    out.push({ kind: "md", target, raw: m[0] });
  }
  for (const m of t.matchAll(/!?\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]/g)) {
    const target = m[1].trim();
    if (!target || /[{}$<>]/.test(target)) continue;
    out.push({ kind: "wiki", target, raw: m[0] });
  }
  return out;
}

// Frontmatter -> { keys: {k: v}, nestedType, ok }
export function frontmatter(text) {
  if (!text.startsWith("---")) return { ok: false, keys: {} };
  const end = text.indexOf("\n---", 3);
  if (end < 0) return { ok: false, keys: {} };
  const keys = {};
  let parent = null;
  for (const line of text.slice(3, end).split("\n")) {
    const top = line.match(/^([A-Za-z_][\w-]*):\s*(.*)$/);
    if (top) { parent = top[1]; keys[top[1]] = top[2].replace(/^["']|["']$/g, ""); continue; }
    const sub = line.match(/^\s+([A-Za-z_][\w-]*):\s*(.*)$/);
    if (sub && parent) keys[`${parent}.${sub[1]}`] = sub[2].replace(/^["']|["']$/g, "");
  }
  return { ok: true, keys };
}

// ---------- vault walk ----------
const SKIP_DIRS = new Set([".git", "node_modules", ".obsidian", ".trash", "_private", ".DS_Store"]);

// Walks the vault, following the claude-memory / claude-skills symlinks once.
export function walk(root, { onFile } = {}) {
  const seen = new Set();
  const files = [];
  const visit = (dir, relDir) => {
    const r = real(dir);
    if (seen.has(r)) return;
    seen.add(r);
    let entries = [];
    try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
    for (const e of entries) {
      if (SKIP_DIRS.has(e.name) || /\.bak\.\d+$/.test(e.name)) continue;
      const abs = path.join(dir, e.name);
      const rel = relDir ? `${relDir}/${e.name}` : e.name;
      let isDir = e.isDirectory();
      let isFile = e.isFile();
      if (e.isSymbolicLink()) {
        try { const st = fs.statSync(abs); isDir = st.isDirectory(); isFile = st.isFile(); } catch { continue; }
      }
      if (isDir) visit(abs, rel);
      else if (isFile) { files.push({ abs, rel }); onFile && onFile(abs, rel); }
    }
  };
  visit(root, "");
  return files;
}

// Index of every file in the vault by lowercase basename (with and without .md),
// for wikilink resolution and did-you-mean suggestions.
export function buildIndex(kb) {
  const files = walk(kb);
  const byBase = new Map();
  const relSet = new Set();
  for (const f of files) {
    relSet.add(f.rel.toLowerCase());
    const b = path.basename(f.rel).toLowerCase();
    for (const key of [b, b.replace(/\.md$/, "")]) {
      if (!byBase.has(key)) byBase.set(key, []);
      byBase.get(key).push(f.rel);
    }
  }
  return { files, byBase, relSet };
}

// Does a link from `fileAbs` resolve? Returns { ok, suggestion }
export function resolveLink(link, fileAbs, kb, index) {
  if (link.kind === "md") {
    let target = link.target.split("#")[0];
    try { target = decodeURIComponent(target); } catch { /* keep raw */ }
    if (!target) return { ok: true };
    const abs = path.resolve(path.dirname(fileAbs), target);
    if (fs.existsSync(abs)) return { ok: true };
    return { ok: false, suggestion: suggest(path.basename(target), index) };
  }
  // wikilink: vault-root path, or unique-ish basename anywhere
  const t = link.target.toLowerCase();
  const withMd = /\.[a-z0-9]{2,4}$/.test(t) ? t : `${t}.md`;
  if (index.relSet.has(withMd) || index.relSet.has(t)) return { ok: true };
  const base = path.basename(withMd);
  if (index.byBase.has(base) || index.byBase.has(path.basename(t))) return { ok: true };
  return { ok: false, suggestion: suggest(base, index) };
}

function suggest(base, index) {
  const stem = base.toLowerCase().replace(/\.md$/, "").replace(/[_\s]/g, "-");
  if (index.byBase.has(stem)) return index.byBase.get(stem)[0];
  const words = stem.split("-").filter((w) => w.length > 3);
  let best = null, bestScore = 0;
  for (const [key, rels] of index.byBase) {
    if (!key.endsWith(".md")) continue;
    const score = words.filter((w) => key.includes(w)).length;
    if (score > bestScore) { bestScore = score; best = rels[0]; }
  }
  if (words.length && bestScore === words.length) return best; // every significant word matches
  // typo fallback: closest stem within edit distance 2
  for (const [key, rels] of index.byBase) {
    if (key.endsWith(".md") || Math.abs(key.length - stem.length) > 2) continue;
    if (editDistance(key, stem) <= 2) return rels[0];
  }
  return null;
}

function editDistance(a, b) {
  const row = Array.from({ length: b.length + 1 }, (_, i) => i);
  for (let i = 1; i <= a.length; i++) {
    let prev = row[0];
    row[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const tmp = row[j];
      row[j] = Math.min(row[j] + 1, row[j - 1] + 1, prev + (a[i - 1] === b[j - 1] ? 0 : 1));
      prev = tmp;
    }
  }
  return row[b.length];
}

// ---------- hook I/O ----------
export async function readStdinJson() {
  const chunks = [];
  for await (const c of process.stdin) chunks.push(c);
  try { return JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}"); } catch { return {}; }
}

// Text a Write / Edit / MultiEdit / NotebookEdit call is about to put on disk.
export function writtenText(toolInput = {}) {
  const parts = [];
  if (typeof toolInput.content === "string") parts.push(toolInput.content);
  if (typeof toolInput.new_string === "string") parts.push(toolInput.new_string);
  if (Array.isArray(toolInput.edits)) for (const e of toolInput.edits) if (e && typeof e.new_string === "string") parts.push(e.new_string);
  if (typeof toolInput.new_source === "string") parts.push(toolInput.new_source);
  return parts.join("\n");
}

export function protectedRoots(cfg) {
  return [cfg.kb_path, cfg.memory_path, path.join(os.homedir(), ".claude", "skills")].filter(Boolean);
}
