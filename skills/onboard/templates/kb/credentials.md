# Credentials

> This file is .gitignore'd and never leaves your machine.
> Store API keys, tokens, and passwords here.
> Claude can read this file to deploy and manage your services - a convenience with a real blast radius. Anything you put here, Claude can act on. Add only what you need it to use; keep the rest out.
> **If a key ever lands in a tracked file and gets committed, treat it as exposed:** gitignoring or deleting it later does not remove it from git history. Rotate the key at the provider, then (optionally) rewrite history. The Trestle secret guard blocks most of these writes before they happen.
> Keys that touch production or money are better kept in a real secret manager (1Password, Bitwarden, your cloud's secret store) - this file is for local development keys.

## Template
```
SERVICE_NAME:
  url: https://...
  api_key: xxx
  notes: what this is for
```
