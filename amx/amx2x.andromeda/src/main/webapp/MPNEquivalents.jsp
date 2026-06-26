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
<title>MPN Equivalents</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

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
  .topbar-left { display: flex; align-items: center; gap: 14px; }
  .topbar-icon {
    width: 42px; height: 42px;
    border-radius: 10px;
    background: #f1f5f9;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px; color: #4b5563; flex-shrink: 0;
  }
  .topbar-name { font-size: 16px; font-weight: 700; color: #111827; margin: 0 0 2px 0; }
  .topbar-type { font-size: 12px; color: #6b7280; margin: 0; }
  .topbar-right {
    display: flex; align-items: center; gap: 8px;
    font-size: 13px; font-weight: 500; color: #374151;
  }

  /* ===== STATE BADGE ===== */
  .state-badge {
    display: inline-flex; align-items: center; justify-content: center;
    padding: 4px 12px; border-radius: 999px;
    font-size: 11px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.3px;
  }
  .state-badge.InWork   { background: #dbeafe; color: #1d4ed8; }
  .state-badge.Frozen   { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
  .state-badge.Released { background: #dcfce7; color: #166534; }
  .state-badge.Obsolete { background: #fef9c3; color: #854d0e; }

  /* ===== LAYOUT ===== */
  .page-container {
    display: flex;
    height: calc(100vh - 65px);
    overflow: hidden;
  }

  .sidebar {
    width: 19%;
    min-width: 180px;  
    flex-shrink: 0;      
    background-color: #f8f9fa;
    border-right: 1px solid #ddd;
    padding: 20px;
    box-sizing: border-box;
    overflow-y: auto; overflow-x: hidden;
}
  .sidebar a {
    display: flex; align-items: center; gap: 10px;
    padding: 10px 12px; color: #4b5563;
    text-decoration: none; margin-bottom: 6px;
    border-radius: 8px; font-size: 13px; font-weight: 500;
    transition: all 0.2s ease;
  }
  .sidebar a:hover { background-color: #e3e7ea; color: #111827; }
  .sidebar a.active { background-color: #4b5563; color: white; font-weight: 600; }
  .sidebar a i { width: 16px; font-size: 13px; color: #6b7280; }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
    flex-grow: 1;
    padding: 0;
    overflow-y: auto; min-width: 0;
    box-sizing: border-box;
    display: flex; flex-direction: column;
  }

  /* ===== TOOLBAR ===== */
  .toolbar {
    background-color: #393a3c;
    padding: 8px 14px;
    display: flex; align-items: center; gap: 8px;
    border-bottom: 1px solid #334155;
    margin: 0;
  }
  .toolbar button {
    background: none; border: none; cursor: pointer;
    padding: 4px 6px; border-radius: 4px;
    display: flex; align-items: center;
  }
  .toolbar button img { width: 18px; height: 18px; filter: invert(1); }
  .toolbar button:hover { background-color: #334155; }

  /* ===== SECTION LABEL ===== */
  .section-label {
    font-weight: 700; font-size: 13px;
    margin: 10px 16px 6px 16px;
    color: #333; text-transform: uppercase; letter-spacing: 0.5px;
  }

  /* ===== TABLE ===== */
  #linkedTable { width: 100% !important; white-space: nowrap; border-collapse: collapse; }
  #linkedTable thead th {
    background: #393a3c !important; color: #e2e8f0 !important;
    font-size: 11px !important; font-weight: 700 !important;
    text-transform: uppercase !important; letter-spacing: 0.5px !important;
    padding: 10px 26px 10px 12px !important;
    border-bottom: 2px solid #334155 !important;
    border-right: 1px solid #334155 !important;
    white-space: nowrap !important;
  }
  #linkedTable thead .sorting:before, #linkedTable thead .sorting:after,
  #linkedTable thead .sorting_asc:before, #linkedTable thead .sorting_asc:after,
  #linkedTable thead .sorting_desc:before, #linkedTable thead .sorting_desc:after {
    color: rgba(255,255,255,0.75) !important; opacity: 1 !important; display: none !important;
  }
  #linkedTable tbody td {
    padding: 10px 12px !important;
    border-bottom: 1px solid #f1f5f9 !important;
    vertical-align: middle !important;
    color: #111111 !important; background: #ffffff !important;
    font-size: 13px !important;
  }
  #linkedTable tbody tr:hover td { background: #f8fafc !important; }

  .dataTables_info, .dataTables_paginate,
  .dataTables_length, .dataTables_filter { display: none !important; }

  #errorMessage { color: #c0392b; margin: 10px 16px; font-size: 13px; }
  #searchOverlay {  display: none; position: absolute;  top: 0; left: 0;  width: 100%; height: 100%;  background: #fff;  z-index: 100;
  flex-direction: column; }
  
#searchOverlay.active {  display: flex;}
#searchOverlayBar {  height: 55px;  background-color: #393a3c;  padding: 8px 14px;  display: flex;  align-items: center;
  border-bottom: 1px solid #334155;
  flex-shrink: 0; }
  
#searchOverlayBar .overlay-title {  color: #e2e8f0;  font-size: 13px;  font-weight: 600;  flex: 1;}
#closeSearchOverlay {  background: none;  border: none;  cursor: pointer;  color: #e2e8f0;  font-size: 13px;  font-weight: 500;
  padding: 4px 8px;  border-radius: 4px;  display: flex;  align-items: center;  gap: 6px; }
  
#closeSearchOverlay:hover { background-color: #334155; }
#searchOverlay iframe {  flex: 1;  width: 100%;  border: none;}
  
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
  <div class="topbar-left">
    <div class="topbar-icon"><i class="fa-solid fa-microchip"></i></div>
    <div>
      <div class="topbar-name" id="mpnName">MPN Equivalents</div>
      <div class="topbar-type" id="mpnType">ManufacturerPartAssembly</div>
    </div>
  </div>
  <div class="topbar-right">
    <span>State:</span>
    <div id="stateBadgeWrapper"></div>
  </div>
</div>

<div class="page-container">
  <div class="sidebar">
    <a class="nav-link" href="MPNProperties.jsp?name=<%= request.getParameter("name") %>">
      <i class="fa-solid fa-microchip"></i> MPN Properties
    </a>
    <a class="nav-link active" href="MPNEquivalents.jsp?name=<%= request.getParameter("name") %>">
      <i class="fa-solid fa-code-compare"></i> Equivalents
    </a>
    <a class="nav-link" href="MPNHistory.jsp?name=<%= request.getParameter("name") %>">
      <i class="fa-regular fa-clock"></i> History
    </a>
    <a class="nav-link" href="MPNLifecycle.jsp?name=<%= request.getParameter("name") %>">
      <i class="fa-solid fa-arrows-rotate"></i> LifeCycle
    </a>
  </div>

  <div class="main-panel">
  <div id="searchOverlay">
  <div id="searchOverlayBar">
    <span class="overlay-title">Add Existing Part </span>
    <button id="closeSearchOverlay">
      <i class="fa-solid fa-arrow-left"></i> Back
    </button>
  </div>
  <iframe id="searchOverlayFrame" src=""></iframe>
</div>
    <div class="toolbar">
      <button class="btn btn-light" title="Link Part/APN" id="addLinkedPart">
        <i class="fa-solid fa-plus" style="color:white;font-size:18px;"></i>
      </button>
      <button class="btn btn-light" data-bs-toggle="tooltip" title="Export to Excel" id="excelexport">
            <img src="https://img.icons8.com/?size=100&id=112690&format=png&color=000000" alt="Add" style="width: 20px; height: 20px;">
        </button>
    </div>

    <div id="errorMessage"></div>
    <div class="section-label" id="linkedTableLabel" style="display:none;">Linked Part / APN</div>
	<div style="overflow-x: auto; padding: 0 16px; width: 100%;">
  	<table class="table table-bordered mt-2" id="linkedTable" style="display:none; min-width: 900px;">
      <thead><tr></tr></thead>
      <tbody></tbody>
    </table>
  </div>
</div>
</div>

<script>

const BASIC_URL = '<%= request.getContextPath() %>';
function loadLinkedTable() {
    const objectid = new URLSearchParams(window.location.search).get('name');
    if (!objectid) {
        $('#errorMessage').text('Missing object ID.').show();
        return;
    }

    $.ajax({
        url: BASIC_URL+'/api/navigatorutilites/getLinkedAPNs',
        data: { objectid: objectid },
        dataType: 'json',
        cache: false,
        success: function (data) {
            $('#errorMessage').hide();

            if (!data || !Array.isArray(data) || data.length === 0) {
                $('#errorMessage').text('No linked part found.').show();
                $('#linkedTableLabel').hide();
                $('#linkedTable').hide();
                if ($.fn.DataTable.isDataTable('#linkedTable')) {
                    $('#linkedTable').DataTable().clear().draw();
                }
                
                return;
            }

            const excludedFields = ['connectionid', 'fts_document'];
            const columns = Object.keys(data[0])
                .filter(key => !excludedFields.includes(key.toLowerCase()))
                .map(key => ({
                    data: key,
                    title: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' '),
                    visible: key.toLowerCase() !== 'objectid'
                }));

            if ($.fn.DataTable.isDataTable('#linkedTable')) {
                $('#linkedTable').DataTable().clear().destroy();
            }

            const thead = $('#linkedTable thead');
            thead.empty();
            const headerRow = $('<tr></tr>');
            columns.forEach(col => headerRow.append('<th>' + col.title + '</th>'));
            thead.append(headerRow);

            $('#linkedTable').DataTable({
                data: data,
                columns: columns,
                paging: false,
                searching: false,
                scrollX: false,
                info: false,
                destroy: true
            });

            $('#linkedTableLabel').show();
            $('#linkedTable').show();
        },
        error: function () {
            $('#errorMessage').text('Failed to load linked part.').show();
        }
    });
}

$(document).ready(function () {
    loadLinkedTable();

    const partInfo = JSON.parse(sessionStorage.getItem('mpnInfo'));
    if (partInfo) {
        $('#mpnName').text(partInfo.name || '');
        $('#mpnType').text((partInfo.type || '') + (partInfo.supertype ? ' · ' + partInfo.supertype : ''));
        if (partInfo.currentstate) {
            const state = partInfo.currentstate;
            const cls = state.replace(/\s/g, '');
            $('#stateBadgeWrapper').html('<span class="state-badge ' + cls + '">' + state + '</span>');
        }
    }

    $('#addLinkedPart').on('click', function () {
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

    window.addEventListener('message', function (event) {
    	if (!event.data) return;

        if (event.data.action === 'closeOnly' || event.data.action === 'closeAndRefresh') {
            document.getElementById('myModal').style.display = 'none';
            document.getElementById('iframeContainer').innerHTML = '';
            loadPartControlTable();
        } else if (event.data.selectedParts) {
            receiveSelectedParts(event.data.selectedParts);
            // Close the search overlay after selection
            document.getElementById('searchOverlay').classList.remove('active');
            document.getElementById('searchOverlayFrame').src = '';
        }
    });
});

function receiveSelectedPart(selectedParts) {
    if (!selectedParts || selectedParts.length === 0) return;

    // Only allow Part supertype
    const invalid = selectedParts.filter(p =>
        !p.supertype || p.supertype.toLowerCase() !== 'part'
    );
    if (invalid.length > 0) {
        alert('Invalid selection. Please select only Part objects.');
        return;
    }

    const objectid = new URLSearchParams(window.location.search).get('name');

    $.ajax({
        url: BASIC_URL+'/api/navigatorutilites/linkAPN/' + encodeURIComponent(objectid),
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(selectedParts),
        success: function () {
            const partId = selectedParts[0].objectid;
            alert('Part "' + partId + '" linked successfully to "' + objectid + '".');
            loadLinkedTable();
        },
        error: function (xhr) {
            let msg = 'Failed to link part.';
            try {
                const err = JSON.parse(xhr.responseText);
                if (err.Message) msg = err.Message;
            } catch (e) {}
            alert(msg);
        }
    });
}

$('#excelexport').on('click', function () {

    const exportData = [];

    const headers = [];

    $('#linkedTable thead th').each(function () {
        headers.push($(this).text().trim());
    });

    exportData.push(headers);

    $('#linkedTable tbody tr').each(function () {

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

    XLSX.utils.book_append_sheet(workbook, worksheet, 'LinkedAPNs');

    XLSX.writeFile(workbook, 'LinkedAPNs.xlsx');
});

</script>
</body>
</html>