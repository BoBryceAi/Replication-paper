# Can AI Do Strategy Replication?

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository is the public website and PDF archive for AI-assisted strategy replication papers generated from the local calculated-replication workflow.

## What the site publishes

- formal journal-style replication PDFs
- batch-level paper library metadata
- a GitHub Pages front end that refreshes when new batches are published

## Current site totals

- published papers: 5
- published batches: 1
- analyzed rows across batches: 525,242
- headline estimates with p < .05: 1
- latest batch: April 4, 2026

## Latest batch

- [Arts, Cassiman, and Hou (2023)](papers/2026-04-04/arts-cassiman-hou-2023-technology-space.pdf) - rows: 5,192, entities: 443, `tech_diff = -0.1935`; `p = 0.78`
- [Ghosh, Martin, Pennings, and Wezel (2014)](papers/2026-04-04/ghosh-2014-data-backed-reproduction.pdf) - rows: 489,193, entities: 200, `breadth x org_recomb_exp_log = -0.0022`; `p = 0.008`
- [Katila and Ahuja (2002)](papers/2026-04-04/katila-ahuja-2002-search-behavior.pdf) - rows: 2,174, entities: 162, `search_scope = 0.0052`; `p = 0.62`
- [Katila and Chen (2008)](papers/2026-04-04/katila-chen-2008-search-timing.pdf) - rows: 4,839, entities: 167, `ahead vs sync on event quality = -0.0854`; `p = 0.12`
- [Rosenkopf (2001)](papers/2026-04-04/rosenkopf-2001-beyond-local-search.pdf) - rows: 23,844, entities: 184, `boundary_existing_field vs local = -0.0389`; `p = 0.39`

## Local refresh tools

- `tools/publish-batch.ps1` copies compiled PDFs from the workspace into this repository and then refreshes the website.
- `tools/update-site.ps1` rebuilds `assets/data/library.json` and `README.md` from the current published batches.

## Workflow skill

- The publishing and manuscript standard is documented at [skills/write-replication-journal-github/SKILL.md](skills/write-replication-journal-github/SKILL.md).
