<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String partName = request.getParameter("name");
    if (partName == null) partName = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Properties</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link rel="stylesheet" href="styles/Properties.css">
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
    <a class="nav-link active"><i class="fa-solid fa-tag"></i>Part Properties</a>
    <a class="nav-link" href="EngineeringBOM.jsp?name=<%= partName %>"><i class="fa-solid fa-sitemap"></i> Engineering BOM</a>
    <a class="nav-link" href="APNEquivalents.jsp?name=<%= partName %>"><i class="fa-solid fa-code-compare"></i> Equivalents</a>
    <a class="nav-link" href="Parthistory.jsp?name=<%= partName %>"><i class="fa-regular fa-clock"></i> History</a>
    <a class="nav-link" href="Lifecycle.jsp?name=<%= partName %>"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
    <a class="nav-link" href="ControlManagement.jsp?name=<%= partName %>"><i class="fa-solid fa-shield-halved"></i> ControlManagement</a>
    <a class="nav-link" href="PartSpecification.jsp?name=<%= partName %>"><i class="fa-regular fa-clipboard"></i> PartSpecification</a>
    <a class="nav-link" href="SpecificationDocumentUpload.jsp?name=<%= partName %>"><i class="fa-regular fa-file"></i> SpecificationDocument</a>
</div>
  <div class="main-panel">
       <div class="toolbar">
      <button id="editBtn" title="Edit">
        <img src="https://img.icons8.com/?size=100&id=43068&format=png&color=000000" alt="Edit" />
      </button>
      <button id="refreshBtn" title="Refresh">
<i class="fa-solid fa-arrows-rotate"></i>      </button>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage" class="error"></div>
    <div id="detailsTable" class="property-card"></div>
  </div>
</div>
    
<div id="modalOverlay"></div>
<div id="editPanel">
    <h5>Edit Part Details</h5>
    <form id="editForm"></form>
    <div class="mt-3">
        <button id="saveBtn" type="button">Save</button>
        <button id="cancelBtn" type="button">Cancel</button>
    </div>
</div>
    <!-- JS Libraries -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>

const BASIC_URL = '<%= request.getContextPath() %>';
let currentPartData = {};

const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
const loggedInUserAccess = user?.access || '';
if(loggedInUserAccess.trim().toLowerCase() === 'reader') $('#editBtn').hide();

$(document).ready(function () {
    const objectId = getQueryParam('name');
    if (!objectId) {
        showError("No 'name' (ObjectId) parameter found in the URL.");
        return;
    }

    showLoading(true);

    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/infos',
        method: 'GET',
        data: { objectId },
        dataType: 'json',
        success: function (data) {
            if (!data || $.isEmptyObject(data)) {
                showError("No details found for ObjectId: " + objectId);
                return;
            }
            currentPartData = data;
            sessionStorage.setItem('partInfo', JSON.stringify(data));
            populateTopBar(data);
            populateTable(data);
            if (loggedInUserAccess.toLowerCase() === 'admin' || loggedInUserAccess.toLowerCase() === 'leader') {
                $('#editBtn').show();
            }
        },
        error: function () {
            showError("Error fetching part details.");
        },
        complete: function () {
            showLoading(false);
        }
    });

    $('#editBtn').on('click', function () {
        if (!$.isEmptyObject(currentPartData)) {
            openEditPanel(currentPartData);
        } else {
            alert("Data not loaded yet.");
        }
    });

    $('#cancelBtn').on('click', closeEditPanel);

    $('#saveBtn').on('click', function () {
        const objectId = getQueryParam('name');
        const descriptionValue = $('[name="description"]').val();  

        if (!descriptionValue || descriptionValue.trim() === '') {
            alert("Description cannot be empty.");
            return;
        }

        const updatedData = {
            "description": descriptionValue
        };

        $.ajax({
            url: BASIC_URL+'/api/datafetchservice/updatepart/' + encodeURIComponent(objectId),
            method: 'PUT',
            contentType: 'application/json',
            data: JSON.stringify(updatedData),
            success: function () {
                alert("Part updated successfully!");
                location.reload();
            },
            error: function (xhr) {
                let msg = "Failed to update part.";
                try {
                    const errResp = JSON.parse(xhr.responseText);
                    if (errResp.Message) msg = errResp.Message;
                } catch (e) {}
                alert(msg);
            }
        });

        closeEditPanel();
    });

    $('#refreshBtn').on('click', function () {
        location.reload();
    });
});

function populateTopBar(data) {
    $('.part-number').text(data.name || '');
    $('.part-type').text(data.type || '');
    $('.part-owner').text(data.owner || '');
    $('.part-created').text(data.createddate || '');

    const icon = (data.type && data.type.toLowerCase() === 'fastener') 
        ? 'https://img.icons8.com/?size=50&id=20544&format=png&color=000000'
        : 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000';
    $('#typeIcon').attr('src', icon);
    $('.state-box .state-label').remove();
    if (data.currentstate) {
	    $('.state-box .state-label').remove();
	    const state = data.currentstate;
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

function populateTable(part) {
    const container = $('#detailsTable');
    container.empty();
    $('#errorMessage').hide();
    $('#detailsTable').show();

    let html = '<div class="property-grid">';

    function addProperty(label, value, icon, extraClass) {
        if (!value || value === '') return;
        html += '<div class="property-item">' +
                    '<div class="property-icon"><i class="' + icon + '"></i></div>' +
                    '<div class="property-content">' +
                        '<span class="property-label">' + label + '</span>' +
                        (extraClass === 'state'
                            ? '<span class="property-state">' + value + '</span>'
                            : '<span class="property-value">' + value + '</span>') +
                    '</div>' +
                '</div>';
    }

    addProperty('Name', part.name, 'fa-solid fa-tag');
    addProperty('Description', part.description, 'fa-solid fa-file-lines');
    if (part.variant) addProperty('Variant', part.variant, 'fa-solid fa-layer-group');
    addProperty('Type', part.type, 'fa-solid fa-screwdriver-wrench');
    addProperty('Owner', part.owner, 'fa-regular fa-user');
    addProperty('Responsible Engineer',part.responsibleengineer,'fa-solid fa-user-gear');
    addProperty('APN', part.apn, 'fa-solid fa-barcode');
    addProperty('Supertype', part.supertype, 'fa-solid fa-diagram-project');
    addProperty('Email', part.email, 'fa-solid fa-envelope');
    addProperty('Created Date', part.createddate, 'fa-solid fa-calendar');
    addProperty('Current State', part.currentstate, 'fa-solid fa-shield-halved', 'state');

    html += '</div>';
    container.html(html);
}
function openEditPanel(part) {
    const form = $('#editForm');
    form.empty();

    const editableFields = ['description'];

    for (const key in part) {
        if (!part.hasOwnProperty(key)) continue;
        if (['objectid', 'historyList', 'fts_document', 'fastenersubpart', 'connectionid'].includes(key.toLowerCase())) continue;
        if (key.toLowerCase() === 'currentstate' && (!part[key] || part[key].trim() === '')) continue;

        const rawValue = part[key] ?? '';
        const safeId = 'edit_' + key.replace(/[^a-zA-Z0-9]/g, '_');
        const lowerKey = key.toLowerCase();
        const label = prettyLabel(lowerKey);
        const isEditable = editableFields.includes(lowerKey);

        const formGroup = $('<div class="mb-3"></div>');
        const labelEl = $('<label></label>').addClass('form-label').attr('for', safeId).text(label);
        const inputEl = $('<input>').attr('type', 'text').addClass('form-control')
                        .attr('id', safeId).attr('name', lowerKey).val(rawValue);

        if (!isEditable) inputEl.attr('readonly', true);

        formGroup.append(labelEl);
        formGroup.append(inputEl);
        form.append(formGroup);
    }

    $('#editPanel').addClass('active');
    $('#modalOverlay').addClass('active');
}

function closeEditPanel() {
    $('#editPanel').removeClass('active');
    $('#modalOverlay').removeClass('active');
}

function getQueryParam(param) {
    return new URLSearchParams(window.location.search).get(param);
}

function showLoading(show) {
    $('#loadingSpinner').css('display', show ? 'block' : 'none');
}

function showError(msg) {
    $('#errorMessage').text(msg).show();
    $('#detailsTable').hide();
    showLoading(false);
}

function prettyLabel(key) {
    const map = {
        description: "Description",
        supertype: "Supertype",
        type: "Type",
        owner: "Owner",
        createddate: "Created Date",
        modifieddate: "Modified Date",
        status: "Status",
        version: "Version"
    };
    return map[key] || key;
}
</script>
</body>
</html>
