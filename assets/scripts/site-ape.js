const DATA_URL = "assets/data/library.json";

const integerFormat = new Intl.NumberFormat("en-US");
const compactFormat = new Intl.NumberFormat("en-US", {
  notation: "compact",
  maximumFractionDigits: 1
});
const oneDecimalFormat = new Intl.NumberFormat("en-US", {
  minimumFractionDigits: 1,
  maximumFractionDigits: 1
});

const state = {
  data: null,
  query: "",
  sort: "newest"
};

async function loadLibrary() {
  try {
    const response = await fetch(`${DATA_URL}?v=${Date.now()}`, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`Failed to load site data (${response.status})`);
    }

    state.data = await response.json();
    renderAll();
  } catch (error) {
    renderError(error);
  }
}

function formatCount(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }
  return integerFormat.format(Number(value));
}

function formatLargeCount(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }
  const numericValue = Number(value);
  return numericValue >= 1000000 ? compactFormat.format(numericValue) : integerFormat.format(numericValue);
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
  if (absoluteValue >= 100) {
    return numericValue.toFixed(1);
  }
  if (absoluteValue >= 10) {
    return numericValue.toFixed(2);
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

function formatMb(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "NA";
  }
  return `${oneDecimalFormat.format(Number(value))} MB`;
}

function createPill(label, className = "") {
  return `<span class="pill ${className}">${label}</span>`;
}

function flattenPapers(data) {
  return data.batches.flatMap((batch, batchIndex) =>
    batch.papers.map((paper, paperIndex) => ({
      ...paper,
      batchDate: batch.date,
      batchDateLabel: batch.dateLabel,
      batchPaperCount: batch.paperCount,
      batchRows: batch.totalRows,
      batchSignificantCount: batch.significantCount,
      batchEntities: batch.totalEntitiesReported,
      batchPdfMb: batch.totalPdfBytesMb,
      batchIndex,
      paperIndex
    }))
  );
}

function paperMatchesQuery(paper, query) {
  if (!query) {
    return true;
  }

  const haystack = [
    paper.title,
    paper.slug,
    paper.date,
    paper.batchDate,
    paper.batchDateLabel,
    paper.headlineTerm,
    paper.pdfName
  ]
    .join(" ")
    .toLowerCase();

  return haystack.includes(query);
}

function sortPapers(papers, sortKey) {
  const sorted = [...papers];

  if (sortKey === "rows") {
    sorted.sort((a, b) => {
      const rowDelta = Number(b.rows) - Number(a.rows);
      if (rowDelta !== 0) {
        return rowDelta;
      }
      return String(b.date).localeCompare(String(a.date));
    });
    return sorted;
  }

  if (sortKey === "signal") {
    sorted.sort((a, b) => {
      const aP = Number(a.headlineP);
      const bP = Number(b.headlineP);
      const aHas = Number.isFinite(aP);
      const bHas = Number.isFinite(bP);

      if (aHas && bHas && aP !== bP) {
        return aP - bP;
      }
      if (aHas !== bHas) {
        return aHas ? -1 : 1;
      }

      const absDelta = Math.abs(Number(b.headlineEstimate || 0)) - Math.abs(Number(a.headlineEstimate || 0));
      if (absDelta !== 0) {
        return absDelta;
      }

      return Number(b.rows) - Number(a.rows);
    });
    return sorted;
  }

  sorted.sort((a, b) => {
    const dateDelta = String(b.date).localeCompare(String(a.date));
    if (dateDelta !== 0) {
      return dateDelta;
    }
    return Number(b.rows) - Number(a.rows);
  });
  return sorted;
}

function buildPaperCard(paper) {
  const significancePill = paper.headlineP !== null && Number(paper.headlineP) < 0.05
    ? createPill("Headline p < .05", "pill-significant")
    : createPill("Published PDF", "pill-muted");

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
}

function renderSummary(data) {
  const { summary, batches } = data;
  const latestBatch = batches[0];

  document.getElementById("metric-papers").textContent = formatCount(summary.totalPapers);
  document.getElementById("metric-batches").textContent = formatCount(summary.totalBatches);
  document.getElementById("metric-rows").textContent = formatLargeCount(summary.totalRows);
  document.getElementById("metric-significant").textContent = formatCount(summary.significantHeadlines);
  document.getElementById("metric-latest").textContent = summary.latestBatchDate || "--";
  document.getElementById("footer-updated").textContent = `Last site refresh: ${summary.generatedAtLabel}. Latest release: ${summary.latestBatchLabel}.`;
  document.getElementById("update-banner-copy").textContent = `${summary.latestBatchLabel} is live with ${formatCount(summary.totalPapers)} public papers across ${formatCount(summary.totalBatches)} published batches.`;

  if (latestBatch) {
    document.getElementById("hero-latest-title").textContent = latestBatch.dateLabel;
    document.getElementById("hero-latest-copy").textContent = `${formatCount(latestBatch.paperCount)} papers, ${formatCount(latestBatch.totalRows)} rows, ${formatCount(latestBatch.significantCount)} headline signals, and ${formatMb(latestBatch.totalPdfBytesMb)} of compiled PDFs.`;
    document.getElementById("hero-latest-pills").innerHTML = [
      createPill(`${formatCount(latestBatch.paperCount)} papers`),
      createPill(`${formatCount(latestBatch.totalRows)} rows`),
      createPill(`${formatCount(latestBatch.totalEntitiesReported)} entities`),
      createPill(`${formatCount(latestBatch.significantCount)} signals`, latestBatch.significantCount > 0 ? "pill-significant" : "")
    ].join("");
  }
}

function renderHeroTopPapers(allPapers) {
  const container = document.getElementById("hero-top-papers");
  const topPapers = sortPapers(allPapers, "rows").slice(0, 3);

  container.innerHTML = topPapers
    .map((paper) => `
      <article class="compact-paper">
        <a href="${paper.pdfUrl}" target="_blank" rel="noreferrer">${paper.title}</a>
        <div class="compact-paper-meta">
          <span>${paper.batchDateLabel}</span>
          <span>${formatCount(paper.rows)} rows</span>
          <span>p ${formatPValue(paper.headlineP)}</span>
        </div>
      </article>
    `)
    .join("");
}

function renderLatestBatch(batch) {
  const latestTitle = document.getElementById("latest-batch-title");
  const latestCopy = document.getElementById("latest-batch-copy");
  const latestGrid = document.getElementById("latest-batch-grid");
  const featurePanel = document.getElementById("latest-feature-panel");

  if (!batch) {
    latestTitle.textContent = "No published batch yet";
    latestCopy.textContent = "The public site does not have a batch to display yet.";
    latestGrid.innerHTML = `<div class="empty-state">No papers are available yet.</div>`;
    featurePanel.innerHTML = `<div class="empty-state">Latest batch metadata is not available.</div>`;
    return;
  }

  latestTitle.textContent = `${batch.dateLabel} batch`;
  latestCopy.textContent = `This release contains ${formatCount(batch.paperCount)} formal replication papers and ${formatCount(batch.totalRows)} analyzed rows drawn from the current executable dataset stack.`;

  featurePanel.innerHTML = `
    <p class="panel-kicker">Batch overview</p>
    <h3>${batch.dateLabel}</h3>
    <p class="section-copy">
      The current release combines long-form replication manuscripts, compiled PDFs, and a synchronized site feed.
      The batch headline counts below are generated directly from the same public JSON archive that drives the rest of this page.
    </p>
    <div class="feature-stat-row">
      <div class="feature-stat">
        <span class="meta-label">Published papers</span>
        <strong>${formatCount(batch.paperCount)}</strong>
      </div>
      <div class="feature-stat">
        <span class="meta-label">Analyzed rows</span>
        <strong>${formatLargeCount(batch.totalRows)}</strong>
      </div>
      <div class="feature-stat">
        <span class="meta-label">Reported entities</span>
        <strong>${formatCount(batch.totalEntitiesReported)}</strong>
      </div>
      <div class="feature-stat">
        <span class="meta-label">Headline signals</span>
        <strong>${formatCount(batch.significantCount)}</strong>
      </div>
    </div>
    <div class="feature-grid">
      <div class="pill-row">
        ${createPill(formatMb(batch.totalPdfBytesMb))}
        ${createPill(`${formatCount(batch.paperCount)} PDFs`)}
        ${createPill(batch.significantCount > 0 ? `${formatCount(batch.significantCount)} p < .05` : "No p < .05 headlines", batch.significantCount > 0 ? "pill-significant" : "pill-muted")}
      </div>
      <p class="section-copy">
        Every latest-batch paper is linked below as a full PDF and remains visible again in the archive section so the site can function both as a landing page and as a historical record.
      </p>
    </div>
  `;

  latestGrid.innerHTML = batch.papers.map(buildPaperCard).join("");
}

function renderBatchGrowth(data) {
  const chart = document.getElementById("batch-growth-chart");
  const batches = [...data.batches].reverse();
  const maxRows = Math.max(...batches.map((batch) => Number(batch.totalRows || 0)), 1);

  chart.innerHTML = batches
    .map((batch) => {
      const width = `${Math.max(8, (Number(batch.totalRows || 0) / maxRows) * 100)}%`;
      return `
        <div class="bar-item">
          <div class="bar-head">
            <strong>${batch.dateLabel}</strong>
            <span>${formatCount(batch.totalRows)} rows</span>
          </div>
          <div class="bar-track">
            <div class="bar-fill" style="width:${width}"></div>
          </div>
          <div class="bar-caption">${formatCount(batch.paperCount)} papers, ${formatCount(batch.significantCount)} headline signals.</div>
        </div>
      `;
    })
    .join("");
}

function renderSampleSizeChart(allPapers) {
  const chart = document.getElementById("sample-size-chart");
  const papers = sortPapers(allPapers, "rows").slice(0, 5);
  const maxRows = Math.max(...papers.map((paper) => Number(paper.rows || 0)), 1);

  chart.innerHTML = papers
    .map((paper) => {
      const width = `${Math.max(8, (Number(paper.rows || 0) / maxRows) * 100)}%`;
      const signalClass = Number.isFinite(Number(paper.headlineP)) && Number(paper.headlineP) < 0.05 ? "is-signal" : "";
      return `
        <div class="bar-item">
          <div class="bar-head">
            <strong>${paper.title}</strong>
            <span>${formatCount(paper.rows)} rows</span>
          </div>
          <div class="bar-track">
            <div class="bar-fill ${signalClass}" style="width:${width}"></div>
          </div>
          <div class="bar-caption">${paper.batchDateLabel}. ${paper.headlineTerm} = ${formatEstimate(paper.headlineEstimate)}; p = ${formatPValue(paper.headlineP)}.</div>
        </div>
      `;
    })
    .join("");
}

function renderLeaderboard(data, query, sortKey) {
  const allPapers = flattenPapers(data)
    .filter((paper) => paperMatchesQuery(paper, query));
  const sorted = sortPapers(allPapers, sortKey);

  document.getElementById("leaderboard-summary").textContent = query
    ? `Showing ${formatCount(sorted.length)} papers for "${query}" sorted by ${sortKey}.`
    : `Showing all ${formatCount(sorted.length)} published papers sorted by ${sortKey}.`;

  const tbody = document.getElementById("leaderboard-body");

  if (!sorted.length) {
    tbody.innerHTML = `<tr><td colspan="8" class="empty-cell">No papers match that search yet.</td></tr>`;
    return;
  }

  tbody.innerHTML = sorted
    .map((paper, index) => {
      const isSignal = Number.isFinite(Number(paper.headlineP)) && Number(paper.headlineP) < 0.05;

      return `
        <tr>
          <td data-label="Rank"><span class="rank-badge">${index + 1}</span></td>
          <td data-label="Paper">
            <div class="table-title">
              <a href="${paper.pdfUrl}" target="_blank" rel="noreferrer">${paper.title}</a>
              <small>${paper.headlineTerm}</small>
            </div>
          </td>
          <td data-label="Batch">${paper.batchDate}</td>
          <td data-label="Rows">${formatCount(paper.rows)}</td>
          <td data-label="Entities">${formatCount(paper.entities)}</td>
          <td data-label="Headline estimate">${formatEstimate(paper.headlineEstimate)}</td>
          <td data-label="P-value">
            <span class="status-dot ${isSignal ? "is-signal" : ""}">${formatPValue(paper.headlineP)}</span>
          </td>
          <td data-label="PDF"><a class="paper-link" href="${paper.pdfUrl}" target="_blank" rel="noreferrer">Open</a></td>
        </tr>
      `;
    })
    .join("");
}

function renderArchive(data, query) {
  const archive = document.getElementById("archive-batches");
  const filteredBatches = data.batches
    .map((batch) => ({
      ...batch,
      papers: batch.papers.filter((paper) => paperMatchesQuery({ ...paper, batchDate: batch.date, batchDateLabel: batch.dateLabel }, query))
    }))
    .filter((batch) => batch.papers.length > 0);

  if (!filteredBatches.length) {
    archive.innerHTML = `<div class="empty-state">No batches match that search yet.</div>`;
    return;
  }

  archive.innerHTML = filteredBatches
    .map((batch) => `
      <section class="batch-shell">
        <div class="batch-header">
          <div>
            <p class="eyebrow">Batch</p>
            <h3>${batch.dateLabel}</h3>
            <p class="batch-meta">${formatCount(batch.paperCount)} papers, ${formatCount(batch.totalRows)} analyzed rows, and ${formatCount(batch.significantCount)} headline signals.</p>
          </div>
          <div class="pill-row">
            ${createPill(`${formatCount(batch.totalEntitiesReported)} entities`)}
            ${createPill(formatMb(batch.totalPdfBytesMb))}
          </div>
        </div>
        <div class="batch-paper-grid">
          ${batch.papers.map(buildPaperCard).join("")}
        </div>
      </section>
    `)
    .join("");
}

function renderAll() {
  if (!state.data) {
    return;
  }

  const allPapers = flattenPapers(state.data);

  renderSummary(state.data);
  renderHeroTopPapers(allPapers);
  renderLatestBatch(state.data.batches[0]);
  renderBatchGrowth(state.data);
  renderSampleSizeChart(allPapers);
  renderLeaderboard(state.data, state.query, state.sort);
  renderArchive(state.data, state.query);
}

function renderError(error) {
  const message = error instanceof Error ? error.message : "The site data feed could not be loaded.";
  document.getElementById("update-banner-copy").textContent = "Live archive data could not be loaded.";
  document.getElementById("hero-latest-title").textContent = "Site data unavailable";
  document.getElementById("hero-latest-copy").textContent = message;
  document.getElementById("latest-batch-title").textContent = "Site data unavailable";
  document.getElementById("latest-batch-copy").textContent = message;
  document.getElementById("latest-feature-panel").innerHTML = `<div class="empty-state">${message}</div>`;
  document.getElementById("latest-batch-grid").innerHTML = `<div class="empty-state">The latest batch cannot be shown without the data feed.</div>`;
  document.getElementById("batch-growth-chart").innerHTML = `<div class="empty-state">No batch data available.</div>`;
  document.getElementById("sample-size-chart").innerHTML = `<div class="empty-state">No paper data available.</div>`;
  document.getElementById("leaderboard-summary").textContent = "No leaderboard data available.";
  document.getElementById("leaderboard-body").innerHTML = `<tr><td colspan="8" class="empty-cell">${message}</td></tr>`;
  document.getElementById("archive-batches").innerHTML = `<div class="empty-state">The archive will appear here once the data feed is available.</div>`;
  document.getElementById("footer-updated").textContent = "Site data feed could not be loaded.";
}

document.getElementById("library-search").addEventListener("input", (event) => {
  state.query = event.target.value.trim().toLowerCase();
  if (state.data) {
    renderLeaderboard(state.data, state.query, state.sort);
    renderArchive(state.data, state.query);
  }
});

document.querySelectorAll(".sort-button").forEach((button) => {
  button.addEventListener("click", () => {
    state.sort = button.dataset.sort || "newest";
    document.querySelectorAll(".sort-button").forEach((candidate) => {
      candidate.classList.toggle("is-active", candidate === button);
    });
    if (state.data) {
      renderLeaderboard(state.data, state.query, state.sort);
    }
  });
});

loadLibrary();
