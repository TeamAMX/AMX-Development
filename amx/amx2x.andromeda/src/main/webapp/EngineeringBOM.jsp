<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
    String partName = request.getParameter("name");
    if (partName == null) partName = "";
%>

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
<link rel="stylesheet" href="styles/EngineeringBOM.css" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
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
    <a class="nav-link" href="Properties.jsp?name=<%= partName %>"><i class="fa-solid fa-tag"></i> Part Properties</a>
    <a class="nav-link active" href="EngineeringBOM.jsp?name=<%= partName %>"><i class="fa-solid fa-sitemap"></i> Engineering BOM</a>
    <a class="nav-link" href="APNEquivalents.jsp?name=<%= partName %>"><i class="fa-solid fa-code-compare"></i> Equivalents</a>
    <a class="nav-link" href="Parthistory.jsp?name=<%= partName %>"><i class="fa-regular fa-clock"></i> History</a>
    <a class="nav-link" href="Lifecycle.jsp?name=<%= partName %>"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
    <a class="nav-link" href="ControlManagement.jsp?name=<%= partName %>"><i class="fa-solid fa-shield-halved"></i> Control Management</a>
    <a class="nav-link" href="PartSpecification.jsp?name=<%= partName %>"><i class="fa-regular fa-clipboard"></i> PartSpecification</a>
    <a class="nav-link" href="SpecificationDocumentUpload.jsp?name=<%= partName %>"><i class="fa-regular fa-file"></i> SpecificationDocument</a>
</div>
<div class="splitter" id="splitter"></div>
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
    <div class="toolbar mt-2">
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Create Part" id="openCreatePanelBtn">
        <i class="fa-solid fa-hammer" style="color:white; font-size:18px;"></i> 
        </button>
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Add Existing Part" id="addExistingpart">
		<i class="fa-solid fa-puzzle-piece" style="color:white; font-size:18px;"></i> 
        </button>
        <button class="btn btn-light" data-bs-toggle="tooltip" title="Export to Excel" id="excelexport">
		<i class="fa-solid fa-download" style="color:white; font-size:18px;"></i> 
        </button>
    </div>
    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>
        <div class="section-label">EBOM</div>
<div style="overflow-x: auto; width: 100%; padding: 0 16px;">
<table id="EBOMTable">
    <thead><tr></tr></thead>
    <tbody></tbody>
</table>
</div>
</div>
    <div id="myModal" class="modal">
        <div class="modal-content">
            <span class="close-button" id="modalCloseBtn">&times;</span>
            <div id="nativeFormContainer"></div>
            <div id="iframeContainer" style="display: none; width: 100%; height: 100%;"></div>
        </div>
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
    const indent = depth * 24;

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

            childData.slice().reverse().forEach(function(child, idx) {
                const keys = Object.keys(child).filter(k => !excludedFields.includes(k));
                const childObjectId = child.objectid || '';
                const isLast = idx === childData.length - 1;

                // Build tree line SVG based on depth
                let treeLines = '';
                for (let d = 1; d < depth; d++) {
                    treeLines += '<span style="display:inline-block;width:20px;border-left:1px dashed #cbd5e1;height:100%;margin-right:0;">&nbsp;</span>';
                }
                treeLines += '<span style="display:inline-block;width:20px;border-left:1px dashed #cbd5e1;border-bottom:1px dashed #cbd5e1;height:12px;vertical-align:bottom;margin-right:2px;"></span>';

                let tr = '<tr class="child-row" data-parent="' + parentObjectId + '" data-objectid="' + childObjectId + '" data-depth="' + depth + '">';

                tr += '<td style="white-space:nowrap;">' +
                    '<span style="display:inline-flex;align-items:center;">' +
                    treeLines +
                    '<span class="child-expand-toggle" data-objectid="' + childObjectId + '">+</span>' +
                    '<input type="checkbox" class="child-row-checkbox" data-objectid="' + childObjectId + '" style="margin:0 6px;">' +
                    '<span style="font-weight:600;">' + (child[keys[0]] || '') + '</span>' +
                    '</span>' +
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
	$('#errorMessage').hide();
	$('.section-label').hide();
	$('#EBOMTable').hide();
    const urlParams = new URLSearchParams(window.location.search);
    const objectid = urlParams.get('name');

    if (!objectid) {
        $('#errorMessage').text('Missing object ID.');
        return;
    }
    $.ajax({
        url:BASIC_URL+'/api/datafetchservice/getcreatedebom',
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
                $('.section-label').hide();
                $('#EBOMTable').hide();
                return;
            }

            $('.section-label').show();
            $('#EBOMTable').show();
            
            const excludedFields = ['objectid', 'linkedobjectid', 'connectionid', 'fts_document'];

            const columns = [
    ...Object.keys(data[0])
        .filter(key => !excludedFields.includes(key))
        .map((key, index) => ({
            data: key,
            title: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' '),
            render: index === 0
            ? function(d) {
                return '<span style="display:inline-flex;align-items:center;gap:4px;">' +
                       '<span class="expand-toggle">+</span>' +
                       '<input type="checkbox" class="row-checkbox" style="margin:0 4px;">' +
                       '<span style="font-weight:600;">' + (d || '') + '</span>' +
                       '</span>';
              }
            : function(d) { return d || ''; }
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
                order: [],
                paging: false,
                searching: false,
                autoWidth: false,
                info: false,
                destroy: true,
                scrollX: false
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

function loadFormInModal(url) {
    const modal = document.getElementById('myModal');
    document.getElementById('nativeFormContainer').style.display = 'none';
    const iframeContainer = document.getElementById('iframeContainer');
    iframeContainer.style.display = 'block';
    iframeContainer.innerHTML = '<iframe src="' + url + '" style="width:100%; height:75vh; max-height: 600px; border:none; border-radius:8px;"></iframe>';
    modal.style.display = 'flex';
}

$(document).ready(function() {
    loadEBOMTable();
    
    document.getElementById('modalCloseBtn').addEventListener('click', function () {
        document.getElementById('myModal').style.display = 'none';
        document.getElementById('iframeContainer').innerHTML = '';
    });
    
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

        loadFormInModal('CreatePartWithConnection.jsp?name=' + encodeURIComponent(objectid));
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
        if (parentObjectId) {
            document.getElementById('searchOverlayFrame').src =
                'search.jsp?name=' + encodeURIComponent(parentObjectId) + '&mode=part';
            document.getElementById('searchOverlay').classList.add('active');
        } else {
            alert('No object ID found!');
        }

    });
    
    document.getElementById('closeSearchOverlay').addEventListener('click', function () {
        document.getElementById('searchOverlay').classList.remove('active');
        document.getElementById('searchOverlayFrame').src = '';
    });
});

window.addEventListener('message', function(event) {
    if (!event.data) return;

    if (event.data.action === 'closeOnly' || event.data.action === 'closeAndRefresh') {
        document.getElementById('myModal').style.display = 'none';
        document.getElementById('iframeContainer').innerHTML = '';
        loadEBOMTable();
    } else if (event.data.selectedParts) {
        receiveSelectedParts(event.data.selectedParts);
        document.getElementById('searchOverlay').classList.remove('active');
        document.getElementById('searchOverlayFrame').src = '';
    }
});


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

//Resizable sidebar splitter
const splitter = document.getElementById('splitter');
const sidebar  = document.querySelector('.sidebar');
let splitterActive = false;

splitter.addEventListener('mousedown', function(e) {
    splitterActive = true;
    splitter.classList.add('active');
    document.body.style.userSelect = 'none';
    document.body.style.cursor = 'col-resize';
});

document.addEventListener('mousemove', function(e) {
    if (!splitterActive) return;
    const containerLeft = document.querySelector('.container').getBoundingClientRect().left;
    let newWidth = e.clientX - containerLeft;
    newWidth = Math.max(120, Math.min(400, newWidth));
    sidebar.style.width = newWidth + 'px';
});

document.addEventListener('mouseup', function() {
    if (!splitterActive) return;
    splitterActive = false;
    splitter.classList.remove('active');
    document.body.style.userSelect = '';
    document.body.style.cursor = '';
});

</script>

</body>
</html>
