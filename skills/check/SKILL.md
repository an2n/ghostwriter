---
name: check
description: >
  Use when someone asks "does this sound AI?", "check if this is AI-written", "what gives
  this away as AI", "run check on this", or "score this text". Also use when reviewing
  a draft for AI tells before publishing, or when a piece of text reads as suspiciously
  polished, generic, or pattern-y and the user wants a forensic breakdown of why.
---

# Check

Reads a piece of text and reports how strongly it reads as AI-written, with a concrete
list of what fired and why. This is a find-only skill - it never rewrites anything. See
`polish` for the fix side.

## How the scoring works

Every check below is a **tell**: something that either fires or doesn't. Each tell carries
a fixed weight - 1 (weak), 2 (moderate), or 3 (strong) - based on how reliable it is as
evidence on its own. Add up the weights of everything that fires, then divide by the
text's length in hundreds of words to get a **tell density**: points per 100 words. A
2,000-word article and a 40-word reply shouldn't be judged on the same raw total, so
density normalizes for length. For anything under 100 words - the common case for a
single post or reply - skip the division and use the raw total directly against the same
bands, with confidence capped lower given the small sample.

| Density (points per 100 words) | Verdict |
|---|---|
| 0 - 1 | Reads human |
| 1 - 3 | Mostly human |
| 3 - 6 | Mixed signals |
| 6 - 10 | Reads AI |
| 10+ | Heavily AI |

A phrase can count toward at most two tells when it's genuinely diagnostic for both (e.g.
"it is important to note that" is both stock vocabulary and reflexive hedging) - never
double-count it twice within the same tell.

## Cluster 1: Word choice

Vocabulary and phrase-level tells - wrong regardless of what sentence they sit in.

**Stock AI vocabulary** (weight 1 each, capped at 3 points total for this tell even if
more fire): delve, leverage (verb), utilize, robust, comprehensive, streamline,
foster/fostering, facilitate, pivotal, nuanced, notable/notably, enduring, garner,
valuable, vibrant, intricate/intricacies, interplay, tapestry (abstract noun), testament
(figurative), underscore (verb), showcase (verb), key (as a vague adjective), align with,
emphasizing, enhance, quietly (as a hedge-flavored adverb), multifaceted, in the realm of,
the landscape of (abstract noun), a myriad of, a plethora of, actually (as filler),
additionally (as an opener), it is worth noting, it is important to note. Cite the exact
word that fired.

**Copula avoidance** (weight 2): swapping "is/are/has" for something fancier - "serves
as", "stands as", "marks", "represents", "boasts", "features", "offers". "The bakery
serves as a neighborhood fixture" should just be "The bakery is a neighborhood fixture."

**Inflated significance** (weight 2): dressing an ordinary fact up as historically
important - "stands as a testament to", "marks a pivotal moment", "indelible mark",
"evolving landscape", "setting the stage for", "deeply rooted in", "a key turning point".
"The shop opened in 2003, marking a pivotal moment in the block's retail history" should
just be "The shop opened in 2003."

**Brochure language** (weight 2): ad copy leaking into plain prose - "nestled in the heart
of", "boasts a rich heritage", "renowned for", "breathtaking", "must-visit", "stunning".
Reads like a travel pamphlet regardless of the subject.

**Elegant variation** (weight 2): relabeling the same person or thing across sentences
instead of reusing the name or a pronoun - "the founder... the entrepreneur... the
visionary... the businessman" for one person across four sentences. A repetition-penalty
sampling artifact; real writers reuse the noun or say "she"/"they."

**Padding participles** (weight 1): a plain fact given a trailing "-ing" clause that adds
nothing - "...symbolizing its enduring connection to the community" tacked onto a
sentence that already stated the fact. Remove the clause and check whether anything was
actually lost.

**Hyphenated-pair overuse** (weight 1): "third-party", "cross-functional", "data-driven"
hyphenated even after the noun, where grammar doesn't call for it ("the report is
data-driven" should be "data driven").

**Vague relation words** (weight 1): "in connection with", "associated with", "connected
to" standing in for a real preposition or verb ("of", "for", "by", "caused by") to avoid
stating the actual relationship directly.

## Cluster 2: Rhythm

How sentence length and softening language behave across the whole piece.

**Flat sentence rhythm** (weight 3): three or more consecutive sentences within 5 words
of each other in length, or nothing under 8 words anywhere in a 150-word stretch, or a
total absence of short fragments. Read it aloud - a steady pulse instead of natural
variation is the tell. Report the actual word-count sequence as evidence (e.g. "14, 16,
13, 15, 17").

**Reflexive hedging** (weight 2): "often", "generally", "typically", "it can be argued",
"it is worth mentioning" softening a claim that didn't need it, versus genuine
uncertainty expressed personally ("I'm not sure this holds when..."). Diplomatic
non-answers to obvious tradeoffs ("while X has benefits, it also presents challenges")
count too.

## Cluster 3: Shape

Document- and paragraph-architecture patterns imposed regardless of content.

**Three-beat symmetry** (weight 3): three items or beats with identical grammatical
shape, split across sentences or comma-joined inside one ("fix the bug, write the tests,
open the PR"). A perfectly symmetrical triplet is a tell either way - real writers vary
the shape or use two items.

**Suspiciously clean paragraph arcs** (weight 2): every paragraph does exactly one job
and lands cleanly, nothing left unresolved. Real writing has at least one paragraph that
does two jobs or doesn't fully close.

**Fake urgency arc in async messages** (weight 2): for Slack/chat-style text -
accomplishment, then caveat, then next-steps, mapped directly onto intro/body/conclusion.
Real messages loop back, add an afterthought, or end somewhere the structure didn't set
up.

**Leading with the negative** (weight 2): "The case for X isn't about Y, it's about Z" -
naming what something isn't before saying what it is. Real writers lead with the actual
point.

**Formatting as substance** (weight 2): bold mini-headings on every bullet, title-case
section headers, decorative emoji on list items. Individually weak, but stacked together
they signal a document assembled from a template rather than written.

**Stock "challenges" section** (weight 2): "Despite its [positive framing], X faces
several challenges... Despite these challenges, X continues to..." - a rigid formula that
restates vagueness instead of adding facts.

**Heading that just repeats itself** (weight 1): a heading followed by one line that only
restates the heading ("## Performance" / "Speed matters.") before real content starts.

**Fake range** (weight 1): presenting two things as endpoints of a spectrum when they
aren't one ("from the founding to the future, from the first customer to the
thousandth").

**Empty uplift ending** (weight 2): closing on vague optimism instead of the last
concrete fact ("the future looks bright, exciting times are ahead").

**Left-in blanks** (weight 3): a bracketed or parenthetical fill-in-the-blank nobody
replaced - "[Company Name]", "(insert client testimonial here)". Near-certain on its own.

**Documenting the old behavior** (weight 1): comments or docs describing what something
used to do instead of what it does now, outside an actual changelog or migration note.

## Cluster 4: Voice and construction

Whether the piece sounds like it came from somewhere, plus the sentence-level rhetorical
moves AI leans on hardest. These last ones are the toughest to catch - they read as good
writing.

**No personal trace** (weight 2): no first person where it would be natural, no second
person in instructional content, a uniformly polished tone with zero roughness or
informality spikes, an opening that reads like a thesis instead of a scene.

**Register collapse** (weight 3): casual markers (`lmk`, `~60%`) sitting on top of
fully-formed, grammatically polished sentences. Real casual writing has fragments
underneath the shorthand, not just shorthand sprinkled onto formal prose.

**Sudden polish or dialect jump** (weight 1): a noticeable jump in grammatical polish
partway through, or an English-variety mismatch with the piece's own context (American
idiom in a clearly British-context piece). Plenty of innocent explanations exist - weak
alone, moderate stacked with other tells in the same section.

**Scaffolding left in from a chat session** (weight 3, fires as a strong tell even alone):
"I hope this helps!", "Of course!", "Want me to expand on any section?", "Here is an
overview of X" - a chatbot's greeting or offer that belongs to the conversational turn,
not the document. Also covers older refusal residue ("As an AI language model, I can't
directly...").

**Literal chatbot markup or tracking artifacts** (weight 3, fires as a strong tell even
alone): raw technical residue from a chatbot's output, unresolved -
`:contentReference[oaicite:0]{index=0}`, `turn0search0`/`turn0image0`, `grok_card`,
`[cite: 1]`, lenticular brackets (`【...†...】`), `ppl-ai-file-upload`, UTM params like
`utm_source=chatgpt.com` or `referrer=grok.com`, or raw Markdown syntax (`**bold**`, `#
heading`, `---`) leaked into a format that isn't Markdown.

**Disclaiming instead of answering** (weight 2): "As of [date]", "specific details are
limited in available sources," followed by a confident-sounding guess dressed as fact.

**Praise before the answer** (weight 2): "Great question! You're absolutely right
that..." - agreeing with the reader before actually answering.

**Staged honesty** (weight 1): "Honestly?", "Look,", "Here's the thing," used as a
standalone hook rather than mid-sentence, claiming candor before an ordinary point.

**Curly punctuation** (weight 1): typographic quotes/apostrophes where straight ones are
the register norm. Weak alone, moderate stacked with anything else.

**Mechanical connectors** (weight 2): "Furthermore," "Moreover," "Additionally," as
paragraph openers; "it is clear that"; "as previously mentioned"; more than one "however"
per 200 words.

**Manufactured reveal** (weight 2): "Turns out the config had a different timeout" - a
dramatic-discovery frame around a fact that didn't need one. State it directly instead.

**Naming the pattern before showing it** (weight 1): "The pattern is almost always the
same," followed by the pattern. Just show it.

**Announcement before the point** (weight 1): "The rule I use:", "What I didn't expect
was...", "Let's dive in" - signposting the reveal instead of making it, with or without
the colon.

**Fake depth** (weight 1): "The real question is," "at its core," "fundamentally" -
dressing an ordinary claim as a hidden truth.

**Dash-wrap overuse** (weight 2): more than one em dash per 300 words, especially the
double-wrap ("X — like this — Y"). This fires identically when written with a plain or
spaced hyphen instead of an em dash - swapping the character to satisfy a "no em dash"
rule doesn't remove the construction, so check for the shape, not the glyph.

**Semicolons joining independent clauses** (weight 1): outside academic or legal
register, basically always a tell.

**Mid-clause colon** (weight 1): "The problem: nobody tests this" - the colon
interrupting an incomplete clause instead of following a full one.

**Over-smooth paragraphs** (weight 2): every sentence connects so cleanly to the next
that nothing could be removed without the paragraph flowing *better*. Real writing has at
least one sentence per paragraph that leaves a small gap if you pull it. Down-weight this
in registers that genuinely reward tight coherence - legal briefs, abstracts.

**Manufactured escalation** (weight 2): three items with no conjunctions, each longer and
heavier than the last, building emotional weight artificially.

**Balanced opposite pairs** (weight 2): "X constantly, Y only once" - an amplifier paired
against a diminisher for rhetorical symmetry. Also covers the closer form: two
consecutive sentences with mirrored subjects ("The code is one thing. Maintaining it is
another.").

**Punchy paragraph-closer** (weight 2): a short, quotable fragment landing the "lesson"
of a paragraph - "That's the part that stuck." Delete it and let the evidence stand
alone.

**"Is the real work" framing** (weight 1): a formulaic landing phrase for delivering a
conclusion.

**Reframe-as-insight pivot** (weight 2): "Seen this way, the whole thing reads
differently" - a participial pivot manufacturing the appearance of insight the sentence
didn't earn.

**Frame-first opener** (weight 1): starting with the thesis ("X is the hard part")
instead of the actual experience.

**Repeated question-shape list** (weight 2): four parallel "what/why" clauses inside one
sentence instead of varied noun phrasing.

**Self-aware parenthetical** (weight 1): "(which I choose to read as progress)" - naming
your own interpretation instead of just stopping at the observation.

**Matched reason-chains** (weight 1): three consecutive sentences all shaped "X because
Y," even across different subjects.

**Comparative framing instead of direct description** (weight 2): "more X than Y," or its
reversed cousin "X rather than Y" - describing something by contrast with an opposite
instead of just describing it.

**Negating before asserting** (weight 2): "not just X," "not X, it's Y" - naming what
something isn't before saying what it is.

**Setup without a colon** (weight 1): "What surprised me was..." - an announcement
sentence, colon or not.

**Quotable closer or mirrored reversal** (weight 2): either a standalone-wisdom closing
line, or full chiasmus ("specific about being wrong" mirrored against "vague about being
right") - real insight is asymmetric.

**Repeated opener** (weight 2): the same sentence-starter two or three times in a row for
emphasis. Collapse or vary it.

**Clean binary where there's a spectrum** (weight 1): "either X or Y" presented as the
only options, including the symmetric-tradeoff variant "(X, but Y) or (A, but B)."

**Choppy fragment run** (weight 1): three or more very short sentences in a row (under 7
words each) with no longer counterweight - the inverse rhythm problem, same family as
forced dramatic-fragment punchlines.

**Aphorism dressed as insight** (weight 1): "X is the language of Y" mid-paragraph, not
just as a closer.

**Answering nobody** (weight 1): "This isn't mainly about X," "to be clear" - rebutting a
position that appears nowhere else in the piece.

**Straw option, quickly dismissed** (weight 1): "A tempting approach would be X, but..."
introducing an option no reader would seriously consider and never mentioning it again.

## What doesn't count on its own

Every one of these needs corroboration from something else before it moves the verdict:

- Perfect grammar - plenty of writers are professionals or edited.
- Mixed casual/formal register in one piece - can reflect field, age, or habit.
- Generic dry prose without any of the tells above - dryness alone isn't a tell.
- Formal or academic vocabulary outside the stock-vocabulary list.
- Salutations and sign-offs on a letter or email - these predate ChatGPT by centuries.
- A single "however," "moreover," or "additionally" - only piled-up use counts.
- Curly quotes alone - many editors and CMSes auto-curl.
- Em dashes alone - many professional editors use them; only the construction (paired
  with other tells) is evidence.
- One short sentence for emphasis - only three or more in a row counts.
- Deliberate repeated openings for rhythm ("She came. She saw. She conquered.") - only
  flag repetition that adds nothing.
- A named, answered objection - the "answering nobody" tell requires the objection to
  come from nowhere.
- Unsourced claims - common in ordinary human writing; not evidence alone.
- Anything from before November 30, 2022 (ChatGPT's public launch) - with rare
  exceptions, not AI-written regardless of score.

Weigh these the other direction - toward human, even against fired tells:
- Specific, unusual, hard-to-invent details (a real address, an odd direct quote).
- Mixed feelings or unresolved tension stated directly.
- Dated, era-bound slang or in-jokes tied to a specific year - models lag current slang.
- Genuine self-corrections mid-sentence.
- Real sentence-length variety, not an even mid-length cadence.

## Calibration

- Texts under 100 words have fewer tells available to fire at all - cap confidence lower
  regardless of the density result.
- Technical writing with domain jargon can suppress the word-choice cluster even in AI
  text - don't penalize accurate domain vocabulary.
- Academic or legal writing legitimately uses hedges and semicolons - down-weight those
  tells in that register.
- ESL writing can mimic some of these patterns (uniform sentence length, hedge-heavy) -
  note when that's plausible.
- The voice-and-construction cluster fires on patterns that read as *good* writing - don't
  discount them for that reason. That's precisely why they're the hardest tells: AI
  learned them from skilled human writers.
- A single well-turned closing line in a long personal essay is less diagnostic than the
  identical pattern in a 200-word post where it's the only memorable sentence.

### Known ceilings on this method (and on any rule-based check)

- Raw, non-instruction-tuned base-model output reads as human to current detectors - what
  they actually key on is RLHF/instruction-tuning residue (polite hedging, structured
  enumeration, "helpful assistant" register), not "AI-ness" itself. If the text plausibly
  came from a base model or a lightly-paraphrased attack, cap confidence lower even when
  surface tells look clean.
- Zero-shot detectors have a documented blind spot on Claude-generated text specifically
  (much lower detection rates than on other model families) - treat a clean result on
  plausibly-Claude text with extra caution.
- Text run through one or more paraphrase passes defeats most surface checks, this one
  included - if the user mentions the text was paraphrased, down-weight everything.
- Non-English text gets miscalibrated badly by most detectors, including this one -
  refuse high confidence outside English unless you have specific calibration for that
  language.

## Output

For every tell that fires, one line: name, a quote or description, and its weight. Skip
anything scoring 0 - don't list what didn't fire. Follow with two to four sentences in
plain language naming the strongest tells - specific about which phrases or absences
mattered, not just a density number. If the verdict lands at "Reads AI" or "Heavily AI,"
add up to three concrete fixes as compact bullets, not a full rewritten sample.

If another skill invoked this one internally (e.g. `ghostwriter` running a pre-check or
verification pass) rather than the user directly asking to check a piece of text, skip
printing any of this. Still run the full analysis for real, but hand back only the
verdict and total density for the caller to build its own one-line status.

## What a clean result actually means

A clean result here means no known, rule-based tell fired. It is not proof the text would
pass a real trained classifier (Pangram, GPTZero) - this is a self-graded checklist
applied by the same kind of model that may have drafted the text, and it can miss
patterns a learned classifier catches, or flag things a learned classifier wouldn't. Don't
report a clean pass as "this is safe" or "this will pass detection" - say what it actually
means: no rule violations found here, risk from anything this checklist doesn't cover
still possible.

## Source

The functional idea of scoring AI-generation signals across multiple categories, and much
of the underlying pattern knowledge, builds on prior work in this space: the
[humanize](https://github.com/harshaneel/humanize) project by Harshaneel Gokhale (MIT
License), and Wikipedia's ["Signs of AI
writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) (CC BY-SA 4.0,
maintained by WikiProject AI Cleanup), which that project and the
[humanizer](https://github.com/blader/humanizer) skill (MIT) also draw on. The clustering,
the density-based scoring mechanic, and the wording throughout are this skill's own.

Academic grounding: Junchao Wu, Shu Yang, Runzhe Zhan, Yulin Yuan, Lidia Sam Chao, and
Derek Fai Wong, "A Survey on LLM-Generated Text Detection: Necessity, Methods, and Future
Directions," *Computational Linguistics* 51(1):275-338, 2025
(https://aclanthology.org/2025.cl-1.8/); Mitchell et al. 2023 (DetectGPT); the AAAI 2025
shared task on machine-generated text detection.
