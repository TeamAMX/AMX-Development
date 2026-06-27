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
    /* Reset and Base Styles */
    * { box-sizing: border-box; margin: 0; padding: 0; }

    html, body {
        height: 100%;
        overflow: hidden; /* Prevents the whole page from scrolling */
        font-family: 'Inter', -apple-system, sans-serif;
        margin: 0;
        background: transparent;
    }

    /* The Main Container */
    #createMPNForm {
        width: 100%;
        height: 100vh; /* Forces the form to be exactly the height of the iframe/window */
        background: #ffffff;
        border-radius: 18px;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }

    /* Fixed Header */
    h2 {
        margin: 0;
        padding: 24px 30px 16px;
        font-size: 24px;
        font-weight: 700;
        border-bottom: 1px solid #eef2f7;
        color: #111827;
        flex: 0 0 auto; /* Tells flexbox: DO NOT grow, DO NOT shrink */
        background: #ffffff;
        z-index: 10;
    }

    /* Scrollable Body */
    .form-body {
        flex: 1 1 auto; /* Grow and shrink as needed */
        min-height: 0; /* CRITICAL: Forces flexbox to allow shrinking, triggering the scrollbar */
        overflow-y: auto; /* Adds the scrollbar when content overflows */
        padding: 24px 30px;
        display: flex;
        flex-direction: column;
        gap: 18px;
    }

    /* Custom Scrollbar */
    .form-body::-webkit-scrollbar {
        width: 8px;
    }
    .form-body::-webkit-scrollbar-track {
        background: transparent;
    }
    .form-body::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 10px;
    }
    .form-body::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
    }

    /* Fixed Footer */
    .form-footer {
        padding: 16px 30px;
        border-top: 1px solid #eef2f7;
        background: #ffffff; 
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        flex: 0 0 auto; /* Tells flexbox: DO NOT grow, DO NOT shrink */
        z-index: 10;
    }

    /* Buttons (Black/Grey Theme) */
    .btn-submit {
        min-width: 110px;
        padding: 0 20px;
        height: 40px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        background: #0f172a; /* Dark Slate/Black */
        color: white;
        transition: background 0.2s;
    }
    .btn-submit:hover { background: #334155; }

    .btn-cancel {
        min-width: 110px;
        height: 40px;
        padding: 0 20px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        background: #f1f5f9; /* Light Grey */
        color: #475569;
        border: none;
        transition: background 0.2s;
    }
    .btn-cancel:hover { background: #e2e8f0; }

    /* Inputs & Labels */
    .mb-3 { margin-bottom: 0; }

    label {
        font-size: 13px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 6px;
        display: block;
    }

    select, textarea, input {
        background-color: #f8fafc !important;
        border: 1px solid #cbd5e1 !important;
        color: #0f172a !important;
        border-radius: 6px !important;
        padding: 10px 14px !important;
        font-size: 14px !important;
        transition: all 0.2s ease;
        width: 100%;
    }

    /* Grey focus rings instead of blue/cyan */
    select:focus, textarea:focus, input:focus { 
        border-color: #6b7280 !important; 
        box-shadow: 0 0 0 3px rgba(0, 0, 0, 0.1) !important;
        outline: none;
    }

    /* Manufacturer Search Wrapper Styles */
    .mfg-search-wrapper {
      position: relative;
      display: flex;
      align-items: center;
    }

    .mfg-search-wrapper .search-icon {
      position: absolute;
      left: 14px;
      top: 50%;
      transform: translateY(-50%);
      cursor: pointer;
      color: #94a3b8;
      display: flex;
      align-items: center;
      transition: color 0.2s;
      z-index: 5;
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
      padding-left: 40px !important;  
      width: 100%;
      margin-bottom: 0;
    }

    /* Dark grey active state for search icon */
    .mfg-search-wrapper #manufacturerInput:focus + .search-icon,
    .mfg-search-wrapper #manufacturerInput:focus ~ .search-icon,
    .mfg-search-wrapper:focus-within .search-icon {
      color: #0f172a;
    }

    .mfg-clear-btn {
      position: absolute;
      right: 14px;
      top: 50%;
      transform: translateY(-50%);
      background: none;
      border: none;
      cursor: pointer;
      padding: 0;
      color: #94a3b8;
      display: none;
      align-items: center;
      line-height: 1;
      transition: color 0.2s;
      z-index: 5;
    }

    .mfg-clear-btn:hover {
      color: #0f172a;
    }

    .mfg-clear-btn svg {
      width: 14px;
      height: 14px;
      stroke: currentColor;
      fill: none;
      stroke-width: 2.5;
      stroke-linecap: round;
    }

    /* Autocomplete Dropdown Styling */
    .ui-autocomplete {
      font-family: 'Inter', -apple-system, sans-serif;
      font-size: 13px;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      max-height: 200px;
      overflow-y: auto;
      overflow-x: hidden;
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
    }

    .ui-menu-item-wrapper {
      padding: 10px 14px !important;
    }

    /* Dark grey active selection instead of Cyan */
    .ui-state-active,
    .ui-widget-content .ui-state-active {
      background: #0f172a !important;
      border-color: #0f172a !important;
      color: white !important;
      border-radius: 4px;
    }
    
    /* ===== Responsible Engineer Search Dropdown ===== */
    .re-wrapper {
        position: relative;
        width: 100%;
    }

    .re-search-box {
        display: block;
        position: relative;
        width: 100%;
        background: #ffffff;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        box-shadow: none;
        z-index: 1;
        overflow: hidden;
    }

    .re-search-input-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 14px;
        border-bottom: 1px solid #e2e8f0;
    }

    .re-search-input-wrap svg {
        flex-shrink: 0;
        color: #94a3b8;
    }

    .re-search-input-wrap input {
        border: none !important;
        background: transparent !important;
        box-shadow: none !important;
        padding: 0 !important;
        font-size: 14px !important;
        color: #0f172a !important;
        width: 100%;
        outline: none;
    }

    .re-list {
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.2s ease;
    }

    .re-search-box.open .re-list {
        max-height: 200px;
        overflow-y: auto;
    }

    .re-list-item {
        padding: 6px 16px;
        font-size: 14px;
        color: #0f172a;
        cursor: pointer;
        transition: background 0.15s;
    }

    .re-list-item:hover {
        background: #f1f5f9;
    }

    .re-list-item.no-results {
        color: #94a3b8;
        cursor: default;
    }

    .re-list::-webkit-scrollbar { width: 6px; }
    .re-list::-webkit-scrollbar-track { background: transparent; }
    .re-list::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
    
    
  </style>
</head>
<body>
  <form id="createMPNForm">
    <h2>Create MPN</h2>

    <div class="form-body">
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
          <span class="search-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <circle cx="11" cy="11" r="7"></circle>
              <line x1="16.5" y1="16.5" x2="22" y2="22"></line>
            </svg>
          </span>
          <input type="text" id="manufacturerInput" class="form-control"
                 placeholder="Search manufacturer..." autocomplete="off" required />
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
        <label for="reSearchInput" class="form-label">Responsible Engineer</label>
        <div class="re-wrapper">
          <div class="re-search-box" id="reSearchBox">
            <div class="re-search-input-wrap">
              <svg id="reSearchIcon" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="cursor:pointer;">
                <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
              </svg>
              <input type="text" id="reSearchInput" placeholder="Search Responsible Engineer..." autocomplete="off"/>
            </div>
            <div class="re-list" id="reList"></div>
          </div>
          <input type="hidden" id="inputResponsibleEngineer" name="ResponsibleEngineer"/>
        </div>
      </div>
    </div>

    <div class="form-footer">
      <button type="button" class="btn-cancel" id="cancelBtn">Cancel</button>
      <button type="submit" class="btn-submit">Submit</button>
    </div>
  </form>

  <script>
    const BASIC_URL = '<%= request.getContextPath() %>';
    const isInIframe = window.self !== window.top;
    
    $(document).ready(async function () {

      // Cancel button logic integrated for iframe handling
      $('#cancelBtn').on('click', function() {
        if (isInIframe) {
          window.parent.postMessage({ action: 'closeOnly' }, '*');
        } else {
          window.close();
        }
      });
	
     const user = JSON.parse(sessionStorage.getItem('loggedInUser'));// BUG_1035 Fix  by koushik
      if (user) {
        $('#inputResponsibleEngineer').val(user.username || '');
      } else {
        alert('No logged-in user. Please log in.');
        if (isInIframe) {
          window.parent.postMessage({ action: 'closeOnly' }, '*');
        } else {
          window.close();
        }
        return;
      }

      // BUG_1035 Fix started by koushik
      let allEngineers = [];
      try {
        const personsRes = await fetch(BASIC_URL + '/api/datafetchservice/persons');
        if (personsRes.ok) {
          const persons = await personsRes.json();
          allEngineers = persons.map(p => p.Username || p.username).filter(Boolean);
        }
      } catch (err) {
        console.warn('Could not load engineers:', err);
      }

      const reSearchBox   = document.getElementById('reSearchBox');
      const reSearchInput = document.getElementById('reSearchInput');
      const reList        = document.getElementById('reList');
      const engineerInput = document.getElementById('inputResponsibleEngineer');

      function renderList(filter) {
        const filtered = filter ? allEngineers.filter(u => u.toLowerCase().includes(filter.toLowerCase())): allEngineers;
        reList.innerHTML = '';
        if (filtered.length === 0) {
          reList.innerHTML = '<div class="re-list-item no-results">No results found</div>';
          return;
        }
        filtered.forEach(name => {
          const item = document.createElement('div');
          item.className = 're-list-item';
          item.textContent = name;
          item.addEventListener('click', () => {
            engineerInput.value = name;
            reSearchInput.value = name;
            reList.innerHTML = '';
            reSearchBox.classList.remove('open');
          });
          reList.appendChild(item);
        });
      }

      document.getElementById('reSearchIcon').addEventListener('click', () => {
        renderList('');
        reSearchBox.classList.add('open');
        reSearchInput.focus();
      });

      reSearchInput.addEventListener('input', () => {
        const val = reSearchInput.value;
        if (val.length === 0) {
          reSearchBox.classList.remove('open');
          reList.innerHTML = '';
        } else if (val.length >= 3) {
          renderList(val);
          reSearchBox.classList.add('open');
        }
      });

      document.addEventListener('click', (e) => {
        if (!e.target.closest('.re-wrapper')) {
          reSearchBox.classList.remove('open');
        }
      });

      // Pre-fill search input
      if (user && user.username) {
        reSearchInput.value = user.username;
      }
	// BUG_1035 Fix ended by koushik
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
        	    url: BASIC_URL+'/api/db/manufacturers',
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
            const isInIframe = window.self !== window.top;
            if (isInIframe) {
              // Send message to load MPNProperties.jsp
              window.parent.postMessage({
                  action: 'loadProperties',
                  type: 'mpn',
                  id: objectId  
              }, '*');
            } else {
              window.close();
            }
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