<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Part Specification - History</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>
  * { box-sizing: border-box; }

  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #f7f9fa;
    color: #333;
  }

  /* ===== TOPBAR ===== */
  .topbar {
    display: flex;
    background: #ffffff;
    border-bottom: 1px solid #e2e5e9;
    padding: 12px 20px;
    align-items: center;
    justify-content: space-between;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  }
  .topbar-left {
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .topbar-icon {
    width: 42px;
    height: 42px;
    border-radius: 10px;
    background: #f1f5f9;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    color: #4b5563;
    flex-shrink: 0;
  }
  .topbar-name {
    font-size: 16px;
    font-weight: 700;
    color: #111827;
    margin: 0 0 2px 0;
  }
  .topbar-type {
    font-size: 12px;
    color: #6b7280;
    margin: 0;
  }
  .topbar-right {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    font-weight: 500;
    color: #374151;
  }

  .state-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 4px 12px;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }
  .state-badge.InWork      { background: #dbeafe; color: #1d4ed8; }
  .state-badge.InApproval  { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
  .state-badge.Completed   { background: #dcfce7; color: #166534; }
  .state-badge.Cancelled   { background: #1f2937; color: #ffffff; }

  /* ===== LAYOUT ===== */
  .page-container {
    display: flex;
    height: calc(100vh - 65px);
    overflow: hidden;
  }

  .sidebar {
    width: 19%;
    background-color: #f8f9fa;
    border-right: 1px solid #ddd;
    padding: 20px;
    font-size: 14px;
    box-sizing: border-box;
    overflow-y: auto;
    overflow-x: hidden;
  }
  .sidebar a {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    color: #4b5563;
    text-decoration: none;
    margin-bottom: 6px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 500;
    transition: all 0.2s ease;
    white-space: nowrap;
  }
  .sidebar a:hover { background-color: #e3e7ea; color: #111827; }
  .sidebar a.active { background-color: #4b5563; color: white; font-weight: 600; }
  .sidebar a i { width: 16px; font-size: 13px; color: #6b7280; }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
    flex-grow: 1;
    padding: 0;
    overflow-y: auto;
    box-sizing: border-box;
  }

  /* ===== HISTORY TIMELINE ===== */
  .history-wrapper {
    overflow-y: auto;
    width: 100%;
    max-width: 1100px;
    box-sizing: border-box;
  }
  .history-toolbar {
    background-color: #000000;
    padding: 8px 14px;
    display: flex;
    align-items: center;
    gap: 10px;
    border-bottom: 1px solid #334155;
    margin: 0;
  }
  .history-toolbar h4 {
    margin: 0;
    font-size: 13px;
    font-weight: 600;
    color: #e2e8f0;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }
  .history-icon {
    width: 18px;
    height: 18px;
    filter: invert(1);
  }

  .timeline {
    position: relative;
    padding: 24px 28px 24px 68px;
  }
  .timeline::before {
    content: '';
    position: absolute;
    left: 42px; top: 24px; bottom: 24px;
    width: 2px;
    background: #e5e7eb;
  }

  .timeline-item {
    position: relative;
    padding: 11px 20px;
    border-bottom: 1px solid #f1f5f9;
    display: flex;
    align-items: flex-start;
    gap: 16px;
    background: #fff;
    transition: background 0.15s;
  }
  .timeline-item:last-child { border-bottom: none; }
  .timeline-item:hover { background: #f8fafc; }

  .timeline-dot {
    position: absolute;
    left: -32px; top: 20px;
    width: 14px; height: 14px;
    border-radius: 50%;
    border: 2px solid #fff;
    box-shadow: 0 0 0 2px #e5e7eb;
    flex-shrink: 0;
    z-index: 1;
  }

  .timeline-icon {
    width: 32px; height: 32px;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 13px;
    flex-shrink: 0;
  }

  .timeline-content { flex: 1; }
  .timeline-sub { font-size: 12px; color: #6b7280; margin-top: 2px; }
  .timeline-date { font-size: 11px; color: #9ca3af; white-space: nowrap; margin-left: auto; padding-top: 2px; }

  #noHistoryMsg {
    padding: 24px;
    text-align: center;
    color: #9ca3af;
    font-size: 13px;
  }

  .timeline-dot.dot-created  { background: #22c55e; box-shadow: 0 0 0 2px #22c55e33; }
  .timeline-dot.dot-promoted { background: #3b82f6; box-shadow: 0 0 0 2px #3b82f633; }
  .timeline-dot.dot-default  { background: #9ca3af; box-shadow: 0 0 0 2px #9ca3af33; }
  .timeline-dot.dot-demoted  { background: #f97316; box-shadow: 0 0 0 2px #f9731633; }

  .timeline-icon.icon-created  { background: #dcfce7; color: #166534; }
  .timeline-icon.icon-promoted { background: #dbeafe; color: #1d4ed8; }
  .timeline-icon.icon-default  { background: #f3f4f6; color: #4b5563; }
  .timeline-icon.icon-demoted { background: #ffedd5; color: #c2410c; }

  .timeline-action {
    font-size: 13px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 2px;
  }

  .timeline-action .state-highlight {
    font-weight: 700;
  }

  .state-highlight.draft    { color: #6c757d; }
  .state-highlight.inwork   { color: #5bc0de; }
  .state-highlight.frozen   { color: #6c757d; }
  .state-highlight.released { color: #28a745; }

  /* Loading / Error */
  #loadingSpinner {
    display: none;
    width: 36px;
    height: 36px;
    border: 3px solid #e2e5e9;
    border-top: 3px solid #4b5563;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 40px auto;
  }
  @keyframes spin {
    0%   { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  #errorMessage {
    color: #c0392b;
    margin: 20px;
    text-align: center;
    font-size: 13px;
    display: none;
  }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>

<body>

<!-- Topbar -->
<div class="topbar">
  <div class="topbar-left">
    <div class="topbar-icon">
      <i class="fa-solid fa-sliders"></i>
    </div>
    <div>
      <div class="topbar-name" id="psName">Part Specification Details</div>
      <div class="topbar-type" id="psType">PartSpecification</div>
    </div>
  </div>
  <div class="topbar-right">
    <span>State:</span>
    <div id="stateBadgeWrapper"></div>
  </div>
</div>

<div class="page-container">
  <!-- Sidebar -->
  <div class="sidebar">
    <a href="PartSpecificationdetails.jsp?name=<%= request.getParameter("name") %>" class="nav-link"><i class="fa-solid fa-sliders"></i> PASP-Properties</a>
    <a href="PartSpecificationFiles.jsp?name=<%= request.getParameter("name") %>" class="nav-link"><i class="fa-regular fa-file"></i> Files</a>
    <a href="PartSpecificationHistory.jsp?name=<%= request.getParameter("name") %>" class="nav-link active"><i class="fa-regular fa-clock"></i> History</a>
  </div>

  <!-- Main Panel -->
  <div class="main-panel">
    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>

    <div class="history-wrapper" id="historyCard">
      <div class="history-toolbar">
        <img src="history.gif" alt="History Icon" class="history-icon" />
        <h4>History Timeline</h4>
      </div>
      <div class="timeline" id="historyTimelineContainer"></div>
      <div id="noHistoryMsg" style="display:none;">No history found for this Part Specification.</div>
    </div>
  </div><!-- /.main-panel -->
</div><!-- /.page-container -->

<script>
const BASIC_URL = '<%= request.getContextPath() %>';

$(document).ready(function () {
  const objectId = getQueryParam('name') || '';

  if (!objectId) {
    showError("No 'name' (ObjectId) parameter found in the URL.");
    return;
  }

  populateTopBarFromSession();
  loadHistoryTimeline(objectId);

  function populateTopBarFromSession() {
    const partInfo = JSON.parse(sessionStorage.getItem('partInfo') || 'null');
    if (!partInfo) return;
    $('#psName').text(partInfo.name || 'Part Specification Details');
    $('#psType').text(partInfo.type || '');
    if (partInfo.currentstate) {
      const state = partInfo.currentstate;
      const cls = state.replace(/\s/g, '');
      $('#stateBadgeWrapper').html('<span class="state-badge ' + cls + '">' + state + '</span>');
    }
  }

  function getQueryParam(param) {
    return new URLSearchParams(window.location.search).get(param);
  }

  function showLoading(show) {
    $('#loadingSpinner').css('display', show ? 'block' : 'none');
  }

  function showError(msg) {
    $('#errorMessage').text(msg).show();
    showLoading(false);
  }

  function getEntryType(entry) {
    const lower = entry.toLowerCase();
    if (lower.includes('created'))  return 'created';
    if (lower.includes('promoted')) return 'promoted';
    if (lower.includes('demoted'))  return 'demoted';
    return 'default';
  }

  function getIconHtml(type) {
    const icons = {
      created:  '<i class="fa-solid fa-plus"></i>',
      promoted: '<i class="fa-solid fa-arrow-up"></i>',
      demoted:  '<i class="fa-solid fa-arrow-down"></i>',
      default:  '<i class="fa-solid fa-circle-dot"></i>'
    };
    return icons[type] || icons.default;
  }

  function parseEntry(raw) {
    // Format: "Action by User yyyy-MM-dd HH:mm:ss.SSS" OR "Action yyyy-MM-dd HH:mm:ss.SSS"
    const dateRegex = /(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}(?:[.\d+Z]*)?)/;
    const dateMatch = raw.match(dateRegex);
    const date = dateMatch ? dateMatch[1].replace('T', ' ').split('.')[0] : '';
    let text = raw.replace(dateRegex, '').trim();
    text = text.replace(/\s+at\s*$/i, '').trim();

    let by = '';
    const byMatch = text.match(/\bby\s+(\S+)/i);
    const type = getEntryType(text);

    if (byMatch) {
      if (byMatch[1].toLowerCase() !== "system") {
        by = byMatch[0];
      }
      text = text.replace(byMatch[0], '').trim();
    }

    return { text, by, date, type };
  }

  function buildStateHighlight(text) {
    return text.replace(/\b(Draft|InWork|Frozen|Released)\b/gi, function(match) {
      return '<span class="state-highlight ' + match.toLowerCase() + '">' + match + '</span>';
    });
  }

  function displayHistory(historyInput) {
    let entries = [];
    if (Array.isArray(historyInput)) {
      entries = historyInput.map(e => typeof e === 'string' ? e.trim() : '').filter(e => e !== '');
    } else if (typeof historyInput === 'string') {
      entries = historyInput.split('|').map(e => e.trim()).filter(e => e !== '');
    }

    if (entries.length === 0) {
      $('#noHistoryMsg').show();
      return;
    }

    const container = $('#historyTimelineContainer');
    container.empty();

    entries.forEach(function(raw) {
      const { text, by, date, type } = parseEntry(raw);
      const actionHtml = buildStateHighlight(text);

      const item = $('<div class="timeline-item"></div>');
      const dot  = $('<div class="timeline-dot dot-' + type + '"></div>');
      const icon = $('<div class="timeline-icon icon-' + type + '">' + getIconHtml(type) + '</div>');
      const content = $('<div class="timeline-content"></div>');
      const action = $('<div class="timeline-action">' + actionHtml + '</div>');

      content.append(action);

      if (by) {
        const sub = $('<div class="timeline-sub">' + by + '</div>');
        content.append(sub);
      }

      const dateEl = $('<div class="timeline-date">' + date + '</div>');

      item.append(dot).append(icon).append(content).append(dateEl);
      container.append(item);
    });
  }

  function loadHistoryTimeline(objectId) {
    $('#historyTimelineContainer').empty();
    $('#noHistoryMsg').hide();
    showLoading(true);

    $.ajax({
      url: BASIC_URL + '/api/datafetchservice/getpartspecificationhistory',
      method: 'GET',
      data: { objectId: objectId },
      dataType: 'json',
      success: function(data) {
        if (data && data.history) {
          displayHistory(data.history);
        } else {
          $('#noHistoryMsg').show();
        }
      },
      error: function(xhr, status, error) {
        console.error('AJAX error:', status, error);
        showError('Failed to fetch history data.');
      },
      complete: function() {
        showLoading(false);
      }
    });
  }
});
</script>
</body>
</html>
