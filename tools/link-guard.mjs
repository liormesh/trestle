#!/usr/bin/env node
// Trestle hook - link guard (PostToolUse: Write | Edit | MultiEdit).
//
// After Claude writes a markdown file in your knowledge base, memory or skills, checks the
// links in the text it just wrote - relative markdown links and [[wikilinks]] - and reports
// any that point at nothing, with a did-you-mean suggestion.
//
// Why: the knowledge base only works if the brain can follow its pointers. A broken link is
// a silent dead end - nothing fails, Claude just never finds the file. Catching it on the
// write that created it costs nothing; finding twenty of them a month later costs a session.
//
// It never blocks (the write already happened). Exit 2 = feedback shown to Claude so it
// fixes the link in the same turn; exit 0 = all good.

import { loadConfig, readStdinJson, writtenText, extractLinks, resolveLink, buildIndex, inside, protectedRoots } from "./lib.mjs";

const input = await readStdinJson();
const file = input?.tool_input?.file_path;
if (!file || !file.toLowerCase().endsWith(".md")) process.exit(0);

const cfg = loadConfig();
if (!protectedRoots(cfg).some((r) => inside(file, r))) process.exit(0);

// Only the text just written - pre-existing breakage elsewhere in the file is /73's job.
const links = extractLinks(writtenText(input.tool_input));
if (links.length === 0) process.exit(0);

const index = buildIndex(cfg.kb_path);
const broken = [];
for (const l of links) {
  const r = resolveLink(l, file, cfg.kb_path, index);
  if (!r.ok) broken.push(`  ${l.raw}${r.suggestion ? `  -> did you mean ${r.suggestion}?` : ""}`);
}
if (broken.length === 0) process.exit(0);

process.stderr.write(
  `Trestle link guard: ${broken.length} link(s) in ${file} point at nothing:\n${broken.join("\n")}\n` +
    `Fix each to the real filename (markdown links are relative to the file's own folder; ` +
    `[[wikilinks]] resolve by filename anywhere in the vault).\n`
);
process.exit(2);
