---
name: walkthrough
description: Screenshot walkthrough of a web-app scenario. Use when the user wants to see a flow screen by screen, review a PR's UI without clicking through it, or re-shoot one section after a fix.
argument-hint: "<scenario> [--only-end-state] [--reshoot NN ...]"
---

Produce a screenshot walkthrough of `$ARGUMENTS`.

The main session gathers the inputs, then spawns **one agent on `fable`** that
does the whole run: drives the browser, writes the captions, writes the
oddities. The oddities are why the walkthrough exists, and they need the
strongest model watching the app in the moment, so the run is one agent on
one model.

## 1. Inputs

Gather these before spawning, and ask for any that are missing.

- **Scenario**, one or two sentences. "The account page after a completed
  checkout." "Editing the profile updates an unsaved draft."
- **Base URL** of the running app, checked to respond.
- **How to sign in.** A seeded account, or a mail-catcher URL plus one
  sentence on how the login form works. Sign-in is per project and arrives as
  an input every run.
- **Output directory.** Convention: `scratch/walkthrough-<slug>/` in the
  repo, with `scratch/` git-ignored. Confirm per repo, and confirm it holds
  no walkthrough already.
- **Scope.** The whole flow, or `--only-end-state`: only the screen the
  scenario ends on. A single screenshot makes a single-section walkthrough.
- Optional: a PR or spec number for the title.

`--reshoot` takes the existing directory and section numbers instead; see §5.

## 2. Output

In the output directory:

- `index.html`, a copy of [template.html](template.html) filled in. The
  template is the page: replace every UPPERCASE placeholder, repeat the section and figure blocks as needed, and leave the style alone.
- One PNG per shot, `NN-slug.png` or `NNx-slug.png`: `NN` the section
  number, `x` a letter (`03-orders.png`, `03a-orders-empty.png`). Letters
  are what let a reshoot insert beside an existing shot.
- `shoot.mjs`, the Playwright script the agent wrote to drive the app. It is
  part of the output: a reshoot reruns pieces of it.

The run is done when every screen the scenario names has a section, every
figure carries a path label, and `open index.html` has put the page in the
browser.

## 3. Driving the browser

Two browsers; pick one and name it in the report.

- **A headless script**, the default. Playwright is rarely a dependency of
  the app under test, so use the copy npx has cached, or `npx playwright`:

  ```sh
  ls -d ~/.npm/_npx/*/node_modules/playwright | head -1
  ```

  The generic shape of `shoot.mjs`:

  ```js
  import { chromium } from "<that path>/index.mjs";
  const browser = await chromium.launch({ channel: "chrome" });   // installed Chrome, nothing downloads
  const context = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  const page = await context.newPage();
  page.on("console", (m) => console.log("console:", m.type(), m.text()));
  // sign in, per the inputs
  await page.goto(`${BASE}/settings`);
  await page.getByRole("button", { name: /save/i }).waitFor();   // wait on app state
  console.log("url:", page.url());                                 // feeds the path label
  await page.screenshot({ path: `${OUT}/01-settings.png`, fullPage: true });
  ```

  Grow the script as the walkthrough proceeds and keep it runnable end to end.

- **The Playwright MCP tools** (`mcp__plugin_playwright_playwright__*`): one
  shared tab and one cookie jar for the whole Claude session, so one agent at
  a time, and a second sign-in logs the first out. Reach for them when
  interactive poking is worth more than a rerunnable script.

Rules that came from getting it wrong:

- **Wait on state.** Confirmation pages that poll, background reconcilers,
  and email delivery can take a minute or more. Wait on the element or text
  that proves the state arrived; a fixed sleep shoots the wrong frame.
- **Full `page.goto` before shooting after a state change.** Single-page
  shells keep a stale header across a soft navigation, and a stale strip
  reads as an oddity that is not there.
- **Full-page shots for whole screens, viewport shots for dialogs.** A
  `<dialog>` modal scrolls off a full-page shot. For one card or control,
  take an element screenshot and give the figure `class="crop"`.
- **Shoot hosted third parties too**: a payment provider's checkout, an
  OAuth page, the mail catcher, each labelled with its host.
- **Read the console log**, and mark dev-only noise (favicon 404s, framework
  dev-tool timing warnings) as dev-only when it reaches the oddities.
- **Fresh identity** where sign-up is part of the flow, so seeded state stays
  out of the screens.

## 4. Writing the page

One `<section id="sNN">` per screen, numbered in the order a user meets
them. Each has:

- An `<h2>`: the number and a short name for the screen.
- One paragraph in plain English: what is on screen, how you got here, what
  to look at. Quote on-screen text exactly, capitalisation and punctuation
  included. Describe what is there; the spec's wording belongs in an oddity
  when the two differ.
- One `<figure>` per shot. Above every image, `<p class="path">` holding the
  path from `page.url()` with ids and tokens collapsed: `/orders/[id]`,
  `/verify?token=[token]`. Off-site pages get their host,
  `checkout.example.com`. The figcaption names the state shown, one line.

Every section is a TOC entry. The header paragraph carries the capture date,
the base URL, the viewport, and one sentence of setup the reader needs.

### Oddities

The last section, id `oddities`, titled "Screens not captured, and oddities
noticed". The title stays even when everything was captured; only the
`.note` paragraph goes.

An oddity is anything that looked wrong, surprising, or inconsistent while
driving: copy and plurals, timing, a redirect that lands somewhere odd, a
console error, a missing link, a control that looks enabled and is not, a
typeface or spacing mismatch, a label that differs from the spec's wording.
List every one, including those that may be by design; say "by design per
the tests" when you found that, and the reviewer decides.

Write them as a numbered `<ol>`, each item:

- The problem in a few bold words, or "Minor" / "Dev-only"
  when that is what it is.
- One or two sentences that stand alone: the path, the text quoted exactly,
  what you expected if that is not obvious. The reader pastes each item into
  a checklist verbatim.

## 5. Reshoot mode

`--reshoot NN [NN ...]` re-does named sections of an existing walkthrough
after a fix. The agent:

1. Reads `index.html` and `shoot.mjs` from the directory. The section's
   paragraph and figcaptions describe the screen to reach; the script knows
   how to sign in and get there.
2. Edits `shoot.mjs` so only the needed sections run, and reruns it. New
   shots take the next free letter (`04b` after `04a`); a shot the fix made
   plainly wrong is replaced in place, and the report says so.
3. Rewrites that section's paragraph and figures. Every other section stays
   byte-for-byte as it was.
4. Re-reads the oddities: removes an item the fix resolved and names it in
   the report, adds any new one, leaves the rest.
5. Reports as in §6, scoped to the sections touched.

## 6. Report back

The page is the artifact; the report is short:

- The path to `index.html` and which browser drove it.
- Sections and shot count, one line.
- Anything the scenario asked for that was not captured, and why.
- The oddities, numbered, each as its one or two sentences from the page.
  The user records a decision per item, so each must make sense with the
  page closed.
