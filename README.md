# Can AI Do Strategy Replication?

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository is the public website and PDF archive for AI-assisted strategy replication papers generated from the local calculated-replication workflow.

## What the site publishes

- formal journal-style replication PDFs
- batch-level paper library metadata
- a GitHub Pages front end that refreshes when new batches are published

## Current site totals

- published papers: 20
- published batches: 4
- analyzed rows across batches: 2,152,936
- headline estimates with p < .05: 8
- latest batch: April 8, 2026

## Latest batch

- [Moser, Ohmstedt, and Rhode (2018)](papers/2026-04-08/moser-ohmstedt-rhode-2018-patent-citations.pdf) - rows: 712,375, entities: 345, `Patent quality = 0.0963`; `p = < .001`
- [Ahuja and Lampert (2001)](papers/2026-04-08/ahuja-lampert-2001-breakthrough-inventions.pdf) - rows: 23,901, entities: 184, `Novel technologies = 0.0589`; `p = 0.82`
- [Roach and Cohen (2013)](papers/2026-04-08/roach-cohen-2013-public-research-knowledge-flows.pdf) - rows: 2,511, entities: 178, `External public-research citations = 0.022`; `p = 0.59`
- [Rosenkopf and Almeida (2003)](papers/2026-04-08/rosenkopf-almeida-2003-overcoming-local-search.pdf) - rows: 23,901, entities: 184, `Mobility bridge x technological distance = 0.0722`; `p = 0.002`
- [Wu, Hitt, and Lou (2020)](papers/2026-04-08/wu-hitt-lou-2020-data-analytics-innovation.pdf) - rows: 23,901, entities: 184, `AI score x breadth of recombination = -0.0024`; `p = 0.74`

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
