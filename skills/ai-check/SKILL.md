---
name: ai-check
description: >
  Use when someone asks "does this sound AI?", "check if this is AI-written", "what gives
  this away as AI", "run ai-check on this", or "score this text". Also use when reviewing
  a draft for AI tells before publishing, or when a piece of text reads as suspiciously
  polished, generic, or pattern-y and the user wants a forensic breakdown of why.
---

# AI-Check Skill

Forensic analysis of text for AI-generation signals. Grounded in the published detection
literature (Wu et al. 2025, Mitchell et al. 2023, Kujur 2025, AAAI 2025 shared task) and in
Wikipedia's ["Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
pattern catalog, maintained by WikiProject AI Cleanup (see Source at the end).

The output is a structured report, not a vague judgment. Every fired signal cites evidence.

---

## The nine signal categories

Score each category 0–3:
- 0 = No signal detected (human-consistent)
- 1 = Weak signal (possible AI, could be human)
- 2 = Moderate signal (likely AI pattern)
- 3 = Strong signal (near-certain AI pattern)

**Severity-to-score mapping (use for every category):**

| Evidence in category | Score |
|---|---|
| No flagged instances | 0 |
| One weak instance, or vague unease without a specific quote | 1 |
| One moderate instance, or two or more weak instances | 2 |
| One strong instance, or two or more moderate instances, or four or more weak instances | 3 |

**Double-counting policy:** a single phrase can fire at most two distinct signals when the phrase is genuinely diagnostic for both. Example: "it is important to note that" is both Signal A (banned vocabulary) and Signal C (institutional hedge). Log it under both, but the same phrase cannot count as two separate weak instances inside the same category.

**Total score cap:** 9 categories × 3 = 27 maximum.

### Signal A: Perplexity (word predictability)

Look for vocabulary that is maximally safe and expected — words that are technically correct
but never the most precise or interesting choice a knowledgeable human would make.

Flags:
- Generic verbs where domain-specific ones belong ("address" instead of "untangle", "implement" instead of "wire up")
- Adjectives that describe without adding information ("significant improvements", "notable progress", "key challenges")
- Hedged assertions that swap specificity for safety ("can often lead to", "may result in", "tends to")
- Any of the canonical AI vocabulary list:
  delve, leverage (verb), utilize, robust, comprehensive, streamline, foster/fostering,
  facilitate, pivotal, nuanced, notable, notably, enduring, garner, valuable, vibrant,
  intricate/intricacies, interplay, tapestry (abstract noun), testament (figurative),
  underscore (verb), showcase (verb), key (as a vague adjective), align with, emphasizing,
  enhance, quietly (as a hedge-flavored adverb), gate/gated/gating (figurative only —
  established technical usage is fine), it is worth noting, it is important to note,
  multifaceted, in the realm of, the landscape of (abstract noun), a myriad of, a plethora of,
  actually (as filler), additionally (as a paragraph opener)
- Copula avoidance: elaborate verbs standing in for "is"/"are"/"has" ("serves as", "stands as",
  "marks", "represents", "boasts", "features", "offers"). "The clinic serves as the county's
  only walk-in center" should just be "is."
- Significance inflation: "stands as a testament to", "marks a pivotal moment in", "indelible
  mark", "evolving landscape", "setting the stage for", "deeply rooted in", "a key turning point"
- Promotional/sales register: "nestled in the heart of", "boasts a rich heritage", "renowned
  for", "breathtaking", "must-visit", "stunning" — reads like an ad, especially for places,
  culture, or products
- Elegant variation (synonym cycling): the same referent relabeled across sentences instead of
  reused or pronoun'd — "the protagonist / the main character / the central figure / the hero"
  for one person. Caused by repetition-penalty sampling; humans reuse the canonical noun or a
  pronoun instead.
- Shallow analysis via -ing phrases: a plain fact dressed up with a trailing participial clause
  that adds no information ("...symbolizing its enduring connection to...", "...reflecting a
  broader commitment to..."). Strip the phrase and check whether any fact was lost — usually
  none was.
- Hyphenated-pair overuse: "third-party", "cross-functional", "data-driven", "long-term" etc.
  hyphenated even where grammar doesn't require it (after the noun: "the report is data-driven"
  should be "data driven").
- Vague connection/association: "in connection with", "associated with", "connected to" used
  to abstract away a direct relationship instead of a concrete verb or preposition ("of", "for",
  "by", "caused by", "working with").

Cite the exact word or phrase that fired.

### Signal B: Burstiness deficit (sentence uniformity)

Measure the variation in sentence length across the text.

Flags:
- Three or more consecutive sentences within 5 words of the same length
- No sentence shorter than 8 words in any 150-word block
- Metronomic rhythm — reading the passage aloud produces a steady pulse rather than natural variation
- No fragments used for emphasis

Report: list the sentence lengths in sequence (e.g. "14, 16, 13, 15, 17 — five consecutive sentences within 4 words of each other").

### Signal C: Hedge density

Count the softening and epistemic hedge words.

Flags:
- "often", "generally", "typically", "in many cases", "it can be argued" appearing where direct assertion is warranted
- "it is important to note that", "it is worth mentioning", "one might consider"
- Diplomatic framing of obvious tradeoffs: "while X has benefits, it also presents challenges"
- Uncertainty expressed as institutional hedging rather than personal ("results may vary") vs human ("I'm not sure this holds when...")

Report: quote each hedge and note whether it was warranted by genuine uncertainty or reflexive softening.

### Signal D: Structural tells

Look for document architecture patterns AI imposes regardless of content.

Flags:
- Bullet list where prose would serve better
- Topic sentence + evidence + restatement of topic sentence (humans skip the restatement)
- "In conclusion / To summarize / In summary" openers on closing paragraphs
- "In this [post/article/section] I will..." openers
- Numbered steps for content that isn't genuinely sequential
- Three-part structure imposed on every paragraph (intro, body, conclusion at micro-scale)
- **Tricolon parallel structure:** three examples or beats with identical grammatical shape.
  Fires across sentences ("You X. Y. Does Z? You X. Y. Does Z? You X. Y. Does Z?") and just
  as strongly within one sentence as a comma-separated triad of parallel verb phrases or
  clauses ("fix the bug, write the tests, open the PR"). Perfectly symmetrical triplets are
  AI-constructed regardless of which form they take. Real writers use two examples or vary
  the shape. Severity: strong.
- **Perfect paragraph-per-idea arc:** every paragraph does exactly one narrative job and
  advances the arc cleanly (setup → tension → lesson → evidence → reflection). Real personal
  writing has a paragraph that meanders, does two jobs, or doesn't fully resolve. A piece
  where every paragraph lands cleanly is architecturally perfect in a way human writing
  isn't. Severity: moderate in isolation, strong combined with other signals.
- **Three-act Slack/update structure:** for informal async messages, accomplishment → caveat
  → next steps maps directly to intro/body/conclusion. Real updates loop back, add a
  mid-message second thought, or end with something that doesn't fit the structure.
- **Strawman pivot:** "The case for X isn't about Y, it's about Z" / "It's not about X,
  it's about Y." Leading with what something is NOT before saying what it IS.
  Real writers lead with the actual point. Severity: moderate.
- **Formatting-as-substance:** bold text or bold mini-headings standing in for actual sentence
  structure ("- **User Experience:** The experience was improved..." for every bullet), title-
  case headings ("## Strategic Negotiations And Global Partnerships"), or emoji used as bullet
  decoration (🚀 **Launch Phase:** ...). None of these are AI-specific by themselves, but
  stacked together they signal a document assembled from a template rather than written.
- **Outline-formula "Challenges and Future Prospects" section:** "Despite its X, Y faces several
  challenges... Despite these challenges, Y continues to thrive." A stock closing section that
  restates vagueness instead of adding facts. Severity: moderate.
- **Heading repeated in the first sentence:** a heading followed by a one-line paragraph that
  only restates the heading ("## Performance" / "Speed matters.") before real content starts.
- **False "from X to Y" range:** presenting two items as endpoints of a range when they aren't
  really a spectrum ("from the Big Bang to the cosmic web, from stars to dark matter").
- **Generic positive ending:** closing on vague optimism instead of the last concrete fact
  ("The future looks bright... exciting times lie ahead"). Severity: moderate.
- **Writing about the previous version outside a changelog:** documentation or comments that
  describe what used to happen instead of current behavior, outside release notes or migration
  guides.
- **Unfilled placeholder/template text:** a bracketed or parenthetical fill-in-the-blank left
  unreplaced — "[Company Name]", "(insert client testimonial here)", "[Topic]".
  A near-certain tell on its own — humans don't leave Mad-Libs-style blanks in finished text.

### Signal E: Specificity deficit

Measure whether claims are grounded in concrete detail.

Flags:
- Abstract claim with no number, name, time reference, or example: "Many organizations have adopted..."
- Passive constructions obscuring the actor: "it has been found that", "research suggests"
- Universalist framing: "teams often find", "developers frequently encounter" (applicable to everyone, specific to no one)
- Named examples that are suspiciously generic or perfectly illustrative (AI picks canonical examples: "Netflix", "Amazon", "Stripe" without context)
- Vague-source attribution: "Industry reports", "observers have cited", "experts argue", "some
  critics argue" — a claim assigned to unnamed authorities instead of a named source
- Name-dropping as proof of importance: a list of publications or a follower count that gives no
  context ("cited in the NYT, BBC, Financial Times, and The Hindu... over 500,000 followers") —
  padding a credibility claim instead of grounding it

Report: quote each unanchored claim.

### Signal F: Transition word fingerprint

Catalog the connective tissue between sentences and paragraphs.

Flags (strong AI signals):
- "Furthermore," as paragraph opener
- "Moreover," as paragraph opener
- "Additionally," as paragraph opener
- "It is clear that"
- "This highlights / underscores / demonstrates the importance of"
- "As previously mentioned"
- "In addition to the above"
- "It goes without saying"
- "Needless to say"

Flags (moderate signals):
- "However," used more than once per 200 words
- "Therefore," used as a mechanical logical connector rather than earned conclusion
- **"Turns out" / "it turns out that"** as a pivot or reveal. AI uses this to create
  the illusion of a discovery narrative. "Turns out the config had a lower timeout"
  → "The config had a lower timeout." Quote each instance. Severity: moderate.
- **Tutorial-voice transitions:** "The standard fix is...", "The common approach is...",
  "Simple enough on paper" — these frame what follows as received wisdom, not personal
  experience. Strong signal in technical writing.
- **Announcement-colon patterns:** "The rule I use:", "The key insight:", "The approach
  here:", "The other thing I'd say:" — announcing before revealing. Severity: moderate.
  Also fires without a colon: "What I didn't expect was...", "What surprised me was...",
  "The thing I realized was..." — these are announcement sentences even without the colon.
  The colon isn't the tell; the announcement structure is.
- **Pattern announcement:** stating that a pattern exists before describing it.
  "The pattern is almost always the same" followed by the pattern. Real writers
  just describe the pattern.
- **False-depth framing:** "the real question is", "at its core", "what really matters",
  "fundamentally", "the deeper issue", "the heart of the matter" — dresses an ordinary point up
  as a hidden truth.
- **Signposting/tutorial announcements:** "let's dive in", "let's explore", "here's what you
  need to know", "without further ado", "heads up," "quick note" before the actual point.

### Signal G: Punctuation fingerprint

Count the three AI punctuation tells:

**Em dashes:** Count total em dashes. More than 1 per 300 words is a signal. Specific sub-patterns:
- Double em dash wrapping (— like this —) is a near-certain AI pattern
- Em dash as pivot ("not mid-sprint — and the on-call rotation") — list-joiner em dash
  connecting two items within a sentence
- Em dash as dramatic aside ("X — which is worth noting — Y")
Report exact count, location, and which sub-pattern.

**Plain-hyphen dash-wrapping (the em-dash pattern in disguise):** the same three sub-patterns
above — double wrapping, list-joiner, dramatic aside — fire identically when written with a
plain hyphen or spaced hyphen (` - `) instead of an em dash. This matters most in exactly the
register where em dashes are already banned (a style guide, a voice profile): the underlying
AI-constructed shape survives by swapping the character while the construction itself is
unchanged. Never let "no em dashes" read as "this text has no dash-wrapping tell" — check for
the construction, not the specific glyph. Report the same way: exact count, location, and
sub-pattern, noting it fired via plain hyphen rather than em dash.

**Semicolons:** Any semicolon linking two independent clauses in non-academic prose is a flag.
Report exact count. Exception: comma-containing lists ("Austin, TX; Denver, CO").

**Mid-sentence colons:** A colon preceded by an incomplete clause ("The problem: nobody tests
this" / "The answer: start earlier") is an AI structural pattern. Report each instance.

**Curly quotation marks:** Typographic (curly) quotes and apostrophes where straight quotes are
the register norm (technical writing, casual prose, most non-published contexts) are a near-
certain single-character ChatGPT tell. Weak signal alone (many editors and CMSes auto-curl),
moderate when stacked with other tells.

**Chatbot markup/citation residue:** literal technical artifacts from a chatbot's raw output,
pasted in unresolved. Unlike the other punctuation tells, a single instance of these is a
near-certain tell on its own — it isn't a stacking signal.
- ChatGPT: `:contentReference[oaicite:0]{index=0}`, `oai_citation`, `turn0search0`/`turn0image0`,
  `citeturn0news0`
- Gemini: `[cite: 1]`, `[span_1](start_span)` / `(end_span)`
- Grok: `grok_card`, `grok_render_citation_card_json`
- DeepSeek: lenticular brackets with a dagger, e.g. `【85†L261-269】`
- Perplexity: `[attached_file:1]`, `ppl-ai-file-upload` inside a URL
- UTM tracking left on a source link: `utm_source=chatgpt.com`, `utm_source=openai`,
  `utm_source=copilot.com`, `referrer=grok.com`
- Raw Markdown syntax (`**bold**`, `# heading`, `---` thematic breaks) leaked into output for
  a format that isn't Markdown

### Signal H: Voice and register

Look for absence of human traces.

Flags:
- No first-person perspective anywhere in a piece where first-person would be natural
- No second-person direct address in instructional or opinionated content
- Consistent "polished neutral tone" — no personality variance, no roughness, no informality spikes
- No rhetorical questions used as transitions
- No self-correction or mid-thought qualification ("actually, that's not quite right")
- Opening sentence is a thesis, definition, or contextual framing rather than mid-thought or scene

**Register collapse (Slack / informal writing):**
The most commonly missed signal in casual-register text. AI writes Slack messages that read
like polished status reports with informal markers sprinkled in. Look for:
- Complete, well-formed sentences throughout — real Slack has fragments
- Topic-per-paragraph structure even in a short message
- Formal vocabulary underneath casual markers (`~60%` and `lmk` but the sentences
  themselves are well-constructed prose)
- No self-corrections mid-message ("oh also. just realized...")
- Three-act arc (accomplishment / caveat / next steps) intact beneath the informality
- Numbers written as words ("three incidents") rather than numerals with approximations
  ("~3 incidents", "<10min")
Severity: strong when informal markers are present but prose structure is polished.

**Templated closers in email/professional writing:**
"Happy to jump on a call if that's easier."
"Let me know if you have any questions."
"Feel free to reach out."
These are the written equivalent of a throat-clearing opener. Real engineers end emails
after the last substantive point, or with a specific ask, or with "lmk."
Severity: weak in isolation, moderate when combined with other signals.

**Chatbot residue left in the answer:** a greeting, offer, or sign-off that belongs to the chat
turn, not the document: "I hope this helps!", "Of course!", "Certainly!", "Want me to expand on
any section?", "Here is an overview of X." Strong signal — this is scaffolding from a chat
session pasted into content that should stand alone. Also covers older prompt-refusal residue
("As an AI language model, I can't directly add content to this, but I can help you draft...")
— rare in current models but a near-certain tell when present.

**Pronounced register or dialect shift:** a sudden jump to noticeably more polished grammar
than the surrounding text, or an English-variety mismatch with the piece's own context (e.g.
American spelling/idiom in a piece clearly by or about someone in a British-English context).
Weak alone (plenty of human explanations — editing, code-switching, ESL), moderate when it
lines up with other signals firing in the same section.

**Knowledge-cutoff disclaimers and guessed gap-fill:** "As of [date]", "up to my last training
update", "while specific details are limited in available sources" followed by a plausible-
sounding guess presented as fact ("it appears to have been founded sometime in the 1990s").
Report the disclaimer and, separately, flag the guess it's covering for.

**Overly agreeable tone:** praising or agreeing with the reader before answering ("Great
question! You're absolutely right that..."). Strong signal in conversational registers.

**Fake-candid opener:** a staged pause claiming honesty before an ordinary point — "Honestly?",
"Look,", "Here's the thing,", "Real talk," — used as a standalone hook rather than mid-sentence.

### Signal I: Rhetorical scaffolding

Sentence and paragraph-level construction patterns that AI learned from polished writing
and applies too consistently. These are the hardest signals to catch — they feel like
good writing. Grammarly and live detectors flag these even when punctuation and vocabulary
are clean.

**Local coherence over-smooth** (severity: moderate-strong, corpus-dependent)
A pattern related to findings in recent research (DivEye, arXiv 2509.18880, TMLR 2026):
every sentence connects too perfectly to the next, zero friction, zero cognitive-load
artifacts. AI text often has no sentences that slightly misfire, no thoughts that shift
direction mid-clause, no paragraph that doesn't close cleanly.
Evidence: read each paragraph and check whether any sentence could be removed and the
paragraph would still read perfectly. In human writing, removing a sentence often creates
a noticeable gap. In AI writing, the paragraph usually flows better without it.
Symptoms:
- Every paragraph opens with a claim and closes with a confirmation of that claim
- No sentence has a vocabulary mismatch with surrounding sentences
- No abrupt topic shift within a paragraph
- No sentence that slightly misfires before correcting

**Calibration caveat (important).** SHAP-based explainability analysis (arXiv 2603.23146) found that
AI-text detectors rely on dataset-specific stylistic cues, not stable
machine-authorship signals. Treat over-smoothness as a corpus-conditional indicator, not a
universal authorship invariant. If the text is from a register that genuinely rewards tight
coherence (academic abstracts, legal briefs, polished marketing copy), down-weight this signal.

**Formula personal essay opener** (severity: moderate)
"The failure I think about most often happened in 2019."
"The moment I remember most clearly was..."
"The decision I regret most is..."
Pattern: "The [noun] I [remember/think about/regret] most [adverb]" — AI's deliberate-
introspection construction for opening personal essays. Real writers start with the
incident, not with a ranked claim about their memory of it.

**Asyndeton tricolon building in complexity** (severity: moderate)
Three items without conjunctions, each longer and more emotionally heavy than the last:
"Two hours of degraded service, six engineers figuring out what I'd done wrong, a
postmortem where I had to explain my reasoning to people who had been paged at home."
AI constructs these to manufacture escalating emotional weight.
Report the three items and their increasing length.

**Intensifier/diminisher opposition** (severity: moderate)
"X [action] obsessively and Y [action] barely at all" — a balanced contrast using an
amplifier against a diminisher. Same family as chiasmus but at the adverb level.
Other forms: "X constantly / Y once", "X carefully / Y hardly".
Quote the opposition.

**Mini-aphorism paragraph closer** (severity: moderate)
A 4–7 word fragment or short sentence used to close a paragraph with a punchy lesson:
"That's the part that stuck."
"That's what changed."
"That's the whole thing."
"That's the real cost."
AI appends these to tell the reader what conclusion to draw. Distinct from a sentence-
length aphoristic closer — this fires even on very short fragments.

**Landing phrase: "is the actual/real work"** (severity: moderate)
"Getting close enough to understand a failure is the actual work."
"Deploying is the easy part. Debugging production is the actual work."
AI's formulaic landing phrase for delivering conclusions. Quote it.

**Parallel subject mirror** (severity: weak-moderate)
Two consecutive sentences opening with mirrored noun phrases that reflect each other:
"The failure itself is just the event. Understanding it is separate."
"The code is one thing. Maintaining it is another."
AI constructs these as closing pairs. Report the mirrored subjects.

**Participial reframe pivot** (severity: moderate)
Presenting a list of facts, then using a participial opener to reframe them as something more:
"Laid out in a petition, the same facts read like a deliberate strategy."
"Arranged that way, it sounds more planned than it was."
"Seen this way, the whole arc reads differently."
AI uses this pivot to manufacture the appearance of insight. The observation should be made
directly without the reframing device. Quote the participial opener.

**Thesis-first opener / "X is the easy/hard part"** (severity: moderate)
Starting a personal piece with the frame before the experience:
"Gathering evidence for an EB1A petition is the easy part."
"The writing is harder than the research."
"X has become increasingly important."
AI leads with the thesis because it's been trained on essays. Real writers start in the
middle of the experience. Quote the opener.

**Within-sentence anaphoric parallel list** (severity: moderate-strong)
Four parallel items with the same question-word structure inside a single sentence:
"what existed before, what problem it solved, why the problem mattered, what changed after"
Grammarly and other detectors score this identically to consecutive-sentence anaphora.
The fix is varying the noun forms: "context, the actual problem, what changed" — not
four parallel "what/why" question-clause starters.
Quote the full list.

**Composed self-aware parenthetical** (severity: moderate)
A parenthetical clause where the writer meta-comments on their own interpretation:
"which I choose to read as progress"
"which I take as a sign of X"
"which I'm choosing to interpret as Y"
These feel reflective but read as placed. Real reflection names the concrete behavior
and stops; it doesn't append the writer's chosen interpretation of that behavior.
Quote the parenthetical.

**Parallel reason chains** (severity: moderate)
Three consecutive sentences with the same "subject + because/when + reason" structure,
even when the subjects vary:
"I filed patents because X. localaik started because Y. I gave talks when Z."
The parallel clause shape is detectable even across different subjects. Vary the
clause structure: one "because", one bare assertion, one gerund or fragment.
Report how many parallel reason-chains fire in sequence.

**"More X than Y" comparative framing** (severity: moderate)
All forms: "feels more like X than Y", "more specific than vague", "faster than".
AI describes things by framing against an opposite. Humans describe directly.
Quote the comparative.

**"Not just X" / "not X, it's Y" / "not X but Y" diminishment** (severity: moderate)
Naming what something isn't before saying what it is. "It's not self-reported, it's
merit-based." "Reasoning, not just behavior." All three forms are the same pattern. Also
fires reversed as "X rather than Y" ("prioritizing consolidation of power ... rather than
ideological purity") — same negative-parallelism family, just flipped order.
Quote the diminishment.

**Setup sentences without colons** (severity: moderate)
Announcement sentences of the form "What [verb phrase] was [the revelation]" — the colon
is not the tell, the announcement structure is. All forms fire:
- "What I didn't expect was..."
- "What surprised me was..."
- "The thing I realized was..."
- "What it didn't have was..."
- "What ended up working was..."
- "What changed everything was..."
- "What finally clicked was..."
- "What made the difference was..."
Any sentence of the form "What [verb phrase] was [the revelation]" is an announcement
sentence regardless of whether a colon follows. Quote the setup sentence.

**Aphoristic / chiasmus closer** (severity: moderate-strong)
Two sub-patterns:
1. A closing sentence quotable as standalone: "The boilerplate is cheaper than the
   confusion." "The work doesn't sell itself."
2. Chiasmus — reversed parallel that sounds like insight: "Being specific about being
   wrong is more useful than being vague about being right." — "specific/wrong" mirrored
   against "vague/right." Real insight is asymmetric; AI constructs symmetric reversals.
Quote and identify which sub-pattern.

**Anaphora — same sentence-starter 2–3× consecutively** (severity: moderate)
"I still read slowly. I still lose the thread."
"Why this structure. Why the error handling. Why the cache TTL."
AI uses repeated openers for emphasis. Humans collapse them or vary the structure.
Report the repeated opener and how many times it fires.

**"Turns out" / "it turns out that" as reveal pivot** (severity: moderate)
AI's dramatic reveal device: "Turns out the config had a different timeout."
Direct statement: "The config had a different timeout." The "turns out" adds nothing
except the illusion of a discovery narrative. Quote each instance.

**"Either X or Y" / "between X and Y" binary framing** (severity: moderate)
Clean binary choices presented as the only options. Real situations are a spectrum.
"Teams face a choice between mocking (fast, but drifts) or live endpoints (accurate, but
expensive)" — also fires the balanced parenthetical pattern below.

**Balanced parenthetical pairs** (severity: moderate)
"(X, but Y) or (A, but B)" — two symmetric trade-offs in one sentence.
Real trade-offs are asymmetric. The symmetry signals AI construction.
Quote the parallel parentheticals.

**Inverted burstiness** (severity: weak)
Three or more consecutive very short sentences (under 7 words each) without a longer
counterweight. "The code was fine. The logic held. Nothing left a trace." Reads choppy
in isolation. Distinct from Signal B which flags uniform medium-length sentences. Same family
as forced dramatic-fragment punchlines ("Then it arrived. No preference for symmetry. No
aesthetic prior. The old rules were gone.").

**Formulaic saying (aphorism dressed as insight)** (severity: moderate)
"X is the language of Y", "X becomes a trap", "X is not a tool but a mirror." Turns an ordinary
claim into a saying that sounds deep but adds no detail. Distinct from the aphoristic closer
above in that this fires mid-paragraph, not just as a closer.

**Answering an objection no one raised** (severity: moderate)
"This isn't mainly about X", "I'm not saying Y", "to be clear", "don't get me wrong" — rebutting
a position that appears nowhere else in the text. Same family as the strawman pivot (Signal D)
but fires as a mid-paragraph defensive aside rather than a paragraph-opening pivot.

**Rejecting a fake alternative** (severity: moderate)
"A tempting approach would be X, but..." — introducing an option no reader would seriously
consider, dismissing it in one clause, and never mentioning it again. Often a leftover drafting
idea. One instance may be a real design tradeoff; two or more unrelated rejections in one piece
is the tell.

---

## Output format

If another skill invoked this one as an internal sub-step (e.g. `ghostwriter` running a
pre-check or verification pass) rather than the user directly asking to check a piece of
text, skip the report below entirely. Still do the full analysis - score all nine signals
for real - but hand back only what the calling skill needs (verdict, score) for it to
build its own one-line status. Don't print this report in that case; the calling
skill's own output rules govern what the user sees.

Otherwise - a direct "does this sound AI" / "check this" request - always output in this
structure:

## AI-check report

Verdict: Human / Likely Human / Uncertain / Likely AI / AI
Score: 0–27 / 27

What fired: for every signal scoring above 0, one short line - the signal letter, a quote
or description of what fired, and its severity (weak/moderate/strong). Signals scoring 0
aren't listed at all. Two to four sentences after that naming the strongest signals in
plain language - specific about which phrases or absences were most diagnostic, not just
a score.

Recommended fixes: only if the score is above 6. Concrete changes for the top two or three
signals, as compact bullets, not a rewritten sample.

No tables, no separate Confidence/AI-edited-fraction header block - just verdict, score,
what fired, and (if warranted) fixes.

---

## Scoring thresholds

| Total score | Verdict |
|---|---|
| 0–4 | Human |
| 5–8 | Likely Human |
| 9–13 | Uncertain |
| 14–19 | Likely AI |
| 20–27 | AI |

## Calibration notes

- Short texts (<100 words) have fewer signals available; note this and adjust confidence to Medium max
- Technical writing with domain jargon can suppress Signal A even in AI text — don't penalize accurate domain vocabulary
- Academic or legal writing legitimately uses hedges and semicolons — adjust Signal C and G accordingly
- ESL writing can mimic some AI patterns (uniform sentence length, hedge-heavy); note if this is plausible
- A text can score AI on structure/transitions but human on voice — report both honestly
- Signal I (rhetorical scaffolding) fires on patterns that feel like *good* writing — do not discount
  them because the writing quality is high. These are the hardest tells precisely because AI learned
  them from skilled human writers. A "more like X than Y" comparative in an otherwise clean piece
  is still a signal.
- Register collapse (Signal H) requires cross-checking: informal markers alone do not make a Slack
  message human. Look at the sentence structure underneath the `lmk` and `~60%`. If the underlying
  prose is polished and well-formed, the informal markers are surface noise.
- Aphoristic closers (Signal I) are context-dependent — a single well-turned closing line in a long
  personal essay is less diagnostic than the same pattern in a 200-word post where it's the only
  memorable sentence. Weight accordingly.
- Perfect grammar and consistent style are not proof by themselves — many writers are edited
  professionals. Polish alone is not a tell.
- Mixed casual/formal register in one piece can reflect the writer's field, age, or habits, not
  mixed authorship.
- "Bland" or generic dry prose is not automatically AI — AI prose has *specific* tells (this
  checklist). Dryness without any of them is just dry writing.
- Formal/academic vocabulary alone is not a tell — only the specific overused list in Signal A
  counts. Don't flag every formal word.
- Salutations and sign-offs predate ChatGPT by centuries — don't flag letter-style openings or
  closings on their own.
- A single "however," "moreover," or "additionally" is not a tell — these are AI-coded only when
  piled up (Signal F already requires more than one per 200 words for the moderate tier).
- Curly quotes alone are not a tell (many editors and CMSes auto-curl) — count only when stacked
  with other signals.
- Em dashes alone are not a tell — many professional editors and journalists use them. They're
  evidence only paired with other formulaic patterns.
- One short sentence for emphasis is not a tell — flag dramatic fragments only when three or
  more appear in a row (see Inverted burstiness, Signal I).
- Deliberate repeated openings for rhythm ("She came. She saw. She conquered.") are not
  anaphora-as-AI-tell — flag repetition only when it adds nothing.
- Useful disclaimers, scope statements, legal/safety notices, and named objections that are
  actually answered in the text are not the "answering objections no one raised" pattern —
  that pattern requires the objection to appear from nowhere.
- Unsourced claims are common across ordinary human writing on the web — lack of citation alone
  proves nothing without another signal alongside it.
- Text from before November 30, 2022 (ChatGPT's public launch) is, with rare exceptions, not
  AI-written regardless of how it scores.

### Signals that argue for human authorship

Weigh these against the flags above — their presence should pull the verdict toward human even
when some signals fired:
- Specific, unusual, hard-to-invent details (a real address, an odd direct quote, "the lawyer
  who used to work upstairs from my dentist")
- Mixed feelings or unresolved tension stated directly ("I think this is mostly good, but it
  bothers me and I can't fully explain why")
- Dated, era-bound slang or in-jokes tied to a specific year and subculture — models lag behind
  current slang by a year or more
- Genuine asides, parentheticals, or self-corrections mid-sentence ("(I keep wanting to say
  'almost' here, but it really was certain.)")
- Real variety in sentence length rather than an even mid-length cadence

### Known detection ceilings (cap confidence accordingly)

- **Base-model output is a known ceiling.** arXiv 2605.19516 ("Base Models Look Human") and corroborating
  Pangram analysis show that raw, non-instruction-tuned base-model output reads as human to current
  SOTA detectors. What modern detectors actually fire on is RLHF / instruction-tuning artifacts (polite
  hedging, structured enumeration, perfect coherence, "helpful assistant" register), not "AI-ness" per
  se. If the text plausibly came from a base model or a minimally-fine-tuned paraphraser (HIP-style
  attack), cap confidence at Medium even when surface signals look clean.
- **Claude blind spot in zero-shot detectors.** The DetectRL benchmark (arXiv 2410.23746) documents that Binoculars
  achieves only ~55% AUROC on Claude-generated text vs ~88% on GPT-3.5. If the source
  model is plausibly Claude, treat low scores with extra caution.
- **Iteratively-paraphrased text is a ceiling.** PADBen (arXiv 2511.00416) shows detectors >90% on
  direct AI text fail catastrophically on text that has been iteratively paraphrased through one or
  more LLMs. If the user mentions the text was paraphrased or rewritten, down-weight all signals.
- **Stylistic cues are corpus-conditional.** SHAP-based explainability analysis (arXiv 2603.23146) shows that
  surface stylistic features detectors rely on are dataset-specific, not stable authorship signals.
  This applies most strongly to Signal I (rhetorical scaffolding). Do not over-anchor on any single
  signal; require corroboration across categories.
- **Multilingual text needs language-matched calibration.** AI detectors badly misclassify non-English text — they wrongly flag lightly-polished
  human Arabic as AI, with one commercial detector dropping from 92% to 12% accuracy (arXiv 2511.16690). Refuse High confidence on non-English text
  unless calibration is known.

### Reference detector landscape (for context)

If the user asks "what would tool X say?", these are the current characteristics:

- **GPTZero (2025)** uses RL adversarial self-training plus a learned classifier ensemble, not just
  perplexity + burstiness. Produces a 4-class output (human / slight / moderate / full AI-assist).
  Older "GPTZero relies on perplexity + burstiness" framing is stale.
- **Binoculars** is a strong zero-shot baseline but has the Claude blind spot above.
- **Pangram 3.0** claims 99.98% accuracy with 1-in-10,000 FPR and 97% on humanized text per vendor
  benchmarks (independent replication pending).
- **EditLens** estimates AI-edit fraction rather than binary authorship (94.7 F1 binary, 90.4 F1 ternary).
- **Ghostbuster** is the canonical black-box (no token probs needed) detector — 99 F1 in-domain,
  degrades out-of-domain.
- **DependencyAI** uses syntactic dependency n-grams + LightGBM, cross-lingual without LLM access.

## Source

The nine-signal scoring framework and scoring rubric are adapted from the
[ai-check](https://github.com/harshaneel/humanize) skill by Harshaneel Gokhale (MIT
License, Copyright (c) 2026 Harshaneel Gokhale), part of the same project as `ai-clean`'s
source. That framework is itself grounded in the AI-text-detection literature (Wu et al.
2025 - Junchao Wu, Shu Yang, Runzhe Zhan, Yulin Yuan, Lidia Sam Chao, and Derek Fai Wong,
"A Survey on LLM-Generated Text Detection: Necessity, Methods, and Future Directions,"
Computational Linguistics 51(1):275-338, 2025, https://aclanthology.org/2025.cl-1.8/;
Mitchell et al. 2023, Kujur 2025, AAAI 2025 shared task). The additional
content-pattern flags folded in above (sales language, name-dropping, chatbot residue,
knowledge-cutoff disclaimers, formatting abuse, and the false-positive guardrails) are adapted
from Wikipedia's ["Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing),
maintained by WikiProject AI Cleanup, via the humanizer skill (github.com/blader/humanizer, MIT).
