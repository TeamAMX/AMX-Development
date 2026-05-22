<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Create Part</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }

body {
    font-family: 'Inter', sans-serif;
    margin: 0;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background: transparent;
}

body::before {
    content: "";
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.10);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    z-index: -1;
}

#createPartForm {
    width: 100%;
    max-width: 560px;
    max-height: 82vh;
    overflow-y: auto;
    background: #ffffff;
    border-radius: 18px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 25px 60px rgba(0,0,0,0.18);
    display: flex;
    flex-direction: column;
    padding: 0;
}

h2 {
    margin: 0;
    padding: 22px 24px;
    font-size: 1.15rem;
    font-weight: 700;
    border-bottom: 1px solid #e5e7eb;
    background: #ffffff;
    border-radius: 18px 18px 0 0;
}

.form-body {
    overflow-y: auto;
    padding: 22px 24px;
    max-height: calc(82vh - 140px);
    display: flex;
    flex-direction: column;
    gap: 14px;
}

label {
    font-size: 12px;
    font-weight: 600;
    color: #6b7280;
    margin-bottom: 6px;
    display: block;
}

textarea,
select,
input {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    font-size: 13px;
    font-family: 'Inter', sans-serif;
}

textarea:focus, select:focus, input:focus {
    border-color: #368ec4;
    box-shadow: 0 0 0 3px rgba(54, 142, 196, 0.15);
    outline: none;
}

input[readonly], textarea[readonly] {
    background-color: #f3f4f6;
    color: #6b7280;
}

#inputDescription { min-height: 80px; resize: vertical; }
#inputResponsibleEngineer { height: 38px; resize: none; }

.form-footer {
    padding: 16px 24px;
    border-top: 1px solid #e5e7eb;
    background: #fafbfc;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    border-radius: 0 0 18px 18px;
}

.btn-submit {
    min-width: 110px;
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 0.9rem;
    font-weight: 600;
    border: none;
    cursor: pointer;
    background: #111827;
    color: white;
}

.btn-submit:hover { background: #1f2937; }

.btn-cancel {
    min-width: 110px;
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 0.9rem;
    font-weight: 600;
    cursor: pointer;
    background: #f3f4f6;
    color: #374151;
    border: 1px solid #d1d5db;
}

.btn-cancel:hover { background: #e5e7eb; }

.mb-3 { margin-bottom: 0; }
</style>
</head>
<body>
   <form id="createPartForm">
    <h2>Create Part</h2>

    <div class="form-body">
      <div class="mb-3">
        <label for="supertype">SuperType</label>
        <select id="supertype" name="supertype" class="form-select" required>
          <option value="">Select</option>
        </select>
      </div>
      <div class="mb-3">
        <label for="type">Type</label>
        <select id="type" name="type" class="form-select" required>
          <option value="">Select</option>
        </select>
      </div>
      <div class="mb-3">
        <label for="APN">APN</label>
        <select id="APN" name="APN" class="form-select" required>
          <option value="">Select</option>
        </select>
      </div>
      <div class="mb-3" id="subtype-container" style="display:none;">
        <label for="subtype">Subtype</label>
        <select id="subtype" name="subtype" class="form-select">
          <option value="">Select</option>
        </select>
      </div>
      <div class="mb-3" id="variant-container" style="display:none;">
        <label for="variant">Variant</label>
        <select id="variant" name="variant" class="form-select">
          <option value="">Select</option>
        </select>
      </div>
      <div class="mb-3">
        <label for="inputDescription">Description</label>
        <textarea id="inputDescription" class="form-control" rows="4" placeholder="Enter description" required></textarea>
      </div>
      <div class="mb-3">
        <label for="inputResponsibleEngineer">Responsible Engineer</label>
        <textarea id="inputResponsibleEngineer" class="form-control" rows="1" readonly></textarea>
      </div>
    </div>

    <div class="form-footer">
      <button type="button" class="btn-cancel" onclick="window.close()">Cancel</button>
      <button type="submit" class="btn-submit">Submit</button>
    </div>
  </form>

  <script>
    window.addEventListener('DOMContentLoaded', async () => {
      const supertypeSelect = document.getElementById('supertype');
      const typeSelect = document.getElementById('type');
      const apnSelect = document.getElementById('APN');
       const subtypeContainer = document.getElementById('subtype-container');
      const variantContainer = document.getElementById('variant-container');
      const descriptionInput = document.getElementById('inputDescription');
      const engineerInput = document.getElementById('inputResponsibleEngineer');
      const form = document.getElementById('createPartForm');

      let dropdownData = {};

      // Load dropdown data
      try {
        const response = await fetch('http://localhost:8080/andromeda/api/db/dropdowns');
        dropdownData = await response.json();

        dropdownData.superTypes = dropdownData.superTypes || [];

        supertypeSelect.innerHTML = '<option value="">Select</option>';

        if (dropdownData.superTypes.includes('Part')) {
          const option = new Option('Part', 'Part');
          supertypeSelect.add(option);
        }


        supertypeSelect.addEventListener('change', () => {
          const selectedSuper = supertypeSelect.value;
          typeSelect.innerHTML = '<option value="">Select</option>';
          apnSelect.innerHTML = '<option value="">Select</option>';
          subtypeContainer.style.display = 'none';
          variantContainer.style.display = 'none';
          descriptionInput.value = '';

          if (selectedSuper && dropdownData.types[selectedSuper]) {
            dropdownData.types[selectedSuper].forEach(type => {
              const option = new Option(type, type);
              typeSelect.add(option);
            });
          }
        });

        	  typeSelect.addEventListener('change', () => {
        	  const selectedType = typeSelect.value.trim().toLowerCase();
        	  apnSelect.innerHTML = '<option value="">Select</option>';
        	  document.getElementById('subtype').innerHTML = '<option value="">Select</option>';
        	  document.getElementById('variant').innerHTML = '<option value="">Select</option>';
        	  document.getElementById('subtype-container').style.display = 'none';
        	  document.getElementById('variant-container').style.display = 'none';
        	  descriptionInput.value = '';

        	  // Populate APN dropdown
        	  const normalizedKey = selectedType.replace(/\s+/g, '').toLowerCase();
        	  const apnList = dropdownData.apn && dropdownData.apn[normalizedKey];

        	  if (Array.isArray(apnList)) {
        	    apnList.forEach(apnWithLabel => {
        	      const option = new Option(apnWithLabel, apnWithLabel);
        	      apnSelect.add(option);
        	    });
        	  }

        	  if (selectedType === 'fastener') {
        		    document.getElementById('subtype-container').style.display = 'block';
        		    document.getElementById('variant-container').style.display = 'block';
        		}
        	});

			 apnSelect.addEventListener('change', () => {
        	  const selectedType = typeSelect.value.trim().toLowerCase();
        	  const selectedAPN = apnSelect.value;

        	  if (selectedType === 'fastener' && selectedAPN) {
        		const rawLabel = selectedAPN.substring(selectedAPN.indexOf('-') + 1).trim();
        	    const apnKeyMap = {"Bolts": "bolts","Nuts": "nuts","Screws": "screws","Rivets": "rivets","Washers": "washers","Clips & Clamps": "clips & clamps",
        	    		"Pins": "pins","Fastener for Interior": "interior","Electrical System Fastener": "electrical","Security Fastener": "security",
        	    		"Fasteners for Body Panels": "body-panels",
        	    		"Fastener for body panels": "body-panels",
        	    		"Fastener for Body Panels": "body-panels","Suspension & Steering": "suspension & steering","Engine&Mechanical": "engine & mechanical",
  						"Exhaust System": "exhaust","Fuel System": "fuel-system","Brake System": "brake-system","Transmission": "transmission",
  						"Radiator & Cooling": "radiator & cooling","Underbody & Frame": "underbody & frame","Miscellaneous Fastener": "miscellaneous"};
        	    const apnKey = apnKeyMap[rawLabel];

        	    const subtypeSelect = document.getElementById('subtype');
        	    const variantSelect = document.getElementById('variant');
        	    subtypeSelect.innerHTML = '<option value="">Select</option>';
        	    variantSelect.innerHTML = '<option value="">Select</option>';

        	    if (apnKey) {
        	    
        	      const subtypesRaw = dropdownData.fastenerSubtypes[apnKey];
        	      if (subtypesRaw && subtypesRaw.length > 0) {
        	        subtypesRaw[0].split(',').map(s => s.trim()).forEach(subtype => {
        	          subtypeSelect.add(new Option(subtype, subtype));
        	        });
        	      } else {
        	      }

        	      const variantsRaw = dropdownData.fastenerVariants[apnKey];
        	      if (variantsRaw && variantsRaw.length > 0) {
        	        variantsRaw[0].split(',').map(v => v.trim()).forEach(variant => {
        	          variantSelect.add(new Option(variant, variant));
        	        });
        	      } else {
        	      }

        	      document.getElementById('subtype-container').style.display = 'block';
        	      document.getElementById('variant-container').style.display = 'block';
        	    } else {
        	      document.getElementById('subtype-container').style.display = 'none';
        	      document.getElementById('variant-container').style.display = 'none';
        	    }
        	  } else {
        	    document.getElementById('subtype-container').style.display = 'none';
        	    document.getElementById('variant-container').style.display = 'none';
        	  }
        	});


      } catch (err) {
        alert('Failed to load dropdown data.');
      }

      const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
      if (user) {
        engineerInput.value = user.username || '';
      } else {
        alert('No logged-in user. Please log in.');
        window.close();
      }

   // Form submission
      form.addEventListener('submit', async (e) => {
    	    e.preventDefault();

    	    // Create form data object
    	    const formData = {
    	        SuperType: supertypeSelect.value.trim(),
    	        Type: typeSelect.value.trim(),
    	        APN: apnSelect.value.trim(),
    	        Subtype: document.getElementById('subtype').value.trim(), // This is your subtype value
    	        Variant: document.getElementById('variant').value.trim(),
    	        Description: descriptionInput.value.trim(),
    	        ResponsibleEngineer: engineerInput.value.trim()
    	    };

    	    if (formData.Type.toLowerCase() === 'fastener') {
    	        formData.FastenerSubPart = formData.Subtype;  
    	        delete formData.Subtype;  
    	    }

    	    // Validation
    	    if (!formData.SuperType || !formData.Type || !formData.APN || !formData.Description) {
    	        alert('Please fill in all required fields.');
    	        return;
    	    }

    	    if (formData.Type.toLowerCase() === 'fastener') {
    	        if (!formData.FastenerSubPart || !formData.Variant) {
    	            alert('FastenerSubPart and Variant are required when Type is Fastener.');
    	            return;
    	        }
    	    }

    	    // Submit data
    	    try {
    	        const res = await fetch('http://localhost:8080/andromeda/api/navigatorutilites/create', {
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
    	        const successMessage = "The following object was created successfully!\n"
    	            + "SuperType: " + formData.SuperType + "\n"
    	            + "Type: " + formData.Type + "\n"
    	            + "Name: " + formData.APN;
    	        alert(successMessage);

    	        const objectId = result.ObjectId; 
    	        if (objectId) {
    	            if (window.opener && window.opener.loadPartPropertiesInIframe) {
    	                window.opener.loadPartPropertiesInIframe(objectId); 
    	            }
    	            window.close();
    	        } else {
    	            alert('Could not retrieve the ID for the new part.');
    	        }
    	    } catch (error) {
    	        alert('Submission failed: ' + error.message);
    	    }
    	});
    });
  </script>
</body>
</html>