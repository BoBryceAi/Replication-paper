# Can AI Do Strategy Replication?

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository is the public website and PDF archive for AI-assisted strategy replication papers generated from the local calculated-replication workflow.

## What the site publishes

- formal journal-style replication PDFs
- batch-level paper library metadata
- a GitHub Pages front end that refreshes when new batches are published

## Current site totals

- published papers: 25
- published batches: 5
- analyzed rows across batches: 2,207,452
- headline estimates with p < .05: 11
- latest batch: April 9, 2026

## Latest batch

- [Kneeland, Schilling, and Aharonson (2020)](papers/2026-04-09/kneeland-schilling-aharonson-2020-outlier-innovation.pdf) - rows: 23,901, entities: 184, `Distant recombination = 0.0203`; `p = 0.020`
- [Ahuja (2000)](papers/2026-04-09/ahuja-2000-collaboration-networks.pdf) - rows: 2,378, entities: 177, `Direct ties = -0.0125`; `p = < .001`
- [Bhaskarabhatla and Hegde (2014)](papers/2026-04-09/bhaskarabhatla-hegde-2014-patenting-open-innovation.pdf) - rows: 1,958, entities: 189, `Post-1989 electronics shift in patenting = 0.4569`; `p = 0.001`
- [Rothaermel and Hess (2007)](papers/2026-04-09/rothaermel-hess-2007-dynamic-capabilities.pdf) - rows: 23,901, entities: 184, `Firm science x network ties = 0`; `p = 0.96`
- [Owen-Smith and Powell (2004)](papers/2026-04-09/owen-smith-powell-2004-knowledge-networks.pdf) - rows: 2,378, entities: 177, `Component size x open science = 0.0008`; `p = 0.18`

## Local refresh tools

- `tools/publish-batch.ps1` copies compiled PDFs from the workspace into this repository and then refreshes the website.
- `tools/update-site.ps1` rebuilds `assets/data/library.json` and `README.md` from the current published batches.

## Workflow skill

- The publishing and manuscript standard is documented at [skills/write-replication-journal-github/SKILL.md](skills/write-replication-journal-github/SKILL.md).

## Workflow and skill stack

- Manuscript production follows a paper-first replication process that reads the source paper, maps every major decision point, checks the exact processed local files, and writes the article only after the evidence chain is explicit.
- Every paper must reconstruct the original article's published methodology before interpreting the local rerun, including the original sample, measurement architecture, estimator, and identifying comparison.
- Every paper must name the actual processed local dataset families used in the replication body, such as DISCERN-linked firm panels, PatentView-style patent files, rolling citation-link networks, and CRSP or Compustat-linked controls when those are part of the executable stack.
- Every paper must include a detailed original-versus-replication comparison section covering methodology, data architecture, focal estimated effects, substantive interpretation, and final conclusion rather than only a headline coefficient check.
- The public archive is refreshed when the workflow standard changes, so older published batches can be rewritten to match the current paper standard rather than freezing earlier weaker templates.
- The core GitHub skill is write-replication-journal-github, supported by dgm-method-design, dgm-research-positioning, citation-management, literature-review, and peer-review for stronger structure, citation density, and final manuscript polish.
