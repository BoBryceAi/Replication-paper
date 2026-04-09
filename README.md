# AI-Augmented Replication in Management Science

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository documents a live program of AI-assisted replication in strategy and innovation research.
The central claim is practical rather than rhetorical: if AI can lower the time cost of reconstructing designs, assembling data, re-estimating models, and writing formal replication reports, then systematic replication becomes much more feasible in fields where verification has historically been too expensive.

The archive is therefore designed to do two things at once.
First, it publishes formal replication papers that reconstruct the original study logic as carefully as the current local data stack allows.
Second, it creates a running record of what is codified and portable in published research, and what still depends on tacit judgment, hidden cleaning decisions, and context-specific interpretation.

## The Problem: Science's Most Expensive Bottleneck

High-quality replication is still costly.
In management and strategy research, that cost is magnified by long causal chains, heterogeneous samples, complex construct definitions, and frequent reliance on linked firm, patent, and science datasets that are difficult to rebuild from scratch.

The result is an incentive problem.
Novel findings are rewarded more directly than careful verification, even though cumulative knowledge depends on verification.
This repository is built around the view that AI does not remove the need for judgment, but it can reduce the marginal cost of disciplined replication enough to make replication a realistic ongoing workflow rather than a rare side project.

## The AI Replication Paradox

AI-assisted replication creates two opposing effects.

1. Scientific dividend.
Researchers can use AI to reconstruct methodology, identify decision points, map required data objects, rerun specifications, and generate readable replication reports much faster than a purely manual workflow.

2. Imitation pressure.
The same capability reduces the cost of reconstructing codified knowledge from published work.
When the architecture of a study is clearly written down, an AI-assisted reader can often recover much of the design from the article and a related data stack.

This is why the important boundary is not whether AI can read a paper.
The important boundary is what remains tacit: judgment about construct validity, data exclusions, historical context, theoretical scope, and the unrecorded craft of empirical research.

## How the Replication Workflow Works

1. Paper-first reading.
The workflow reads the original paper before estimating anything and reconstructs the published theory, sample, variable definitions, estimator, and identification logic.

2. Decision mapping.
The workflow identifies every major decision point: what data are required, which measures are directly observable, which need local analogues, and where the local evidence chain departs from the source design.

3. Local data assembly.
The workflow uses only processed datasets already present in the workspace.
It does not invent unavailable results and does not claim a byte-identical rerun when the underlying source archives are absent.

4. Estimation and comparison.
The workflow estimates the local model, exports paper-level results, and compares the original article and the local replication on design, effects, interpretation, and conclusion.

5. Journal-style paper production.
Each replication is written as a formal paper, compiled to PDF, and published into the archive together with refreshed website metadata.

## Dataset Files Used in the Current Workflow

The current archive is built from processed local datasets that already exist in the workspace.
Different papers use different subsets of these files, but the following are the core inputs that appear across the replication pipeline.

### Base Patent-to-Firm Mapping and Firm Controls

- `Data_Analysis/code/Regression/input/sp500_patents_firm_level_1986_2016_gvkey.csv`: patent-to-firm bridge linking `patent_id`, `gvkey`, `permno`, and timing fields.
- `Data_Analysis/code/Regression/input/g_uspc_at_issue.tsv`: primary USPC class mapping used for technology-class controls and class fixed effects.
- `Data_Analysis/code/Regression/input/firmyear_active_years_from_stocknames_plus_sp500flag_1986_2016.csv`: firm-year activity panel used to define active periods and S&P 500 membership.
- `Data_Analysis/input_files/crsp/funda_annual.csv`: accounting and market variables used to derive assets, R&D intensity, profitability, leverage, cash, and related controls.

### DISCERN Science and Non-Patent Literature Files

- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pub_per_year_permno_adj.dta`: yearly firm publication counts.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pat_per_year_permno_adj.dta`: yearly firm patent counts in the DISCERN-linked panel.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pub_stock_permno_adj.dta`: cumulative publication stock by firm-year.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/pat_stock_permno_adj.dta`: cumulative patent stock by firm-year.
- `Data_Analysis/code/SP500_gvkey_permno/DISCERN_DEC_2020/data/corp_NPL_cite_per_year_firm_80_15.dta`: internal and external science-channel measures based on non-patent literature citations.

### Patent Recombination, Impact, and Citation Files

- `Data_Analysis/output_files/USPTO_Focal/USPTO_focal_recombination_1986_2016_recombtypes_exp.csv`: patent-level recombination breadth, recombination degree, and prior-experience measures.
- `Data_Analysis/code/Regression/output/gvkey_clean_reproduction_dataset.csv`: cleaned patent outcome panel with inventive impact, top-tail indicators, prior-art counts, firm age, and patent-stock controls.
- `Data_Analysis/output_files/Focal Patent/discern_focal_backward_patent_uspc_primary.csv`: backward patent-link file used to build rolling firm citation networks.
- `Data_Analysis/output_files/Focal Patent/discern_backward_app_citations_long.csv`: applicant, examiner, and other backward citation channels used in citation-practice replications.
- `Data_Analysis/output_files/kpss_dataset/DATASET2.csv`: patent-quality panel used in citation-quality analogues.

### AI and Paper-Level Output Files

- `Data_Analysis/code/Regression/output/ai_subfield_patent_classification.csv`: patent-level AI tags and subfield scores used in AI-enabled innovation replications.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_analysis_dataset.csv`: paper-level estimation dataset exported for each replication.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_model_coefficients.csv`: coefficient table used in the manuscript and website summary.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_model_fit.csv`: model-fit statistics exported from the local estimation.
- `patent literature/daily_replications/YYYY-MM-DD/<paper-slug>/results/*_sample_summary.csv`: sample counts and descriptive summary values used in the paper.

## Why This Matters

### For Management and Strategy Research

The replication burden in strategy research is unusually high because theory, measurement, and context are tightly coupled.
That makes the field an especially useful setting for testing what AI can and cannot reconstruct from published work and a related data stack.

### For the Open Science Community

This archive treats AI-assisted replication as infrastructure.
Instead of waiting for occasional hand-built replication projects, the workflow creates a lower-cost path for continuously checking published claims and documenting the boundary between robust transfer and fragile reconstruction.

### For Strategy Practice

The project also has a strategic implication.
If AI lowers the cost of reconstructing codified knowledge, then the gap between published knowledge and imitable knowledge narrows.
Understanding what remains tacit is therefore not just a scientific issue; it is also a strategic one.

## Current Archive

- published papers: 25
- published batches: 5
- analyzed rows across batches: 2,207,452
- headline estimates with p < .05: 11
- latest batch: April 9, 2026

## Latest Batch

- [Kneeland, Schilling, and Aharonson (2020)](papers/2026-04-09/kneeland-schilling-aharonson-2020-outlier-innovation.pdf) - rows: 23,901, entities: 184, `Distant recombination = 0.0203`; `p = 0.020`
- [Ahuja (2000)](papers/2026-04-09/ahuja-2000-collaboration-networks.pdf) - rows: 2,378, entities: 177, `Direct ties = -0.0125`; `p = < .001`
- [Bhaskarabhatla and Hegde (2014)](papers/2026-04-09/bhaskarabhatla-hegde-2014-patenting-open-innovation.pdf) - rows: 1,958, entities: 189, `Post-1989 electronics shift in patenting = 0.4569`; `p = 0.001`
- [Rothaermel and Hess (2007)](papers/2026-04-09/rothaermel-hess-2007-dynamic-capabilities.pdf) - rows: 23,901, entities: 184, `Firm science x network ties = 0`; `p = 0.96`
- [Owen-Smith and Powell (2004)](papers/2026-04-09/owen-smith-powell-2004-knowledge-networks.pdf) - rows: 2,378, entities: 177, `Component size x open science = 0.0008`; `p = 0.18`

## Repository Structure

- `papers/YYYY-MM-DD/` stores the published PDFs for each batch.
- `assets/data/library.json` stores the structured metadata used by the website.
- `tools/publish-batch.ps1` publishes a local batch into the site repository.
- `tools/update-site.ps1` rebuilds the website metadata and this README from the currently published batches.
- `skills/write-replication-journal-github/SKILL.md` documents the manuscript and publishing standard.

## What Each Replication Package Contains

- a formal journal-style replication paper in PDF form
- a paper-specific estimation dataset exported from the local workflow
- coefficient and fit summaries used in the manuscript
- a detailed comparison between the original paper and the local replication
- explicit statements about the local data boundary and replication decisions

## Foundational Literature

- Replication and reproducibility: Open Science Collaboration (2015); Camerer et al. (2016, 2018); Bettis et al. (2016).
- Knowledge-based and organizational-learning foundations: Nelson and Winter (1982); Barney (1991); Grant (1996); Cohen and Levinthal (1990); Nonaka (1994); Polanyi (1966).
- AI, knowledge work, and strategic implications: Dell'Acqua et al. (2023); Doshi and Hauser (2024); Doshi et al. (2025).

## Local Refresh Tools

- `tools/publish-batch.ps1` copies compiled PDFs from the workspace into this repository and refreshes the public archive.
- `tools/update-site.ps1` rebuilds `assets/data/library.json` and `README.md` from the currently published batches.

## Citation

```bibtex
@misc{ai_bryce_2026,
  author       = {Bryce Ai},
  title        = {AI-Augmented Replication in Management Science},
  year         = {2026},
  publisher    = {GitHub},
  url          = {https://github.com/BoBryceAi/Replication-paper}
}
```

## About

This repository is maintained as an ongoing project on AI-assisted replication in management science and strategy research.
Contact: [GitHub](https://github.com/BoBryceAi)

The archive is a living document. It is intended to grow as more replications are completed, more data boundaries are documented, and the gap between codified and tacit knowledge becomes easier to study directly.
