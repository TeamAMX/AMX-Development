<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Engineering BOM</title>
<link rel="stylesheet"
href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css"/>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
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

  .folder-box {
    background: #e3e7eb;
    border: 1px solid #d1d6dc;
    width: 28px;
    height: 28px;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-right: 8px;
    flex-shrink: 0;
  }

  .folder-box img {
    width: 16px;
    height: 16px;
  }

  .part-number {
    font-weight: 700;
    font-size: 14px;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }

  .description {
    font-weight: 600;
    font-size: 13px;
    color: #555;
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

  .state-label {
    margin-right: 4px;
  }

  .btn-submit {
    background-color: #5c8bff;
    border: 1px solid #3f70ff;
    color: white;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-submit:hover {
    background-color: #3f70ff;
  }

  .btn-evaluate {
    background-color: #e5e7ea;
    border: 1px solid #c6cad2;
    color: #555;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-evaluate:hover {
    background-color: #c6cad2;
  }

  .info-box {
    font-size: 11px;
    color: #666;
    padding-left: 4px;
    line-height: 1.3;
  }

  .info-box strong {
    color: #444;
  }

  .topbar > div:not(:last-child) {
    margin-right: -1px; 
  }
	
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
  display: block;
  padding: 8px;
  color: #333;
  text-decoration: none;
  margin-bottom: 10px;
  border-radius: 4px;
}

.sidebar a:hover {
  background-color: #e3e7ea; 
}

.sidebar a.active {
  background-color:#808080;
  color: white;
   font-weight: bold;
}

.main-panel {
    flex-grow: 1;
    padding: 20px;
    overflow-y: auto;
    min-width: 0;
    width: 0;
    box-sizing: border-box;
}


.container {
    display: flex;
    height: calc(100vh - 56px);
    overflow: hidden;
    width: 100%;
}


.topbar {
  display: flex;
  background: #f5f7fa;
  border-bottom: 1px solid #cfd3db;
  padding: 6px 12px;
  font-size: 13px;
  color: #333;
}

  .toolbar {
    margin-bottom: 5px;
    padding-left: 2px;
  }
  .toolbar button {
    background: none;
    border: none;
    cursor: pointer;
    margin-right: 6px;
    vertical-align: middle;
    padding: 2px 4px;
  }
  .toolbar button img {
    vertical-align: middle;
    width: 18px;
    height: 18px;
  }
  .toolbar button:hover {
    background-color: #e3f2fd;
    border-radius: 2px;
  }

table.properties {
  width: 100%;
  border-collapse: collapse;
  border: 1px solid #ddd;
  font-size: 16px;
  font-family: Arial, sans-serif;
  margin: 0 auto;
}

table.properties th,
table.properties td {
  padding: 12px 16px;
  border: 1px solid #ddd; 
  vertical-align: middle;
}

table.properties th {
  background: #fafafa;
  font-weight: bold;
  width: 200px; 
  text-align: left;
}

  .folder-icon {
    width: 16px;
    height: 16px;
    vertical-align: middle;
    margin-right: 6px;
  }

.properties-container {
  max-height: 600px; 
  overflow-y: auto;
  border: 1px solid #ddd;
  margin-top: 0;
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
    display: none;
    color: red;
    margin: 10px 0;
    font-weight: bold;
  }
#detailsTable {
   width: 100%;
   border-collapse: collapse;
   margin-top: 10px;
}
th, td {
   border: 1px solid #dee2e6;
   padding: 12px;
   text-align: left;
   font-wrap-mode:nowrap;
}
th {
background-color: #f8f9fa;
width: 200px;
forn-wrap-mode:nowrap;
}
.nav-tabs {
            margin-bottom: 20px;
        }
        .nav-tabs .nav-link.active {
            background-color: #e9ecef;
            font-weight: bold;
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
        }
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
        #createPanel.active {
            right: 0;
        }
        #createPanel iframe {
            border: none;
            width: 100%;
            height: calc(100% - 56px);
        }
#EBOMTable {
    white-space: nowrap;
}

#EBOMTable th,
#EBOMTable td {
    white-space: nowrap;
}
    
   .section-label {
    font-weight: bold;
    font-size: 14px;
    margin: 10px 0 5px 0;
    color: #333;
  }
#partSpecificationTable, #addExistingDataTable {
    display: none;
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
.state-badge.InWork {
  background-color: #5bc0de;
}
.state-badge.Frozen {
  background-color: #6c757d;
}
.state-badge.Released {
  background-color: #28a745;
  color: #fff;
}
.state-badge.Obsolete {
    background-color: #ffc107;
    color: #000;
}

tr.details-row td {
    background-color: #f1f5f9;
    padding: 0 !important;
}
table.child-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
}
table.child-table th {
    background-color: #e2e8f0;
    padding: 8px 12px;
    border: 1px solid #cbd5e1;
    font-weight: bold;
}
table.child-table td {
    padding: 8px 12px;
    border: 1px solid #cbd5e1;
    background-color: #f8fafc;
}
tr.shown td.expand-btn span {
    color: red;
}

</style>
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

        <a class="nav-link"href="Properties.jsp?name=<%= request.getParameter("name") %>">Part Properties</a>
        <a class="nav-link active"href="EngineeringBOM.jsp?name=<%= request.getParameter("name") %>">Engineering BOM</a>
        <a class="nav-link"href="APNEquivalents.jsp?name=<%= request.getParameter("name") %>">Equivalents</a>
        <a class="nav-link"href="Parthistory.jsp?name=<%= request.getParameter("name") %>">History</a>
        <a class="nav-link"href="Lifecycle.jsp?name=<%= request.getParameter("name") %>">LifeCycle</a>
        <a class="nav-link"href="ControlManagement.jsp?name=<%= request.getParameter("name") %>">Control Management</a>
        <a class="nav-link"href="PartSpecification.jsp?name=<%= request.getParameter("name") %>">PartSpecification</a>
        <a class="nav-link"href="SpecificationDocumentUpload.jsp?name=<%= request.getParameter("name") %>">SpecificationDocument</a>

    </div>
   <div class="main-panel">
    <div class="toolbar mt-2">
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Create Part" id="openCreatePanelBtn">
            <img src="https://img.icons8.com/?size=100&id=KJRE9LhcSvaT&format=png&color=000000" alt="Add" style="width:20px height:20px;">
        </button>
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Add Existing Part" id="addExistingpart">
            <img src="https://img.icons8.com/?size=100&id=K0l4dwcsMaJa&format=png&color=000000" alt="Add Existing Part" style="width: 20px; height: 20px;">
        </button>
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Export to Excel" id="excelexport">
            <img src="https://img.icons8.com/?size=100&id=112690&format=png&color=000000" alt="Export" style="width: 20px; height: 20px;">
        </button>
    </div>
    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>
        <div class="section-label">EBOM</div>
<div style="overflow-x: auto; width: 100%;">
<table class="table table-bordered mt-2" id="EBOMTable">
    <thead>
        <tr>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>
</div>
</div>
    <div id="createPanel">
        <iframe id="createIframe" src=""></iframe>
    </div>
</div>
<script>

const BASIC_URL = '<%= request.getContextPath() %>';

function removeDescendants(objectId) {
    $('#EBOMTable tbody tr.child-row[data-parent="' + objectId + '"]').each(function() {
        const childId = $(this).data('objectid');
        removeDescendants(childId);
        $(this).remove();
    });
}

function loadChildRows(parentObjectId, parentTr, depth) {
    const totalCols = $('#EBOMTable').DataTable().columns().count();
    const indent = depth * 20;

    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/getcreatedchildpart',
        data: { objectid: parentObjectId },
        dataType: 'json',
        success: function (childData) {
            removeDescendants(parentObjectId);

            if (!childData || childData.message === 'No Child Part data found.' ||
                !Array.isArray(childData) || childData.length === 0) {
                return;
            }

            const excludedFields = ['fts_document', 'objectid', 'connectionid'];
            const headerCells = $('#EBOMTable thead th');

            childData.slice().reverse().forEach(function(child) {
                const keys = Object.keys(child).filter(k => !excludedFields.includes(k));
                const childObjectId = child.objectid || '';

                let tr = '<tr class="child-row" data-parent="' + parentObjectId + '" data-objectid="' + childObjectId + '" data-depth="' + depth + '" style="background:#f1f5f9;">';

                tr += '<td style="white-space:nowrap; padding-left:' + (8 + indent) + 'px;">' +
                '<span class="child-expand-toggle" data-objectid="' + childObjectId + '" style="cursor:pointer; font-size:14px; font-weight:bold; color:#5c8bff; margin-right:4px;">+</span>' +
                '<input type="checkbox" class="child-row-checkbox" data-objectid="' + childObjectId + '" style="margin-right:4px;">' +
                (child[keys[0]] || '') +
                '</td>';
                for (let i = 1; i < totalCols; i++) {
                    tr += '<td style="white-space:nowrap;">' + (child[keys[i]] || '') + '</td>';
                }

                tr += '</tr>';
                $(parentTr).after(tr);
            });
        },
        error: function () {
            console.error('Failed to load child parts.');
        }
    });
}

function loadChildTable(row, rowData, dt) {
    loadChildRows(rowData.objectid, row.node(), 1);
}

function loadEBOMTable() {
    $('#errorMessage').text('Loading parts...');
    $('.section-label:contains("EBOMTable")').hide();
    const urlParams = new URLSearchParams(window.location.search);
    const objectid = urlParams.get('name');

    if (!objectid) {
        $('#errorMessage').text('Missing object ID.');
        return;
    }
    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/getcreatedebom',
        data: { objectid: objectid },
        dataType: 'json',
        cache: false,
        success: function(data) {
            $('#errorMessage').text('');
            
            if (!data || !Array.isArray(data) || data.length === 0 || data.message) {
                $('#errorMessage').text(data ? data.message || 'No part found.' : 'Error loading data.');
                if ($.fn.DataTable.isDataTable('#EBOMTable')) {
                    $('#EBOMTable').DataTable().clear().draw();
                }
                $('.section-label:contains("EBOMTable")').hide();
                $('#EBOMTable').hide();
                return;
            }

            $('.section-label:contains("EBOMTable")').show();
            $('#EBOMTable').show();
            
            const excludedFields = ['objectid', 'linkedobjectid', 'connectionid', 'fts_document'];

            const columns = [
    ...Object.keys(data[0])
        .filter(key => !excludedFields.includes(key))
        .map((key, index) => ({
            data: key,
            title: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' '),
            render: index === 0
                ? function (data) {
                    return '<span class="expand-toggle" style="cursor:pointer; font-size:16px; font-weight:bold; color:#5c8bff; margin-right:6px;">+</span>' +
                           '<input type="checkbox" class="row-checkbox" style="margin-right:6px;">' +
                           (data || '');
                  }
                : function (data) {
                    return data || '';
                  }
        }))
];

            if ($.fn.DataTable.isDataTable('#EBOMTable')) {
                $('#EBOMTable').DataTable().clear().destroy();
            }

            const thead = $('#EBOMTable thead');
            thead.empty();
            const headerRow = $('<tr></tr>');
            columns.forEach(col => {
                headerRow.append(`<th>${col.title}</th>`);
            });
            thead.append(headerRow);

            const dt = $('#EBOMTable').DataTable({
                data: data,
                columns: columns,
                order: [[columns.findIndex(c => c.data === 'createddate') || 0, 'desc']],
                paging: false,
                searching: false,
                autoWidth: false,
                info: false,
                destroy: true
            });

            $('#EBOMTable tbody').off('click', '.expand-toggle').on('click', '.expand-toggle', function () {
                const tr = $(this).closest('tr');
                const row = dt.row(tr);
                const rowData = row.data();

                if (tr.hasClass('shown')) {
                    removeDescendants(rowData.objectid);
                    tr.removeClass('shown');
                    $(this).text('+').css('color', '#5c8bff');
                } else {
                    loadChildTable(row, rowData, dt);
                    tr.addClass('shown');
                    $(this).text('−').css('color', 'red');
                }
            });
            
            $('#EBOMTable tbody').off('click', '.child-expand-toggle').on('click', '.child-expand-toggle', function () {
                const toggle = $(this);
                const childObjectId = toggle.data('objectid');
                const parentTr = toggle.closest('tr');
                const depth = parseInt(parentTr.data('depth') || 1);

                if (parentTr.hasClass('child-shown')) {
                    removeDescendants(childObjectId);
                    parentTr.removeClass('child-shown');
                    toggle.text('+').css('color', '#5c8bff');
                } else {
                    loadChildRows(childObjectId, parentTr[0], depth + 1);
                    parentTr.addClass('child-shown');
                    toggle.text('−').css('color', 'red');
                }
            });
        },
        error: function(xhr, status, error) {
            console.error('AJAX error:', status, error);
            $('#errorMessage').text('Failed to load parts.');
        }
    });
}

// Receive selected parts from search.jsp popup and link them
function receiveSelectedParts(selectedParts) {
    if (!selectedParts || selectedParts.length === 0) return;

    // Validate: only allow Part supertype
    const invalidItems = selectedParts.filter(function(p) {
        return !p.supertype || p.supertype.toLowerCase() !== 'part';
    });

    if (invalidItems.length > 0) {
        alert('Invalid selection. Please select only Part objects.');
        return;
    }

    // Check for duplicates already in the EBOM table
    const existingIds = [];
    if ($.fn.DataTable.isDataTable('#EBOMTable')) {
        $('#EBOMTable').DataTable().rows().data().each(function(row) {
            if (row.objectid) existingIds.push(row.objectid);
        });
    }

    const duplicate = selectedParts.find(function(p) {
        return existingIds.includes(p.objectid);
    });
    if (duplicate) {
        alert('Part "' + duplicate.name + '" is already linked in the EBOM.');
        return;
    }

 // Determine parent only from checked row
    let parentObjectId = null;

    const checkedParent = document.querySelector('.row-checkbox:checked');
    const checkedChild = document.querySelector('.child-row-checkbox:checked');

    if (checkedChild) {
        parentObjectId = checkedChild.getAttribute('data-objectid');
    } else if (checkedParent) {
        const tr = checkedParent.closest('tr');
        const row = $('#EBOMTable').DataTable().row(tr);
        const rowData = row.data();
        parentObjectId = rowData ? rowData.objectid : null;
    }

    if (!parentObjectId) {
        alert('Please select a parent part.');
        return;
    }
    
    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/linkebomparts/' + encodeURIComponent(parentObjectId),
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(selectedParts),
        success: function() {
            const linkedId = selectedParts[0].objectid;
            alert('Part "' + linkedId + '" linked successfully to "' + parentObjectId + '".');
            loadEBOMTable();
        },
        error: function(xhr) {
            let msg = 'Failed to link part.';
            try {
                const err = JSON.parse(xhr.responseText);
                if (err.Message) msg = err.Message;
            } catch (e) {}
            alert(msg);
        }
    });
}

$(document).ready(function() {
    loadEBOMTable();
    
    // Only one checkbox at a time
    $(document).on('change', '.row-checkbox', function () {
        if ($(this).is(':checked')) {
            $('.row-checkbox').not(this).prop('checked', false);
            $('.child-row-checkbox').prop('checked', false);
        }
    });

    $(document).on('change', '.child-row-checkbox', function () {
        if ($(this).is(':checked')) {
            $('.child-row-checkbox').not(this).prop('checked', false);
            $('.row-checkbox').prop('checked', false);
        }
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

    // Create child part via slide-in panel
    document.getElementById('openCreatePanelBtn').addEventListener('click', function () {
        const checkedParent = document.querySelector('.row-checkbox:checked');
        const checkedChild = document.querySelector('.child-row-checkbox:checked');

        if (!checkedParent && !checkedChild) {
            alert('Please select a row to create a child part for.');
            return;
        }

        let objectid = null;

        if (checkedChild) {
            objectid = checkedChild.getAttribute('data-objectid');
        } else {
            const tr = checkedParent.closest('tr');
            const row = $('#EBOMTable').DataTable().row(tr);
            const rowData = row.data();
            objectid = rowData ? rowData.objectid : null;
        }

        if (!objectid) {
            alert('No object ID found for selected row.');
            return;
        }

        const panel = document.getElementById('createPanel');
        panel.classList.add('active');
        document.getElementById('createIframe').src = 'CreatePartWithConnection.jsp?name=' + encodeURIComponent(objectid);
    });

 // Add Existing Part: open search.jsp popup (Part mode)
    $('#addExistingpart').on('click', function () {
        const checkedParent = document.querySelector('.row-checkbox:checked');
        const checkedChild  = document.querySelector('.child-row-checkbox:checked');

        if (!checkedParent && !checkedChild) {
            alert('Please select a parent row to link the existing part to.');
            return;
        }

        let parentObjectId = null;
        if (checkedChild) {
            parentObjectId = checkedChild.getAttribute('data-objectid');
        } else {
            const tr = checkedParent.closest('tr');
            const row = $('#EBOMTable').DataTable().row(tr);
            const rowData = row.data();
            parentObjectId = rowData ? rowData.objectid : null;
        }

        if (!parentObjectId) {
            alert('No object ID found for selected row.');
            return;
        }

        window.open(
            'search.jsp?name=' + encodeURIComponent(parentObjectId) + '&mode=part',
            'AddExistingPartPopup',
            'width=900,height=800,left=100,top=100,resizable=yes'
        );
    });
    
    // Listen for messages from search.jsp popup and slide-in panel
    window.addEventListener('message', function(event) {
        if (!event.data) return;

        if (event.data.action === 'closeOnly') {
            document.getElementById('createPanel').classList.remove('active');
        } else if (event.data.action === 'closeAndRefresh') {
            document.getElementById('createPanel').classList.remove('active');
            loadEBOMTable();
        } else if (event.data.selectedParts) {
            receiveSelectedParts(event.data.selectedParts);
        }
    });
});

function closeCreatePanel() {
    const panel = document.getElementById('createPanel');
    panel.classList.remove('active');
    document.getElementById('createIframe').src = '';
}

$('#excelexport').on('click', function () {
    const exportData = [];
    const headers = [];

    $('#EBOMTable thead th').each(function () {
        headers.push($(this).text().trim());
    });
    exportData.push(headers);

    $('#EBOMTable tbody tr').each(function () {
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
    XLSX.utils.book_append_sheet(workbook, worksheet, 'EBOM');
    XLSX.writeFile(workbook, 'EBOM.xlsx');
});

</script>

</body>
</html>
