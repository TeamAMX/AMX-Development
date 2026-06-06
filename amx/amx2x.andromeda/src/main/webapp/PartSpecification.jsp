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
    background-color: #1f2937;
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
  display:none !important;
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

  .modal {
    display: none;
    position: fixed;
    z-index: 2000;
    left: 0;
    top: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(2px);
    align-items: center;
    justify-content: center;
    padding: 0px 57px 40px 0px;
}

.modal-content {
        background-color: white;
        padding: 24px; 
        border-radius: 18px;
        width: 100%;
        max-width: 500px; 
        box-shadow: 0 25px 60px rgba(0,0,0,0.18);
        overflow: hidden;
        border: none;
        position: relative;
    }

    .close-button {
        position: absolute;
        right: 20px;
        top: 20px;
        font-size: 24px;
        cursor: pointer;
        color: #64748b;
        z-index: 50;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: white;
        border-radius: 50%;
        transition: background 0.2s;
    }

    .close-button:hover {
        background: #f1f5f9;
        color: #0f172a;
    }

.modal-content iframe {
    width: 100%;
    height: 100%;
    border: none;
}
.form-heading {
    font-size: 20px;
    font-weight: 700;
}
form label {
    font-size: 12px;
    font-weight: 600;
    color: var(--3dx-text-secondary);
}
form textarea, form select, form input {
    font-size: 13px !important;
    border-radius: 6px !important;
    border: 1px solid var(--3dx-border) !important;
    margin-bottom: 15px;
}
form textarea:focus, form select:focus, form input:focus {
    border-color: #6b7280 !important; 
    box-shadow: 0 0 0 3px rgba(0, 0, 0, 0.1) !important;
}

.btn-primary-dx {
    background-color: var(--3dx-accent-blue);
    border: none;
    color: white;
    padding: 8px 18px;
    font-size: 13px;
    font-weight: 600;
    border-radius: 6px;
}
.btn-secondary-dx {
    background-color: #e2e5e9;
    border: none;
    color: var(--3dx-text-main);
    padding: 8px 18px;
    font-size: 13px;
    font-weight: 500;
    border-radius: 6px;
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
  <a class="nav-link" href="Parthistory.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clock"></i> History</a>
  <a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
  <a class="nav-link" href="ControlManagement.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-shield-halved"></i> Control Management</a>
  <a class="nav-link active" href="PartSpecification.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clipboard"></i> PartSpecification</a>
  <a class="nav-link" href="SpecificationDocumentUpload.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-file"></i> SpecificationDocument</a>
</div>

  <div class="main-panel">
    <div class="toolbar mt-2">
      <button class="btn btn-light" data-bs-toggle="tooltip" title="Create Part Specification" id="createPartSpecificationLink">
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

  <div id="myModal" class="modal">
    <div class="modal-content">
      <span class="close-button" id="modalCloseBtn">&times;</span>
      
      <div id="nativeFormContainer">
        
      </div>

      <div id="iframeContainer" style="display: none; width: 100%; height: 100%;"></div>

    </div>
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

    
    document.getElementById('modalCloseBtn').addEventListener('click', function () {
        document.getElementById('myModal').style.display = 'none';
        document.getElementById('iframeContainer').innerHTML = '';
    });
    
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
    
    const objectid = new URLSearchParams(window.location.search).get('name');
    if (!objectid) {
        alert('No object ID found.');
        return;
    }

    document.getElementById('createPartSpecificationLink').addEventListener('click', function (e) {
        e.preventDefault();
        loadFormInModal('PartSpecificationwithconnection.jsp?name=' + encodeURIComponent(objectid));
    });
});

function loadFormInModal(url) {
    const modal = document.getElementById('myModal');
    document.getElementById('nativeFormContainer').style.display = 'none';
    const iframeContainer = document.getElementById('iframeContainer');
    iframeContainer.style.display = 'block';
    
    iframeContainer.innerHTML = '<iframe src="' + url + '" style="width:100%; height:75vh; max-height: 600px; border:none; border-radius:8px;"></iframe>';
    modal.style.display = 'flex';
}

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

    if (event.data.action === 'closeOnly' || event.data.action === 'closeAndRefresh') {
        document.getElementById('myModal').style.display = 'none';
        document.getElementById('iframeContainer').innerHTML = '';
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
