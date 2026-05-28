<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Create MPN</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>

  <style>
    body {
      margin: 0;
      background-color: #f9f9f9;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: flex-start;
    }

    #createMPNForm {
      width: 100%;
      max-width: 600px;
      padding: 30px;
      background-color: white;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
      display: flex;
      flex-direction: column;
      gap: 10px;
      overflow-y: auto;
    }

    h2 {
      margin-bottom: 15px;
      color: #333;
      font-size: 22px;
      font-weight: bold;
    }

    label {
      font-weight: 600;
      color: #555;
    }

    textarea,
    select,
    input {
      margin-bottom: 10px;
      padding: 8px;
      border-radius: 5px;
      border: 1px solid #ccc;
      font-size: 14px;
    }

    textarea:focus,
    select:focus,
    input:focus {
      border-color: #00afc4;
      box-shadow: 0 0 0 0.2rem rgba(0, 175, 196, 0.25);
      outline: none;
    }

    .d-flex {
      display: flex;
      justify-content: flex-end;
    }

    .d-flex .btn {
      margin-left: 5px;
      padding: 8px 16px;
      font-size: 14px;
    }

    .mb-3 {
      margin-bottom: 10px;
    }

    #inputDescription {
      min-height: 80px;
      font-family: Arial, sans-serif;
      font-size: 14px;
      resize: vertical;
    }

    #inputResponsibleEngineer {
      height: 30px;
      resize: vertical;
    }

    button {
      padding: 8px 16px;
      border-radius: 5px;
      font-size: 14px;
      cursor: pointer;
    }

    button[type="submit"] {
      background-color: #00afc4;
      color: white;
      border: none;
    }

    button[type="button"].btn-secondary {
      background-color: #6c757d;
      color: white;
    }

    button:hover {
      opacity: 0.9;
    }

    button[type="submit"]:hover {
      background-color: #007c8d;
    }

    button[type="button"].btn-secondary:hover {
      background-color: #5a6268;
    }

    @media screen and (max-width: 768px) {
      #createMPNForm {
        padding: 20px;
        width: 100%;
      }
    }

    .mfg-search-wrapper {
      position: relative;
      display: flex;
      align-items: center;
    }

    .mfg-search-wrapper .search-icon {
  position: absolute;
  left: 10px;
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  color: #aaa;
  display: flex;
  align-items: center;
}

    .mfg-search-wrapper .search-icon svg {
      width: 16px;
      height: 16px;
      stroke: currentColor;
      fill: none;
      stroke-width: 2;
      stroke-linecap: round;
      stroke-linejoin: round;
    }

    .mfg-search-wrapper #manufacturerInput {
      padding-left: 34px;  
      width: 100%;
      margin-bottom: 0;
    }

    .mfg-search-wrapper #manufacturerInput:focus + .search-icon,
    .mfg-search-wrapper #manufacturerInput:focus ~ .search-icon {
      color: #00afc4;
    }

    .mfg-search-wrapper:focus-within .search-icon {
      color: #00afc4;
    }

    .mfg-clear-btn {
      position: absolute;
      right: 10px;
      top: 50%;
      transform: translateY(-50%);
      background: none;
      border: none;
      cursor: pointer;
      padding: 0;
      color: #aaa;
      display: none;
      align-items: center;
      line-height: 1;
    }

    .mfg-clear-btn:hover {
      color: #555;
      opacity: 1;
    }

    .mfg-clear-btn svg {
      width: 14px;
      height: 14px;
      stroke: currentColor;
      fill: none;
      stroke-width: 2.5;
      stroke-linecap: round;
    }

    .ui-autocomplete {
      font-family: Arial, sans-serif;
      font-size: 14px;
      border: 1px solid #ccc;
      border-radius: 5px;
      max-height: 200px;
      overflow-y: auto;
      overflow-x: hidden;
    }

    .ui-menu-item-wrapper {
      padding: 8px 12px !important;
    }

    .ui-state-active,
    .ui-widget-content .ui-state-active {
      background: #00afc4 !important;
      border-color: #00afc4 !important;
      color: white !important;
    }
  </style>
</head>
<body>
  <form id="createMPNForm">
    <h2>Create MPN</h2>

    <div class="mb-3">
      <label for="supertype" class="form-label">Super Type</label>
      <input type="text" id="supertype" name="supertype" class="form-control"
             value="ManufacturerPartAssembly" readonly />
    </div>

    <div class="mb-3">
      <label for="type" class="form-label">Type</label>
      <input type="text" id="type" name="type" class="form-control"
             value="ManufacturerPart" readonly />
    </div>

    <div class="mb-3">
      <label for="mpnTitle" class="form-label">MPN Title</label>
      <input type="text" id="mpnTitle" name="mpnTitle" class="form-control"
             placeholder="Enter MPN Title" required />
    </div>

    <div class="mb-3">
      <label for="manufacturerInput" class="form-label">Manufacturer</label>
      <div class="mfg-search-wrapper">
        <!-- Search icon (left) -->
        <span class="search-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <circle cx="11" cy="11" r="7"></circle>
            <line x1="16.5" y1="16.5" x2="22" y2="22"></line>
          </svg>
        </span>
        <!-- Visible typeahead input -->
        <input type="text" id="manufacturerInput" class="form-control"
               placeholder="Search manufacturer..." autocomplete="off" required />
        <!-- Clear button (right) -->
        <button type="button" class="mfg-clear-btn" id="mfgClearBtn" title="Clear" tabindex="-1">
          <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
      <input type="hidden" id="manufacturer" name="manufacturer" />
    </div>

    <div class="mb-3">
      <label for="inputDescription" class="form-label">Description</label>
      <textarea id="inputDescription" class="form-control" rows="4"
                placeholder="Enter description" required></textarea>
    </div>

    <div class="mb-3">
      <label for="inputResponsibleEngineer" class="form-label">Responsible Engineer</label>
      <textarea id="inputResponsibleEngineer" class="form-control" rows="1" readonly></textarea>
    </div>

    <div class="d-flex justify-content-end gap-2">
      <button type="submit" class="btn btn-primary">Submit</button>
      <button type="button" class="btn btn-secondary" onclick="window.close()">Cancel</button>
    </div>
  </form>

  <script>
  
  const BASIC_URL = '<%= request.getContextPath() %>';
    $(document).ready(function () {

      const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
      if (user) {
        $('#inputResponsibleEngineer').val(user.username || '');
      } else {
        alert('No logged-in user. Please log in.');
        window.close();
      }

      const $mfgInput   = $('#manufacturerInput');
      const $mfgHidden  = $('#manufacturer');
      const $clearBtn   = $('#mfgClearBtn');

      function toggleClear() {
        $clearBtn.css('display', $mfgInput.val() ? 'flex' : 'none');
      }

      $mfgInput.on('input', toggleClear);

      $clearBtn.on('click', function () {
    	  $mfgInput.val('');
    	  $mfgHidden.val('');
    	  toggleClear();
    	  $mfgInput.focus();
    	});

      $('.search-icon').on('click', function (e) {
    	  e.preventDefault();
    	  e.stopPropagation();
    	  const term = $mfgInput.val().trim();
    	  $mfgInput.autocomplete('option', 'minLength', 0);
    	  $mfgInput.autocomplete('search', term);
    	});
      
      $mfgInput.autocomplete({
        minLength: 3,

        source: function (request, response) {
        	  $.ajax({
        	    url:BASIC_URL+'/api/db/manufacturers',
        	    method: 'GET',
        	    dataType: 'json',
        	    data: { search: request.term },
        	    success: function (data) {
        	      response(data);
        	      $mfgInput.autocomplete('option', 'minLength', 3);
        	    },
        	    error: function () {
        	      console.warn('Failed to load manufacturers');
        	      response([]);
        	      $mfgInput.autocomplete('option', 'minLength', 3);
        	    }
        	  });
        	},

        	select: function (event, ui) {
        		  if (!ui.item.value) return false;
        		  $mfgInput.val(ui.item.value);
        		  $mfgHidden.val(ui.item.value);
        		  toggleClear();
        		  return false;
        		},

        		response: function (event, ui) {
        		  if (!ui.content.length) {
        		    ui.content.push({ value: '', label: 'No manufacturers found' });
        		  }
        		},

      });

      $('#createMPNForm').on('submit', async function (e) {
        e.preventDefault();

        if (!$mfgHidden.val().trim()) {
          alert('Please select a manufacturer from the list.');
          $mfgInput.focus();
          return;
        }

        const formData = {
          SuperType:           $('#supertype').val().trim(),
          Type:                $('#type').val().trim(),
          MPNTitle:            $('#mpnTitle').val().trim(),
          Manufacturer:        $mfgHidden.val().trim(),
          Description:         $('#inputDescription').val().trim(),
          ResponsibleEngineer: $('#inputResponsibleEngineer').val().trim()
        };

        if (!formData.SuperType || !formData.Type || !formData.MPNTitle ||
            !formData.Manufacturer || !formData.Description) {
          alert('Please fill in all required fields.');
          return;
        }

        try {
          const res = await fetch(BASIC_URL+'/api/navigatorutilites/createMPN', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            credentials: 'include',
            body: new URLSearchParams(formData)
          });

          const result = await res.json();

          if (!res.ok || result.Status !== 'Success') {
            alert('Error: ' + (result.Message || 'Something went wrong'));
            return;
          }

          alert(
            'The following MPN was created successfully!\n' +
            'SuperType: '   + formData.SuperType  + '\n' +
            'Type: '        + formData.Type        + '\n' +
            'MPN Title: '   + formData.MPNTitle    + '\n' +
            'Manufacturer: ' + formData.Manufacturer
          );

          const objectId = result.ObjectId;
          if (objectId) {
            if (window.opener && window.opener.loadMPNPropertiesInIframe) {
              window.opener.loadMPNPropertiesInIframe(objectId);
            }
            window.close();
          } else {
            alert('Could not retrieve the ID for the new MPN.');
          }

        } catch (error) {
          alert('Submission failed: ' + error.message);
        }
      });
    });
  </script>
</body>
</html>
