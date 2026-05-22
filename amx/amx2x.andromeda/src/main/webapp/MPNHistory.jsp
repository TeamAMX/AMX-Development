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
<title>MPN History</title>
<style>
  body { font-family: Arial, sans-serif; margin: 0; padding: 0; background: #fff; color: #333; }
  .topbar { display: flex; background: #f5f7fa; border-bottom: 1px solid #cfd3db; padding: 6px 12px; font-size: 13px; color: #333; }
  .topbar > div { display: flex; align-items: center; padding: 6px 12px; background: #f9fbfd; border: 1px solid #cfd3db; border-right: none; white-space: nowrap; }
  .topbar > div:last-child { border-right: 1px solid #cfd3db; }
  .part-number { font-weight: 700; font-size: 14px; padding-right: 12px; border-right: 1px solid #cfd3db; margin-right: 12px; }
  .state-box { font-weight: 600; font-size: 13px; color: #333; display: flex; align-items: center; gap: 8px; padding-right: 12px; border-right: 1px solid #cfd3db; }
  .state-label { margin-right: 4px; }
  .info-box { font-size: 11px; color: #666; padding-left: 4px; line-height: 1.3; }
  .topbar > div:not(:last-child) { margin-right: -1px; }
  .vertical-line img { height: 20px; width: 1px; margin: 0 10px; }
  .container { display: flex; height: calc(100vh - 56px); font-size: 13px; }
  .sidebar { width: 19%; background-color: #f8f9fa; border-right: 1px solid #ddd; padding: 20px; font-size: 14px; box-sizing: border-box; overflow-y: auto; overflow-x: hidden; }
  .sidebar a { display: block; padding: 8px; color: #333; text-decoration: none; margin-bottom: 10px; border-radius: 4px; }
  .sidebar a:hover { background-color: #e3e7ea; }
  .sidebar a.active { background-color: #808080; color: white; font-weight: bold; }
  .main-panel { flex-grow: 1; padding: 20px; overflow-y: auto; font-size: 13px; box-sizing: border-box; }
  #loadingSpinner { display: none; border: 4px solid #f3f3f3; border-top: 4px solid #3498db; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 20px auto; }
  @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
  #errorMessage { text-align: center; margin-top: 20px; }
  #historyTable { display: none; margin-top: 0; }
  #historyTable thead { display: none; }
  .toolbar { display: flex; align-items: center; margin-bottom: 5px; background-color: #f8f9fa; padding: 8px 12px; border-radius: 4px; border: 1px solid #ddd; }
  .toolbar h4 { margin: 0; font-weight: 600; color: #444; font-size: 1rem; }
  .history-icon { width: 18px; height: 18px; margin-right: 8px; vertical-align: middle; }
  .state-box .state-badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-weight: 700; font-size: 13px; color: white; margin-left: 8px; user-select: none; text-transform: uppercase; min-width: 80px; text-align: center; }
  .state-badge.InWork  { background-color: #5bc0de; }
  .state-badge.Frozen  { background-color: #6c757d; }
  .state-badge.Released { background-color: #28a745; color: #fff; }
  .state-badge.Obsolete { background-color: #ffc107; color: #000; }
</style>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
</head>
<body>

<div class="topbar">
  <div class="left-section">
    <div class="image-box">
      <img id="typeIcon" src="" alt="Type Icon" />
    </div>
    <div class="part-info">
      <div class="part-number" style="font-weight:700; font-size:14px;"></div>
      <div class="part-type" style="font-size:12px; color:#666; margin-top:2px;"></div>
    </div>
    <div class="vertical-line"></div>
  </div>
  <div class="right-section">
    <div class="state-box">
      <span class="state-label">State:</span>
    </div>
    <div class="vertical-line"></div>
    <div class="info-box"></div>
    <div class="vertical-line"></div>
  </div>
</div>

<div class="container">

  <div class="sidebar">
    <a class="nav-link" href="MPNProperties.jsp?name=<%= request.getParameter("name") %>">MPN Properties</a>
    <a class="nav-link" href="MPNEquivalents.jsp?name=<%= request.getParameter("name") %>">Equivalents</a>
    <a class="nav-link active" href="MPNHistory.jsp?name=<%= request.getParameter("name") %>">History</a>
    <a class="nav-link" href="MPNLifecycle.jsp?name=<%= request.getParameter("name") %>">LifeCycle</a>
  </div>

  <div class="main-panel">
    <div class="toolbar">
      <img src="history.gif" alt="History Icon" class="history-icon" />
      <h4>History Entries</h4>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>
    <div id="noHistoryMsg" class="text text-center mt-3" style="display:none;"></div>
    <table id="historyTable" class="display table table-striped table-bordered" style="width:100%">
      <thead>
        <tr><th></th></tr>
      </thead>
      <tbody></tbody>
    </table>
  </div>
</div>

<script>
let dataTable;

function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
}

function showLoading(show) {
    $('#loadingSpinner').css('display', show ? 'block' : 'none');
}

function showError(msg) {
    $('#errorMessage').text(msg).show();
    $('#historyTable').hide();
    showLoading(false);
}

function escapeHtml(text) {
    return $('<div>').text(text).html();
}

function displayHistory(historyInput) {
    let entries = [];

    if (Array.isArray(historyInput)) {
        entries = historyInput.map(e => typeof e === 'string' ? e.trim() : '').filter(e => e !== '');
    } else if (typeof historyInput === 'string') {
        entries = historyInput.split('|').map(e => e.trim()).filter(e => e !== '');
    }

    if (entries.length === 0) {
        showError("No valid history entries found.");
        return;
    }

    if ($.fn.DataTable.isDataTable('#historyTable')) {
        dataTable.clear().destroy();
    }
    $('#historyTable tbody').empty();

    entries.forEach(entry => {
        $('#historyTable tbody').append('<tr><td>' + escapeHtml(entry) + '</td></tr>');
    });

    dataTable = $('#historyTable').DataTable({
        searching: false,
        paging: false,
        ordering: false,
        info: false,
        lengthChange: false
    });

    $('#errorMessage').hide();
    $('#historyTable').show();
    showLoading(false);
}

$(document).ready(function () {
    const objectId = getQueryParam('name');

    const partInfo = JSON.parse(sessionStorage.getItem('mpnInfo'));
    if (partInfo) {
        $('.part-number').text(partInfo.name || '');
        $('.part-type').text(partInfo.type || '');
        $('#typeIcon').attr('src', 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000');

        if (partInfo.currentstate) {
            const state = partInfo.currentstate;
            const badge = $('<span>').addClass('state-badge ' + state.replace(/\s/g, '')).text(state);
            $('.state-box').empty().append(
                $('<span>').addClass('state-label').text('State: '),
                badge
            );
        }
    } else {
        $('.part-number').text('');
        $('.part-type').text('');
        $('#typeIcon').attr('src', 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000');
        $('.state-box').empty().append($('<span>').addClass('state-label').text('State:'));
    }

    if (!objectId) {
        showError("No 'name' parameter found in URL.");
        return;
    }

    showLoading(true);

    $.ajax({

        url: 'http://localhost:8080/andromeda/api/navigatorutilites/getMPNHistory',
        method: 'GET',
        data: { objectId: objectId },
        dataType: 'json',
        success: function(data) {
            if (data && data.history) {
                displayHistory(data.history);
            } else {
                showError("No history found for this MPN.");
            }
        },
        error: function(xhr, status, error) {
            console.error("AJAX error:", status, error);
            showError("Failed to fetch MPN history data.");
        }
    });
});
</script>
</body>
</html>
