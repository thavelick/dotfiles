---
name: Competitive SEO Analysis
description: Conduct systematic SEO competitive analysis for landing pages by auditing current content, identifying target keywords, analyzing competitor strategies, and generating data-driven recommendations. Use when you need to improve search rankings, find content gaps, or develop SEO strategy based on competitor insights.
allowed-tools: Bash, Grep, Read, Glob, Write
---

# Competitive SEO Analysis

## Purpose
This skill guides a systematic competitive analysis process to improve SEO performance by analyzing competitor content, identifying gaps, and creating actionable recommendations.

## When to Use This Skill
- Analyzing existing landing pages or form pages for SEO improvement
- Planning and researching new pages before creation
- Comparing your content against competitor strategies
- Identifying content gaps and missing information
- Planning SEO enhancements with data-driven insights
- Creating comprehensive competitive analysis reports

## Analysis Process

### Phase 1: Current Page Audit or New Page Planning
**For existing pages:**
1. **Review existing page structure** - Examine the current page's content, headings, meta tags, schema markup
2. **Extract target keywords** - Identify primary keywords, secondary variations, and long-tail opportunities from:
   - Meta keywords field
   - H1 and H2 headings
   - Current page content focus
3. **Document current state** - Note what's already optimized and what gaps exist

**For new pages:**
1. **Define target keywords** - Identify the primary topic and keyword phrases the page should rank for
2. **Document intended purpose** - Clarify the page's role and user intent (how-to, reference, comparison, etc.)
3. **Note any existing content** - If repurposing or building on existing materials, document what resources are available

### Phase 2: Competitive Research
1. **Run targeted searches** - Use `searxng_search.py` which is in your PATH. Run the
   script by name only (no path prefix). Exclude Reddit and YouTube results, and use
   Google-only results with `!startpage` flag:
   ```bash
   searxng_search.py --full-count 3 -n 3 "[KEYWORD] -site:reddit.com
   -site:youtube.com !startpage"
   ```
   Run 3 separate searches:
   - 1 primary keyword search
   - 1 secondary keyword search
   - 1 long-tail keyword search

   **Important**: If `searxng_search.py` doesn't work or produces errors, abort
   immediately and ask for help. Do NOT fall back to WebFetch or other tools.

   If you receive authorization failures (403 Forbidden) from a site, exclude that
   domain and rerun the search to get results from alternative competitors:
   ```bash
   searxng_search.py --full-count 3 -n 3 "[KEYWORD] -site:blocked-domain.com
   -site:reddit.com -site:youtube.com !startpage"
   ```

2. **Analyze top 3 competitors** - Focus analysis on the top 3 unique competitor
   sites (excluding blocked/unauthorized sites). For each competitor, focus on:
   - Non-government competitors (form generation sites, tax software, document
     services)
   - Page titles and meta descriptions
   - Content structure and organization
   - Content sections and schema markup
   - Value propositions and unique features

### Phase 3: Content Gap Analysis
Compare your content against competitors and identify:
- Missing deadline information
- Limited form comparison content
- Lack of error prevention guidance
- Insufficient user journey support
- Technical complexity barriers
- Missing process guidance
- Incomplete content coverage

### Phase 4: Generate Recommendations
Create actionable suggestions for:
- Content enhancements addressing identified gaps
- SEO technical improvements (meta descriptions, schema, structure)

### Phase 5: Quality Assurance

**Originality and Plagiarism Avoidance:**
- Use different perspectives and approaches than competitors
- Focus on solutions rather than just problems
- Create unique content flow and organization
- Include company-specific insights and features
- Add practical steps and processes unique to your offering
- Use conversational, helpful tone that reflects your brand voice

**Content Validation:**
- Verify accuracy of technical information
- Ensure recommendations align with user intent
- Validate SEO optimization elements
- Confirm originality and uniqueness of suggested content

**Documentation:**
- For existing pages: Create analysis document with findings and recommendations
- For new pages: Create a comprehensive outline/specification including target
  keywords, content sections, unique value propositions, and SEO elements
- Document expected SEO impact and success metrics
- Save output to `/tmp/competitive-analysis-[topic].md` with the structured
  template below
- **Line wrapping**: After writing the document, fold output to 98 characters
  maximum, breaking only at word boundaries:
  ```bash
  fold -w 98 -s /tmp/competitive-analysis-[topic].md > /tmp/temp.md && \
  mv /tmp/temp.md /tmp/competitive-analysis-[topic].md
  ```

## Key Principles

**Data-driven**: Base all recommendations on actual competitor analysis, not assumptions.

**Actionable**: Provide specific, implementable recommendations with clear expected outcomes.

**Original**: Create unique content approaches that differentiate from competitors rather than copying.

**Comprehensive**: Cover all content aspects—structure, keywords, FAQs, schema, and user experience.

## Output Format

Create a detailed analysis document including:
- Audit findings from current page
- Target keywords identified
- Competitor summary (top 3 competitors analyzed)
- Content gaps discovered
- SEO technical opportunities
- Specific implementation recommendations

## Examples

**Example 1: Improve Existing Page**
- Input: Audit W2 form landing page with outdated startup tax content
- Process: Run 3 searches (primary: "w2 form", secondary: "w2 tax form", long-tail:
  "how to file w2 as freelancer") and analyze top 3 competitors
- Output: Recommendations to remove irrelevant content, integrate builder help
  content, add deadline info, improve content coverage

**Example 2: Plan New Product Landing Page**
- Input: Plan new product page targeting "tax software for freelancers"
- Process: Run 3 targeted searches (primary: "tax software for freelancers",
  secondary: "freelancer tax tools", long-tail: "best tax software for self-employed
  contractors") to find competitor pages
- Output: Page outline including target keywords, recommended content sections,
  unique value propositions, schema markup opportunities, and competitive advantages
  to emphasize

**Example 3: Competitive Comparison**
- Input: Analyze product page against top competitors
- Process: Run 3 searches to identify gaps in feature descriptions, comparison
  content, use cases from top 3 competitors
- Output: Content recommendations to outrank competitors and capture long-tail
  keywords

## Output Template

Save analysis results to `/tmp/competitive-analysis-[topic].md` with this structure:

```markdown
# Competitive SEO Analysis: [Topic/Page Name]

## Summary
[Brief overview of the analysis scope and key findings]

## Target Keywords
- Primary: [primary keyword phrases]
- Secondary: [secondary keyword variations]
- Long-tail: [long-tail opportunities]

## Competitors Analyzed
1. [Competitor 1 URL]
2. [Competitor 2 URL]
3. [Competitor 3 URL]

## Competitor Analysis

### Competitor 1: [Name]
- **URL**: [url]
- **Page Title**: [title strategy]
- **Meta Description**: [description approach]
- **Key Content Sections**: [main sections identified]
- **Schema Markup**: [structured data implementation]
- **Content Approach**: [how they structure and present information]

### Competitor 2: [Name]
[Same structure]

### Competitor 3: [Name]
[Same structure]

## Content Gaps Identified
- [Gap 1: specific missing content]
- [Gap 2: missing information]
- [Gap 3: weak coverage area]
- [Gap 4: opportunity]

## Recommendations

### Content Enhancements
- [Specific recommendation 1]
- [Specific recommendation 2]
- [Specific recommendation 3]

### SEO Technical Improvements
- Meta title optimization: [specific suggestion]
- Meta description: [specific suggestion]
- Schema markup: [specific implementation]
- Internal linking: [strategy]

## Implementation Notes
[Any specific context, constraints, or additional guidance for implementation]
```

## Tools Used
- `searxng_search.py`: Primary tool for competitive research and finding top-ranking
  pages. This script is in your PATH and should be run by name only (no path prefix).
  If the tool doesn't work or produces errors, abort immediately and ask for help.
  Do NOT fall back to WebFetch or other tools.
  - `--full-count 3`: Get full content and metadata for results
  - `-n 3`: Number of search results to return
  - `-site:domain.com`: Exclude specific domains from results
  - `!startpage`: Return Google-only results
- Grep: Search existing codebase for related content
- Read: Examine current page structure
- Glob: Find related files and documentation
- Bash: Run search commands, manage analysis, and fold output to 98 characters
  with word boundary breaking using `fold -w 98 -s`
