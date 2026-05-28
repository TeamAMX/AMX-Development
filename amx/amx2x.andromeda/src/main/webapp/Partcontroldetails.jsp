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
<title>Part Control Details</title>
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

  /* ===== DETAILS CARD — 2 column grid ===== */
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
    background: #1f2937;
    color: white;
    border: none;
    padding: 8px 20px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
  }
  #saveBtn:hover { background: #374151; }
  #cancelBtn {
    background: #f3f4f6;
    color: #374151;
    border: none;
    padding: 8px 20px;
    border-radius: 8px;
    font-size: 13px;
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
    padding: 22px 26px;
    margin: 0;
    font-size: 28px;
    font-weight: 700;
    border-bottom: 1px solid #eef2f7;
}

.edit-form-body {
    max-height: 300px;
    overflow-y: auto;
    padding: 22px 26px;
}

.edit-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    padding: 18px 26px;
    border-top: 1px solid #eef2f7;
    background: #fafbfd;
}

#editForm .form-control {
    height: 42px;
    border-radius: 10px;
    font-size: 14px;
}

#editForm .form-label {
    margin-bottom: 6px;
    font-size: 13px;
    font-weight: 600;
    color: #6b7280;
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
      <div class="topbar-name" id="pcName">Part Control Details</div>
      <div class="topbar-type" id="pcType">PartControl</div>
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
    <a href="Partcontroldetails.jsp?name=<%= request.getParameter("name") %>" class="nav-link active"><i class="fa-solid fa-sliders"></i> PC-Properties</a>
    <a class="nav-link" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clock"></i> History</a>
    <a class="nav-link" href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
    <a class="nav-link" href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-shield-halved"></i> Part Management</a>
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
  </div>
</div>

<div id="editPanel">
  <div class="edit-modal">
    <h5>Edit Part Control Details</h5>
    <div class="edit-form-body">
      <form id="editForm"></form>
    </div>
    <div class="edit-footer">
      <button id="cancelBtn" type="button" class="btn-cancel">
        Cancel
      </button>
      <button id="saveBtn" type="button" class="btn-save">
        Save
      </button>
    </div>
  </div>
</div>

 <script>
 
 const BASIC_URL = '<%= request.getContextPath() %>';
let currentPartData = {};
let loggedInUserAccess = 'admin';  

$(document).ready(function () {
  const objectId = getQueryParam('name') || '';

  if (!objectId) {
    showError("No 'name' (ObjectId) parameter found in the URL.");
    return;
  }

  showLoading(true);

  $.ajax({
    url: BASIC_URL+'/api/datafetchservice/getinfospc',
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
      url: BASIC_URL+'/api/datafetchservice/updatepartcontrol/' + encodeURIComponent(objectId),
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
	    $('#pcName').text(data.name || 'Part Control Details');
	    $('#pcType').text((data.type || '') + (data.supertype ? ' · ' + data.supertype : ''));
	    if (data.currentstate) {
	        const state = data.currentstate;
	        const cls = state.replace(/\s/g, '');
	        $('#stateBadgeWrapper').html('<span class="state-badge ' + cls + '">' + state + '</span>');
	    }
	}
  
  function populateTable(part) {
	    const card = $('#detailsCard');
	    card.empty();
	    $('#errorMessage').hide();

	    const fieldIcons = {
	        name:         'fa-solid fa-tag',
	        description:  'fa-solid fa-align-left',
	        type:         'fa-solid fa-cube',
	        supertype:    'fa-solid fa-layer-group',
	        owner:        'fa-regular fa-user',
	        assignee:     'fa-regular fa-user',
	        email:        'fa-regular fa-envelope',
	        createddate:  'fa-regular fa-calendar',
	        modifieddate: 'fa-regular fa-calendar-check',
	        currentstate: 'fa-solid fa-circle-dot',
	        version:      'fa-solid fa-code-branch'
	    };

	    const excludedKeys = ['fts_document', 'objectid', 'historylist', 'connectionid', 'linkedobjectid'];

	    if (part.name) {
	        card.append(buildRow('name', 'Name', part.name, fieldIcons));
	    }

	    for (const key in part) {
	        if (!part.hasOwnProperty(key)) continue;
	        if (excludedKeys.includes(key.toLowerCase())) continue;
	        if (key.toLowerCase() === 'name') continue;
	        if (key.toLowerCase() === 'currentstate' && (!part[key] || part[key].trim() === '')) continue;
	        const label = prettyLabel(key.toLowerCase());
	        card.append(buildRow(key.toLowerCase(), label, part[key] ?? 'N/A', fieldIcons));
	    }
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
});
</script>
</body>
</html>
