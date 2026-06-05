# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code skill for WeChat Official Account (微信公众号) content creation workflow. It covers the full lifecycle: topic discovery → research → writing → polishing → formatting → publishing → post-publish review.

This is **not** a traditional codebase with build/test commands. It's a skill definition that instructs AI agents how to help users create and publish WeChat articles.

## Architecture

**SKILL.md** is the entry point. It defines:
- Frontmatter metadata (name, description, triggers, allowed-tools)
- Intent routing (what to do based on user input)
- Two execution modes: 全自动 (unattended) vs 半自动 (interactive with confirmation checkpoints)
- The 9-step workflow overview with pointers to reference docs

**references/** contains detailed instructions for each workflow phase. SKILL.md points here when the agent needs specifics. Files use `wxmp-` prefix to avoid naming conflicts.

**scripts/** are shell scripts (curl + jq) for API interaction. All read config from `config/wxmp.json`. Key scripts:
- `wx-auth.sh` — token management with 2-hour cache in `/tmp/wxmp-token.json`
- `wx-upload-image.sh` — upload images to WeChat material system
- `wx-draft.sh` — create draft articles
- `wx-publish.sh` — publish with async status polling
- `wx-stats.sh` — daily summary stats (API limit: 1-day max per query, script auto-loops)
- `wx-articles.sh` — list published articles
- `wx-article-stats.sh` — per-article detailed stats (7-day max range)
- `wx-generate-image.sh` — Agnes AI image generation (文生图)

**templates/** contains 5 beautiful HTML templates with inline styles:
- `minimal-white.html` — clean, lots of whitespace (tutorials, guides)
- `magazine.html` — elegant, editorial style (deep articles, opinions)
- `dark-mode.html` — dark background, tech feel (tech, programming)
- `card-style.html` — modular cards, easy to scan (lists, roundups)
- `gradient.html` — colorful gradients, youthful (lifestyle, stories)

**templates/article.html** is the WeChat-compatible HTML template with inline styles (WeChat strips external CSS/JS).

## Key Constraints

- WeChat HTML content must use **inline styles only** — no `<link>`, `<style>`, `<script>`, `<iframe>`
- Images must be uploaded to WeChat's material system first (via `wx-upload-image.sh`), then referenced by CDN URL
- `access_token` expires every 2 hours; `wx-auth.sh` caches it in `/tmp/wxmp-token.json`
- Publishing is async — `wx-publish.sh` polls status until complete
- Daily publish limits: subscription accounts (订阅号) 1/day, service accounts (服务号) 4/day
- Stats APIs have time span limits: `getarticlesummary` max 1 day, `getarticletotal` max 7 days
- Stats data has ~1 day delay (can't query today's data until tomorrow)

## Configuration

```bash
cp config/wxmp.example.json config/wxmp.json  # then fill in AppID + Secret + Agnes API Key
```

The config file contains secrets and is gitignored. Required fields:
- `appid` / `secret` — WeChat Official Account API credentials
- `agnes_api_key` — Agnes AI API key for image generation (optional)

## Modifying the Skill

When editing SKILL.md or reference files:
- Keep SKILL.md under 500 lines; detailed content goes in references/
- Follow the existing frontmatter format (preamble-tier, version, description, triggers, allowed-tools)
- Reference files should be self-contained — the agent reads them independently
- Use imperative form in instructions, explain the "why" not just the "what"
