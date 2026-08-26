---
name: ghostwriter
description: >
  Use when the user says "rewrite this", "write this better", "reply to this",
  "in my voice", or invokes /ghostwriter. Add your own trigger phrases, including
  in other languages you write in, if you use different ones regularly. Rewrites,
  improves, or drafts replies in the user's own voice instead of generic
  AI-sounding prose, using a style profile built from their real writing.
---

# Ghostwriter

Write or rewrite text so it sounds like the user wrote it, not like an assistant wrote it.

## Voice profile

This skill ships in a shared repo, so the profile itself does NOT live in this repo or in
any project's memory system (project memory is scoped to one working directory; this skill
needs to work from any of them). It lives in one fixed personal file:

`~/.claude/ghostwriter-profile.md`

- **If that file exists**: read it and apply it. It has the user's real sentence-length
  pattern, vocabulary they actually use vs. avoid, how they open paragraphs/messages, and
  specific tics. Trust it over any generic default below.
- **If it doesn't exist yet**: ask once for 2-3 samples of things the user has actually
  written (Slack, email, LinkedIn, whatever's natural for the register in question). Distill
  a profile (sentence length variance, real vocabulary, opener habits, tics, how they sign
  off or don't) and write it to `~/.claude/ghostwriter-profile.md` so future invocations,
  in any project, skip this step. Then apply it to the task at hand.
- Never commit or copy this file into a project repo. It's personal, machine-local data,
  not part of the plugin.
- If the user corrects the tone, register, or a specific word choice more than once in a
  session, that's a signal the profile has drifted from how they actually write now. Offer
  to update `~/.claude/ghostwriter-profile.md` with what changed — don't rewrite it
  silently on a single correction, since one atypical piece of feedback isn't a reliable
  basis for changing a profile built from real samples.

## Rules regardless of profile

- No genre templates. A "new job" post, a "thanks for the feedback" reply, a "following
  up" email all have a default AI shape (tricolon of nice things, nervous-but-excited
  contrast, CTA question). Break the shape even when individual sentences pass style
  checks — templated *structure* is a stronger tell than word choice.
- No setup → tease → punchline joke structure ("Can't say more yet. [reveal]. So
  [ironic tag line].") This is the single most common way AI fakes personality in
  marketing copy. It isn't its own named pattern in `ai-check`'s Signal I catalog, so it
  needs calling out here. Everything else in Signal I — comparative framing ("more X
  than Y"), aphorism/landing-phrase closers, parallel-subject mirrors, anaphora, binaries
  — is already covered by the post-rewrite `ai-check` audit below; it isn't duplicated
  here since that's a real invocation now, not a remembered checklist.
- Status lines are plain text, no leading symbol (no `>`, no bullet, no emoji) — a leading
  `>` renders as a blockquote bar in this client, which isn't wanted here.
- Emit each status line as its own text output immediately after that skill call returns,
  before invoking the next skill — not batched together at the end. The tool calls and the
  status lines interleave in the actual order things happen: call `ai-check`, then write
  its status line, then call `ai-clean`, then write its status line, and so on. Never
  collect them and print them all in a block right before the final text.
- If there is existing text to rewrite (not a from-scratch draft), invoke `ai-check` with the
  Skill tool on that input text first. After it returns, write its status line, e.g.
  `Checked input - reads as Likely AI, 3 signals fired`. Use its findings to target the
  rewrite at what's actually firing, instead of running every lever uniformly regardless of
  whether the input needs it.
- Then invoke the `ai-clean` skill with the Skill tool. After it returns, write its status
  line, e.g. `Cleaned draft`. Do not apply its levers from memory — memory drifts and skips
  steps the actual skill text enforces (its pre-output gate, its full banned-word list).
  Load it, then draft the baseline hygiene pass for real (burstiness, no hedge padding, no
  banned AI vocabulary, punctuation normalization), directed by what `ai-check` found on
  the input.
- Then layer the voice profile on top, as its own distinct step with its own status line,
  e.g. `Applied voice profile`. The profile overrides ai-clean's generic defaults wherever
  they conflict (e.g. if the user's real writing runs short and fragmented, don't "improve"
  it toward more complete sentences). This step doesn't call a Skill tool, but it's real
  work being done to the draft, so it still gets reported like the others — don't let it
  happen silently just because there's no tool call attached to it.
- For "reply to this": match the register of what's being replied to, but keep the
  user's voice. A reply to a client email isn't a LinkedIn post.
- Output the rewritten/drafted text only, no preamble beyond the status lines above. No
  trailing result line after the text — the status lines already told the user what
  happened as it happened, so there's nothing left to summarize.
- Never print `ai-check`'s full report (the Verdict/Confidence/Score block, the signal
  breakdown table, the evidence log) as part of this flow — only the one-line status per
  invocation. Give the full report only if the user asks for it afterward.

## Necessary, not sufficient

Invoke `ai-check` a second time, now on the drafted output, before returning it - load it
fresh each time, don't self-score from memory of a past run. This is a different check than
the pre-rewrite pass above: that one diagnosed the input to steer the rewrite, this one
verifies the output actually improved and didn't introduce anything new. After it returns,
output one short status line, e.g. `Verified output - reads as Human`. Report just the
verdict tier here too, never a raw score or a made-up percentage (the score is a rule-hit
count, not a probability — "1/27 -> 96% human" would be inventing precision the checklist
doesn't support).

If the verdict isn't Human or Likely Human, don't stop there - go back to `ai-clean` with
these fresh findings and redraft (status line: `Redraft 1 - reapplying ai-clean`), then
run `ai-check` again and report its status line (`Verified output - reads as Uncertain`).
Cap this at two redraft cycles. If it's still not Human or Likely Human after that, say so
plainly in that last status line (e.g. `Verified output - still Uncertain after 2
redrafts`) instead of looping forever or quietly passing a weaker verdict through.

It covers both a
statistical/rhetorical-scaffolding taxonomy (burstiness, chiasmus, asyndeton tricolon, participial reframe pivots,
parallel-subject mirrors) and a content-pattern catalog folded in from Wikipedia's "Signs of
AI writing" (sales language, name-dropping, chatbot residue, knowledge-cutoff disclaimers,
curly quotes, formatting abuse) — one report, both angles covered.

A clean `ai-check` result means no *known, rule-based* pattern fired. It is not proof the
text will pass a real trained classifier (Pangram, GPTZero). `ai-check` is a self-graded
rubric applied by the same model that may have drafted the text, and it only checks its full
genre-template / rhetorical-scaffolding list on outputs over 150 words, so short posts (the
common case here: LinkedIn posts, replies) get a thinner check by construction. A real
"new job" or "we're hiring" post scored "Human" by `ai-check` has already been caught by
a real classifier as 100% AI once. Don't report a clean `ai-check` pass as "this is safe" or
"this will pass detection." Say what it actually means: no rule violations found, template
and structural risk still possible, especially under 150 words.
