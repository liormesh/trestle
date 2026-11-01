#!/usr/bin/env node
// Trestle hook - secret guard (PreToolUse: Write | Edit | MultiEdit | NotebookEdit).
//
// Blocks a write into your knowledge base, memory or skills when the text contains a
// credential-shaped value (API key, token, private key, password-bearing connection string).
// `_private/` is exempt - that is where credentials are supposed to live.
//
// Why: once a key lands in a tracked file and gets committed, gitignoring or deleting it
// later does not remove it from git history. The only real fix after that is rotating the
// key. Stopping it at write time is cheap; cleaning it up later is not.
//
// Honest scope: this is a seatbelt. It sees file writes made through Claude's edit tools,
// not text written by a shell command (echo / sed / heredoc). Exit 2 = block, with the
// reason shown to Claude so it can reroute the value to _private/credentials.md.

import path from "node:path";
import { loadConfig, readStdinJson, writtenText, findSecrets, mask, inside, protectedRoots } from "./lib.mjs";

const input = await readStdinJson();
const file = input?.tool_input?.file_path || input?.tool_input?.notebook_path;
if (!file) process.exit(0);

const cfg = loadConfig();
const roots = protectedRoots(cfg);
if (!roots.some((r) => inside(file, r))) process.exit(0);
if (file.split(path.sep).includes("_private") || file.split("/").includes("_private")) process.exit(0);

const hits = findSecrets(writtenText(input.tool_input));
if (hits.length === 0) process.exit(0);

process.stderr.write(
  `Trestle secret guard: blocked a write to ${file}.\n` +
    `It contains ${hits.length} credential-shaped value(s): ${hits.slice(0, 3).map(mask).join(", ")}.\n` +
    `Put the value in _private/credentials.md (git-ignored) or an environment variable, and write a pointer here instead ` +
    `(e.g. "key: see _private/credentials.md > Stripe"). If this is a false positive (an example or a revoked key), ` +
    `rewrite it so it is visibly fake (sk-ant-XXXX...).\n`
);
process.exit(2);
