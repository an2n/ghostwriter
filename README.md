<p align="center">
  <img src="https://github.com/user-attachments/assets/3047988f-337b-4a2c-a3f1-3adcd3fab890" alt="Ghostwriter" />
</p>

# Ghostwriter

A Claude Code plugin that writes text in your own voice instead of generic AI prose, 
with an ai clean and check built into the pipeline.

## What's in here

Three skills, each with one job:

- **`ghostwriter`** — the orchestrator. Loads your voice profile, runs the pipeline below,
  and drafts the actual rewrite.
- **`ai-check`** — find-only. Scores a piece of text across nine detection signals
  (perplexity, burstiness, hedge density, structural tells, specificity, transitions,
  punctuation, voice/register, rhetorical scaffolding) and returns a verdict and a score out
  of 27. Never rewrites anything.
- **`ai-clean`** — rewrite-only. Applies nine hygiene levers (word choice, sentence-length
  variance, hedge removal, structural flattening, specificity, voice, transitions,
  punctuation, RLHF-voice stripping) to move text in the human direction. Never scores
  anything.

`ghostwriter` is the one you actually invoke. `ai-check` and `ai-clean` are also directly
callable on their own if you just want a score or just want a cleanup pass without the
voice-profile layer.

## How the pipeline works

Say "rewrite this", "write this better", "reply to this", "in my voice", or invoke
`/ghostwriter` with text:

1. **Load the voice profile** from `~/.claude/ghostwriter-profile.md` (see below). If it
   doesn't exist yet, it asks once for 2-3 writing samples and builds one.
2. **Check the input** — if there's existing text to rewrite, `ai-check` runs on it first
   to find out what's actually wrong, so the rewrite targets real problems instead of
   applying every lever blindly.
3. **Clean** — `ai-clean` runs the hygiene pass, directed by what the check found.
4. **Apply the voice profile** on top, overriding `ai-clean`'s generic defaults wherever
   they conflict with how you actually write.
5. **Verify the output** — `ai-check` runs again on the draft. If it's not Human or Likely
   Human, the pipeline goes back to `ai-clean` and redrafts, capped at two cycles.
6. **Return the text**, with a one-line plain-text status after each step as it happens
   (no leading symbols, no emoji, no batching everything at the end) — never the full
   `ai-check` report inline.

A clean `ai-check` result means no known rule-based pattern fired. It is **not** proof the
text would pass a real trained classifier (Pangram, GPTZero) — `ai-check` is a self-graded
rubric, not a substitute for one.

## The voice profile

`ghostwriter` needs `~/.claude/ghostwriter-profile.md` to know what "your voice" actually
means. This file is personal, machine-local data — it never lives in this repo or gets
committed anywhere. It's built once from 2-3 real writing samples (a LinkedIn post, an
email, a Slack message — whatever's natural) and covers sentence shape, real vocabulary,
punctuation habits, and register range across the contexts you actually write in.

If the profile drifts from how you actually write (you keep correcting the same thing),
`ghostwriter` will offer to update it — never silently, and never off a single correction.

## Installing

**Quick local setup (no plugin system):**

```bash
git clone https://github.com/an2n/ghostwriter.git ghostwriter
cp -r ghostwriter/skills/ghostwriter ~/.claude/skills/ghostwriter
cp -r ghostwriter/skills/ai-check ~/.claude/skills/ai-check
cp -r ghostwriter/skills/ai-clean ~/.claude/skills/ai-clean
```

Restart Claude Code (or start a new session) and the three skills are available - try
`/ghostwriter`, or say "rewrite this in my voice" with some text.

**As an installed plugin:** point Claude Code's plugin/marketplace mechanism at this repo.
Skill discovery is declared in `.claude-plugin/plugin.json` (`"skills": "./skills"`), so
once the plugin is installed, `ghostwriter`, `ai-check`, and `ai-clean` are picked up
automatically - no manual copying needed, and future `git pull`s in the plugin's install
location keep it current.

**Keeping a local copy in sync:** if you edit the skills in this repo, re-run the `cp -r`
commands above (or symlink instead of copying) to push changes into `~/.claude/skills/` -
editing the repo alone doesn't affect what Claude Code actually runs.

## Attribution

`ai-clean` and `ai-check`'s core frameworks - the nine hygiene levers, the nine-signal
scoring rubric, and the banned word/phrase list - are adapted from the
[humanize](https://github.com/harshaneel/humanize) project by Harshaneel Gokhale (MIT
License, Copyright (c) 2026 Harshaneel Gokhale), which itself draws on 50+ peer-reviewed
detection-literature sources.

`ai-check`'s additional content-pattern catalog draws on two further sources:

- Wikipedia's ["Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing),
  maintained by WikiProject AI Cleanup, licensed CC BY-SA 4.0.
- The [humanizer](https://github.com/blader/humanizer) skill (MIT), which itself adapted
  patterns from the same Wikipedia page.

This repo is MIT licensed (see `LICENSE`), consistent with the MIT-licensed material it
builds on. One nuance worth knowing: Wikipedia's "Signs of AI writing" content is CC BY-SA
4.0, which is share-alike - reuse of that specific content should carry the same
attribution-and-share-alike terms if you redistribute it further, separate from the MIT
terms covering the rest of this repo.
