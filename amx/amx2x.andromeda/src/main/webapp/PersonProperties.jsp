<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Person Properties</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
  * { box-sizing: border-box; }

  body {
    font-family: 'Inter', Arial, sans-serif;
    padding: 24px;
    background-color: #f7f9fa;
    margin: 0;
  }

  /* ===== PROFILE HEADER CARD ===== */
  .profile-header {
    background: linear-gradient(135deg, #1f2937 0%, #374151 100%);
    border-radius: 14px;
    padding: 24px 28px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
  }

  .profile-left {
    display: flex;
    align-items: center;
    gap: 18px;
  }

  .profile-avatar {
    width: 64px;
    height: 64px;
    border-radius: 50%;
    background: rgba(255,255,255,0.15);
    border: 2px solid rgba(255,255,255,0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    font-weight: 700;
    color: #ffffff;
    letter-spacing: 1px;
    flex-shrink: 0;
  }

  .profile-title h2 {
    margin: 0 0 4px 0;
    font-size: 20px;
    font-weight: 700;
    color: #ffffff;
  }

  .profile-title p {
    margin: 0;
    font-size: 13px;
    color: rgba(255,255,255,0.65);
  }

  .profile-actions {
    display: flex;
    gap: 10px;
  }

  .profile-actions button {
    background: rgba(255,255,255,0.12);
    border: 1px solid rgba(255,255,255,0.25);
    color: #ffffff;
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    transition: all 0.15s ease;
  }

  .profile-actions button:hover {
    background: rgba(255,255,255,0.22);
  }

  .profile-actions button i { font-size: 13px; }

  /* ===== DETAILS CARD ===== */
  .details-card {
    background: #ffffff;
    border-radius: 14px;
    border: 1px solid #e2e5e9;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  }

  .detail-row {
    display: flex;
    align-items: center;
    padding: 14px 20px;
    border-bottom: 1px solid #f1f5f9;
    gap: 16px;
    transition: background 0.15s;
  }

  .detail-row:last-child { border-bottom: none; }
  .detail-row:hover { background: #f8fafc; }

  .detail-icon {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    background: #f1f5f9;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #4b5563;
    font-size: 14px;
    flex-shrink: 0;
  }

  .detail-label {
    font-size: 13px;
    font-weight: 600;
    color: #374151;
    width: 120px;
    flex-shrink: 0;
  }

  .detail-separator {
    color: #d1d5db;
    font-size: 13px;
    margin-right: 8px;
  }

  .detail-value {
    font-size: 13px;
    color: #111827;
    flex: 1;
  }

  .detail-value.email { color: #2563eb; }

  .badge-access {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 3px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
    border: 1.5px solid transparent;
  }
  .badge-reader  { background: #e8f0f7; color: #005686; border-color: #b3cfe8; }
  .badge-author  { background: #fff4e5; color: #b76e00; border-color: #f5c98a; }
  .badge-leader  { background: #e6f4ea; color: #1e7e34; border-color: #a8d5b0; }
  .badge-admin   { background: #fde8e8; color: #c0392b; border-color: #f5b0aa; }
  .badge-default { background: #f1f3f5; color: #626974; border-color: #d1d5db; }

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
  .error {
    color: #c0392b;
    margin-top: 20px;
    text-align: center;
    font-size: 13px;
  }

  /* ===== EDIT PANEL ===== */
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
 .btn-save {
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
  .btn-save:hover { background: #1f2937; }

  .btn-cancel {
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
  .btn-cancel:hover { background: #e5e7eb; }
  
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

#editForm .form-control[readonly],
#editForm .form-control:disabled {
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

</head>

<body>

  <div class="profile-header">
    <div class="profile-left">
      <div class="profile-avatar" id="profileAvatar">--</div>
      <div class="profile-title">
        <h2 id="personName">Person Details</h2>
        <p>View and manage person information</p>
      </div>
    </div>
    <div class="profile-actions">
      <button id="editBtn" style="display:none;">
        <i class="bi bi-pencil-fill"></i> Edit
      </button>
      <button id="refreshBtn">
        <i class="bi bi-arrow-clockwise"></i> Refresh
      </button>
    </div>
  </div>

  <div id="loadingSpinner"></div>
  <div id="errorMessage" class="error"></div>

  <div class="details-card" id="detailsCard"></div>

  <div id="editPanel">
  <div class="edit-modal">
    <h5>Edit Person Details</h5>
    <div class="edit-form-body">
      <form id="editForm"></form>
    </div>
    <div class="edit-footer">
    
     <button type="button" class="btn-save" id="saveBtn">
        Save 
    </button>
    <button type="button" class="btn-cancel" id="cancelBtn">
        Cancel
    </button>
</div>
	</div>
	</div>
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  
  const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
  const loggedInUserAccess = user?.access || '';
  const loggedInUserName = user?.username || '';
  
    const BASIC_URL = '<%= request.getContextPath() %>';

    let originalPersonData = {};
    let accessOptions = [];

    const fieldIcons = {
      username:  'bi-person-fill',
      firstname: 'bi-person',
      lastname:  'bi-person',
      country:   'bi-globe',
      email:     'bi-envelope-fill',
      access:    'bi-shield-lock-fill'
    };

    function getBadgeClass(access) {
      const map = { reader: 'badge-reader', author: 'badge-author', leader: 'badge-leader', admin: 'badge-admin' };
      return map[(access || '').toLowerCase()] || 'badge-default';
    }

    function prettyLabel(key) {
      const map = {
        firstname: 'First Name', lastname: 'Last Name',
        country: 'Country', username: 'Username',
        email: 'Email', access: 'Access'
      };
      return map[key] || key.charAt(0).toUpperCase() + key.slice(1);
    }

    function getInitials(person) {
      const f = (person.Firstname || '').charAt(0).toUpperCase();
      const l = (person.Lastname || '').charAt(0).toUpperCase();
      return f + l || '??';
    }

    function populateCard(person) {
      $('#profileAvatar').text(getInitials(person));
      const fullName =(person.Firstname || '') + ' ' + (person.Lastname || '');

    	$('#personName').text(fullName.trim() || 'Person Details');
      const card = $('#detailsCard');
      card.empty();

      const order = ['Username', 'Firstname', 'Lastname', 'Country', 'Email', 'Access'];
      order.forEach(function(key) {
        if (!(key in person)) return;
        const lowerKey = key.toLowerCase();
        const value = person[key] ?? 'N/A';
        const icon = fieldIcons[lowerKey] || 'bi-circle';
        const label = prettyLabel(lowerKey);

        let valueHtml;
        if (lowerKey === 'email') {
          valueHtml = '<span class="detail-value email">' + value + '</span>';
        } else if (lowerKey === 'access') {
          const cls = getBadgeClass(value);
          valueHtml = '<span class="badge-access ' + cls + '">' + value + '</span>';
        } else {
          valueHtml = '<span class="detail-value">' + value + '</span>';
        }

        card.append(`
                <div class="detail-row">
                  <div class="detail-icon"><i class="bi \${icon}"></i></div>
                  <div class="detail-label">\${label}</div>
                  <span class="detail-separator">:</span>
                  \${valueHtml}
                </div>
              `);
      });

      $('#errorMessage').hide();
    }

    $(document).ready(function () {
      const objectId = getQueryParam('name');
      if (!objectId) {
        showError("No 'name' parameter found in the URL.");
        return;
      }

      showLoading(true);

      $.ajax({
        url: BASIC_URL + '/api/datafetchservice/persons',
        method: 'GET',
        dataType: 'json',
        success: function (data) {
          const person = data.find(p => p.ObjectId === objectId);
          if (!person) { showError('No person found.'); return; }
          originalPersonData = { ...person };
          populateCard(person);
          if (loggedInUserAccess.trim().toLowerCase() === 'admin') $('#editBtn').show();
        },
        error: function () { showError('Error fetching person details.'); },
        complete: function () { showLoading(false); }
      });

      $.ajax({
        url: BASIC_URL + '/api/datafetchservice/personaccess',
        method: 'GET',
        dataType: 'json',
        success: function (data) { accessOptions = data || []; },
        error: function () { alert('Failed to load access options.'); }
      });

      $('#editBtn').on('click', function () {
        if (!$.isEmptyObject(originalPersonData)) openEditPanel(originalPersonData);
        else alert('Data not loaded yet.');
      });

      $('#cancelBtn').on('click', closeEditPanel);

      $('#saveBtn').on('click', function () {
        const objectId = getQueryParam('name');
        const updatedData = {};
        $('#editForm').serializeArray().forEach(({ name, value }) => { updatedData[name] = value; });

        $.ajax({
          url: BASIC_URL + '/api/datafetchservice/updatePerson/' + encodeURIComponent(objectId),
          method: 'PUT',
          contentType: 'application/json',
          data: JSON.stringify(updatedData),
          success: function () { alert('Updated successfully!'); location.reload(); },
          error: function (xhr) { alert('Error: ' + xhr.responseText); }
        });
        closeEditPanel();
      });

      $('#refreshBtn').on('click', function () { location.reload(); });
    });

    function openEditPanel(person) {
      const form = $('#editForm');
      form.empty();
      let readonlyFields =[] ;
      if(person.Username === loggedInUserName){
    	  readonlyFields=['username'];
      }
      else{
    	  readonlyFields = ['username','firstname','lastname','country','email'];
      }
      

      for (const key in person) {
        if (!person.hasOwnProperty(key) || key === 'ObjectId') continue;
        const value = person[key] ?? '';
        const safeId = 'edit_' + key.replace(/[^a-zA-Z0-9]/g, '_');
        const lowerKey = key.toLowerCase();
        const label = prettyLabel(lowerKey);
        const formGroup = $('<div class="mb-3"></div>');
        formGroup.append($('<label></label>').addClass('form-label').attr('for', safeId).text(label));

        if (lowerKey === 'access') {
          const select = $('<select></select>').addClass('form-control').attr({ id: safeId, name: lowerKey });
          accessOptions.forEach(opt => {
            const option = $('<option></option>').attr('value', opt).text(opt);
            if (opt === value) option.attr('selected', true);
            select.append(option);
          });
          if (readonlyFields.includes(lowerKey)) select.prop('disabled', true);
          formGroup.append(select);
        } else {
          const input = $('<input>').attr('type', 'text').addClass('form-control')
            .attr({ id: safeId, name: lowerKey }).val(value);
          if (readonlyFields.includes(lowerKey)) input.prop('readonly', true);
          formGroup.append(input);
        }
        form.append(formGroup);
      }
      $('#editPanel').addClass('active');
    }

    function closeEditPanel() { $('#editPanel').removeClass('active'); }
    function getQueryParam(param) { return new URLSearchParams(window.location.search).get(param); }
    function showLoading(show) { $('#loadingSpinner').css('display', show ? 'block' : 'none'); }
    function showError(msg) { $('#errorMessage').text(msg).show(); showLoading(false); }
  </script>
</body>

</html>
