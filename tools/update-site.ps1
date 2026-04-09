[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    Split-Path -Parent $PSScriptRoot
}

function Get-WorkspaceRoot {
    $repoRoot = Get-RepoRoot
    Split-Path -Parent (Split-Path -Parent $repoRoot)
}

function Get-Tokens {
    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return @()
    }

    return ($Text.ToLowerInvariant() -split '[^a-z0-9]+') | Where-Object { $_ } | Select-Object -Unique
}

function Get-OverlapScore {
    param(
        [string[]]$Left,
        [string[]]$Right
    )

    $score = 0
    foreach ($token in $Left) {
        if ($Right -contains $token) {
            $score++
        }
    }

    return $score
}

function Find-BestPdfMatch {
    param(
        [pscustomobject]$Row,
        [System.IO.FileInfo[]]$PdfFiles,
        [System.Collections.Generic.HashSet[string]]$UsedNames
    )

    $exactMatch = $PdfFiles | Where-Object {
        -not $UsedNames.Contains($_.Name) -and $_.BaseName -eq $Row.slug
    } | Select-Object -First 1

    if ($exactMatch) {
        return $exactMatch
    }

    $candidateTokens = Get-Tokens ("{0} {1}" -f $Row.slug, $Row.paper)
    $bestMatch = $null
    $bestScore = -1

    foreach ($pdf in $PdfFiles) {
        if ($UsedNames.Contains($pdf.Name)) {
            continue
        }

        $score = Get-OverlapScore -Left $candidateTokens -Right (Get-Tokens $pdf.BaseName)
        if ($score -gt $bestScore) {
            $bestScore = $score
            $bestMatch = $pdf
        }
    }

    if ($bestScore -ge 2) {
        return $bestMatch
    }

    $remaining = @($PdfFiles | Where-Object { -not $UsedNames.Contains($_.Name) })
    if ($remaining.Count -eq 1) {
        return $remaining[0]
    }

    return $null
}

function Format-SizeLabel {
    param(
        [long]$Bytes
    )

    if ($Bytes -ge 1MB) {
        return "{0:N1} MB" -f ($Bytes / 1MB)
    }

    return "{0:N0} KB" -f ($Bytes / 1KB)
}

function Convert-ToDateLabel {
    param(
        [string]$DateText
    )

    try {
        $dateValue = [datetime]::ParseExact($DateText, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)
        return $dateValue.ToString("MMMM d, yyyy", [System.Globalization.CultureInfo]::InvariantCulture)
    }
    catch {
        return $DateText
    }
}

function Get-DoubleOrNull {
    param(
        [object]$Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $null
    }

    return [double]$Value
}

function Get-IntOrNull {
    param(
        [object]$Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $null
    }

    return [int64]$Value
}

function Write-TextFile {
    param(
        [string]$Path,
        [string[]]$Lines
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    [System.IO.File]::WriteAllLines($Path, $Lines, [System.Text.UTF8Encoding]::new($false))
}

function Format-HeadlineForReadme {
    param(
        [object]$Estimate,
        [object]$PValue,
        [string]$Term
    )

    if ($null -eq $Estimate) {
        return "PDF published"
    }

    $estimateValue = [double]$Estimate
    $pValue = [double]$PValue

    if ($pValue -lt 0.001) {
        $pText = "< .001"
    }
    elseif ($pValue -lt 0.1) {
        $pText = "{0:N3}" -f $pValue
    }
    else {
        $pText = "{0:N2}" -f $pValue
    }

    return ('`{0} = {1}`; `p = {2}`' -f $Term, [math]::Round($estimateValue, 4), $pText)
}

$repoRoot = Get-RepoRoot
$workspaceRoot = Get-WorkspaceRoot
$publishPapersRoot = Join-Path $repoRoot "papers"
$dailyReplicationRoot = Join-Path $workspaceRoot "patent literature\daily_replications"
$siteDataPath = Join-Path $repoRoot "assets\data\library.json"
$readmePath = Join-Path $repoRoot "README.md"
$repoUrl = "https://github.com/BoBryceAi/Replication-paper"
$siteUrl = "https://bobryceai.github.io/Replication-paper/"

$batchDirectories = @(Get-ChildItem -Path $publishPapersRoot -Directory | Sort-Object Name -Descending)
$batchObjects = @()

foreach ($batchDir in $batchDirectories) {
    $pdfFiles = @(Get-ChildItem -Path $batchDir.FullName -File -Filter *.pdf | Sort-Object Name)
    if ($pdfFiles.Count -eq 0) {
        continue
    }

    $summaryCsv = Join-Path $dailyReplicationRoot (Join-Path $batchDir.Name "calculated_batch_summary.csv")
    $summaryRows = @()
    if (Test-Path $summaryCsv) {
        $summaryRows = @(Import-Csv -LiteralPath $summaryCsv)
    }

    $usedNames = New-Object 'System.Collections.Generic.HashSet[string]'
    $paperObjects = @()

    foreach ($row in $summaryRows) {
        $match = Find-BestPdfMatch -Row $row -PdfFiles $pdfFiles -UsedNames $usedNames
        if ($match) {
            [void]$usedNames.Add($match.Name)
        }

        $paperObject = [ordered]@{
            slug = [string]$row.slug
            title = [string]$row.paper
            date = $batchDir.Name
            pdfName = if ($match) { $match.Name } else { $null }
            pdfUrl = if ($match) { ("papers/{0}/{1}" -f $batchDir.Name, $match.Name).Replace("\", "/") } else { $null }
            rows = Get-IntOrNull -Value $row.rows
            entities = Get-IntOrNull -Value $row.unique_entities
            headlineTerm = [string]$row.headline_term
            headlineEstimate = Get-DoubleOrNull -Value $row.headline_estimate
            headlineP = Get-DoubleOrNull -Value $row.headline_p
            pdfSizeBytes = if ($match) { [int64]$match.Length } else { $null }
            pdfSizeLabel = if ($match) { Format-SizeLabel -Bytes $match.Length } else { $null }
        }

        $paperObjects += [pscustomobject]$paperObject
    }

    foreach ($pdf in ($pdfFiles | Where-Object { -not $usedNames.Contains($_.Name) })) {
        $paperObjects += [pscustomobject]([ordered]@{
            slug = $pdf.BaseName
            title = ($pdf.BaseName -replace '-', ' ')
            date = $batchDir.Name
            pdfName = $pdf.Name
            pdfUrl = ("papers/{0}/{1}" -f $batchDir.Name, $pdf.Name).Replace("\", "/")
            rows = $null
            entities = $null
            headlineTerm = "PDF available"
            headlineEstimate = $null
            headlineP = $null
            pdfSizeBytes = [int64]$pdf.Length
            pdfSizeLabel = Format-SizeLabel -Bytes $pdf.Length
        })
    }

    $rowTotal = [int64](($paperObjects | Where-Object { $null -ne $_.rows } | Measure-Object -Property rows -Sum).Sum)
    $entityTotal = [int64](($paperObjects | Where-Object { $null -ne $_.entities } | Measure-Object -Property entities -Sum).Sum)
    $pdfTotal = [int64](($paperObjects | Where-Object { $null -ne $_.pdfSizeBytes } | Measure-Object -Property pdfSizeBytes -Sum).Sum)
    $significantCount = @($paperObjects | Where-Object { $null -ne $_.headlineP -and $_.headlineP -lt 0.05 }).Count

    $batchObjects += [pscustomobject]([ordered]@{
        date = $batchDir.Name
        dateLabel = Convert-ToDateLabel -DateText $batchDir.Name
        paperCount = $paperObjects.Count
        totalRows = $rowTotal
        totalEntitiesReported = $entityTotal
        totalPdfBytes = $pdfTotal
        totalPdfBytesMb = [math]::Round(($pdfTotal / 1MB), 2)
        significantCount = $significantCount
        papers = @($paperObjects)
    })
}

$latestBatch = $batchObjects | Select-Object -First 1
$generatedAt = (Get-Date).ToUniversalTime()
$summaryObject = [ordered]@{
    totalPapers = @($batchObjects | ForEach-Object { $_.paperCount } | Measure-Object -Sum).Sum
    totalBatches = $batchObjects.Count
    totalRows = @($batchObjects | ForEach-Object { $_.totalRows } | Measure-Object -Sum).Sum
    significantHeadlines = @($batchObjects | ForEach-Object { $_.significantCount } | Measure-Object -Sum).Sum
    totalPdfBytes = @($batchObjects | ForEach-Object { $_.totalPdfBytes } | Measure-Object -Sum).Sum
    generatedAtUtc = $generatedAt.ToString("yyyy-MM-ddTHH:mm:ssZ")
    generatedAtLabel = $generatedAt.ToString("MMMM d, yyyy 'at' HH:mm 'UTC'", [System.Globalization.CultureInfo]::InvariantCulture)
    latestBatchDate = if ($latestBatch) { $latestBatch.date } else { $null }
    latestBatchLabel = if ($latestBatch) { $latestBatch.dateLabel } else { "No batch yet" }
}

$siteObject = [ordered]@{
    site = [ordered]@{
        title = "Can AI Do Strategy Replication?"
        subtitle = "A live archive of AI-assisted, data-backed replication papers in strategy and innovation research."
        repoUrl = $repoUrl
        pagesUrl = $siteUrl
    }
    summary = $summaryObject
    batches = @($batchObjects)
}

Write-TextFile -Path $siteDataPath -Lines @((ConvertTo-Json -Depth 8 -InputObject $siteObject))

$readmeLines = @'
# AI-Augmented Replication in Management Science

> *"Innovation points out paths that are possible; replication points out paths that are likely; progress relies on both."*
> - Open Science Collaboration (2015, p. 943)

Live site: <{SITE_URL}>

Repository: <{REPO_URL}>

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
'@ -replace '\{SITE_URL\}', $siteUrl -replace '\{REPO_URL\}', $repoUrl -split "`r?`n"

$readmeLines += @(
    "",
    ("- published papers: {0}" -f $summaryObject.totalPapers),
    ("- published batches: {0}" -f $summaryObject.totalBatches),
    ("- analyzed rows across batches: {0:N0}" -f $summaryObject.totalRows),
    ("- headline estimates with p " + "< .05: " + $summaryObject.significantHeadlines),
    ("- latest batch: {0}" -f $summaryObject.latestBatchLabel),
    "",
    "## Latest Batch"
)

if ($latestBatch) {
    $readmeLines += ""
    foreach ($paper in $latestBatch.papers) {
        $headlinePart = Format-HeadlineForReadme -Estimate $paper.headlineEstimate -PValue $paper.headlineP -Term $paper.headlineTerm
        $rowLabel = if ($null -ne $paper.rows) { "{0:N0}" -f $paper.rows } else { "NA" }
        $entityLabel = if ($null -ne $paper.entities) { "{0:N0}" -f $paper.entities } else { "NA" }
        $readmeLines += "- [{0}]({1}) - rows: {2}, entities: {3}, {4}" -f $paper.title, $paper.pdfUrl, $rowLabel, $entityLabel, $headlinePart
    }
}
else {
    $readmeLines += "", "- No published batch has been detected yet."
}

$readmeLines += @(
    "",
    "## Repository Structure",
    "",
    '- `papers/YYYY-MM-DD/` stores the published PDFs for each batch.',
    '- `assets/data/library.json` stores the structured metadata used by the website.',
    '- `tools/publish-batch.ps1` publishes a local batch into the site repository.',
    '- `tools/update-site.ps1` rebuilds the website metadata and this README from the currently published batches.',
    '- `skills/write-replication-journal-github/SKILL.md` documents the manuscript and publishing standard.',
    "",
    "## What Each Replication Package Contains",
    "",
    "- a formal journal-style replication paper in PDF form",
    "- a paper-specific estimation dataset exported from the local workflow",
    "- coefficient and fit summaries used in the manuscript",
    "- a detailed comparison between the original paper and the local replication",
    "- explicit statements about the local data boundary and replication decisions",
    "",
    "## Theoretical Foundations",
    "",
    "**The Replication Crisis**",
    "",
    "- Open Science Collaboration. (2015). Estimating the reproducibility of psychological science. *Science, 349*(6251), aac4716. https://doi.org/10.1126/science.aac4716",
    "- Camerer, C. F., Dreber, A., Forsell, E., Ho, T.-H., Huber, J., Johannesson, M., Kirchler, M., Almenberg, J., Altmejd, A., Chan, T., Heikensten, E., Holzmeister, F., Imai, T., Isaksson, S., Nave, G., Pfeiffer, T., Razen, M., & Wu, H. (2016). Evaluating replicability of laboratory experiments in economics. *Science, 351*(6280), 1433-1436. https://doi.org/10.1126/science.aaf0918",
    "- Camerer, C. F., Dreber, A., Holzmeister, F., Ho, T.-H., Huber, J., Johannesson, M., Kirchler, M., Nave, G., Nosek, B. A., Pfeiffer, T., Altmejd, A., Buttrick, N., Chan, T., Chen, Y., Forsell, E., Gampa, A., Heikensten, E., Hummer, L., Imai, T., ... Wu, H. (2018). Evaluating the replicability of social science experiments in *Nature* and *Science* between 2010 and 2015. *Nature Human Behaviour, 2*(9), 637-644. https://doi.org/10.1038/s41562-018-0399-z",
    "- Bettis, R. A., Ethiraj, S., Gambardella, A., Helfat, C., & Mitchell, W. (2016). Creating repeatable cumulative knowledge in strategic management. *Strategic Management Journal, 37*(2), 257-261. https://doi.org/10.1002/smj.2477",
    "",
    "**The Knowledge-Based View & Organizational Learning**",
    "",
    "- Nelson, R. R., & Winter, S. G. (1982). *An evolutionary theory of economic change*. Harvard University Press.",
    "- Barney, J. (1991). Firm resources and sustained competitive advantage. *Journal of Management, 17*(1), 99-120. https://doi.org/10.1177/014920639101700108",
    "- Grant, R. M. (1996). Toward a knowledge-based theory of the firm. *Strategic Management Journal, 17*(S2), 109-122. https://doi.org/10.1002/smj.4250171110",
    "- Cohen, W. M., & Levinthal, D. A. (1990). Absorptive capacity: A new perspective on learning and innovation. *Administrative Science Quarterly, 35*(1), 128-152. https://doi.org/10.2307/2393553",
    "- Nonaka, I. (1994). A dynamic theory of organizational knowledge creation. *Organization Science, 5*(1), 14-37. https://doi.org/10.1287/orsc.5.1.14",
    "- Polanyi, M. (1966). *The tacit dimension*. University of Chicago Press.",
    "",
    "**AI, Knowledge Work, and Strategic Implications**",
    "",
    "- Dell'Acqua, F., McFowland, E., Mollick, E. R., Lifshitz-Assaf, H., Kellogg, K. C., Rajendran, S., Krayer, L., Candelon, F., & Lakhani, K. R. (2023). Navigating the jagged technological frontier: Field experimental evidence of the effects of AI on knowledge worker productivity and quality. *Harvard Business School Working Paper* No. 24-013. https://doi.org/10.2139/ssrn.4573321",
    "- Doshi, A. R., & Hauser, O. P. (2024). Generative AI enhances individual creativity but reduces the collective diversity of novel content. *Science Advances, 10*(28), eadn5290. https://doi.org/10.1126/sciadv.adn5290",
    "- Doshi, A. R., Bell, J. J., Mirzayev, E., & Vanneste, B. (2025). Generative artificial intelligence and evaluating strategic decisions. *Strategic Management Journal, 46*(4). https://doi.org/10.1002/smj.3677",
    "",
    "## How to Contribute",
    "",
    "1. Read a source paper closely before touching the data.",
    "2. Identify the required data objects and map them to the processed local files that actually exist in the workspace.",
    "3. Build the replication around the executable local dataset rather than imagined source archives or unavailable raw inputs.",
    "4. Write the comparison section explicitly: original methodology, local dataset architecture, focal effects, interpretation, and conclusion.",
    "5. Keep human reflection in the loop by recording what appears codified and what still looks tacit or judgment-heavy.",
    "",
    "## Local Refresh Tools",
    "",
    ('- ' + [char]96 + 'tools/publish-batch.ps1' + [char]96 + ' copies compiled PDFs from the workspace into this repository and refreshes the public archive.'),
    ('- ' + [char]96 + 'tools/update-site.ps1' + [char]96 + ' rebuilds ' + [char]96 + 'assets/data/library.json' + [char]96 + ' and ' + [char]96 + 'README.md' + [char]96 + ' from the currently published batches.'),
    "",
    "## Citation",
    "",
    '```bibtex',
    '@misc{ai_bryce_2026,',
    '  author       = {Bryce Ai},',
    '  title        = {AI-Augmented Replication in Management Science},',
    '  year         = {2026},',
    '  publisher    = {GitHub},',
    '  url          = {https://github.com/BoBryceAi/Replication-paper}',
    '}',
    '```',
    "",
    "## About",
    "",
    "This repository is maintained as an ongoing project on AI-augmented reproducibility in management science and strategy research.",
    "Contact: [GitHub](https://github.com/BoBryceAi)",
    "",
    "The archive is a living document. It is intended to grow as more replications are completed, more data boundaries are documented, and the gap between codified and tacit knowledge becomes easier to study directly."
)

Write-TextFile -Path $readmePath -Lines $readmeLines
Write-Host ("Updated site data for {0} published batch(es)." -f $summaryObject.totalBatches)
