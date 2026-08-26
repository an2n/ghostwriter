<p align="center">
  <img src="assets/ghostwriter.png" alt="Ghostwriter" width="200" />
</p>

# Ghostwriter

> A ghostwriter is a professional writer hired to draft or edit literary works, articles,
> or speeches that are published under another person's name.

An agent skill set that writes text in your own voice instead of generic AI prose, with an
ai clean and check built into the pipeline. Works with Claude Code, Codex CLI, ChatGPT
desktop, OpenCode, and any other agent that reads skills off the filesystem.

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

```bash
git clone https://github.com/an2n/ghostwriter.git
cd ghostwriter
./skills.sh          # Claude Code (~/.claude/skills) - also picked up by OpenCode
./skills.sh codex     # Codex CLI (~/.codex/skills)
./skills.sh chatgpt   # ChatGPT desktop / other agents (~/.agents/skills)
./skills.sh all       # all of the above
```

`skills.sh` symlinks by default, so a later `git pull` in this repo updates whatever
you've installed automatically. Pass `--copy` for a self-contained install that doesn't
depend on this repo staying where it is.

Restart your agent (or start a new session) and the three skills are available - try
`/ghostwriter` (Claude Code), or just say "rewrite this in my voice" with some text.

For agents without filesystem-based skill folders (ChatGPT web, Gemini, Cursor, Aider),
there's nothing to install - paste the contents of `skills/ghostwriter/SKILL.md` (and the
other two, if you want the full pipeline) directly into the conversation.

**As a Claude Code plugin:** point Claude Code's plugin/marketplace mechanism at this repo
instead of running `skills.sh`. Skill discovery is declared in
`.claude-plugin/plugin.json` (`"skills": "./skills"`).

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
