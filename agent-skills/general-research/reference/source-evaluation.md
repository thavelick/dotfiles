# Source evaluation: lateral reading

## Contents
- The four moves (Caulfield)
- Lateral vs. vertical reading (SHEG)
- Source-quality heuristics
- Funding and conflicts of interest
- Citation discipline

## The four moves

From Caulfield, *Web Literacy for Student Fact-Checkers*. Apply to every non-trivial source before relying on it:

1. **Check for previous work.** Has someone already fact-checked this claim? (Snopes, Politifact, academic reviews, Wikipedia's references section.) If yes, you may be done; if no, continue.
2. **Go upstream to the source.** Almost every web claim is a re-report. Trace it back to the original — the journal paper, the dataset, the press release, the actual document. Stop reporting on the report.
3. **Read laterally.** To evaluate a source, leave the source. Open new searches about the publication, the author, the funding, what other people say about them. The truth is in the network around the source, not on the source's About page.
4. **Circle back.** If you get lost in lateral reading, go back to the start of the claim with what you've learned and re-evaluate.

## Lateral vs. vertical reading

From SHEG (Stanford History Education Group / Digital Inquiry Group):

- **Vertical reading** = staying on the page, judging by URL, design, "About Us", tone. This is what naive readers do. It's what professional fact-checkers explicitly *don't* do.
- **Lateral reading** = opening other tabs to ask "who is this site, who funds it, who else cites it, what do critics say." This is how trained fact-checkers operate.

For this skill, lateral reading means: when you fetch source X and want to weight its claims, also issue a `WebSearch` for the publisher/author/organization to see what independent sources say about them. Don't just trust the source's self-description.

## Source-quality heuristics

In rough order of trust for empirical claims (always context-dependent):

1. **Primary**: the original dataset, peer-reviewed paper, government report, court filing, official statement, raw measurements.
2. **Specialist secondary**: domain-expert reporting (e.g., scientific journalism that links to and accurately summarizes papers), reputable industry analysis with disclosed methodology.
3. **General secondary**: mainstream news with reporting, editorial process, corrections.
4. **Tertiary**: Wikipedia, encyclopedias — useful as a *map of where to look*, not the destination. Use the citations.
5. **Aggregators / SEO content / AI-generated summaries**: treat as leads only. Anthropic's research-agent team specifically had to suppress these because they outranked authoritative sources. Don't repeat that mistake.
6. **Advocacy sources**: read them, but weight by their stake in the answer. A trade association report on the safety of its industry's product needs corroboration from a non-aligned source.

**Diversity of source type matters more than diversity of source count.** Ten SEO articles re-summarizing the same press release is one source, not ten.

## Funding and conflicts of interest

When a source has a financial or ideological stake in the answer, that doesn't disqualify it — but it does need to be surfaced to the user. Common cases worth flagging:

- **Industry-funded studies** on the safety/efficacy of that industry's product (food industry funding nutrition reviews, pharma funding drug trials, fossil-fuel industry funding climate analyses).
- **Advocacy organizations** publishing on their advocacy topic (a trade association on its industry, an environmental group on emissions, a think tank on its policy area).
- **Authors with consultancy or expert-witness ties** to the side they're writing about.

Do a quick lateral check (Caulfield move 3) on funding when a source is load-bearing for your conclusion. If the source is industry-aligned, name that funding in your final answer alongside the citation — e.g., "Maki 2024 (industry-funded review)." Don't just cite without flagging; don't dismiss the source either.

If a source's funding is unclear, say so rather than assuming.

## Citation discipline

- **Cite only sources you actually fetched and read.** Search-result snippets are not sources. The model sometimes hallucinates citations; the only protection is the rule "if I didn't open it, I don't cite it."
- **When you cite, name the source by title and publisher**, not just URL. The user should be able to evaluate the source from the citation alone.
- **Note primary vs. secondary** in your final answer when it matters ("the underlying NOAA dataset shows X; a Reuters summary characterizes that as Y").
- **Flag when sources disagree** rather than averaging or picking the one you like. Disagreement is information.
