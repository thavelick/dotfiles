# Grilling: offline mode for the mobile reader

Ticket: PROJ-812. Claimed by @you, 2026-03-14.

## Context

The reader is online-only today; every page is fetched on open. Offline mode is
the last piece before the app can ship to field users on bad connections.

Settled already, not for re-deciding:

- Sync is one-way: the server is authoritative, the device never writes back.
- Cached content is scoped to one account and cleared on sign-out.
- Storage budget is 200 MB; eviction is least-recently-opened.
- No background sync — the app only fetches while it is in the foreground.

## Questions

- [x] Q1 Trigger — does caching happen automatically or on an explicit "save"?
- [x] Q2 Granularity — is the cached unit a page, a chapter, or a whole book?
- [ ] Q3 Staleness — how does a reader know a cached page is out of date?
- [ ] Q4 Eviction warning — is the reader told before content is dropped?
- [ ] Q5 Failure — what does opening an uncached page offline show?

## Decisions

- **Q1** Explicit save, no automatic caching. Silent background downloads on a
  metered connection are the complaint we would get first, and an explicit save
  makes the 200 MB budget the reader's own to spend.
- **Q2** The chapter is the unit. A page is too small to be worth a progress
  indicator, a book too large to finish on a bad connection.

## Notes

- Open question behind Q3: whether the server exposes a per-chapter version at
  all, or only a book-level `updated_at`.
