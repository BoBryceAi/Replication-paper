# AI-Augmented Replication in Management Science

> *"Innovation points out paths that are possible; replication points out paths that are likely; progress relies on both."*
> - Open Science Collaboration (2015, p. 943)

Live site: <https://bobryceai.github.io/Replication-paper/>

Repository: <https://github.com/BoBryceAi/Replication-paper>

This repository documents a live program of AI-assisted replication in strategy and innovation research.
Its central claim is practical rather than rhetorical: if AI can lower the time cost of reconstructing designs, assembling data, re-estimating models, and writing formal replication reports, then systematic replication becomes much more feasible in fields where verification has historically been too expensive.

The archive is designed to do two things at once.
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

## How an AI Agent Replicates a Paper

### Stage 1 - Claim Extraction

The workflow begins with paper-first reading.
Before estimating anything, it reconstructs the original article's theory, focal claims, sample, variable definitions, estimator, and identification logic.
The goal is not to paraphrase the abstract, but to recover the actual architecture of the published argument.

### Stage 2 - Data Assembly

The workflow then identifies every major decision point: what data are required, which measures are directly observable, which need local analogues, and where the local evidence chain departs from the source design.
Only processed datasets already present in the workspace are used.
The workflow does not invent unavailable results and does not claim a byte-identical rerun when the underlying source archives are absent.

### Stage 3 - Specification and Estimation

Once the local data boundary is explicit, the workflow estimates the local model, exports paper-level datasets, and records coefficient, fit, and sample files.
This stage is where replication becomes operational rather than rhetorical: the paper must state exactly what was estimated from which processed local files.

### Stage 4 - Effect Size Comparison

The replication is not reduced to a single coefficient check.
Each paper compares the original article and the local rerun on methodology, dataset architecture, focal effects, substantive interpretation, and final conclusion.
This makes it possible to distinguish clean recovery, partial recovery, and meaningful divergence.

### Stage 5 - Human Reflection (The Critical Step)

The final step is interpretive.
Even when the workflow can reconstruct a great deal of a study, the replication still has to ask what remains tacit: judgment about exclusions, historical context, construct validity, and theoretical scope.
That reflection is part of the scientific contribution rather than an afterthought.

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

## Why This Matters: Three Audiences, Three Arguments

### For Management Scholars

The replication burden in strategy research is unusually high because theory, measurement, and context are tightly coupled.
That makes the field an especially useful setting for testing what AI can and cannot reconstruct from published work and a related data stack.

### For Strategy Practitioners

If AI lowers the cost of reconstructing codified knowledge, then the gap between published knowledge and imitable knowledge narrows.
Understanding what remains tacit is therefore not just a scientific issue; it is also a strategic one.

### For the Open Science Community

This archive treats AI-assisted replication as infrastructure.
Instead of waiting for occasional hand-built replication projects, the workflow creates a lower-cost path for continuously checking published claims and documenting the boundary between robust transfer and fragile reconstruction.

## Current Archive

- published papers: 30
- published batches: 6
- analyzed rows across batches: 2,951,882
- headline estimates with p < .05: 12
- latest batch: April 10, 2026

## Latest Batch

- [Moser, Ohmstedt, and Rhode (2018)](papers/2026-04-10/moser-ohmstedt-rhode-2018-patent-citations.pdf) - rows: 712,375, entities: 345, `Patent quality = 0.0963`; `p = < .001`
- [Bhaskarabhatla and Hegde (2014)](papers/2026-04-10/bhaskarabhatla-hegde-2014-patenting-open-innovation.pdf) - rows: 3,265, entities: 210, `Post-1989 electronics shift in patenting = 0.2748`; `p = 0.18`
- [Roach and Cohen (2013)](papers/2026-04-10/roach-cohen-2013-public-research-knowledge-flows.pdf) - rows: 2,511, entities: 178, `External public-research citations = 0.022`; `p = 0.59`
- [Owen-Smith and Powell (2004)](papers/2026-04-10/owen-smith-powell-2004-knowledge-networks.pdf) - rows: 2,378, entities: 177, `Component size x open science = 0.0008`; `p = 0.18`
- [Wu, Hitt, and Lou (2020)](papers/2026-04-10/wu-hitt-lou-2020-data-analytics-innovation.pdf) - rows: 23,901, entities: 184, `AI score x breadth of recombination = -0.0024`; `p = 0.74`

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

## Theoretical Foundations

**The Replication Crisis**

- Open Science Collaboration. (2015). Estimating the reproducibility of psychological science. *Science, 349*(6251), aac4716. https://doi.org/10.1126/science.aac4716
- Camerer, C. F., Dreber, A., Forsell, E., Ho, T.-H., Huber, J., Johannesson, M., Kirchler, M., Almenberg, J., Altmejd, A., Chan, T., Heikensten, E., Holzmeister, F., Imai, T., Isaksson, S., Nave, G., Pfeiffer, T., Razen, M., & Wu, H. (2016). Evaluating replicability of laboratory experiments in economics. *Science, 351*(6280), 1433-1436. https://doi.org/10.1126/science.aaf0918
- Camerer, C. F., Dreber, A., Holzmeister, F., Ho, T.-H., Huber, J., Johannesson, M., Kirchler, M., Nave, G., Nosek, B. A., Pfeiffer, T., Altmejd, A., Buttrick, N., Chan, T., Chen, Y., Forsell, E., Gampa, A., Heikensten, E., Hummer, L., Imai, T., ... Wu, H. (2018). Evaluating the replicability of social science experiments in *Nature* and *Science* between 2010 and 2015. *Nature Human Behaviour, 2*(9), 637-644. https://doi.org/10.1038/s41562-018-0399-z
- Bettis, R. A., Ethiraj, S., Gambardella, A., Helfat, C., & Mitchell, W. (2016). Creating repeatable cumulative knowledge in strategic management. *Strategic Management Journal, 37*(2), 257-261. https://doi.org/10.1002/smj.2477

**The Knowledge-Based View & Organizational Learning**

- Nelson, R. R., & Winter, S. G. (1982). *An evolutionary theory of economic change*. Harvard University Press.
- Barney, J. (1991). Firm resources and sustained competitive advantage. *Journal of Management, 17*(1), 99-120. https://doi.org/10.1177/014920639101700108
- Grant, R. M. (1996). Toward a knowledge-based theory of the firm. *Strategic Management Journal, 17*(S2), 109-122. https://doi.org/10.1002/smj.4250171110
- Cohen, W. M., & Levinthal, D. A. (1990). Absorptive capacity: A new perspective on learning and innovation. *Administrative Science Quarterly, 35*(1), 128-152. https://doi.org/10.2307/2393553
- Nonaka, I. (1994). A dynamic theory of organizational knowledge creation. *Organization Science, 5*(1), 14-37. https://doi.org/10.1287/orsc.5.1.14
- Polanyi, M. (1966). *The tacit dimension*. University of Chicago Press.

**AI, Knowledge Work, and Strategic Implications**

- Dell'Acqua, F., McFowland, E., Mollick, E. R., Lifshitz-Assaf, H., Kellogg, K. C., Rajendran, S., Krayer, L., Candelon, F., & Lakhani, K. R. (2023). Navigating the jagged technological frontier: Field experimental evidence of the effects of AI on knowledge worker productivity and quality. *Harvard Business School Working Paper* No. 24-013. https://doi.org/10.2139/ssrn.4573321
- Doshi, A. R., & Hauser, O. P. (2024). Generative AI enhances individual creativity but reduces the collective diversity of novel content. *Science Advances, 10*(28), eadn5290. https://doi.org/10.1126/sciadv.adn5290
- Doshi, A. R., Bell, J. J., Mirzayev, E., & Vanneste, B. (2025). Generative artificial intelligence and evaluating strategic decisions. *Strategic Management Journal, 46*(4). https://doi.org/10.1002/smj.3677

## How to Contribute

1. Read a source paper closely before touching the data.
2. Identify the required data objects and map them to the processed local files that actually exist in the workspace.
3. Build the replication around the executable local dataset rather than imagined source archives or unavailable raw inputs.
4. Write the comparison section explicitly: original methodology, local dataset architecture, focal effects, interpretation, and conclusion.
5. Keep human reflection in the loop by recording what appears codified and what still looks tacit or judgment-heavy.

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

This repository is maintained as an ongoing project on AI-augmented reproducibility in management science and strategy research.
Contact: [GitHub](https://github.com/BoBryceAi)

The archive is a living document. It is intended to grow as more replications are completed, more data boundaries are documented, and the gap between codified and tacit knowledge becomes easier to study directly.
