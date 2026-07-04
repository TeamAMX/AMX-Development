<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Part Specification - Files</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
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

  /* ===== FILES TABLE ===== */
  .files-table-card {
    background: #ffffff;
    border-radius: 0;
    border: none;
    box-shadow: none;
    width: 100%;
    max-width: 1100px;
    overflow-x: auto;
    margin-top: 16px;
  }
  #filesTable {
    width: 100% !important;
    white-space: nowrap;
    border-collapse: collapse;
  }
  #filesTable thead th {
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
    text-align: left;
  }
  #filesTable tbody td {
    padding: 10px 12px !important;
    border-bottom: 1px solid #f1f5f9 !important;
    border-right: none !important;
    vertical-align: middle !important;
    color: #111111 !important;
    background: #ffffff !important;
    font-size: 13px !important;
  }
  #filesTable tbody tr:hover td { background: #f8fafc !important; }
  #filesTable tbody td.file-name-cell a {
    color: #2563eb;
    text-decoration: none;
    font-weight: 600;
  }
  #filesTable tbody td.file-name-cell a:hover { text-decoration: underline; }
  #noFilesMsg {
    padding: 24px;
    text-align: center;
    color: #9ca3af;
    font-size: 13px;
  }

  .section-label {
    font-weight: 700;
    font-size: 13px;
    margin: 10px 16px 6px 16px;
    color: #333;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

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
  /* BUG-1061 started by Nageswari */
  /* ===== TOOLBAR ===== */
.toolbar {
    background: #000;
    padding: 8px 12px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid #334155;
}

.toolbar button {
    background: transparent;
    border: none;
    cursor: pointer;
    padding: 6px;
    border-radius: 4px;
}

.toolbar button:hover {
    background: #334155;
}

.toolbar img {
    width: 18px;
    height: 18px;
    filter: invert(1);
}
.toolbar button .fa-file-circle-minus {
    color: #f87171;
    font-size: 18px;
}
  /* BUG-1061 started by Nageswari */
    
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
    <a href="PartSpecificationFiles.jsp?name=<%= request.getParameter("name") %>" class="nav-link active"><i class="fa-regular fa-file"></i> Files</a>
    <a href="PartSpecificationHistory.jsp?name=<%= request.getParameter("name") %>" class="nav-link"><i class="fa-regular fa-clock"></i> History</a>
    <a href="PartSpecificationLifeCycle.jsp?name=<%= request.getParameter("name") %>" id="lifeCycleTab" class="nav-link"><i class="fa-solid fa-arrows-rotate"></i>LifeCycle</a>
  
  </div>

  <!-- Main Panel -->
  <div class="main-panel">
    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>
    <!-- BUG-1061 started by Nageswari -->
<div class="toolbar">
    <button id="uploadBtn" title="Upload File">
        <img src="https://img.icons8.com/?size=450&id=e2tnuDc86xd6&format=png&color=000000" alt="Upload">
    </button>
    <!-- BUG-1061 Ended by Nageswai -->
    <button id="downloadBtn" title="download File">
        <img src="https://img.icons8.com/?size=150&id=0xU3XgGHcgvR&format=png&color=000000" alt="Download">
    </button>
    <button data-bs-toggle="tooltip" title="Remove file" id="removeBtn">
      <i class="fa-solid fa-file-circle-minus"></i>
    </button>
</div>
    <div class="files-table-card" id="filesCard">
      <div class="section-label"></div>
      <div style="overflow-x: auto; padding: 0 16px; width: 100%;">
        <table id="filesTable">
          <thead><tr></tr></thead>
          <tbody></tbody>
        </table>
      </div>
      <div id="noFilesMsg" style="display:none;">No files found for this Part Specification.</div>
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
  loadFilesTable(objectId);
  //BUG-1062 started by koushik
  //Only one file can be selected
  $(document).on('change', '.file-row-checkbox', function () {
      if ($(this).is(':checked')) {
          $('.file-row-checkbox').not(this).prop('checked', false);
      }
  });
  //BUG-1062 ended by koushik
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

  function loadFilesTable(objectId) {
    $('#filesTable thead tr').empty();
    $('#filesTable tbody').empty();
    $('#noFilesMsg').hide();
    showLoading(true);

    $.ajax({
      url: BASIC_URL + '/api/datafetchservice/getfilesforpartspec',
      method: 'GET',
      data: { objectId: objectId },
      dataType: 'json',
      success: function (files) {
        if (!files || !Array.isArray(files) || files.length === 0) {
          $('#noFilesMsg').show();
          return;
        }

        const excludedFields = ['objectid', 'connectionid', 'linkedobjectid', 'fts_document', 'filedata', 'filename'];
        const allKeys = Object.keys(files[0]).filter(k => !excludedFields.includes(k));

        // Preferred order first, then any remaining columns not explicitly listed
        const preferredOrder = ['name', 'title', 'owner', 'filesize'];
        const keys = preferredOrder.filter(k => allKeys.includes(k))
          .concat(allKeys.filter(k => !preferredOrder.includes(k)));

        const headerRow = $('#filesTable thead tr');
        keys.forEach(function (key) {
          headerRow.append('<th>' + key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' ') + '</th>');
        });
        
        function formatFileSize(bytes) {
            bytes = Number(bytes);
            if (isNaN(bytes)) return '';
            if (bytes < 1024)
                return bytes + " B";
            else if (bytes < 1024 * 1024)
                return (bytes / 1024).toFixed(2) + " KB";
            else
                return (bytes / (1024 * 1024)).toFixed(2) + " MB";
        }
        const tbody = $('#filesTable tbody');
        files.forEach(function (file) {
          let tr = '<tr>';
          //BUG-1062 started by koushik
          keys.forEach(function (key, idx) {
            let value = file[key] || '';
            if (key === 'filesize') {
              value = formatFileSize(value);
            }
            if (idx === 0) {
              const link = 'FileProperties.jsp?name=' + encodeURIComponent(file.objectid || '');
              tr += '<td class="file-name-cell">' + value + '</a></td>';
            } else {
              tr += '<td>' + value + '</td>';
            }
          });
          tr += '</tr>';
          tbody.append(tr);
        });
        //BUG-1062 ended by koushik

      },
      error: function () {
        showError('Failed to load files.');
      },
      complete: function () {
        showLoading(false);
      }
    });
  }
});
/* BUG-1061 Started by Nageswari */
document.getElementById("uploadBtn").addEventListener("click", function () {

    const objectId = new URLSearchParams(window.location.search).get("name");

    window.parent.loadFormInModal(
        "CreateFileForm.jsp?name=" + encodeURIComponent(objectId)
    );

});
/* BUG-1061 Ended by Nageswari */
//BUG-1062 started by koushik
document.getElementById("downloadBtn").addEventListener("click", function () {
    const checkedFile = document.querySelector(".file-row-checkbox:checked");
    if (!checkedFile) {
        alert("Please select a file");
        return;
    }
    const fileObjectId = checkedFile.dataset.objectid;
    const fileName = checkedFile.dataset.filename;
    downloadFile(fileObjectId, fileName);
});

function downloadFile(objectId, fileName) {
    if (!objectId || !fileName) {
        return;
    }
    const downloadUrl =
        BASIC_URL +
        "/api/datafetchservice/download?objectid=" +
        encodeURIComponent(objectId) +
        "&fileName=" +
        encodeURIComponent(fileName);
    const a = document.createElement("a");
    a.href = downloadUrl;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}

document.getElementById("removeBtn").addEventListener("click", function () {
    const checkedFile = document.querySelector(".file-row-checkbox:checked");
    if (!checkedFile) {
        alert("Please select a file");
        return;
    }
    const fileObjectId = checkedFile.dataset.objectid;
    const fileName = checkedFile.dataset.filename;

    if (!confirm("Are you sure you want to delete this file?")) {
        return;
    }

    $.ajax({
        url: BASIC_URL + "/api/datafetchservice/deleteFile" +
             "?objectid=" + encodeURIComponent(fileObjectId) +
             "&fileName=" + encodeURIComponent(fileName),
        type: "DELETE",
        success: function () {
            alert("File deleted successfully");
            location.reload();
        },
        error: function () {
            alert("Failed to delete file");
        }
    });
});
//BUG-1062 ended by koushik
</script>
</body>
</html>
