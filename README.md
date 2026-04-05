# Can AI Do Strategy Replication?

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository is the public website and PDF archive for AI-assisted strategy replication papers generated from the local calculated-replication workflow.

## What the site publishes

- formal journal-style replication PDFs
- batch-level paper library metadata
- a GitHub Pages front end that refreshes when new batches are published

## Current site totals

- published papers: 10
- published batches: 2
- analyzed rows across batches: 1,289,755
- headline estimates with p < .05: 5
- latest batch: April 5, 2026

## Latest batch

- [Moser, Ohmstedt, and Rhode (2018)](papers/2026-04-05/moser-ohmstedt-rhode-2018-patent-citations.pdf) - rows: 712,375, entities: 345, `Patent quality = 0.0963`; `p = < .001`
- [Ahuja and Lampert (2001)](papers/2026-04-05/ahuja-lampert-2001-breakthrough-inventions.pdf) - rows: 23,901, entities: 184, `Novel technologies = 0.0589`; `p = 0.82`
- [Kneeland, Schilling, and Aharonson (2020)](papers/2026-04-05/kneeland-schilling-aharonson-2020-outlier-innovation.pdf) - rows: 23,901, entities: 184, `Distant recombination = 0.0203`; `p = 0.020`
- [Ahuja (2000)](papers/2026-04-05/ahuja-2000-collaboration-networks.pdf) - rows: 2,378, entities: 177, `Direct ties = -0.0125`; `p = < .001`
- [Bhaskarabhatla and Hegde (2014)](papers/2026-04-05/bhaskarabhatla-hegde-2014-patenting-open-innovation.pdf) - rows: 1,958, entities: 189, `Post-1989 electronics shift in patenting = 0.4569`; `p = 0.001`

## Local refresh tools

- `tools/publish-batch.ps1` copies compiled PDFs from the workspace into this repository and then refreshes the website.
- `tools/update-site.ps1` rebuilds `assets/data/library.json` and `README.md` from the current published batches.

## Workflow skill

- The publishing and manuscript standard is documented at [skills/write-replication-journal-github/SKILL.md](skills/write-replication-journal-github/SKILL.md).
