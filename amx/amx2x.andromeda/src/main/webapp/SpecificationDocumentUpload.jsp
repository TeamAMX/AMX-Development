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
<title>SpecificationDocumentUpload</title>
<style>
  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }

  /* ===== TOPBAR ===== */
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
  /* Remove icon — keep red color, don't invert */
  .toolbar button .fa-file-circle-minus {
    filter: none;
    color: #f87171;
    font-size: 18px;
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

  /* ===== FILE LIST AREA ===== */
  .file-list-wrapper {
    margin: 16px;
    border: 1px solid #e2e5e9;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  }

  .file-list-header {
    background: #393a3c;
    color: #e2e8f0;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    padding: 10px 16px;
    border-bottom: 2px solid #334155;
  }

  #documentTable {
    width: 100%;
    border-collapse: collapse;
  }

  #documentTable tbody tr {
    border-bottom: 1px solid #f1f5f9;
    transition: background 0.15s ease;
  }

  #documentTable tbody tr:last-child {
    border-bottom: none;
  }

  #documentTable tbody tr:hover {
    background: #f8fafc;
  }

  #documentTable tbody td {
    padding: 12px 16px;
    font-size: 13px;
    color: #2b303a;
    vertical-align: middle;
  }

  /* File row styling */
  .file-row-container {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .file-row-container input[type="radio"] {
    accent-color: #4b5563;
    width: 14px;
    height: 14px;
    cursor: pointer;
    flex-shrink: 0;
  }

  .file-name {
    font-size: 13px;
    color: #1f2937;
    font-weight: 500;
  }

  .file-icon {
    color: #6b7280;
    font-size: 14px;
    flex-shrink: 0;
  }

  /* Empty state */
  .empty-state {
    padding: 40px 16px;
    text-align: center;
    color: #9ca3af;
    font-size: 13px;
  }
  .empty-state i {
    font-size: 32px;
    margin-bottom: 10px;
    display: block;
    color: #d1d5db;
  }

  #loadingSpinner {
    display: none;
    padding: 10px 16px;
    font-size: 13px;
    color: #666;
  }
  #errorMessage {
    display: none;
    color: #c0392b;
    margin: 10px 16px;
    font-weight: bold;
    font-size: 13px;
  }

  #typeIcon {
    width: 50px;
    height: 50px;
    object-fit: contain;
  }
</style>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

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
  <a class="nav-link" href="PartSpecification.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clipboard"></i> PartSpecification</a>
  <a class="nav-link active" href="SpecificationDocumentUpload.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-file"></i> SpecificationDocument</a>
</div>
  <div class="main-panel">
  <div class="toolbar">
    <button data-bs-toggle="tooltip" title="Upload file" id="uploadBtn">
      <img src="https://img.icons8.com/?size=450&id=e2tnuDc86xd6&format=png&color=000000" alt="Upload">
    </button>
    <button data-bs-toggle="tooltip" title="Download file" id="downloadBtn">
      <img src="https://img.icons8.com/?size=150&id=0xU3XgGHcgvR&format=png&color=000000" alt="Download">
    </button>
    <button data-bs-toggle="tooltip" title="Remove file" id="removeBtn">
      <i class="fa-solid fa-file-circle-minus"></i>
    </button>
  </div>

  <input type="file" id="fileInput" style="display: none;" />
  <div id="loadingSpinner"></div>
  <div id="errorMessage"></div>

  <div class="file-list-wrapper">
    <div class="file-list-header">Uploaded File List</div>
    <table id="documentTable">
      <tbody id="documentTableBody"></tbody>
    </table>
  </div>
</div>
</div>
<script>

const BASIC_URL = '<%= request.getContextPath() %>';
$(document).ready(function () {
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
    	    $('.state-box .state-label').remove();
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
    }

    loadUploadedFiles();
});

document.getElementById('uploadBtn').addEventListener('click', function () {
    document.getElementById('fileInput').click();
});

document.getElementById('fileInput').addEventListener('change', function (event) {
    const file = event.target.files[0];
    if (!file) return;

    $('#loadingSpinner').text('Uploading...').show();
    $('#errorMessage').hide();

    const reader = new FileReader();
    reader.onload = function (e) {
        const base64Data = e.target.result.split(',')[1]; 

        const urlParams = new URLSearchParams(window.location.search);
        const objectId = urlParams.get('name') || '';

        const payload = JSON.stringify({
            objectid: objectId,
            fileContentBase64: base64Data,
            fileName: file.name,
            fileType: file.type
        });

        $.ajax({
            url:BASIC_URL+'/api/datafetchservice/upload',
            type: 'POST',
            data: payload,
            contentType: 'application/json',
            success: function (response) {
                $('#loadingSpinner').hide();
                if (response.message) {
                    alert(response.message);
                } else if (response.error) {
                    $('#errorMessage').text(response.error).show();
                } else {
                    alert('Upload Completed');
                }
                loadUploadedFiles();
            },
            error: function (xhr, status, error) {
                $('#loadingSpinner').hide();
                $('#errorMessage').text('Upload failed: ' + error).show();
            }
        });
    };

    reader.onerror = function () {
        $('#loadingSpinner').hide();
        $('#errorMessage').text('Failed to read file').show();
    };

    reader.readAsDataURL(file);
});

function loadUploadedFiles() {
    const urlParams = new URLSearchParams(window.location.search);
    const objectId = urlParams.get('name') || '';
    if (!objectId) return;

    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/getUploadedFiles?objectid=' + encodeURIComponent(objectId),
        method: 'GET',
        dataType: 'json',
        success: function (data) {
            const tbody = $('#documentTableBody');
            tbody.empty();

            if (Array.isArray(data) && data.length > 0) {
                data.forEach(function (file) {
                    const row = $('<tr></tr>');
                    const container = $('<div class="file-row-container"></div>');
                    const radio = $('<input type="radio" name="selectedFile" class="fileRadio">').val(file.fileName);
                    const icon = $('<i class="fa-regular fa-file file-icon"></i>');
                    const name = $('<span class="file-name"></span>').text(file.fileName);
                    container.append(radio).append(icon).append(name);
                    row.append($('<td></td>').append(container));
                    tbody.append(row);
                });
            } else {
                tbody.append(`
                    <tr><td>
                        <div class="empty-state">
                            <i class="fa-regular fa-folder-open"></i>
                            No files uploaded
                        </div>
                    </td></tr>
                `);
            }
        },
        error: function (xhr, status, error) {
            console.error('Error fetching files:', error);
            $('#errorMessage').text('Failed to fetch files').show();
        }
    });
}

document.getElementById('downloadBtn')
.addEventListener('click', function () {

	const selectedFile =
	    $('.fileRadio:checked').val();

	if (!selectedFile) {

	    alert('Please select a file');

	    return;
	}

	downloadFile(selectedFile);
});

function downloadFile(fileName) {
    const urlParams = new URLSearchParams(window.location.search);
    const objectId = urlParams.get('name') || '';
    if (!objectId || !fileName) return;
    const downloadUrl = BASIC_URL+'/api/datafetchservice/download?objectid='+ encodeURIComponent(objectId) + '&fileName=' + encodeURIComponent(fileName);
    const a = document.createElement('a');
    a.href = downloadUrl;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}

document.getElementById('removeBtn').addEventListener('click', function () {
    const selectedFile = $('.fileRadio:checked').val();
    if (!selectedFile) {
        alert('Please select a file');
        return;
    }

    if (!confirm('Are you sure you want to delete this file?')) {
        return;
    }

    const urlParams =new URLSearchParams(window.location.search);
    const objectId = urlParams.get('name') || '';

    $.ajax({ url:BASIC_URL+'/api/datafetchservice/deleteFile' + '?objectid=' + encodeURIComponent(objectId) + '&fileName=' + encodeURIComponent(selectedFile),

        type: 'DELETE',
        success: function () { alert('File deleted successfully');
            loadUploadedFiles();
        },

        error: function () {
            alert('Failed to delete file');
        }
    });
});

</script>
</body>
</html>
