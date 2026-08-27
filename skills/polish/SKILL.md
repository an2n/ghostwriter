---
name: polish
description: >
  Use whenever the user asks to "humanize", "make this sound more human", "rewrite to
  avoid AI detection", "make this less AI-sounding", "add a human voice", or "write like
  a person". Also use when the user pastes text and asks why it reads as robotic, generic,
  flat, or AI-like, or when generating new text in a register where AI tells (em dashes,
  semicolons, hedges, banned vocabulary like "delve", "leverage", "robust") would damage
  credibility.
---

# Polish

Rewrites text to move it toward the statistical and stylistic shape of human writing.
This is a rewrite-only skill - it never scores anything. See `check` for the audit
side; the two are companions but operate independently.

## Six moves, apply all of them

Not a checklist to pick from - every move gets applied on every rewrite. Skipping one
because "this draft doesn't need it" is usually wrong; the tells compound quietly.

### Move 1: Word choice

Swap predictable vocabulary for what a person would actually reach for in context:

- Generic verb → specific one: "address" → "untangle", "utilize" → "lean on", "implement"
  → "wire up"
- Let the subject matter pick the words: a backend engineer says "flush the buffer," not
  "clear the temporary data storage"
- One or two genuinely surprising but accurate word choices per paragraph
- Cut on sight: delve, leverage (verb), robust, streamline, significant, comprehensive,
  notably, it is worth noting, in today's fast-paced world

**Elegant variation.** LLMs avoid repeating a noun by cycling synonyms for the same
referent - a repetition-penalty sampling artifact. "The founder built the company. The
entrepreneur later sold it. The visionary now advises startups." Same person, three
labels. Fix: pick the canonical noun and reuse it, or use a pronoun for variation.
Synonym-cycling is detectable; pronoun reference reads human.

**Copula avoidance.** "Serves as," "stands as," "marks," "represents," "boasts,"
"features," "offers" standing in for "is"/"are"/"has." "The bakery serves as a
neighborhood fixture" → "The bakery is a neighborhood fixture." Use the plain verb.

**Inflated significance.** "Stands as a testament to," "marks a pivotal moment,"
"indelible mark," "evolving landscape," "deeply rooted in." Cut entirely or replace with
the concrete claim: "The shop opened in 2003, marking a pivotal moment in the block's
retail history" → "The shop opened in 2003."

**Brochure language.** "Nestled in the heart of," "vibrant," "breathtaking," "must-visit,"
"boasts a rich heritage," "renowned for." Cut it. "Nestled in the heart of the valley,
Marrowbend stands as a vibrant town with a rich cultural heritage" → "Marrowbend is a town
in the valley, population around 4,000."

**Vague sourcing.** "Industry observers have noted," "experts argue," "several sources
indicate" without naming one. Name the actual source, or cut the claim: "Industry
observers have noted adoption has accelerated" → "Adoption tripled between Q2 2024 and Q1
2025 per [named survey]." If you can't anchor it, don't make the claim.

**Vague relation words.** "In connection with," "associated with," "connected to"
avoiding a direct relationship. Use "of," "for," "by," "caused by," or "working with," and
state the actual connection.

**Hyphenated-pair overuse.** "Third-party," "cross-functional," "data-driven" hyphenated
after the noun where grammar doesn't require it. "The report is data-driven" → "data
driven."

**Filler constructions.** Run this substitution pass:

| Verbose | Direct |
|---|---|
| In order to achieve this goal | To achieve this |
| Due to the fact that | Because |
| At this point in time | Now |
| In the event that | If |
| Has the ability to | Can |
| It is important to note that the data shows | The data shows |
| Make a decision | Decide |
| In a manner that is | (drop entirely) |
| With regard to / With respect to | About / On |
| Despite the fact that | Although |
| Prior to / Subsequent to | Before / After |
| The fact that | (drop entirely, rephrase) |

### Move 2: Sentence rhythm

Enforce real length variance. Target: standard deviation of sentence word count above 8.

- Every 3-4 sentences, drop in one sentence of 5 words or fewer. Just drop it. Like that.
- Every 3-4 sentences, let one sentence genuinely earn its length - a compound thought
  that would lose its relationship if split.
- Never more than 3 consecutive sentences within 5 words of each other.
- Uniform *short* runs are just as much a tell as uniform *long* ones - three choppy
  fragments in a row without a longer counterweight reads forced, not punchy.
- Watch the middle of a paragraph specifically: the opening and closing sentences often
  vary on their own, but the middle three or four collapse into the same band.

### Move 3: Cut the padding

Audit every softening word and every imposed structure at once - both are the same
underlying tell: content shaped by a template instead of by what actually needs saying.

**Reflexive hedges.** Delete "it is important to note that," "generally speaking," "in
many cases," "often," "typically" unless genuine uncertainty is being expressed. Replace
with direct assertion. If uncertainty is real, say it personally: "I'm not sure this
holds for edge cases" beats "results may vary."

**Announcing before showing.** "The pattern is X" said before X is described. "The rule I
use:", "The key insight:" - preamble before the actual content. State the thing directly.

**Diplomatic non-answers.** "While X has benefits, it also presents challenges" dodging
an actual tradeoff. Name the specific tradeoff instead.

**Bullet-list default.** Convert intro-plus-three-bullets into a flowing paragraph where
the items are joined by sense, not markers, unless the user specifically asked for a
list.

**Bloated sectioning.** "There are three main factors: ..." - just discuss the factors
and let the transitions carry the structure. Numbered sections only when order genuinely
matters.

**Restating what was just said.** Topic sentence, evidence, then a restatement of the
topic sentence. Cut the restatement - humans don't recap two sentences later.

**Leading with the negative.** "The case for X isn't Y, it's Z" / "It's not about X, it's
about Y." Lead with Z (or Y) directly; address the alternative afterward if it's worth
addressing at all.

**Comparative framing.** "More specific than vague," "faster than Y," or the reversed
"X rather than Y." Describe the thing directly; drop the contrast.

**Negating before asserting.** "Not just X," "not X, it's Y." State what it is, skip the
negation.

**Clean binaries.** "Either X or Y," "between X and Y" where the real situation is a
spectrum or has a third option. Name the actual situation.

**Symmetric trade-off pairs.** "(X, but Y) or (A, but B)" - real trade-offs are
asymmetric. Break the symmetry or drop one side.

**Stock structural moves**, one line each - fix means the same as the description implies
unless noted:

| Pattern | Fix |
|---|---|
| Repeated sentence opener 2-3x in a row | Collapse or vary the opener |
| "Turns out X" as a reveal | State X directly |
| Thesis-first opener on a personal piece | Start in the middle of the experience |
| Formula essay opener ("The failure I think about most...") | Start with the incident itself |
| Three-item escalating list, no conjunctions | Break the third item into its own sentence, or join two with "and" |
| Amplifier/diminisher opposition ("X constantly, Y once") | Make the contrast asymmetric |
| Punchy paragraph-closer delivering a "lesson" | Delete it; let the evidence stand |
| Formulaic landing phrase ("is the actual work") | State the conclusion plainly |
| Mirrored-subject closing pair | Vary one subject; break the mirror |
| Every sentence connecting too perfectly (over-smooth) | Introduce one sentence per paragraph that shifts direction or misfires slightly |
| Participial reframe pivot ("Seen this way...") | Make the observation directly |
| Tricolon (three beats, identical grammar) | Break the symmetry, or cut to two |
| Perfect one-job-per-paragraph arc | Let one paragraph do two jobs, or leave something unresolved |
| Three-act Slack arc under the surface | Add a fourth element that doesn't fit, or loop back to something |
| Outline-formula "Challenges" section | Cut it, or replace with the specific challenge and what's being done |
| Unfilled placeholder ("[Company Name]") | Fill it with the real detail, or rewrite so it isn't needed |

### Move 4: Anchor with specifics

Every abstract claim needs a real anchor:

- "Many companies have adopted this" → "Three teams I've seen do this - one at a
  50-person startup, two at larger orgs - all landed on the same approach."
- "Performance improved significantly" → "Latency dropped from 340ms to 80ms under the
  same load."
- "This is a common problem" → "Every team I've talked to hits this around the
  50-engineer mark."

If real specifics aren't available, use a plausible specificity frame instead of
inventing a fact: "when you're running at X scale...", "in the cases I've seen...". Never
fabricate a number, name, or date to sound more concrete - that's its own kind of tell,
and it's dishonest regardless.

### Move 5: Let a voice come through

Human writing carries the writer's actual perspective, not a polished, opinion-free
narrator:

- First person where natural: "I find that...", "In my experience..."
- Occasional second person: "If you've ever debugged this..."
- A rhetorical question used as a real transition, not a tic
- Mid-thought self-correction: "actually, that's not quite right - more precisely..."
- Contractions in conversational registers

**Strip the assistant voice.** This is the single highest-value cleanup, because current
detectors mostly key on instruction-tuning residue - the "helpful assistant" register -
rather than "AI-ness" in the abstract.

| Tell | Fix |
|---|---|
| "Here's how I'd think about it...", "Let me walk you through..." | Cut the framing, just say the thing |
| "On one hand X, on the other Y, ultimately depends on..." | Pick a side and state it |
| Listing 5 unrequested considerations instead of answering | Answer, then add the constraint if needed |
| Defining terms the reader already knows | Cut it, trust the reader |
| A caveat appended to every claim | Make the claim; caveat only real edge cases |
| "That's a great question, and..." | Cut entirely |
| Closing summary recapping what was just said | Cut it |
| "I hope this helps", "let me know if..." | Cut, end on the last substantive sentence |
| "While I understand the appeal of X, I would suggest..." | Just disagree: "X doesn't work because Y" |
| Knowledge-cutoff disclaimer ("as of my training cutoff...") | Cut, state what you actually know |
| Chat scaffolding pasted into content ("Here is an overview of X", "Of course!") | Strip on sight |
| Prompt-refusal residue ("As an AI language model, I can't...") | Strip, state the content directly |
| Sycophantic opener ("Great question!", "You're absolutely right!") | Cut; if something's genuinely good, name what specifically |

### Move 6: Reset the punctuation

**Em dashes and their hyphen disguise.** Max one per 300 words. Never the double-wrap ("X
— like this — Y"), never as a list-joiner mid-sentence. If the register bans em dashes
(a style guide, a voice profile), don't just swap the character for a plain hyphen - "X -
like this - Y" is the exact same construction wearing different punctuation. Break the
construction itself: cut the aside, split the sentence, or fold it into one clause.
Satisfying "no em dash" by character-substitution alone leaves the tell fully intact.

**Semicolons.** Treat every one as a bug outside explicitly formal/academic register.
Replace with a period, or "and"/"but"/"so" when the relationship matters. Exception:
comma-containing lists ("Austin, TX; Denver, CO").

**Mid-sentence colons.** Colons go at the end of a complete clause, introducing what
follows - not mid-thought. "The answer is: start earlier" → "Start earlier." One colon
per paragraph max in non-list prose.

**Curly quotes.** Straight quotes and apostrophes are the human signal in technical and
casual writing. Run a find-replace before shipping unless the register is genuinely
typeset publishing (a magazine, a print book).

## The chatbot-artifact check (run this on every output, no exceptions)

Search the draft for literal residue from a chatbot's raw output before calling anything
done:

- `oaicite`, `turn0search`/`turn0image`, `grok_card`, `[cite: `, `[span_`, lenticular
  brackets (`【...†...】`), `utm_source=chatgpt.com`/`openai`/`copilot.com`,
  `referrer=grok.com`
- Raw Markdown (`**bold**`, `# heading`, `---`) leaked into a format that isn't Markdown
- Any bracketed placeholder left unfilled ("[Company Name]", "(insert testimonial
  here)")

Any hit gets deleted outright - this isn't a style judgment call, it's leftover garbage.

## Rewrite protocol

1. **Read the input first.** Note the domain, audience, and register.

2. **Check for a voice sample.** If the user has supplied their own prior writing, extract
   5-10 concrete style facts before touching anything else - real sentence-length
   variance, real vocabulary level, how paragraphs open, real punctuation habits, real
   recurring phrases. Apply the six moves *in service of those facts*, not the generic
   defaults below. If the sample runs short and fragmented, don't "improve" it toward
   longer sentences - that would be moving away from the actual voice, not toward it.

3. **Check for factual anchors.** Count the numbers, names, dates, and concrete examples
   in the input. If there are none and no voice sample was given, stop and say so instead
   of producing clean-but-empty output:

   > This input has no factual anchors - no numbers, names, dates, or examples. A cleaned
   > version would look polished but still read as generic to a learned classifier, which
   > scores specificity separately from surface style. Options: add real specifics, give
   > me a writing sample to match, or confirm you want me to proceed anyway.

4. **Rewrite in one pass**, applying all six moves. Light editing won't move the
   statistical fingerprint - this needs real structural change.

5. **Gate check before calling it done.** Scan for each of these and fix any hit:
   - Em dash count over the 1-per-300-words threshold, in either dash form
   - Any semicolon
   - Any word from the banned list below
   - Comparative framing ("more X than Y", "X rather than Y")
   - Negating-before-asserting ("not just X", "not X, it's Y")
   - Chatbot markup/citation residue (see above)
   - Unfilled placeholders

6. **Self-check what the gate doesn't cover:**
   - No three consecutive sentences within 5 words of each other
   - At least one sentence under 6 words per 150 words of output
   - Every paragraph has at least one specific anchor
   - No bullet list unless requested
   - Consistent voice throughout - no drifting from third-person formal to first-person
     casual mid-piece
   - Every colon follows a complete clause (informal fragments are fine in casual
     registers)

7. **One audit loop.** Ask directly: what in this still reads as AI? These residuals are
   almost always the Move 3/Move 5 patterns that survive because they feel like good
   writing - a mini-aphorism closer, a mirrored pair, a leftover assistant-voice tic.
   Fix them, then re-run steps 5-6 once. Don't loop past this - diminishing returns, and
   over-editing creates a different problem (choppy, voiceless prose). If a flagged
   sentence's removal leaves a paragraph too thin, the paragraph was too thin - collapse
   or merge it rather than keeping the pattern to preserve length.

8. **Length sanity check.** If the output is under half the input's length, the input
   likely had a lot of padding that got correctly cut. Don't pad it back - that
   reintroduces exactly what was removed. Instead, append one line after the rewrite (not
   before): "Input had a lot of filler; this is N% shorter. To make it longer honestly,
   give me real specifics to add."

9. **Output the rewritten text only.** No preamble, no "here's the humanized version."
   Just the text.

## Writing new content from scratch

Same six moves apply from the first sentence, not just to a rewrite:

- Start mid-thought when the register allows: "The tricky part about X isn't what most
  people think."
- No "In this post, I will..." opener.
- No summary paragraph unless the piece is genuinely long enough to need a re-anchor.
- Calibrate to the domain - an engineer's Slack message and a founder's board memo don't
  sound alike.

## Domain calibration

**Technical:** domain-native vocabulary ("the hot path," "this falls apart at scale"),
short declarative sentences for definitive claims, direct tradeoffs ("the downside is
real: you lose..."), real tool names and version numbers when available.

**Narrative/essay:** open with a scene, not a thesis. Let the argument emerge from
evidence. Deliberate fragments for rhythm. One moment of genuine uncertainty per 500
words.

**Professional/business:** cut "I hope this message finds you well," state the ask in the
first sentence or two, use real numbers and deadlines, keep paragraphs to 2-3 sentences.

**Slack/async updates:** abbreviations and approximations (`~60%`, `<10min`, `fwiw`,
`lmk`), fragments and incomplete clauses throughout, mid-message second thoughts ("oh
also -"), one thought bleeding into the next rather than topic-per-paragraph, numerals
with approximation markers rather than spelled-out numbers, lowercase default. The
accomplishment-caveat-next-steps arc has to actually break somewhere, not just get
`fwiw` sprinkled on top.

## What this skill does not do

- Guarantee a 0% score on any commercial detector - no method does that reliably.
- Add invented facts to increase apparent specificity - use plausible framing instead,
  never fabrication.
- Change the factual content of the input, only its expression.
- Apply the identical transformation to every register - domain and audience matter.

## Reference: banned words and phrases

**Core vocabulary:** delve, leverage (verb), utilize, robust, comprehensive, streamline,
foster, facilitate, pivotal, nuanced, multifaceted, crucial (overused), enduring, garner,
valuable, vibrant, tapestry (figurative), testament (figurative), interplay, intricate,
intricacies, landscape (abstract noun), showcase (verb), highlight (standalone verb),
underscore (standalone verb), align with, actually (as filler), additionally (as opener)

**Hedge clusters:** it is important to note, it is worth mentioning, notably, it's worth
noting, in many cases, generally speaking, it can be argued

**Formula openers/closers:** in today's fast-paced world, in conclusion, in summary, to
summarize, it goes without saying, needless to say, at the end of the day, at its core,
under the hood, the standard fix, the common approach, simple enough on paper

**Transition fingerprint:** furthermore, moreover, it is clear that, this highlights,
this underscores, as previously mentioned, turns out (as a pivot), it turns out that

**Significance inflation:** stands as a testament to, marks a pivotal moment in, indelible
mark, evolving landscape, setting the stage for, deeply rooted in, plays a vital role, a
key turning point, represents a shift in

**Brochure register:** nestled in the heart of, in the heart of, breathtaking,
must-visit, stunning, boasts a rich heritage, renowned for, groundbreaking (figurative),
vibrant (cultural copy)

**Quantifier inflation:** a myriad of, a plethora of, in the realm of, the landscape of
(abstract)

**False-depth tropes:** the real question is, what really matters, fundamentally, the
deeper issue, the heart of the matter, in reality

**Tutorial scaffolding:** let's dive in, let's explore, let's break this down, here's what
you need to know, now let's look at, without further ado

**Knowledge-cutoff disclaimers:** as of my training cutoff, up to my last training update,
while specific details are limited based on available information, based on what I know
up to

**Sycophantic prefixes:** great question, you're absolutely right, that's an excellent
point, of course!, certainly!

**Templated closers:** happy to jump on a call, let me know if you have any questions,
feel free to reach out, i hope this helps, looking forward to connecting soon

**Binary framing opener:** whether X or Y

## Source

The functional idea of a multi-lever rewrite pass targeting statistical AI-detection
signals, and much of the underlying pattern knowledge, builds on prior work in this
space: the [humanize](https://github.com/harshaneel/humanize) project by Harshaneel
Gokhale (MIT License). The six-move grouping, the protocol structure, and the wording
throughout are this skill's own.

Academic grounding: Junchao Wu, Shu Yang, Runzhe Zhan, Yulin Yuan, Lidia Sam Chao, and
Derek Fai Wong, ["A Survey on LLM-Generated Text Detection: Necessity, Methods, and Future
Directions,"](https://aclanthology.org/2025.cl-1.8/) *Computational Linguistics*
51(1):275-338, 2025; Mitchell et al. 2023 (DetectGPT).
