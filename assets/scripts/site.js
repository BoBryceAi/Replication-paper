const DATA_URL = "assets/data/library.json";

const numberFormat = new Intl.NumberFormat("en-US");
const oneDecimalFormat = new Intl.NumberFormat("en-US", { maximumFractionDigits: 1, minimumFractionDigits: 1 });
const compactFormat = new Intl.NumberFormat("en-US", { notation: "compact", maximumFractionDigits: 1 });

const state = {
  data: null,
  query: ""
};

async function loadLibrary() {
  try {
    const response = await fetch(`${DATA_URL}?v=${Date.now()}`, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`Failed to load site data (${response.status})`);
    }

    state.data = await response.json();
    render();
  } catch (error) {
    renderError(error);
  }
}

function formatCount(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }
  return numberFormat.format(Number(value));
}

function formatLargeCount(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }
  const numericValue = Number(value);
  if (numericValue >= 1000000) {
    return compactFormat.format(numericValue);
  }
  return numberFormat.format(numericValue);
}

function formatOneDecimal(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }
  return oneDecimalFormat.format(Number(value));
}

function formatEstimate(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }

  const numericValue = Number(value);
  const absoluteValue = Math.abs(numericValue);

  if (absoluteValue > 0 && absoluteValue < 0.0001) {
    return numericValue.toExponential(2);
  }
  if (absoluteValue >= 10) {
    return oneDecimalFormat.format(numericValue);
  }
  if (absoluteValue >= 1) {
    return numericValue.toFixed(3);
  }
  if (absoluteValue >= 0.1) {
    return numericValue.toFixed(4);
  }
  return numericValue.toFixed(5);
}

function formatPValue(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }

  const numericValue = Number(value);
  if (numericValue < 0.001) {
    return "< .001";
  }
  if (numericValue < 0.1) {
    return numericValue.toFixed(3);
  }
  return numericValue.toFixed(2);
}

function createPill(label, className = "") {
  return `<span class="pill ${className}">${label}</span>`;
}

function paperMatchesQuery(paper, query) {
  if (!query) {
    return true;
  }

  const haystack = [
    paper.title,
    paper.slug,
    paper.date,
    paper.headlineTerm,
    paper.pdfName
  ]
    .join(" ")
    .toLowerCase();

  return haystack.includes(query);
}

function renderStats(summary) {
  document.getElementById("metric-papers").textContent = formatCount(summary.totalPapers);
  document.getElementById("metric-batches").textContent = formatCount(summary.totalBatches);
  document.getElementById("metric-rows").textContent = formatLargeCount(summary.totalRows);
  document.getElementById("metric-significant").textContent = formatCount(summary.significantHeadlines);
  document.getElementById("footer-updated").textContent = `Last site refresh: ${summary.generatedAtLabel}. Latest batch: ${summary.latestBatchLabel}.`;
}

function renderLatestBatch(batch) {
  const latestTitle = document.getElementById("latest-batch-title");
  const latestCopy = document.getElementById("latest-batch-copy");
  const latestGrid = document.getElementById("latest-batch-grid");

  if (!batch) {
    latestTitle.textContent = "No published batch yet";
    latestCopy.textContent = "The site data feed does not contain any published replication batch.";
    latestGrid.innerHTML = `<div class="empty-state">No papers are available yet.</div>`;
    return;
  }

  latestTitle.textContent = `${batch.dateLabel} batch`;
  latestCopy.textContent = `${formatCount(batch.paperCount)} papers, ${formatCount(batch.totalRows)} analyzed rows, and ${formatCount(batch.significantCount)} headline estimates with p < .05.`;

  latestGrid.innerHTML = batch.papers
    .map((paper) => {
      const significancePill = paper.headlineP !== null && paper.headlineP < 0.05
        ? createPill("Headline p < .05", "pill-significant")
        : createPill("Published PDF", "pill-muted");

      return `
        <article class="paper-card featured">
          <div class="paper-header">
            <span class="paper-kicker">${paper.date}</span>
            <h3 class="paper-title">${paper.title}</h3>
            <a class="paper-link" href="${paper.pdfUrl}" target="_blank" rel="noreferrer">Open PDF</a>
          </div>
          <p class="paper-summary">${paper.headlineTerm} = ${formatEstimate(paper.headlineEstimate)}; p = ${formatPValue(paper.headlineP)}</p>
          <div class="pill-row">
            ${createPill(`${formatCount(paper.rows)} rows`)}
            ${createPill(`${formatCount(paper.entities)} entities`)}
            ${createPill(paper.pdfSizeLabel || "PDF ready")}
            ${significancePill}
          </div>
          <div class="paper-stat-grid">
            <div class="paper-stat">
              <span class="meta-label">Headline estimate</span>
              <strong>${formatEstimate(paper.headlineEstimate)}</strong>
            </div>
            <div class="paper-stat">
              <span class="meta-label">Headline p-value</span>
              <strong>${formatPValue(paper.headlineP)}</strong>
            </div>
          </div>
        </article>
      `;
    })
    .join("");
}

function renderArchive(data, query) {
  const archive = document.getElementById("archive-batches");
  const searchSummary = document.getElementById("search-summary");

  const filteredBatches = data.batches
    .map((batch) => ({
      ...batch,
      papers: batch.papers.filter((paper) => paperMatchesQuery(paper, query))
    }))
    .filter((batch) => batch.papers.length > 0);

  const filteredPaperCount = filteredBatches.reduce((sum, batch) => sum + batch.papers.length, 0);

  searchSummary.textContent = query
    ? `Showing ${formatCount(filteredPaperCount)} papers across ${formatCount(filteredBatches.length)} batches for "${query}".`
    : `Showing all ${formatCount(data.summary.totalPapers)} published papers across ${formatCount(data.summary.totalBatches)} batches.`;

  if (!filteredBatches.length) {
    archive.innerHTML = `<div class="empty-state">No papers match that search yet.</div>`;
    return;
  }

  archive.innerHTML = filteredBatches
    .map((batch) => {
      const paperMarkup = batch.papers
        .map((paper) => {
          const significancePill = paper.headlineP !== null && paper.headlineP < 0.05
            ? createPill("Headline p < .05", "pill-significant")
            : "";

          return `
            <article class="paper-card">
              <div class="paper-header">
                <span class="paper-kicker">${paper.date}</span>
                <h3 class="paper-title">${paper.title}</h3>
                <a class="paper-link" href="${paper.pdfUrl}" target="_blank" rel="noreferrer">Open PDF</a>
              </div>
              <p class="paper-summary">${paper.headlineTerm} = ${formatEstimate(paper.headlineEstimate)}; p = ${formatPValue(paper.headlineP)}</p>
              <div class="pill-row">
                ${createPill(`${formatCount(paper.rows)} rows`)}
                ${createPill(`${formatCount(paper.entities)} entities`)}
                ${createPill(paper.pdfSizeLabel || "PDF ready")}
                ${significancePill}
              </div>
            </article>
          `;
        })
        .join("");

      return `
        <section class="batch-shell">
          <div class="batch-header">
            <div>
              <p class="eyebrow">Batch</p>
              <h3>${batch.dateLabel}</h3>
              <p class="batch-meta">${formatCount(batch.paperCount)} papers, ${formatCount(batch.totalRows)} analyzed rows, ${formatCount(batch.significantCount)} significant headline estimates.</p>
            </div>
            <div class="pill-row">
              ${createPill(`${formatOneDecimal(batch.totalPdfBytesMb)} MB of PDFs`)}
              ${createPill(`${formatCount(batch.totalEntitiesReported)} reported entities`)}
            </div>
          </div>
          <div class="batch-paper-grid">
            ${paperMarkup}
          </div>
        </section>
      `;
    })
    .join("");
}

function render() {
  const { data } = state;
  if (!data) {
    return;
  }

  renderStats(data.summary);
  renderLatestBatch(data.batches[0]);
  renderArchive(data, state.query);
}

function renderError(error) {
  document.getElementById("latest-batch-title").textContent = "Site data unavailable";
  document.getElementById("latest-batch-copy").textContent = error.message;
  document.getElementById("latest-batch-grid").innerHTML = `<div class="empty-state">The public data feed could not be loaded.</div>`;
  document.getElementById("archive-batches").innerHTML = `<div class="empty-state">The paper library will appear here once the data feed is available.</div>`;
  document.getElementById("search-summary").textContent = "No site data available.";
  document.getElementById("footer-updated").textContent = "Site data feed could not be loaded.";
}

document.getElementById("library-search").addEventListener("input", (event) => {
  state.query = event.target.value.trim().toLowerCase();
  if (state.data) {
    renderArchive(state.data, state.query);
  }
});

loadLibrary();
