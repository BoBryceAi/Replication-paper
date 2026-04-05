---
name: write-replication-journal-github
description: Turn calculated replication folders into formal journal-style replication papers, enforce paper-first evidence mapping, validate citation quality, and publish compiled PDFs to the BoBryceAi/Replication-paper repository.
---

# Replication Paper Skill

Use this skill when expanding a calculated replication folder into a formal paper for [BoBryceAi/Replication-paper](https://github.com/BoBryceAi/Replication-paper).

## Core Rule

The paper is not a workflow memo. It must read like a formal journal article while remaining fully traceable to the current local executable datasets.

## Required Sequence

1. Read the source paper first.
2. Identify the source paper's theory, estimand, sample logic, variable definitions, decision points, and reported results.
3. Identify which empirical objects are needed to reproduce the paper.
4. Match those objects to the exact processed local datasets and result files that already exist in the workspace.
5. Run or verify the local calculations from the current executable dataset stack.
6. Write the paper only after the source logic and local evidence mapping are both explicit.
7. Compile, validate, and publish the PDF.

## Data Rules

- Use only the processed or executable datasets already available in the local workspace unless the user explicitly changes that rule.
- Do not claim access to unreconstructed raw pipelines when they are not locally available.
- Do not invent variables, coefficients, robustness checks, citations, or measurement steps.
- Separate direct source facts from local replication decisions.
- Keep the main text focused on data lineage and empirical meaning rather than dumping file paths.

## Paper Requirements

- The manuscript must be paper-like in structure:
  - Abstract
  - Introduction
  - Original study, theory, and replication boundary
  - Data, sample, and measures
  - Empirical strategy
  - Results
  - Comparison to the published study
  - Discussion
  - Conclusion
  - Appendices
- The total paper should usually be 30 to 40 pages.
- The main content before appendices should usually exceed 25 pages.
- The total manuscript should usually exceed 5,000 words.
- The body must include detailed writing, detailed derivation logic, detailed decision reasoning, and detailed data analysis based on the current local dataset.
- Include a formal comparison section showing the original paper's reported results versus the current local dataset results and explaining why they align or differ.

## Citation Standards

- Each paper must include more than 30 references.
- Different papers should not all have the same bibliography size; the literature set should vary by topic.
- Use topic-compatible, top-journal references rather than repeating one generic backbone unchanged across all papers.
- Maintain dense citation support in the prose, roughly one citation every 100 to 200 words when the text is making literature-backed claims.
- Use author-year in-text citation style.
- Use APA-like bibliography output with full author, year, title, journal, volume, issue, and pages.
- After compilation, verify the actual rendered bibliography count from the `.bbl` file rather than assuming the `.bib` file is enough.

## Number And Table Standards

- Format numbers according to type:
  - years as years
  - counts as integers with separators
  - identifiers without inappropriate separators
  - percentages as percentages
  - coefficients and test statistics with scale-sensitive decimals
  - very small values only when scientific notation is genuinely needed
- Do not use one decimal rule for every number type.
- Tables must fit on the page.
- Do not allow important columns to print off-page or half-render.
- Remove raw file paths from manuscript tables unless a path is essential for an appendix-level audit.

## Writing Standards

- The main text should read like a top-journal-style replication paper, not a checklist.
- Keep audit and file-manifest material in appendices or replication notes when it would clutter the narrative.
- Explain why each major local design choice was necessary.
- When the local design differs from the source paper, state the difference directly and interpret its implications.
- Do not pad page length with empty summary tables or repetitive filler.

## Validation Checklist

Before publishing, verify all of the following:

1. The manuscript compiles successfully to PDF.
2. The paper is based on actual local calculations from the current processed dataset stack.
3. The main text includes detailed empirical analysis, not just brief table statements.
4. The reference list exceeds 30 references.
5. The reference count has been checked from the compiled `.bbl`.
6. The bibliography style is author-year APA-like.
7. Table width and formatting are readable in the PDF.
8. Numeric formatting is type-aware.
9. The GitHub publish copy matches the latest compiled local PDF.

## Publish Workflow

- Build manuscripts from the research workspace.
- Compile with `scripts/build_daily_replication_pdfs.ps1`.
- Copy compiled PDFs into `publish/Replication-paper/papers/YYYY-MM-DD/`.
- Update repository-facing documentation when the workflow standard changes.
- Inspect `git status` before commit.
- Commit only the intended publish artifacts.
- Push from `publish/Replication-paper`.

## Default Quality Bar For This Project

If the user says to "remember the process," assume the following standard:

- source paper first
- exact decision-point mapping
- exact local data-object mapping
- current executable dataset only
- detailed derivations in the paper
- detailed data analysis in the paper body
- over 30 references
- varying topic-specific reference counts across papers
- APA-like author-year citations
- comparison to original results
- paper-style prose, not messy workflow notes
- validated PDF published to GitHub
