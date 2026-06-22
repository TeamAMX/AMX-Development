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
<title>PartControl Management</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

<style>
  * { box-sizing: border-box; }

  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
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
  .part-number {
    font-size: 16px;
    font-weight: 700;
    color: #111827;
    margin: 0 0 2px 0;
    border: none;
    padding: 0;
  }
  .part-type {
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

  /* State badge */
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
  .container {
    display: flex;
    height: calc(100vh - 65px);
    overflow: hidden;
    width: 100%;
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
  .toolbar button i {
    font-size: 16px;
    color: #e2e8f0;
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

  /* ===== TABLE ===== */
  #partTable {
    width: 100% !important;
    white-space: nowrap;
    border-collapse: collapse;
  }
  #partTable thead th {
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
  #partTable thead .sorting:before,
  #partTable thead .sorting:after,
  #partTable thead .sorting_asc:before,
  #partTable thead .sorting_asc:after,
  #partTable thead .sorting_desc:before,
  #partTable thead .sorting_desc:after {
    color: rgba(255,255,255,0.75) !important;
    opacity: 1 !important;
  }
  #partTable tbody td {
    padding: 10px 12px !important;
    border-bottom: 1px solid #f1f5f9 !important;
    border-right: none !important;
    vertical-align: middle !important;
    color: #111111 !important;
    background: #ffffff !important;
    font-size: 13px !important;
  }
  #partTable tbody tr:hover td { background: #f8fafc !important; }

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
  #searchOverlay {
  display: none;
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
  background: #fff;
  z-index: 100;
  flex-direction: column;
}
#searchOverlay.active {
  display: flex;
}
#searchOverlayBar {
  height: 55px;
  background-color: #393a3c;
  padding: 8px 14px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid #334155;
  flex-shrink: 0;
}
#searchOverlayBar .overlay-title {
  color: #e2e8f0;
  font-size: 13px;
  font-weight: 600;
  flex: 1;
}
#closeSearchOverlay {
  background: none;
  border: none;
  cursor: pointer;
  color: #e2e8f0;
  font-size: 13px;
  font-weight: 500;
  padding: 4px 8px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  gap: 6px;
}
#closeSearchOverlay:hover { background-color: #334155; }
#searchOverlay iframe {
  flex: 1;
  width: 100%;
  border: none;
}
  
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>

<div class="topbar">
  <div class="topbar-left">
    <div class="topbar-icon">
      <i class="fa-solid fa-sliders"></i>
    </div>
    <div>
      <div class="part-number"></div>
      <div class="part-type"></div>
    </div>
  </div>
  <div class="topbar-right">
    <span>State:</span>
    <div class="state-box">
      <span class="state-label">State:</span>
    </div>
  </div>
</div>

<div class="container">
    <div class="sidebar">
  <a href="Partcontroldetails.jsp?name=<%= request.getParameter("name") %>" class="nav-link"><i class="fa-solid fa-sliders"></i> PC-Properties</a>
  <a class="nav-link" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clock"></i> History</a>
  <a href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>" class="nav-link"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
  <a href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>" class="nav-link active"><i class="fa-solid fa-shield-halved"></i> Part Management</a>
</div>
    <div class="main-panel">
    <div id="searchOverlay">
  <div id="searchOverlayBar">
    <span class="overlay-title">Add Existing Part</span>
    <button id="closeSearchOverlay">
      <i class="fa-solid fa-arrow-left"></i> Back
    </button>
  </div>
  <iframe id="searchOverlayFrame" src=""></iframe>
</div>
  <div class="toolbar">
  <button data-bs-toggle="tooltip" title="Create Part" id="createPartLink">
    <img src="https://img.icons8.com/?size=100&id=KJRE9LhcSvaT&format=png&color=000000" alt="Add">
  </button>
  <button data-bs-toggle="tooltip" title="Add Existing Part" id="addExistingpart">
    <img src="https://img.icons8.com/?size=100&id=K0l4dwcsMaJa&format=png&color=000000" alt="Add">
  </button>
  <button data-bs-toggle="tooltip" title="Export to Excel" id="excelexport">
    <img src="https://img.icons8.com/?size=100&id=112690&format=png&color=000000" alt="Export">
  </button>
</div>
        <div id="loadingSpinner"></div>
        <div id="errorMessage" class="error"></div>
        <div class="section-label">Part Management Table</div>
    <div style="overflow-x: auto; padding: 0 16px; width: 100%;">
  <table id="partTable">
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
        return !p.supertype || p.supertype.toLowerCase() !== 'part';
    });
    if (invalidItems.length > 0) {
        alert('Invalid selection. Please select only Part objects.');
        return;
    }

    const objectid = new URLSearchParams(window.location.search).get('name');
    if (!objectid) {
        alert('No object ID found.');
        return;
    }

    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/linkparttocontrol/' + encodeURIComponent(objectid),
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(selectedParts),
        success: function() {
            alert('Part "' + selectedParts[0].objectid + '" linked successfully.');
            loadPartTable();
        },
        error: function(xhr) {
            let msg = 'Failed to link part.';
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

function loadPartTable() {
    $('#errorMessage').text('Loading part controls...');
    $('.section-label:contains("PartTable")').hide();
    const urlParams = new URLSearchParams(window.location.search);
    const objectid = urlParams.get('name');
    if (!objectid) {
        $('#errorMessage').text('Missing object ID.');
        return;
    }
    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/getlinkedpart',
        data: { objectid: objectid },
        dataType: 'json',
        cache: false,
        success: function(data) {
            $('#errorMessage').text('');

            if (!data || !Array.isArray(data) || data.length === 0 || data.message) {
                $('#errorMessage').text(data ? data.message || 'No part Control found.' : 'Error loading data.');
                if ($.fn.DataTable.isDataTable('#partTable')) {
                    $('#partTable').DataTable().clear().draw();
                }
                $('.section-label:contains("partTable")').hide();
                $('#partTable').hide();
                return;
            }
            $('.section-label:contains("partTable")').show();
            $('#partTable').show();

            const excludedFields = ['objectid', 'linkedobjectid', 'connectionid', 'fts_document'];
            const columns = Object.keys(data[0])  
                .filter(key => !excludedFields.includes(key))
                .map(key => ({
                    data: key,
                    title: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' ')
                }));

            if ($.fn.DataTable.isDataTable('#partTable')) {
                $('#partTable').DataTable().destroy();
            }
            const thead = $('#partTable thead');
            thead.empty();
            const headerRow = $('<tr></tr>');
            columns.forEach(col => {
                headerRow.append(`<th>${col.title}</th>`);
            });
            thead.append(headerRow);

            $('#partTable').DataTable({
                data: data,
                columns: columns,
                order: [[ columns.findIndex(c => c.data === 'createddate') || 0, 'desc' ]],
                responsive: false,
                paging: false,
                searching: false,
                info: false,
                destroy: true
            });
        },
        error: function() {
            $('#errorMessage').text('Failed to load part controls.');
        }
    });
}

    $(document).ready(function() {
        loadPartTable();

        
        document.getElementById('modalCloseBtn').addEventListener('click', function () {
            document.getElementById('myModal').style.display = 'none';
            document.getElementById('iframeContainer').innerHTML = '';
        });

	const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
        
	if (partInfo) {
	    $('.part-number').text(partInfo.name || '');
	    $('.part-type').text(partInfo.type || '');
	    if (partInfo.currentstate) {
	        const state = partInfo.currentstate;
	        const cls = state.replace(/\s/g, '');
	        $('.state-box').html('<span class="state-badge ' + cls + '">' + state + '</span>');
	    }
	}
	 const objectid = new URLSearchParams(window.location.search).get('name');
     if (!objectid) {
         alert('No object ID found.');
         return;
     }
     
     document.getElementById('createPartLink').addEventListener('click', function (e) {
         e.preventDefault();
         loadFormInModal('CreatePartForControl.jsp?name=' + encodeURIComponent(objectid));
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
            document.getElementById('searchOverlayFrame').src =
                'search.jsp?name=' + encodeURIComponent(objectid) + '&mode=part';
            document.getElementById('searchOverlay').classList.add('active');
        } else {
            alert('No object ID found!');
        }
    });

    document.getElementById('closeSearchOverlay').addEventListener('click', function () {
        document.getElementById('searchOverlay').classList.remove('active');
        document.getElementById('searchOverlayFrame').src = '';
    });

    
    window.addEventListener('message', function(event) {
        if (!event.data) return;

        if (event.data.action === 'closeOnly' || event.data.action === 'closeAndRefresh') {
            document.getElementById('myModal').style.display = 'none';
            document.getElementById('iframeContainer').innerHTML = '';
            loadPartTable();
        } else if (event.data.selectedParts) {
            receiveSelectedParts(event.data.selectedParts);
            document.getElementById('searchOverlay').classList.remove('active');
            document.getElementById('searchOverlayFrame').src = '';
        }
    });
    function closeCreatePanel() {
        const panel = document.getElementById('myModal');
        panel.classList.remove('active');
        document.getElementById('iframeContainer').src = '';
    }
    
    $('#excelexport').on('click', function () {

        const exportData = [];

        const headers = [];

        $('#partTable thead th').each(function () {
            headers.push($(this).text().trim());
        });

        exportData.push(headers);

        $('#partTable tbody tr').each(function () {

            const row = [];

            $(this).find('td').each(function () {

                let cellText = $(this).text()
                    .replace(/\+/g, '')
                    .replace(/−/g, '')
                    .trim();

                row.push(cellText);
            });

            if (row.length > 0) {
                exportData.push(row);
            }
        });

        const worksheet = XLSX.utils.aoa_to_sheet(exportData);

        const workbook = XLSX.utils.book_new();

        XLSX.utils.book_append_sheet(workbook, worksheet, 'LinkedParts');

        XLSX.writeFile(workbook, 'LinkedParts.xlsx');
    });
    
</script>
</body>
</html>
