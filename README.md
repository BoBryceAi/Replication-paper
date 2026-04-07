# Can AI Do Strategy Replication?

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository is the public website and PDF archive for AI-assisted strategy replication papers generated from the local calculated-replication workflow.

## What the site publishes

- formal journal-style replication PDFs
- batch-level paper library metadata
- a GitHub Pages front end that refreshes when new batches are published

## Current site totals

- published papers: 15
- published batches: 3
- analyzed rows across batches: 1,366,347
- headline estimates with p < .05: 6
- latest batch: April 7, 2026

## Latest batch

- [Roach and Cohen (2013)](papers/2026-04-07/roach-cohen-2013-public-research-knowledge-flows.pdf) - rows: 2,511, entities: 178, `External public-research citations = 0.022`; `p = 0.59`
- [Rosenkopf and Almeida (2003)](papers/2026-04-07/rosenkopf-almeida-2003-overcoming-local-search.pdf) - rows: 23,901, entities: 184, `Mobility bridge x technological distance = 0.0722`; `p = 0.002`
- [Rothaermel and Hess (2007)](papers/2026-04-07/rothaermel-hess-2007-dynamic-capabilities.pdf) - rows: 23,901, entities: 184, `Firm science x network ties = 0`; `p = 0.96`
- [Owen-Smith and Powell (2004)](papers/2026-04-07/owen-smith-powell-2004-knowledge-networks.pdf) - rows: 2,378, entities: 177, `Component size x open science = 0.0008`; `p = 0.18`
- [Wu, Hitt, and Lou (2020)](papers/2026-04-07/wu-hitt-lou-2020-data-analytics-innovation.pdf) - rows: 23,901, entities: 184, `AI score x breadth of recombination = -0.0024`; `p = 0.74`

## Local refresh tools

- `tools/publish-batch.ps1` copies compiled PDFs from the workspace into this repository and then refreshes the website.
- `tools/update-site.ps1` rebuilds `assets/data/library.json` and `README.md` from the current published batches.

## Workflow skill

- The publishing and manuscript standard is documented at [skills/write-replication-journal-github/SKILL.md](skills/write-replication-journal-github/SKILL.md).

## Workflow and skill stack

- Manuscript production follows a paper-first replication process that reads the source paper, maps every major decision point, checks the exact processed local files, and writes the article only after the evidence chain is explicit.
- The core GitHub skill is write-replication-journal-github, supported by dgm-method-design, dgm-research-positioning, citation-management, literature-review, and peer-review for stronger structure, citation density, and final manuscript polish.
