# Query craft

Adapted from Dan Russell's SearchResearch posts and Anthropic multi-agent lessons.

## Contents
- Breadth-then-depth
- Right level of abstraction
- Finding primary sources
- Querying against your own confirmation bias

## Breadth-then-depth

Default failure mode: long, hyper-specific queries that return few results. Anthropic's research agents had to be explicitly told to stop doing this.

Pattern:

1. **First pass: short, broad.** 2–4 word queries to map the landscape. "climate migration drivers". "displacement statistics". You're learning vocabulary, not finding answers yet.
2. **Second pass: targeted.** Now that you know the actual terms of art (e.g., "internal displacement", "IDMC GRID report", "slow-onset vs. sudden-onset displacement"), search for specifics.
3. **Third pass: primary sources.** Search for the dataset/paper/report behind the secondary claims you've now seen repeated. (Russell's SR-02 post warns that asking AI directly for "the consensus on climate migration" returns a blurry, averaged answer — the broad-then-narrow pattern is how you escape that.)

## Right level of abstraction

From Russell: prompts that are too abstract get platitudes; too specific get hallucinations. This applies to your own search queries too.

From Russell's SR-01 example on California coastal erosion:

- Too abstract: "tell me about coastal erosion in California" — returns a generic geology overview, useless for research.
- Too specific: "exact cubic yards of sand lost from southern Half Moon Bay between Nov 12 and Nov 15, 1983" — likely returns nothing, or a confidently fabricated number.
- Right: "1982-1983 El Niño coastal erosion Northern California" plus a follow-up asking which agencies/archives hold the wave-height and sand-loss data — keywords likely to appear in real documents, and a path to primary sources.

When you don't know the right level: start abstract, then use the vocabulary you find to get more specific.

## Finding primary sources

Strategies:

- Add `site:.gov`, `site:.edu`, or specific domains (`site:epa.gov`, `site:nature.com`) to push past SEO content.
- Add `filetype:pdf` to find reports and papers.
- Search for "[claim] dataset" or "[claim] methodology" to find the source behind a number.
- When a secondary source quotes a study, search for the study's title or first author directly.
- Wikipedia's "References" section is often the fastest path to primary sources for well-covered topics.

## Querying against your own confirmation bias

After you have a leading hypothesis, deliberately search for the *opposite*:

- Instead of "evidence X causes Y", also search "X does not cause Y" or "criticism of X causes Y" or "limitations of [study that supports X]".
- Search for the strongest opposing expert ("critics of [position]", "[position] debunked", "review of [position]").
- If you can't find any credible disconfirmation, that's evidence either (a) the question is settled or (b) you're inside an echo chamber. Distinguish by looking for sources that are *expert but outside the dominant institutional view* — review papers, dissents, replication failures.

This is the operational form of Heuer's "seek to refute, not confirm" rule.
