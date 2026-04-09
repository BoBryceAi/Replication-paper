# Can AI Do Strategy Replication?

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository is the public website and PDF archive for AI-assisted, data-backed replication papers in strategy and innovation research.
Each paper is published only after the workflow reconstructs the original study design, states the local data boundary clearly, and compares the original result with the local replication result.

## What this repository contains

- formal journal-style replication PDFs
- batch-level paper library metadata
- a GitHub Pages front end that refreshes when new batches are published
- the workflow and skill files that turn local replication folders into public outputs

## Replication standard

- read the original paper first and reconstruct the published methodology before estimating the local analogue
- identify the required data objects and name the exact processed local datasets used in the manuscript body
- separate direct source facts from local replication decisions instead of blending them together
- compare the original paper and the replication on data architecture, estimand, effect pattern, and conclusion
- publish only compiled PDFs together with refreshed site metadata

## Dataset files used in the local workflow

The archive is built from processed local datasets that already exist in the workspace.
Not every paper uses every file, but the current replication pipeline draws from the following core inputs.

### Base patent-to-firm mapping and firm controls

- `Data_Analysis/code/Regression/input/sp500_patents_firm_level_1986_2016_gvkey.csv` - patent-to-firm bridge used to map `patent_id`, `gvkey`, `permno`, and grant timing.
- `Data_Analysis/code/Regression/input/g_uspc_at_issue.tsv` - primary USPC class mapping used for technology-class controls and class fixed effects.
- `Data_Analysis/code/Regression/input/firmyear_active_years_from_stocknames_plus_sp500flag_1986_2016.csv` - firm-year activity panel used to define active observations and S&P 500 membership.
- `Data_Analysis/input_files/crsp/funda_annual.csv` - annual accounting file used to derive `log_assets`, `rd_intensity`, `roa`, leverage, cash, and market-value style controls.

### DISCERN science and non-patent literature files

- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pub_per_year_permno_adj.dta` - yearly firm publication counts.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pat_per_year_permno_adj.dta` - yearly firm patent counts in the DISCERN-linked panel.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pub_stock_permno_adj.dta` - cumulative publication stock by firm-year.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pat_stock_permno_adj.dta` - cumulative patent stock by firm-year.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/corp_NPL_cite_per_year_firm_80_15.dta` - internal and external science-channel measures based on non-patent literature citations.

### Patent recombination, impact, and citation files

- `Data_Analysis/output_files/USPTO_Focal/USPTO_focal_recombination_1986_2016_recombtypes_exp.csv` - patent-level recombination breadth, recombination degree, and prior-experience measures.
- `Data_Analysis/code/Regression/output/gvkey_clean_reproduction_dataset.csv` - cleaned patent outcome panel with inventive impact, top-tail indicators, prior-art counts, firm age, and same-year patent totals.
- `Data_Analysis/output_files/Focal Patent/discern_focal_backward_patent_uspc_primary.csv` - backward patent-link file used to build rolling firm citation networks.
- `Data_Analysis/output_files/Focal Patent/discern_backward_app_citations_long.csv` - applicant, examiner, and other backward citation channels used in citation-practice replications.
- `Data_Analysis/output_files/kpss_dataset/DATASET2.csv` - patent-quality panel used in the Moser-style citation-quality analogue.

### AI and paper-specific augmentation files

- `Data_Analysis/code/Regression/output/ai_subfield_patent_classification.csv` - patent-level AI tags and subfield scores used in AI-enabled innovation replications.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_analysis_dataset.csv` - the paper-level estimation dataset exported for each replication.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_model_coefficients.csv` - the coefficient table used in the manuscript and website summary.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_model_fit.csv` - fit statistics exported from the local model.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_sample_summary.csv` - sample counts and descriptive summary values used in the paper.

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

## Repository layout

- `papers/YYYY-MM-DD/` stores the published PDFs for each batch.
- `assets/data/library.json` stores the structured metadata used by the website.
- `tools/publish-batch.ps1` publishes a local batch into the site repository.
- `tools/update-site.ps1` rebuilds the website metadata and README from the currently published batches.
- `skills/write-replication-journal-github/SKILL.md` documents the manuscript and publishing standard.

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
