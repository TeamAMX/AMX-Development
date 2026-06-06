<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userAccess = (String) session.getAttribute("userAccess");
    if (userAccess == null) {
        userAccess = "Admin";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>History</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>
  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }

 :root {
	--border-color: #e5e7eb;
	}
.topbar-main {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    margin: 16px 24px 0 24px;
    background: #f8fafc;
    border: 1px solid var(--border-color);
    border-radius: 14px;
}
  .left-section {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .image-box {
    width: 48px;
    height: 48px;
    border-radius: 10px;
    background: var(--bg-light);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  #typeIcon {
    width: 26px;
    height: 26px;
    object-fit: contain;
  }

  .part-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .part-number {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--text-main);
  }

  .part-type {
    color: var(--text-muted);
    font-size: 0.85rem;
     margin-top: 4px;
  }

  .right-section {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .state-box {
    display: flex;
    align-items: center;
    font-size: 0.85rem;
    font-weight: 500;
    color: var(--text-muted);
  }

  /* Pill State Badges Layout */
  .state-badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.75rem;
    margin-left: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-align: center;
  }

  .state-badge.InWork {
    background-color: #eff6ff;
    color: #2563eb;
    border: 1px solid #bfdbfe;
  }

  .state-badge.Frozen {
    background-color: #f3f4f6;
    color: #4b5563;
    border: 1px solid #e5e7eb;
  }

  .state-badge.Released {
    background-color: #f0fdf4;
    color: #16a34a;
    border: 1px solid #bbf7d0;
  }

  .state-badge.Obsolete {
    background-color: #fffbeb;
    color: #d97706;
    border: 1px solid #fef3c7;
  }
 

  /* ===== LAYOUT ===== */
  .container {
    display: flex;
    height: calc(100vh - 56px);
    overflow: hidden;
    width: 100%;
    font-size: 13px;
  }

  /* ===== SIDEBAR ===== */
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
    transition: all 0.15s ease;
  }
  .sidebar a:hover { background-color: #e3e7ea; color: #111827; }
  .sidebar a.active { background-color: #4b5563; color: white; font-weight: 600; }
  .sidebar a i { width: 16px; font-size: 13px; color: #6b7280; }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
  flex-grow: 1;
  padding: 0;
  min-width: 0;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

  /* ===== TOOLBAR ===== */
  .toolbar {
    background-color: #000000;
    padding: 8px 14px;
    display: flex;
    align-items: center;
    gap: 10px;
    border-bottom: 1px solid #334155;
    margin: 0;
  }
  .toolbar h4 {
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

  /* ===== STATE BADGES ===== */
  .state-box .state-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 999px;
    font-weight: 600;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    text-align: center;
  }

  /* ===== TIMELINE ===== */
  .timeline-wrapper {
  padding: 24px 28px;
  overflow-y: auto;
  flex: 1;
}

  .timeline {
    position: relative;
    padding-left: 40px;
  }

  .timeline::before {
    content: '';
    position: absolute;
    left: 15px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: #e5e7eb;
  }

  .timeline-item {
    position: relative;
    margin-bottom: 0;
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

  /* Bullet dot on the line */
  .timeline-dot {
    position: absolute;
    left: -32px;
    top: 20px;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    border: 2px solid #fff;
    box-shadow: 0 0 0 2px #e5e7eb;
    flex-shrink: 0;
    z-index: 1;
  }

  .timeline-dot.dot-created  { background: #22c55e; box-shadow: 0 0 0 2px #22c55e33; }
  .timeline-dot.dot-promoted { background: #3b82f6; box-shadow: 0 0 0 2px #3b82f633; }
  .timeline-dot.dot-demoted  { background: #f97316; box-shadow: 0 0 0 2px #f9731633; }
  .timeline-dot.dot-default  { background: #9ca3af; box-shadow: 0 0 0 2px #9ca3af33; }

  /* Icon circle */
  .timeline-icon {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    flex-shrink: 0;
  }

  .timeline-icon.icon-created  { background: #dcfce7; color: #166534; }
  .timeline-icon.icon-promoted { background: #dbeafe; color: #1d4ed8; }
  .timeline-icon.icon-demoted  { background: #ffedd5; color: #c2410c; }
  .timeline-icon.icon-default  { background: #f3f4f6; color: #4b5563; }

  .timeline-content { flex: 1; }

  .timeline-action {
    font-size: 13px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 2px;
  }

  .timeline-action .state-highlight {
    font-weight: 700;
  }

  .state-highlight.inwork   { color: #5bc0de; }
  .state-highlight.frozen   { color: #6c757d; }
  .state-highlight.released { color: #28a745; }
  .state-highlight.obsolete { color: #d97706; }

  .timeline-sub {
    font-size: 12px;
    color: #6b7280;
    margin-top: 2px;
  }

  .timeline-date {
    font-size: 11px;
    color: #9ca3af;
    white-space: nowrap;
    margin-left: auto;
    padding-top: 2px;
  }

  /* Loading / Error */
  #loadingSpinner {
    display: none;
    width: 20px;
    height: 20px;
    border: 3px solid #e2e5e9;
    border-top: 3px solid #4b5563;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 24px auto;
  }
  @keyframes spin {
    0%   { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  #errorMessage {
    text-align: center;
    margin: 20px;
    color: #c0392b;
    font-size: 13px;
  }
</style>

</head>
<body>

<div class="topbar">
    <div class="topbar-main">
        <div class="left-section">
            <div class="image-box">
                <img id="typeIcon" src="" alt="Type Icon" />
            </div>
            <div class="part-info">
                <div class="part-number"></div>
                <div class="part-type"></div>
            </div>
        </div>
        <div class="right-section">
            <div class="state-box">
                <span class="state-label">State:</span>
            </div>
        </div>
    </div>
</div>


<div class="container">
   <div class="sidebar">
  <a class="nav-link" href="Properties.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-tag"></i> Part Properties</a>
  <a class="nav-link" href="EngineeringBOM.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-sitemap"></i> Engineering BOM</a>
  <a class="nav-link" href="APNEquivalents.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-code-compare"></i> Equivalents</a>
  <a class="nav-link active" href="Parthistory.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clock"></i> History</a>
  <a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
  <a class="nav-link" href="ControlManagement.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-shield-halved"></i> Control Management</a>
  <a class="nav-link" href="PartSpecification.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clipboard"></i> PartSpecification</a>
  <a class="nav-link" href="SpecificationDocumentUpload.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-file"></i> SpecificationDocument</a>
</div>

<div class="main-panel">
  <div class="toolbar">
    <img src="history.gif" alt="History Icon" class="history-icon" />
    <h4>History Timeline</h4>
  </div>
  <div class="timeline-wrapper">
    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>
    <div class="timeline" id="timelineContainer"></div>
  </div>
</div>

</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
const BASIC_URL = '<%= request.getContextPath() %>';

function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
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

function getStateFromEntry(entry) {
    const match = entry.match(/to\s+(\w+)/i);
    return match ? match[1].toLowerCase() : '';
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
    // Format: "Action by User yyyy-MM-dd HH:mm:ss.SSS"
    // OR: "Action yyyy-MM-dd HH:mm:ss.SSS"
    const dateRegex = /(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}(?:[.\d+Z]*)?)/;
    const dateMatch = raw.match(dateRegex);
    const date = dateMatch ? dateMatch[1].replace('T', ' ').split('.')[0] : '';
    let text = raw.replace(dateRegex, '').trim();
    text = text.replace(/\s+at\s*$/i, '').trim();

    // Extract "by X" only for created entries
    let by = '';
    const byMatch = text.match(/\bby\s+(\S+)/i);
    const type = getEntryType(text);
    if (type === 'created' && byMatch) {
        by = byMatch[0];
        text = text.replace(byMatch[0], '').trim();
    } else {
        // Remove "by System" or any "by X" from non-created entries
        text = text.replace(/\bby\s+\S+/gi, '').trim();
    }

    return { text, by, date, type };
}

function buildStateHighlight(text) {
    return text.replace(/\b(InWork|Frozen|Released|Obsolete)\b/gi, function(match) {
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
        showError('No valid history entries found.');
        return;
    }

    const container = $('#timelineContainer');
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

    showLoading(false);
}

$(document).ready(function () {
    const objectId = getQueryParam('name');
    const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));

    if (partInfo) {
        $('.part-number').text(partInfo.name || '');
        $('.part-type').text(partInfo.type || '');
        const icon = (partInfo.type && partInfo.type.toLowerCase() === 'fastener')
            ? 'https://img.icons8.com/?size=50&id=20544&format=png&color=000000'
            : 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000';
        $('#typeIcon').attr('src', icon);
        $('.state-box .state-label').remove();
        if (partInfo.currentstate) {
            const state = partInfo.currentstate;
            const badge = $('<span>').addClass('state-badge ' + state.replace(/\s/g, '')).text(state);
            $('<span>').addClass('state-label').text('State: ').append(badge).prependTo('.state-box');
        }
    } else {
        $('.part-number').text('');
        $('.part-type').text('');
        $('#typeIcon').attr('src', 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000');
        $('.state-box .state-label').remove();
    }

    if (!objectId) {
        showError("No 'name' parameter found in URL.");
        return;
    }

    showLoading(true);

    $.ajax({
        url: BASIC_URL + '/api/datafetchservice/history',
        method: 'GET',
        data: { objectId: objectId },
        dataType: 'json',
        success: function(data) {
            if (data && data.history) {
                displayHistory(data.history);
            } else {
                showError('No history field found.');
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX error:', status, error);
            showError('Failed to fetch history data.');
        }
    });
});
</script>

</body>
</html>
