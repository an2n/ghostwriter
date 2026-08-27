---
name: ghost
description: >
  Use when the user says "rewrite this", "write this better", "reply to this",
  "in my voice", or invokes /ghost. Add your own trigger phrases, including
  in other languages you write in, if you use different ones regularly. Rewrites,
  improves, or drafts replies in the user's own voice instead of generic
  AI-sounding prose, using a style profile built from their real writing.
---

# Ghost

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
  marketing copy. It isn't a named tell in `check`'s catalog, so it needs calling out
  here. Everything else that pattern-family covers — comparative framing ("more X than
  Y"), aphorism/landing-phrase closers, parallel-subject mirrors, repeated openers,
  binaries — is already covered by the post-rewrite `check` audit below; it isn't
  duplicated here since that's a real invocation now, not a remembered checklist.
- Status lines are plain text, no leading symbol (no `>`, no bullet, no emoji) — a leading
  `>` renders as a blockquote bar in this client, which isn't wanted here.
- Emit each status line as its own text output immediately after that skill call returns,
  before invoking the next skill — not batched together at the end. The tool calls and the
  status lines interleave in the actual order things happen: call `check`, then write
  its status line, then call `polish`, then write its status line, and so on. Never
  collect them and print them all in a block right before the final text.
- If there is existing text to rewrite (not a from-scratch draft), invoke `check` with the
  Skill tool on that input text first. After it returns, write its status line, e.g.
  `Checked input - reads AI, 4 tells fired`. Use its findings to target the rewrite at
  what's actually firing, instead of running every move uniformly regardless of whether
  the input needs it.
- Then invoke the `polish` skill with the Skill tool. The arguments passed to that call
  must literally include check's findings from the previous step (the specific tells and
  quoted evidence, not just "clean this up") — "directed by what check found" only
  happens if the findings are actually in the args; don't rely on them being visible
  earlier in the conversation, put them in the call itself. After it returns, write its
  status line, e.g. `Cleaned draft`. Do not apply its moves from memory — memory drifts
  and skips steps the actual skill text enforces (its pre-output gate, its full
  banned-word list). Load it, then draft the baseline hygiene pass for real (burstiness,
  no hedge padding, no banned AI vocabulary, punctuation normalization), targeted at what
  check found on the input.
- Then layer the voice profile on top, as its own distinct step with its own status line,
  e.g. `Applied voice profile`. The profile overrides polish's generic defaults wherever
  they conflict (e.g. if the user's real writing runs short and fragmented, don't "improve"
  it toward more complete sentences). This step doesn't call a Skill tool, but it's real
  work being done to the draft, so it still gets reported like the others — don't let it
  happen silently just because there's no tool call attached to it.
- The override only covers structural and mechanical habits the profile actually
  documents — sentence length, fragments, punctuation like a mid-sentence en-dash aside.
  It is not a blanket exemption for whatever content happens to sit inside a matching
  construction. A profile trait says "this shape is how the user writes," not "anything
  wearing this shape is above scrutiny." If a matching construction is carrying content
  that's independently generic (a stock compliment, an empty-uplift closer, praise with
  no specific behind it), that's still worth a redraft using the user's own concrete,
  specific style rather than kept just because the wrapper matched.
- Matching a trait also means matching its scale, not just its presence. If the
  profile's example of an en-dash aside is two words on each side, stuffing a
  three-item comma list behind the same dash isn't "the same trait" - it's a heavier
  construction wearing similar punctuation, and `check`'s clause-stacking tell will
  fire on it regardless of how well the dash itself matches the profile. Same logic for
  any other trait with a size to it: "sparing emoji" means matching the documented
  count, not just using an emoji; "drops the subject pronoun sometimes" means sometimes,
  not in every sentence. Check the actual proportions of the example against what's
  being produced, not just whether the same kind of thing is present.
- The profile is built from the user's own first-person writing, so it has nothing to say
  about phrasing for third-person content where the user isn't the one speaking (a news
  blurb, an encyclopedia-style paragraph, a quote from someone else). Don't force sentence
  fragments or personal tics onto that register just because the profile has them. Still
  report this step — say what actually happened instead of silently skipping the line,
  e.g. `Voice profile - not first-person content, applied general principles only`
  (flat facts over inflated framing, no brochure language, real sentence-length variance
  still apply regardless of register).
- For "reply to this": match the register of what's being replied to, but keep the
  user's voice. A reply to a client email isn't a LinkedIn post.
- Output the rewritten/drafted text only, no preamble beyond the status lines above. No
  trailing result line after the text — the status lines already told the user what
  happened as it happened, so there's nothing left to summarize.
- Never print `check`'s full report (the Verdict/Confidence/Score block, the signal
  breakdown table, the evidence log) as part of this flow — only the one-line status per
  invocation. Give the full report only if the user asks for it afterward.

## Necessary, not sufficient

Invoke `check` a second time, now on the drafted output, before returning it - load it
fresh each time, don't self-score from memory of a past run. This is a different check than
the pre-rewrite pass above: that one diagnosed the input to steer the rewrite, this one
verifies the output actually improved and didn't introduce anything new. After it returns,
output one short status line, e.g. `Verified output - reads human`. Report just the
verdict tier here too, never a raw density number or a made-up percentage (the density is
a weighted tell count, not a probability — turning it into "96% human" would be inventing
precision the checklist doesn't support).

If the verdict isn't "Reads human" or "Mostly human," don't stop there - go back to
`polish`, same rule as the first call: put this verification pass's specific findings
literally in the args, not a vague "try again" (status line: `Redraft 1 - reapplying
polish`), then run `check` again and report its status line (`Verified output - mixed
signals`). Cap this at two redraft cycles. If it's still not in one of those top two tiers
after that, say so plainly in that last status line (e.g. `Verified output - still mixed
signals after 2 redrafts`) instead of looping forever or quietly passing a weaker verdict
through.

`check` covers word-choice tells, sentence-rhythm tells, document-structure tells, and
the harder sentence-level rhetorical moves (chiasmus, mirrored subjects, reframe pivots) -
plus chatbot-residue and formatting-abuse tells that come from the same broader body of
observed AI-writing patterns this whole field draws on.

A clean `check` result means no *known, rule-based* tell fired. It is not proof the
text will pass a real trained classifier (Pangram, GPTZero). `check` is a self-graded
checklist applied by the same model that may have drafted the text, and short posts (the
common case here: LinkedIn posts, replies) simply have fewer words for tells to fire
against, so they get a thinner check by construction, not a more lenient one. A real
"new job" or "we're hiring" post that read clean by a checklist like this has still been
caught by a real classifier as 100% AI before. Don't report a clean `check` pass as
"this is safe" or "this will pass detection." Say what it actually means: no rule
violations found here, risk from anything this checklist doesn't cover still possible,
especially under 150 words.
