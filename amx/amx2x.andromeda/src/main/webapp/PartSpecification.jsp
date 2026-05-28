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
<title>Part Specification</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>
  body {
    font-family: Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }

  .topbar {
    display: flex;
    background: #f5f7fa;
    border-bottom: 1px solid #cfd3db;
    padding: 6px 12px;
    font-size: 13px;
    color: #333;
  }
  .topbar > div {
    display: flex;
    align-items: center;
    padding: 6px 12px;
    background: #f9fbfd;
    border: 1px solid #cfd3db;
    border-right: none;
    white-space: nowrap;
  }
  .topbar > div:last-child { border-right: 1px solid #cfd3db; }
  .topbar > div:not(:last-child) { margin-right: -1px; }
  .part-number {
    font-weight: 700;
    font-size: 14px;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }
  .state-box {
    font-weight: 600;
    font-size: 13px;
    color: #333;
    display: flex;
    align-items: center;
    gap: 8px;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
  }
  .state-label { margin-right: 4px; }
  .info-box {
    font-size: 11px;
    color: #666;
    padding-left: 4px;
    line-height: 1.3;
  }
  .vertical-line img { height: 20px; width: 1px; margin: 0 10px; }

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
  .sidebar a:hover {
    background-color: #e3e7ea;
    color: #111827;
  }
  .sidebar a.active {
    background-color: #4b5563;
    color: white;
    font-weight: 600;
  }
  .sidebar a i {
    width: 16px;
    font-size: 13px;
    color: #6b7280;
  }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
    flex-grow: 1;
    padding: 0;
    overflow-y: auto;
    min-width: 0;
    width: 0;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
  }

  /* ===== TOOLBAR ===== */
  .toolbar {
    background-color: #000000;
    padding: 8px 14px;
    display: flex;
    align-items: center;
    gap: 8px;
    border-bottom: 1px solid #334155;
    margin: 0;
    border-radius: 0;
  }
  .toolbar button {
    background: none;
    border: none;
    cursor: pointer;
    padding: 4px 6px;
    border-radius: 4px;
    display: flex;
    align-items: center;
  }
  .toolbar button img {
    width: 18px;
    height: 18px;
    filter: invert(1);
  }
  .toolbar button:hover { background-color: #334155; }

  /* ===== SECTION LABEL ===== */
  .section-label {
    font-weight: 700;
    font-size: 13px;
    margin: 10px 16px 6px 16px;
    color: #333;
    text-transform: uppercase;
    letter-spacing: 0.5px;
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
  .state-badge.InWork   { background: #dbeafe; color: #1d4ed8; }
  .state-badge.Frozen   { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
  .state-badge.Released { background: #dcfce7; color: #166534; }
  .state-badge.Obsolete { background: #fef9c3; color: #854d0e; }

  /* ===== TABLE ===== */
  #partSpecificationTable {
    width: 100% !important;
    white-space: nowrap;
    border-collapse: collapse;
  }
  #partSpecificationTable thead th {
    background: #393a3c !important;
    color: #e2e8f0 !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.5px !important;
    padding: 10px 26px 10px 12px !important;
    border-bottom: 2px solid #334155 !important;
    border-right: 1px solid #334155 !important;
    white-space: nowrap !important;
  }
  #partSpecificationTable thead .sorting:before,
  #partSpecificationTable thead .sorting:after,
  #partSpecificationTable thead .sorting_asc:before,
  #partSpecificationTable thead .sorting_asc:after,
  #partSpecificationTable thead .sorting_desc:before,
  #partSpecificationTable thead .sorting_desc:after {
    color: rgba(255,255,255,0.75) !important;
    opacity: 1 !important;
  }
  #partSpecificationTable tbody td {
    padding: 10px 12px !important;
    border-bottom: 1px solid #f1f5f9 !important;
    border-right: none !important;
    vertical-align: middle !important;
    color: #111111 !important;
    background: #ffffff !important;
    font-size: 13px !important;
  }
  #partSpecificationTable tbody tr:hover td { background: #f8fafc !important; }

  /* ===== HIDE DATATABLES UI ===== */
  .dataTables_info,
  .dataTables_paginate,
  .dataTables_length,
  .dataTables_filter { display: none !important; }

  /* ===== CREATE PANEL ===== */
  #createPanel {
    position: fixed;
    top: 0;
    right: -400px;
    width: 400px;
    height: 100%;
    background: #fff;
    box-shadow: -2px 0 5px rgba(0,0,0,0.3);
    overflow-y: auto;
    transition: right 0.3s ease;
    z-index: 1051;
    padding: 0;
  }
  #createPanel.active { right: 0; }
  #createPanel iframe {
    border: none;
    width: 100%;
    height: calc(100% - 56px);
  }

  #loadingSpinner {
    display: none;
    position: fixed;
    top: 10px; right: 10px;
    font-size: 14px; color: #666;
  }
  #errorMessage {
    color: red;
    margin: 10px 16px;
    font-weight: bold;
  }
</style>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />

<script>var loggedInUserAccess = '<%= userAccess.trim() %>';</script>
</head>
<body>

<div class="topbar">
  <div class="left-section">
    <div class="image-box">
      <img id="typeIcon" src="" alt="Type Icon" />
    </div>
    <div class="part-info">
      <div class="part-number" style="font-weight: 700; font-size: 14px;"></div>
      <div class="part-type" style="font-size: 12px; color: #666; margin-top: 2px;"></div>
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
  <a class="nav-link" href="Properties.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-tag"></i> Part Properties</a>
  <a class="nav-link" href="EngineeringBOM.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-sitemap"></i> Engineering BOM</a>
  <a class="nav-link" href="APNEquivalents.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-code-compare"></i> Equivalents</a>
  <a class="nav-link" href="Parthistory.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clock"></i> History</a>
  <a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
  <a class="nav-link" href="ControlManagement.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-shield-halved"></i> Control Management</a>
  <a class="nav-link active" href="PartSpecification.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clipboard"></i> PartSpecification</a>
  <a class="nav-link" href="SpecificationDocumentUpload.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-file"></i> SpecificationDocument</a>
</div>

  <div class="main-panel">
    <div class="toolbar mt-2">
      <button class="btn btn-light" data-bs-toggle="tooltip" title="Create Part Specification" id="openCreatePanelBtn">
        <img src="https://img.icons8.com/?size=100&id=KJRE9LhcSvaT&format=png&color=000000" alt="Add" style="width:20px height:20px;">
      </button>
      <button class="btn btn-light" data-bs-toggle="tooltip" title="Link Existing Part Specification" id="addExistingpart">
        <img src="https://img.icons8.com/?size=100&id=K0l4dwcsMaJa&format=png&color=000000" alt="Link" style="width: 20px; height: 20px;">
      </button>
      <button class="btn btn-light" data-bs-toggle="tooltip" title="Export to Excel" id="excelexport">
        <img src="https://img.icons8.com/?size=100&id=112690&format=png&color=000000" alt="Export" style="width: 20px; height: 20px;">
      </button>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>

    <div class="section-label">PartSpecificationTable</div>
	<div style="overflow-x: auto; padding: 0 16px; width: 100%;">
  <table id="partSpecificationTable">
    <thead><tr></tr></thead>
    <tbody></tbody>
  </table>
</div>
  </div>

  <div id="createPanel">
    <iframe id="createIframe" src=""></iframe>
  </div>
</div>

<script>

const BASIC_URL = '<%= request.getContextPath() %>';
function receiveSelectedParts(selectedParts) {
    if (!selectedParts || selectedParts.length === 0) return;

    const invalidItems = selectedParts.filter(function(p) {
        return !p.supertype || p.supertype.toLowerCase() !== 'document';
    });
    if (invalidItems.length > 0) {
        alert('Invalid selection. Please select only Part Specification (Document) objects.');
        return;
    }

    const objectid = new URLSearchParams(window.location.search).get('name');
    if (!objectid) {
        alert('No object ID found.');
        return;
    }

    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/linkpartspecification/' + encodeURIComponent(objectid),
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(selectedParts),
        success: function() {
            alert('Part "' + selectedParts[0].objectid + '" linked successfully.');
            loadPartSpecificationTable();
        },
        error: function(xhr) {
            let msg = 'Failed to link part specification.';
            try {
                const err = JSON.parse(xhr.responseText);
                if (err.Message) msg = err.Message;
            } catch(e) {
                console.error(e);
            }
            alert(msg);
        }
    });
}

function loadPartSpecificationTable() {
    $('#errorMessage').text('Loading part specifications...');
    $('.section-label:contains("PartSpecificationTable")').hide();
    $('#partSpecificationTable').hide();

    const urlParams = new URLSearchParams(window.location.search);
    const objectid = urlParams.get('name');

    if (!objectid) {
        $('#errorMessage').text('Missing object ID.');
        return;
    }

    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/getcreatedpartspecification',
        data: { objectid: objectid },
        dataType: 'json',
        cache: false,
        success: function(data) {
            $('#errorMessage').text('');
            if (!data || !Array.isArray(data) || data.length === 0 || data.message) {
                $('#errorMessage').text(data ? data.message || 'No part Specification found.' : 'Error loading data.');
                if ($.fn.DataTable.isDataTable('#partSpecificationTable')) {
                    $('#partSpecificationTable').DataTable().clear().destroy();
                }
                $('.section-label:contains("PartSpecificationTable")').hide();
                $('#partSpecificationTable').hide();
                return;
            }

            $('.section-label:contains("PartSpecificationTable")').show();
            $('#partSpecificationTable').show();

            const excludedFields = ['objectid', 'linkedobjectid', 'connectionid', 'fts_document'];
            const columns = Object.keys(data[0])
                .filter(key => !excludedFields.includes(key))
                .map(key => ({
                    data: key,
                    title: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' ')
                }));

            if ($.fn.DataTable.isDataTable('#partSpecificationTable')) {
                $('#partSpecificationTable').DataTable().clear().destroy();
            }

            const thead = $('#partSpecificationTable thead');
            thead.empty();
            const headerRow = $('<tr></tr>');
            columns.forEach(col => {
                headerRow.append(`<th>${col.title}</th>`);
            });
            thead.append(headerRow);

            $('#partSpecificationTable').DataTable({
                data: data,
                columns: columns,
                order: [[columns.findIndex(c => c.data === 'createdtime') || 0, 'desc']],
                paging: false,
                searching: false,
                scrollX: false,
                info: false,
                destroy: true
            });
        },
        error: function(xhr, status, error) {
            console.error('AJAX error:', status, error);
            $('#errorMessage').text('Failed to load part specifications.');
            $('.section-label:contains("PartSpecificationTable")').hide();
            $('#partSpecificationTable').hide();
        }
    });
}

$(document).ready(function() {
    loadPartSpecificationTable();

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
            const badge = $('<span>')
                .addClass('state-badge ' + state.replace(/\s/g, ''))
                .text(state);
            $('<span>')
                .addClass('state-label')
                .text('State: ')
                .append(badge)
                .prependTo('.state-box');
        }
    } else {
        $('.part-number').text('');
        $('.part-type').text('');
        $('#typeIcon').attr('src', 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000');
        $('.state-box .state-label').remove();
    }

    document.getElementById('openCreatePanelBtn').addEventListener('click', function () {
        const urlParams = new URLSearchParams(window.location.search);
        const objectid = urlParams.get('name');
        if (objectid) {
            const panel = document.getElementById('createPanel');
            panel.classList.add('active');
            document.getElementById('createIframe').src = 'PartSpecificationwithconnection.jsp?name=' + encodeURIComponent(objectid);
        } else {
            alert('No object ID found!');
        }
    });
});

$('#addExistingpart').on('click', function () {
    const objectid = new URLSearchParams(window.location.search).get('name');
    if (objectid) {
        window.open(
            'search.jsp?name=' + encodeURIComponent(objectid) + '&mode=part',
            'LinkPartSpecificationPopup',
            'width=900,height=800,left=100,top=100,resizable=yes'
        );
    } else {
        alert('No object ID found!');
    }
});

window.addEventListener('message', function(event) {
    if (!event.data) return;

    if (event.data.action === 'closeOnly') {
        document.getElementById('createPanel').classList.remove('active');
    } else if (event.data.action === 'closeAndRefresh') {
        document.getElementById('createPanel').classList.remove('active');
        loadPartSpecificationTable();
    } else if (event.data.selectedParts) {
        receiveSelectedParts(event.data.selectedParts);
    }
});

function closeCreatePanel() {
    const panel = document.getElementById('createPanel');
    panel.classList.remove('active');
    document.getElementById('createIframe').src = '';
}

$('#excelexport').on('click', function () {
    const exportData = [];
    const headers = [];

    $('#partSpecificationTable thead th').each(function () {
        headers.push($(this).text().trim());
    });
    exportData.push(headers);

    $('#partSpecificationTable tbody tr').each(function () {
        const row = [];
        $(this).find('td').each(function () {
            let cellText = $(this).text()
                .replace(/\+/g, '')
                .replace(/−/g, '')
                .trim();
            row.push(cellText);
        });
        if (row.length > 0) exportData.push(row);
    });

    const worksheet = XLSX.utils.aoa_to_sheet(exportData);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'PartSpecification');
    XLSX.writeFile(workbook, 'PartSpecification.xlsx');
});
</script>
</body>
</html>
