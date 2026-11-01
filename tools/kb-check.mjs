#!/usr/bin/env node
// Trestle - workspace health check. `/73` runs it as step 0; you can run it any time:
//
//   node ~/.claude/trestle/kb-check.mjs              session check (files touched in the last 8h)
//   node ~/.claude/trestle/kb-check.mjs --hours 24   wider session window
//   node ~/.claude/trestle/kb-check.mjs --usage 30   skill usage from _analytics/usage.log (last N days)
//
// Read-only except one file: `_analytics/baseline.json` (the ratchet). Prints one line per
// check, `OK` or `WARN - ...`, followed by the offending files. Exit 0 = all OK, 1 = a WARN.
//
// The idea behind it: rules written in memory get forgotten; a check that fails at the end
// of every session does not. Each WARN is a defect from this session, fixed before signing off.
// The ratchet makes the whole vault monotonic: a vault-wide count (broken links, unindexed
// memory, ...) may go down, never up.

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import {
  loadConfig, toolsVersion, walk, buildIndex, extractLinks, resolveLink, frontmatter,
  findSecrets, mask, inside,
} from "./lib.mjs";

const args = process.argv.slice(2);
const argVal = (flag, dflt) => { const i = args.indexOf(flag); return i >= 0 && args[i + 1] ? args[i + 1] : dflt; };
const HOURS = Number(argVal("--hours", process.env.SESSION_HOURS || 8));
const cfg = loadConfig();
const KB = cfg.kb_path;
const MEM = cfg.memory_path;

if (!fs.existsSync(KB)) {
  console.log(`CHECK: no knowledge base at ${KB} (set TRESTLE_KB or run /onboard)`);
  process.exit(2);
}

const USAGE_LOG = path.join(KB, "_analytics", "usage.log");
const USAGE_RE = /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z) (\S+)(?: (.*))?$/;

// ---------- --usage mode ----------
if (args.includes("--usage")) {
  const days = Number(argVal("--usage", 30)) || 30;
  const since = Date.now() - days * 864e5;
  const counts = new Map();
  let bad = 0;
  const lines = fs.existsSync(USAGE_LOG) ? fs.readFileSync(USAGE_LOG, "utf8").split("\n").filter(Boolean) : [];
  for (const l of lines) {
    const m = l.match(USAGE_RE);
    if (!m) { bad++; continue; }
    if (Date.parse(m[1]) >= since) counts.set(m[2], (counts.get(m[2]) || 0) + 1);
  }
  const skillsDir = path.join(KB, "claude-skills");
  const installed = fs.existsSync(skillsDir)
    ? fs.readdirSync(skillsDir).filter((d) => fs.existsSync(path.join(skillsDir, d, "SKILL.md")))
    : [];
  console.log(`USAGE: last ${days} days, ${lines.length} log lines${bad ? `, ${bad} malformed (expected: <ISO-UTC> <skill> <note>)` : ""}`);
  for (const [k, v] of [...counts].sort((a, b) => b[1] - a[1])) console.log(`  ${String(v).padStart(4)}  ${k}`);
  const unused = installed.filter((s) => !counts.has(s) && s !== "onboard");
  if (unused.length) console.log(`UNUSED (${days}d): ${unused.join(", ")}  - dead weight, or a description that never triggers?`);
  process.exit(0);
}

// ---------- gather ----------
let warn = false;
const say = (l) => console.log(l);
const bad = (l, items = []) => { warn = true; console.log(l); for (const i of items.slice(0, 15)) console.log(`  ${i}`); if (items.length > 15) console.log(`  ... and ${items.length - 15} more`); };

const index = buildIndex(KB);
const cutoff = Date.now() - HOURS * 3600e3;
const mdFiles = index.files.filter((f) => f.rel.toLowerCase().endsWith(".md"));
const touched = mdFiles.filter((f) => { try { return fs.statSync(f.abs).mtimeMs >= cutoff; } catch { return false; } });
const isMemory = (f) => inside(f.abs, MEM) && !/^MEMORY/i.test(path.basename(f.abs));
const memoryFiles = mdFiles.filter(isMemory);
const read = (abs) => { try { return fs.readFileSync(abs, "utf8"); } catch { return ""; } };

const memoryIndexText = ["MEMORY.md", "MEMORY-extended.md"].map((n) => read(path.join(MEM, n))).join("\n");

// ---------- per-file checks (run vault-wide for the ratchet; reported for touched files) ----------
function brokenLinks(f) {
  return extractLinks(read(f.abs)).filter((l) => !resolveLink(l, f.abs, KB, index).ok).map((l) => `${f.rel}: ${l.raw}`);
}
function memoryFrontmatterIssues(f) {
  const fm = frontmatter(read(f.abs));
  const stem = path.basename(f.abs, ".md");
  const issues = [];
  if (!fm.ok) return [`${f.rel}: no frontmatter`];
  const type = fm.keys.type || fm.keys["metadata.type"];
  if (!fm.keys.name) issues.push(`${f.rel}: no name`);
  else if (fm.keys.name !== stem) issues.push(`${f.rel}: name "${fm.keys.name}" != filename "${stem}"`);
  if (!fm.keys.description) issues.push(`${f.rel}: no description`);
  if (!type) issues.push(`${f.rel}: no type`);
  if (stem.includes("_")) issues.push(`${f.rel}: underscore filename (convention: <type>-<slug>.md, kebab-case)`);
  return issues;
}
function unindexed(f) {
  const stem = path.basename(f.abs, ".md");
  return memoryIndexText.includes(stem) ? [] : [f.rel];
}
function paraIssues(f) {
  if (!/^projects\//.test(f.rel)) return [];
  const fm = frontmatter(read(f.abs));
  const isOverview = path.basename(f.rel) === "overview.md" && f.rel.split("/").length === 3;
  const st = fm.keys?.state;
  if (!isOverview) return st ? [`${f.rel}: state: on a sub-doc (state lives only on the project's overview.md)`] : [];
  if (!st) return [`${f.rel}: no state: (project | area | archive | icebox)`];
  const out = [];
  if (!["project", "area", "archive", "icebox"].includes(st)) out.push(`${f.rel}: non-canonical state "${st}"`);
  if (!fm.keys.state_changed) out.push(`${f.rel}: no state_changed: date`);
  return out;
}
function secretsIn(f) {
  return findSecrets(read(f.abs)).map((s) => `${f.rel}: ${mask(s)}`);
}

const scan = (files, fn) => files.flatMap(fn);

// ---------- session checks ----------
say(`SCOPE: ${touched.length} md files touched in the last ${HOURS}h (wider: --hours N)`);

const linkHits = scan(touched, brokenLinks);
linkHits.length ? bad(`LINKS: WARN - ${linkHits.length} broken link(s) in touched files:`, linkHits) : say("LINKS: OK");

const secretHits = scan(touched, secretsIn);
secretHits.length ? bad("SECRETS: WARN - credential-shaped values in touched files (move to _private/, then ROTATE if already committed):", secretHits) : say("SECRETS: OK");

const touchedMem = touched.filter(isMemory);
const fmHits = scan(touchedMem, memoryFrontmatterIssues);
fmHits.length ? bad("FRONTMATTER: WARN - memory files need name (= filename) / description / type:", fmHits) : say("FRONTMATTER: OK");

const idxHits = scan(touchedMem, unindexed);
idxHits.length ? bad("MEMORY-INDEX: WARN - memory files no line in MEMORY.md / MEMORY-extended.md points to (they can never be recalled):", idxHits) : say("MEMORY-INDEX: OK");

const paraHits = scan(touched, paraIssues);
paraHits.length ? bad("PARA-STATE: WARN:", paraHits) : say("PARA-STATE: OK");

// MEMORY.md: size and volatility (the hot layer)
const memLines = read(path.join(MEM, "MEMORY.md")).split("\n");
const memCount = memLines.filter((l) => l.trim()).length;
const datedLines = memLines.filter((l) => /\b20\d\d-\d\d-\d\d\b|\bas of\b|\bthis week\b/i.test(l)).length;
if (memCount > 100) bad(`MEMORY-SIZE: WARN - MEMORY.md has ${memCount} lines (smell test ~100): move detail to MEMORY-extended.md or the project doc`);
else say(`MEMORY-SIZE: OK (${memCount} lines${datedLines ? `, ${datedLines} carry dates or "as of" - live status belongs in the handoff doc, not the index` : ""})`);

// stale projects: a `project` is supposed to finish. One that has not moved in 45 days is a decision nobody made.
const stale = [];
for (const f of mdFiles.filter((f) => /^projects\/[^/]+\/overview\.md$/.test(f.rel))) {
  const k = frontmatter(read(f.abs)).keys;
  if (k.state === "project" && k.state_changed && Date.now() - Date.parse(k.state_changed) > 45 * 864e5) stale.push(`${f.rel} (state_changed ${k.state_changed})`);
}
stale.length ? say(`STALE: ${stale.length} project(s) marked "project" with no state change in 45+ days - name the next finish line or demote to area/archive:\n${stale.map((s) => `  ${s}`).join("\n")}`) : say("STALE: OK");

// memory decay sweep: ritual-attached, not calendar-attached. Logged as a `memory-sweep` line in usage.log.
const usage = read(USAGE_LOG).split("\n").filter(Boolean);
const lastSweep = usage.map((l) => l.match(USAGE_RE)).filter((m) => m && m[2] === "memory-sweep").map((m) => Date.parse(m[1])).sort().pop();
const since = lastSweep || (cfg.installed ? Date.parse(cfg.installed) : null);
const days = since ? Math.floor((Date.now() - since) / 864e5) : null;
if (days !== null && days > 30) say(`SWEEP: OVERDUE - ${lastSweep ? `last memory sweep ${days} days ago` : `no sweep logged in ${days} days`} (add "run the memory sweep" to the action items; see feedback-memory-decay.md)`);
else say(`SWEEP: OK${days !== null ? ` (${days} days since ${lastSweep ? "last sweep" : "install"})` : ""}`);

const malformed = usage.filter((l) => !USAGE_RE.test(l)).length;
malformed ? say(`ANALYTICS: ${malformed} usage.log line(s) not in the "<ISO-UTC> <skill> <note>" format - the sweep can't count them`) : say("ANALYTICS: OK");

// sync: only meaningful if the KB is a git repo
if (fs.existsSync(path.join(KB, ".git"))) {
  const git = (...a) => { try { return execFileSync("git", ["-C", KB, ...a], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim(); } catch { return null; } };
  const dirty = (git("status", "--porcelain") || "").split("\n").filter(Boolean).length;
  const ahead = git("rev-list", "--count", "@{u}..HEAD");
  if (dirty) bad(`SYNC: WARN - ${dirty} uncommitted change(s) in the KB (commit + push before ending, or nothing reaches your backup)`);
  else if (ahead && ahead !== "0") bad(`SYNC: WARN - ${ahead} commit(s) not pushed`);
  else say(`SYNC: OK${ahead === null ? " (no upstream set - the KB is not backed up anywhere)" : ""}`);
} else {
  say("SYNC: KB is not a git repo - no history, no backup (see the onboarding summary to set one up, private)");
}

// ---------- ratchet: vault-wide counters may fall, never rise ----------
const big = index.files.filter((f) => { try { return !f.rel.endsWith(".md") && fs.statSync(f.abs).size > 1e6; } catch { return false; } });
const counters = {
  broken_links: scan(mdFiles, brokenLinks).length,
  secrets_in_files: scan(mdFiles, secretsIn).length,
  memory_frontmatter_issues: scan(memoryFiles, memoryFrontmatterIssues).length,
  memory_unindexed: scan(memoryFiles, unindexed).length,
  para_issues: scan(mdFiles, paraIssues).length,
  memory_dated_lines: datedLines,
  large_binaries: big.length,
};
const BASELINE = path.join(KB, "_analytics", "baseline.json");
let base = null;
try { base = JSON.parse(read(BASELINE)); } catch { /* first run */ }
if (!base) {
  fs.mkdirSync(path.dirname(BASELINE), { recursive: true });
  fs.writeFileSync(BASELINE, JSON.stringify(counters, null, 2) + "\n");
  say(`RATCHET: baseline created (${Object.entries(counters).map(([k, v]) => `${k}=${v}`).join(", ")})`);
} else {
  const rose = Object.keys(counters).filter((k) => base[k] !== undefined && counters[k] > base[k]);
  const fell = Object.keys(counters).filter((k) => base[k] === undefined || counters[k] < base[k]);
  if (rose.length) bad(`RATCHET: WARN - vault-wide count went up: ${rose.map((k) => `${k} ${base[k]} -> ${counters[k]}`).join(", ")} (fix it, or it becomes the new normal)`);
  else {
    if (fell.length) {
      const next = { ...base };
      for (const k of fell) next[k] = counters[k];
      fs.writeFileSync(BASELINE, JSON.stringify(next, null, 2) + "\n");
    }
    say(`RATCHET: OK${fell.length ? ` (tightened: ${fell.map((k) => `${k}=${counters[k]}`).join(", ")})` : ""}`);
  }
}

// ---------- framework version ----------
const tv = toolsVersion();
if (!cfg.hasConfig) say(`UPGRADE: this workspace predates Trestle v1.8 (no ~/.claude/trestle/config.json) - run /onboard and pick (d) to update the framework`);
else if (cfg.workspace_version && tv !== "unknown" && cfg.workspace_version !== tv) say(`UPGRADE: tools are v${tv}, workspace rules are v${cfg.workspace_version} - run /onboard and pick (d)`);
else say(`VERSION: v${tv}`);

process.exit(warn ? 1 : 0);
