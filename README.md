# Replication Paper Library

This library hosts compiled patent-literature replication PDFs generated from the local workspace.

Repository: <https://github.com/BoBryceAi/Replication-paper>

## Batch 2026-04-04

- [Arts, Cassiman, and Hou (2023)](papers/2026-04-04/arts-cassiman-hou-2023-technology-space.pdf) - sample rows: 5,192, entities: 443, headline `tech_diff = -0.1935`, `p = 0.7841`
- [Ghosh, Martin, Pennings, and Wezel (2014)](papers/2026-04-04/ghosh-2014-data-backed-reproduction.pdf) - sample rows: 489,193, entities: 200, headline `breadth x org_recomb_exp_log = -0.0022`, `p = 0.0076`
- [Katila and Ahuja (2002)](papers/2026-04-04/katila-ahuja-2002-search-behavior.pdf) - sample rows: 2,174, entities: 162, headline `search_depth = -0.2243`, `search_depth^2 = 0.1059`
- [Katila and Chen (2008)](papers/2026-04-04/katila-chen-2008-search-timing.pdf) - sample rows: 4,839, entities: 167, headline `ahead vs sync on event quality = -0.0854`, `p = 0.1178`
- [Rosenkopf (2001)](papers/2026-04-04/rosenkopf-2001-beyond-local-search.pdf) - sample rows: 23,844, entities: 184, headline `boundary_existing_field = -0.0389`, `boundary_new_field = 0.1126`

## Notes

- All five PDFs in the 2026-04-04 batch compiled locally with MiKTeX on 2026-04-04.
- Each paper is backed by local result CSVs stored under `patent literature/daily_replications/2026-04-04`.
- The publish target for this library is the GitHub repository `BoBryceAi/Replication-paper`.
- The manuscript workflow now uses the installed Codex skill `write-replication-journal-github` to turn calculated replication folders into 30-40 page journal-style PDFs for upload.

## Skill Standard

- The versioned skill definition for this workflow is stored at [skills/write-replication-journal-github/SKILL.md](skills/write-replication-journal-github/SKILL.md).
- That skill now encodes the paper-first workflow, detailed decision mapping, current-dataset-only rule, 30-plus-reference rule, APA-like author-year citation standard, table and number-formatting rules, and publish validation checklist.
