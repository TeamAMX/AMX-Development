<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Part Specification Details</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
  * { box-sizing: border-box; }

  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #f7f9fa;
    color: #333;
  }

.files-table-card {
  background: #ffffff;
  border-radius: 0;
  border: none;
  box-shadow: none;
  width: 100%;
  max-width: 1100px;
  overflow-x: auto;
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
  .page-container{
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
}
  .sidebar a:hover { background-color: #e3e7ea; color: #111827; }
  .sidebar a.active { background-color: #4b5563; color: white; font-weight: 600; }
  .sidebar a i { width: 16px; font-size: 13px; color: #6b7280; }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
    flex-grow: 1;
    padding: 20px 28px;
    overflow-y: auto;
    box-sizing: border-box;
}

  /* ===== TOOLBAR ===== */
  .toolbar {
    display: flex;
    align-items: center;
    gap: 6px;
    justify-content: flex-end;
    margin-bottom: 16px;
  }
  .toolbar button {
    background: #f3f4f6;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    width: 34px;
    height: 34px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: #4b5563;
    font-size: 14px;
    transition: all 0.15s;
  }
  .toolbar button:hover { background: #e5e7eb; color: #111827; }

  .details-card {
    background: #ffffff;
    border-radius: 12px;
    border: 1px solid #e2e5e9;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.04);
    width: 100%;
    max-width: 1100px;
}

  .details-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(320px, 1fr));
    gap: 24px 40px;
    width: 100%;
}

  .detail-field {
    display: flex;
    align-items: flex-start;
    gap: 12px;
  }

  .detail-field-icon {
    width: 34px;
    height: 34px;
    border-radius: 8px;
    background: #f1f5f9;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #4b5563;
    font-size: 14px;
    flex-shrink: 0;
    margin-top: 2px;
  }

  .detail-field-content { flex: 1; }

  .detail-field-label {
    font-size: 11px;
    color: #9ca3af;
    font-weight: 500;
    margin-bottom: 3px;
    text-transform: capitalize;
  }

  .detail-field-value {
    font-size: 13px;
    font-weight: 600;
    color: #111827;
  }

  /* ===== LOADING / ERROR ===== */
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

#saveBtn {
    background: #111827;
    color: white;
    border: none;
    min-width: 110px;
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 0.9rem;
    font-weight: 600;
    cursor: pointer;
}
#saveBtn:hover { background: #1f2937; }

#cancelBtn {
    background: #f3f4f6;
    color: #374151;
    border: 1px solid #d1d5db;
    min-width: 110px;
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 0.9rem;
    font-weight: 600;
    cursor: pointer;
}
#cancelBtn:hover { background: #e5e7eb; }

  #editPanel {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.35);
    backdrop-filter: blur(4px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 2000;

    opacity: 0;
    visibility: hidden;
    transition: all 0.25s ease;
}

#editPanel.active {
    opacity: 1;
    visibility: visible;
}

.edit-modal {
    width: 560px;
    max-width: 92%;
    background: #ffffff;
    border-radius: 18px;
    overflow: hidden;
    box-shadow: 0 25px 60px rgba(0,0,0,0.18);
    animation: popupScale 0.2s ease;
}

.edit-modal h5 {
    padding: 22px 24px;
    margin: 0;
    font-size: 1.15rem;
    font-weight: 700;
    border-bottom: 1px solid #e5e7eb;
    background: #ffffff;
}

.edit-form-body {
    max-height: calc(82vh - 140px);
    overflow-y: auto;
    padding: 22px 24px;
}

.edit-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    padding: 16px 24px;
    border-top: 1px solid #edf0f2;
    background: #fafbfc;
}

#editForm .form-control {
    height: 42px;
    border-radius: 10px;
    font-size: 14px;
    border: 1px solid #e5e7eb;
    background-color: #ffffff;
    padding: 8px 12px;
    width: 100%;
    box-sizing: border-box;
}

#editForm .form-control[readonly] {
    background-color: #f3f4f6;
    color: #6b7280;
}

#editForm .form-label {
    margin-bottom: 6px;
    font-size: 12px;
    font-weight: 600;
    color: #6b7280;
    display: block;
}

@keyframes popupScale {
    from {
        transform: scale(0.96);
        opacity: 0;
    }
    to {
        transform: scale(1);
        opacity: 1;
    }
}
  
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
  <a href="#" id="psPropertiesTab" class="nav-link active"><i class="fa-solid fa-sliders"></i> PS-Properties</a>
 
 <!-- Added by Ajay BUG-1058 New Feature Started -->
  <a href="#" id="filesTab" class="nav-link"><i class="fa-regular fa-file"></i> Files</a>
</div>

  <!-- Main Panel -->
  <div class="main-panel">
    <div class="toolbar">
      <button id="editBtn" title="Edit"><i class="fa-solid fa-pen"></i></button>
      
      <button id="refreshBtn" title="Refresh"><i class="fa-solid fa-arrows-rotate"></i></button>
    </div>

    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>

    <div class="details-card">
      <div class="details-grid" id="detailsCard"></div>
    </div>

<div class="files-table-card" id="filesCard" style="display:none;">
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
 <!-- Added by Ajay BUG-1058 New Feature Ended -->


<div id="editPanel">
  <div class="edit-modal">
    <h5>Edit Part Specification Details</h5>
    <div class="edit-form-body">
      <form id="editForm"></form>
    </div>
    <div class="edit-footer">
     <button id="saveBtn" type="button" class="btn-save">
        Save
      </button>
      <button id="cancelBtn" type="button" class="btn-cancel">
        Cancel
   	  </button>
    </div>
  </div>
</div>

 <script>
 
 const BASIC_URL = '<%= request.getContextPath() %>';
let currentPartData = {};

const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
const loggedInUserAccess = user?.access || '';
if(loggedInUserAccess.trim().toLowerCase() === 'reader') $('#editBtn').hide();

$(document).ready(function () {
  const objectId = getQueryParam('name') || '';

  if (!objectId) {
    showError("No 'name' (ObjectId) parameter found in the URL.");
    return;
  }

  showLoading(true);

  $.ajax({
    url: BASIC_URL+'/api/datafetchservice/getinfops',
    method: 'GET',
    data: { objectId: objectId }, 
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
      } else {
        $('#editBtn').hide();
      }
    },
    error: function (xhr) {
      console.error(" AJAX Error:", xhr);
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
    const descriptionValue = $('[name="description"]').val();

    if (!descriptionValue || descriptionValue.trim() === '') {
      alert("Description cannot be empty.");
      return;
    }

    const updatedData = {
      description: descriptionValue
    };

    $.ajax({
      url: BASIC_URL+'/api/datafetchservice/updatepartspecification/' + encodeURIComponent(objectId),
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
	
  function populateTopBar(data) {
	    $('#psName').text(data.name || 'Part Specification Details');
	    $('#psType').text(data.type || '');
	    if (data.currentstate) {
	        const state = data.currentstate;
	        const cls = state.replace(/\s/g, '');
	        $('#stateBadgeWrapper').html('<span class="state-badge ' + cls + '">' + state + '</span>');
	    }
	}
  
  function populateTable(part) {

	    const card = $('#detailsCard');
	    card.empty();

	    const fieldIcons = {
	        name: 'fa-solid fa-tag',
	        supertype: 'fa-solid fa-layer-group',
	        type: 'fa-solid fa-cube',
	        description: 'fa-solid fa-align-left',
	        createddate: 'fa-regular fa-calendar',
	        owner: 'fa-regular fa-user',
	        email: 'fa-regular fa-envelope',
	        filecount: 'fa-regular fa-file',
	        currentstate: 'fa-solid fa-circle-dot'
	    };

	    card.append(buildRow('name', 'Name', part.name || '', fieldIcons));

	    card.append(buildRow('supertype', 'SuperType', part.supertype || '', fieldIcons));

	    card.append(buildRow('type', 'Type', part.type || '', fieldIcons));

	    card.append(buildRow('description', 'Description', part.description || '', fieldIcons));

	    const createdDate = (part.createddate || part.createdtime || '').split(' ')[0];

	    card.append(buildRow(
	        'createddate',
	        'Created Date',
	        createdDate,
	        fieldIcons
	    ));

	    card.append(buildRow('owner', 'Owner', part.owner || '', fieldIcons));

	    card.append(buildRow('email', 'Email', part.email || '', fieldIcons));

	    // Hardcoded for now
	    card.append(buildRow('filecount', 'File Count', '0', fieldIcons));

	    // Hardcoded for now
	    card.append(buildRow('currentstate', 'Current State', '', fieldIcons));
	}

  function buildRow(key, label, value, fieldIcons) {
	    const icon = fieldIcons[key] || 'fa-solid fa-circle-dot';
	    return `
	        <div class="detail-field">
	            <div class="detail-field-icon"><i class="\${icon}"></i></div>
	            <div class="detail-field-content">
	                <div class="detail-field-label">\${label}</div>
	                <div class="detail-field-value">\${value}</div>
	            </div>
	        </div>
	    `;
	}

  function openEditPanel(part) {
    const form = $('#editForm');
    form.empty();

    const editableFields = ['description'];

    for (const key in part) {
      if (!part.hasOwnProperty(key)) continue;
      if (['objectid', 'historyList', 'fts_document', 'connectionid', 'linkedobjectid', 'name'].includes(key)) continue;
      if (key.toLowerCase() === 'currentstate' && (!part[key] || part[key].trim() === '')) {
          continue;
      }
      const rawValue = part[key] ?? '';
      const safeId = 'edit_' + key.replace(/[^a-zA-Z0-9]/g, '_');
      const lowerKey = key.toLowerCase();
      const label = prettyLabel(lowerKey);
      const isEditable = editableFields.includes(lowerKey);

      const formGroup = $('<div class="mb-3"></div>');
      const labelEl = $('<label></label>').addClass('form-label').attr('for', safeId).text(label);
      const inputEl = $('<input>')
        .attr('type', 'text')
        .addClass('form-control')
        .attr('id', safeId)
        .attr('name', lowerKey)
        .val(rawValue);

      if (!isEditable) {
        inputEl.attr('readonly', true);
      }

      formGroup.append(labelEl);
      formGroup.append(inputEl);
      form.append(formGroup);
    }

    $('#editPanel').addClass('active');
  }

  function closeEditPanel() {
    $('#editPanel').removeClass('active');
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
    return map[key] || key.charAt(0).toUpperCase() + key.slice(1);
  }
  
  $('#psPropertiesTab').on('click', function (e) {
	  e.preventDefault();
	  $(this).addClass('active');
	  $('#filesTab').removeClass('active');
	  $('.toolbar').show();
	  $('.details-card').show();
	  $('#filesCard').hide();
	});

	$('#filesTab').on('click', function (e) {
	  e.preventDefault();
	  $(this).addClass('active');
	  $('#psPropertiesTab').removeClass('active');
	  $('.toolbar').hide();
	  $('.details-card').hide();
	  $('#filesCard').show();
	  loadFilesTable(objectId);
	});
   //Added by Ajay Bug-1059,1060 New Feature Started
	function loadFilesTable() {
		  $('#filesTable thead tr').empty();
		  $('#filesTable tbody').empty();
		  $('#noFilesMsg').hide();
		  showLoading(true);

		  $.ajax({
		    url: BASIC_URL + '/api/datafetchservice/getfilesforpartspec',
		    method: 'GET',
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

		      const tbody = $('#filesTable tbody');
		      files.forEach(function (file) {
		        let tr = '<tr>';
		        keys.forEach(function (key, idx) {
		          const value = file[key] || '';
		          if (idx === 0) {
		            tr += '<td >' + value + '</a></td>';
		          } else {
		            tr += '<td>' + value + '</td>';
		          }
		        });
		        tr += '</tr>';
		        tbody.append(tr);
		      });
		    },
		    error: function () {
		      showError('Failed to load files.');
		    },
		    complete: function () {
		      showLoading(false);
		    }
		  });
		}
	   //Added by Ajay Bug-1059,1060 New Feature Started

  
});

</script>
</body>
</html>
