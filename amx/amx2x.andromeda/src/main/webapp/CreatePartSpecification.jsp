<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Create Part Specification</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
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
    #createPartForm {
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
  </style>
</head>
<body>
  <form id="createPartForm">
    <h2>Create Part Specification</h2>

    <div class="form-body">
      <div class="mb-3">
        <label for="supertype" class="form-label">SuperType</label>
        <select id="supertype" name="SuperType" class="form-select" required>
          <option value="">Select</option>
        </select>
      </div>

      <div class="mb-3">
        <label for="type" class="form-label">Type</label>
        <select id="type" name="Type" class="form-select" required>
          <option value="">Select</option>
        </select>
      </div>

      <div class="mb-3">
        <label for="inputDescription" class="form-label">Description</label>
        <textarea id="inputDescription" name="Description" class="form-control" rows="4" placeholder="Enter description" required></textarea>
      </div>

      <div class="mb-3">
        <label for="inputResponsibleEngineer" class="form-label">Responsible Engineer</label>
        <textarea id="inputResponsibleEngineer" class="form-control" rows="1" readonly></textarea>
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
  
  document.getElementById('cancelBtn').addEventListener('click', () => {
	    if (isInIframe) {
	      window.parent.postMessage({ action: 'closeOnly' }, '*');
	    } else {
	      window.close();
	    }
	  });

  document.addEventListener('DOMContentLoaded', async () => {
	  const supertypeSelect = document.getElementById('supertype');
	  const typeSelect = document.getElementById('type');
	  const engineerInput = document.getElementById('inputResponsibleEngineer'); 
	  const descriptionInput = document.getElementById('inputDescription');
	  const form = document.getElementById('createPartForm');

	  let dropdownData = {};

	  try {
	    const res = await fetch(BASIC_URL+'/api/db/dropdowns');
	    if (!res.ok) throw new Error('Failed to load dropdown data');
	    dropdownData = await res.json();

	    if ((dropdownData.superTypes || []).includes('Document')) {
	      const option = new Option('Document', 'Document');
	      supertypeSelect.add(option);
	    }

	    const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
	    if (user && user.username) {
	      engineerInput.value = user.username;  
	    } else {
	      alert('No logged-in user. Please log in.');
	      if (isInIframe) {
	        window.parent.postMessage({ action: 'closeOnly' }, '*');
	      } else {
	        window.close();
	      }
	      return;
	    }
	  } catch (error) {
	    alert(error.message || 'Failed to load dropdown data.');
	    return;
	  }

	  supertypeSelect.addEventListener('change', () => {
	    const selectedSuper = supertypeSelect.value;
	    typeSelect.innerHTML = '<option value="">Select</option>';
	    if (selectedSuper && dropdownData.types && dropdownData.types[selectedSuper]) {
	      dropdownData.types[selectedSuper].forEach(type => {
	        const option = new Option(type, type);
	        typeSelect.add(option);
	      });
	    }
	  });

	  form.addEventListener('submit', async (e) => {
		    e.preventDefault();

		    const formData = {
		        SuperType: supertypeSelect.value.trim(),
		        Type: typeSelect.value.trim(),
		        ResponsibleEngineer: engineerInput.value.trim(),
		        Description: descriptionInput.value.trim()
		    };

		    if (!formData.SuperType || !formData.Type || !formData.Description) {
		        alert('Please fill in all required fields.');
		        return;
		    }

		    try {
		        const res = await fetch(BASIC_URL+'/api/datafetchservice/createpartspecification', {
		            method: 'POST',
		            headers: { 
		                'Content-Type': 'application/x-www-form-urlencoded',
		                'Accept': 'application/json'
		            },
		            credentials: 'include',
		            body: new URLSearchParams(formData)
		        });

		        const result = await res.json();

		        if (!res.ok || result.Status !== 'Success') {
		            alert('Error: ' + (result.Message || 'Something went wrong'));
		            return;
		        }

		        alert('The following object was created successfully!\nSuperType: ' + formData.SuperType + '\nType: ' + formData.Type +
		              '\nName: ' + result.Name);

		        if (result.Name) {
		            const isInIframe = window.self !== window.top;
		            if (isInIframe) {
		                // Just close the popup, do nothing else
		                window.parent.postMessage({ action: 'closeOnly' }, '*');
		            } else {
		                window.close(); 
		            }
		        } else {
		            alert('Could not retrieve the Name for the new part specification.');
		        }

		    } catch (error) {
		        alert('Submission failed: ' + error.message);
		    }
		});
	});
</script>
</body>
</html>