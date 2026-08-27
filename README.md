<p align="center">
  <img src="assets/ghostwriter.png" alt="Ghostwriter" width="200" />
</p>

<p align="center">
  <a href="https://skills.sh/an2n/ghostwriter"><img src="https://skills.sh/b/an2n/ghostwriter" alt="skills.sh installs" /></a>
</p>

# Ghostwriter

> A ghostwriter is a professional writer hired to draft or edit literary works, articles,
> or speeches that are published under another person's name.

An agent skill set that writes text in your own voice instead of generic AI prose, with a
check and polish pass built into the pipeline. Works with Claude Code, Codex CLI, ChatGPT
desktop, OpenCode, and any other agent that reads skills off the filesystem.

## Installing

```bash
npx skills add an2n/ghostwriter --full-depth --all
```

`--full-depth` is required since this repo has three skills nested under `skills/*/`
rather than a single `SKILL.md` at the root. Drop `--all` to pick specific skills or
agents interactively, or add `-g` for a global (user-level) install instead of
project-level. See `npx skills --help` for the full option set.

Restart your agent (or start a new session) and the three skills are available - try
`/ghost` (Claude Code), or just say "rewrite this in my voice" with some text.

For agents without filesystem-based skill folders (ChatGPT web, Gemini, Cursor, Aider),
there's nothing to install - paste the contents of `skills/ghost/SKILL.md` (and the
other two, if you want the full pipeline) directly into the conversation.

**As a Claude Code plugin:**

```
/plugin marketplace add an2n/ghostwriter
/plugin install ghostwriter@ghostwriter
```

Installed this way, Claude Code namespaces skills by plugin name, so `ghost`, `check`, and
`polish` show up as `ghostwriter:ghost`, `ghostwriter:check`, and `ghostwriter:polish` -
same skills, just addressed through the plugin name.

**As a Codex CLI plugin:**

```
/plugins
```

Add `an2n/ghostwriter` as a marketplace from the plugin browser, then install `ghostwriter`
from it. Start a new session afterward for the bundled skills to load.

## What's in here

Three skills, each with one job:

- **`ghost`** — the orchestrator. Loads your voice profile, runs the pipeline below,
  and drafts the actual rewrite.
- **`check`** — find-only. Scores a piece of text across four tell clusters (word
  choice, rhythm, document shape, voice and construction) and returns a verdict from
  "reads human" to "heavily AI" based on weighted tell density. Never rewrites anything.
- **`polish`** — rewrite-only. Applies six moves (word choice, sentence rhythm, cutting
  padding and imposed structure, anchoring specifics, letting a voice through,
  punctuation) to move text in the human direction. Never scores anything.

`ghost` is the one you actually invoke. `check` and `polish` are also directly
callable on their own if you just want a score or just want a cleanup pass without the
voice-profile layer.

## How the pipeline works

Say "rewrite this", "write this better", "reply to this", "in my voice", or invoke
`/ghost` with text:

1. **Load the voice profile** from `~/.claude/ghostwriter-profile.md` (see below). If it
   doesn't exist yet, it asks once for 2-3 writing samples and builds one.
2. **Check the input** — if there's existing text to rewrite, `check` runs on it first
   to find out what's actually wrong, so the rewrite targets real problems instead of
   applying every move blindly.
3. **Clean** — `polish` runs the hygiene pass, directed by what the check found.
4. **Apply the voice profile** on top, overriding `polish`'s generic defaults wherever
   they conflict with how you actually write.
5. **Verify the output** — `check` runs again on the draft. If it doesn't read as human
   or mostly human, the pipeline goes back to `polish` and redrafts, capped at two
   cycles.
6. **Return the text**, with a one-line plain-text status after each step as it happens
   (no leading symbols, no emoji, no batching everything at the end) — never the full
   `check` report inline.

A clean `check` result means no known rule-based pattern fired. It is **not** proof the
text would pass a real trained classifier (Pangram, GPTZero) — `check` is a self-graded
rubric, not a substitute for one.

## The voice profile

`ghost` needs `~/.claude/ghostwriter-profile.md` to know what "your voice" actually
means. This file is personal, machine-local data — it never lives in this repo or gets
committed anywhere. It's built once from 2-3 real writing samples (a LinkedIn post, an
email, a Slack message — whatever's natural) and covers sentence shape, real vocabulary,
punctuation habits, and register range across the contexts you actually write in.

If the profile drifts from how you actually write (you keep correcting the same thing),
`ghost` will offer to update it — never silently, and never off a single correction.

## Attribution

`polish` and `check` build on the functional idea of pairing a multi-category
AI-detection scorer with a matching multi-lever rewrite pass, an approach explored by the
[humanize](https://github.com/harshaneel/humanize) project by Harshaneel Gokhale (MIT
License) and, for the underlying pattern knowledge, by Wikipedia's ["Signs of AI
writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) (CC BY-SA 4.0,
maintained by WikiProject AI Cleanup) and the
[humanizer](https://github.com/blader/humanizer) skill (MIT) that also draws on it. The
clustering scheme, scoring mechanic, rewrite protocol, and wording in both skills here are
their own, rewritten to be independent of any one source's specific structure or
phrasing rather than a copy of it.

This repo is MIT licensed (see `LICENSE`).
