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
<title>Equivalents</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
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
  .topbar > div:last-child {
    border-right: 1px solid #cfd3db;
  }
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
  .topbar > div:not(:last-child) { margin-right: -1px; }
  .vertical-line img {
    height: 20px;
    width: 1px;
    margin: 0 10px;
  }
  .container {
    display: flex;
    height: calc(100vh - 56px);
    font-size: 13px;
  }
  .sidebar {
    width: 20%;
    background-color: #f8f9fa;
    border-right: 1px solid #ddd;
    padding: 20px;
    font-size: 14px;
    box-sizing: border-box;
    overflow-y: auto;
    overflow-x: hidden;
  }
  .sidebar a {
    display: block;
    padding: 8px;
    color: #333;
    text-decoration: none;
    margin-bottom: 10px;
    border-radius: 4px;
  }
  .sidebar a:hover { background-color: #e3e7ea; }
  .sidebar a.active {
    background-color: #808080;
    color: white;
    font-weight: bold;
  }
  .main-panel {
    flex-grow: 1;
    padding: 20px;
    overflow-y: auto;
    font-size: 13px;
    box-sizing: border-box;
  }
  .toolbar {
    background-color: #f8f9fa;
    padding: 6px 10px;
    border: 1px solid #dee2e6;
    border-bottom: none;
    display: flex;
    gap: 10px;
    border-radius: 4px;
    margin-top: 10px;
    margin-bottom: 5px;
  }
  .toolbar button {
    background: none;
    border: none;
    cursor: pointer;
    padding: 2px 4px;
  }
  .toolbar button img {
    width: 20px;
    height: 20px;
    vertical-align: middle;
  }
  .toolbar button:hover {
    background-color: #e3f2fd;
    border-radius: 2px;
  }
  .section-label {
    font-weight: bold;
    font-size: 14px;
    margin: 10px 0 5px 0;
    color: #333;
  }
  #loadingSpinner {
    display: none;
    position: fixed;
    top: 10px;
    right: 10px;
    font-size: 14px;
    color: #666;
  }
  #errorMessage {
    color: red;
    margin: 10px 0;
    font-weight: bold;
  }
  #mpnTable {
    white-space: nowrap;
  }
  .state-box .state-badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 12px;
    font-weight: 700;
    font-size: 13px;
    color: white;
    margin-left: 8px;
    user-select: none;
    text-transform: uppercase;
    min-width: 80px;
    text-align: center;
  }
  .state-badge.InWork  { background-color: #5bc0de; }
  .state-badge.Frozen  { background-color: #6c757d; }
  .state-badge.Released { background-color: #28a745; }
  .state-badge.Obsolete { background-color: #ffc107; color: #000;
   }
  #mpnTable thead th {
  background-color: #e9ecef;
  color: #333;
  font-weight: bold;
  border-bottom: 2px solid #ccc;
  white-space: nowrap;
}
#mpnTable_wrapper {
  overflow-x: auto;
  width: 100%;
}

#mpnTable {
  min-width: 900px;
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
    <a class="nav-link" href="Properties.jsp?name=<%= request.getParameter("name") %>">Part Properties</a>
    <a class="nav-link" href="EngineeringBOM.jsp?name=<%= request.getParameter("name") %>">Engineering BOM</a>
    <a class="nav-link active" href="APNEquivalents.jsp?name=<%= request.getParameter("name") %>">Equivalents</a>
    <a class="nav-link" href="Parthistory.jsp?name=<%= request.getParameter("name") %>">History</a>
    <a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>">LifeCycle</a>
    <a class="nav-link" href="ControlManagement.jsp?name=<%= request.getParameter("name") %>">Control Management</a>
    <a class="nav-link" href="PartSpecification.jsp?name=<%= request.getParameter("name") %>">PartSpecification</a>
    <a class="nav-link" href="SpecificationDocumentUpload.jsp?name=<%= request.getParameter("name") %>">SpecificationDocument</a>
  </div>

  <div class="main-panel">
    <div class="toolbar">
      <button class="btn btn-light" title="Add Existing MPN" id="addExistingMPN">
        <img src="https://img.icons8.com/?size=100&id=K0l4dwcsMaJa&format=png&color=000000" alt="Add Existing MPN" />
      </button>
      <button class="btn btn-light" data-bs-toggle="tooltip" title="Export to Excel" id="excelexport">
            <img src="https://img.icons8.com/?size=100&id=112690&format=png&color=000000" alt="Add" style="width: 20px; height: 20px;">
        </button>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>

    <div class="section-label" id="mpnTableLabel" style="display:none;">MPN Equivalents</div>
    <table class="table table-bordered mt-2" id="mpnTable" style="display:none;">
      <thead><tr></tr></thead>
      <tbody></tbody>
    </table>
  </div>
</div>

<script>


const BASIC_URL = '<%= request.getContextPath() %>';
function loadMPNTable() {
    const objectid = new URLSearchParams(window.location.search).get('name');
    if (!objectid) {
        $('#errorMessage').text('Missing object ID.').show();
        return;
    }

    $.ajax({
        url: BASIC_URL+'/api/navigatorutilites/getLinkedMPNs',
        data: { objectid: objectid },
        dataType: 'json',
        cache: false,
        success: function (data) {
            $('#errorMessage').hide();

            if (!data || !Array.isArray(data) || data.length === 0) {
                $('#errorMessage').text('No MPN equivalents found.').show();
                $('#mpnTableLabel').hide();
                $('#mpnTable').hide();
                if ($.fn.DataTable.isDataTable('#mpnTable')) {
                    $('#mpnTable').DataTable().clear().draw();
                }
                return;
            }

            const excludedFields = ['connectionid', 'fts_document', 'manufacturerid'];
            const columns = Object.keys(data[0])
                .filter(key => !excludedFields.includes(key.toLowerCase()))
                .map(key => ({
                    data: key,
                    title: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' '),
                    visible: key.toLowerCase() !== 'objectid'
                }));

            if ($.fn.DataTable.isDataTable('#mpnTable')) {
                $('#mpnTable').DataTable().clear().destroy();
            }

            const thead = $('#mpnTable thead');
            thead.empty();
            const headerRow = $('<tr></tr>');
            columns.forEach(col => headerRow.append(`<th>${col.title}</th>`));
            thead.append(headerRow);

            $('#mpnTable').DataTable({
                data: data,
                columns: columns,
                paging: false,
                searching: false,
                scrollX: false,
                info: false,
                destroy: true
            });

            $('#mpnTableLabel').show();
            $('#mpnTable').show();
        },
        error: function () {
            $('#errorMessage').text('Failed to load MPN equivalents.').show();
        }
    });
}

$(document).ready(function () {
    loadMPNTable();

    // Populate topbar from sessionStorage
    const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
    if (partInfo) {
        $('.part-number').text(partInfo.name || '');
        $('.part-type').text(partInfo.type || '');
        const icon = (partInfo.type && partInfo.type.toLowerCase() === 'fastener')
            ? 'https://img.icons8.com/?size=50&id=20544&format=png&color=000000'
            : 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000';
        $('#typeIcon').attr('src', icon);

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
    }

    // Open MPN search popup
    $('#addExistingMPN').on('click', function () {
        const objectid = new URLSearchParams(window.location.search).get('name');
        if (objectid) {
            window.open(
                'search.jsp?name=' + encodeURIComponent(objectid) + '&mode=mpn',
                'AddExistingMPNPopup',
                'width=900,height=800,left=100,top=100,resizable=yes'
            );
        } else {
            alert('No object ID found!');
        }
    });

    // Listen for selected MPNs sent back from the search popup
    window.addEventListener('message', function (event) {
        if (event.data && event.data.selectedMPNs) {
            receiveSelectedMPNs(event.data.selectedMPNs);
        }
    });
});

function receiveSelectedMPNs(selectedMPNs) {
    if (!selectedMPNs || selectedMPNs.length === 0) return;

    const invalidItems = selectedMPNs.filter(m => 
        !m.supertype || m.supertype.toLowerCase() !== 'manufacturerpartassembly'
    );

    if (invalidItems.length > 0) {
        alert('Invalid selection. Please select only MPN objects.');
        return;
    }

    // Check for duplicate
    const existingIds = [];
    if ($.fn.DataTable.isDataTable('#mpnTable')) {
        $('#mpnTable').DataTable().rows().data().each(function (row) {
            if (row.objectid) existingIds.push(row.objectid);
        });
    }

    const duplicate = selectedMPNs.find(m => existingIds.includes(m.objectid));
    if (duplicate) {
        alert('MPN "' + duplicate.objectid + '" is already linked.');
        return;
    }

    const objectid = new URLSearchParams(window.location.search).get('name');

    $.ajax({
        url: BASIC_URL+'/api/navigatorutilites/linkMPNs/' + encodeURIComponent(objectid),
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(selectedMPNs),
        success: function () {
            const mpnId = selectedMPNs[0].objectid;
            alert('MPN "' + mpnId + '" linked successfully to "' + objectid + '".');
            loadMPNTable();
        },
        error: function (xhr) {
            let msg = 'Failed to link MPN.';
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

    $('#mpnTable thead th').each(function () {
        headers.push($(this).text().trim());
    });

    exportData.push(headers);

    $('#mpnTable tbody tr').each(function () {

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

    XLSX.utils.book_append_sheet(workbook, worksheet, 'Equivalents');

    XLSX.writeFile(workbook, 'APNEquivalents.xlsx');
});

</script>
</body>
</html>