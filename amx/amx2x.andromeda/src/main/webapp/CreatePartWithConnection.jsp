<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Create Part</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    body {
  margin: 0;
  background-color: #f9f9f9;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 20px 0;
  overflow-y: auto;
}
    #createPartForm {
      width: 100%;
      max-width: 600px;
      padding: 30px;
      background-color: white;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }
    h2 {
      margin-bottom: 20px;
    }
    label {
      font-weight: 600;
    }
    textarea,
    select,
    input {
      margin-bottom: 15px;
    }
    .form-control:focus,
    .form-select:focus {
      border-color: #00afc4;
      box-shadow: 0 0 0 0.2rem rgba(0, 175, 196, 0.25);
    }
  </style>
</head>
<body>
 <form id="createPartForm">
    <h2>Create Part</h2>
    <div class="mb-3">
      <label for="supertype" class="form-label">SuperType</label>
      <select id="supertype" name="supertype" class="form-select" required>
        <option value="">Select</option>
      </select>
    </div>
    <div class="mb-3">
      <label for="type" class="form-label">Type</label>
      <select id="type" name="type" class="form-select" required>
        <option value="">Select</option>
      </select>
    </div>
    <div class="mb-3">
      <label for="APN" class="form-label">APN</label>
      <select id="APN" name="APN" class="form-select" required>
        <option value="">Select</option>
      </select>
    </div>
    <!--new fields-->
 
    <div class="mb-3" id="subtype-container" style="display:none;">
      <label for="subtype" class="form-label">Subtype</label>
      <select id="subtype" name="subtype" class="form-select">
        <option value="">Select</option>
      </select>
    </div>
    <div class="mb-3" id="variant-container" style="display:none;">
      <label for="variant" class="form-label">Variant</label>
      <select id="variant" name="variant" class="form-select">
        <option value="">Select</option>
      </select>
    </div>
 
    <div class="mb-3">
      <label for="inputDescription" class="form-label">Description</label>
      <textarea id="inputDescription" class="form-control" rows="4" placeholder="Enter description" required></textarea>
    </div>
    <div class="mb-3">
      <label for="inputResponsibleEngineer" class="form-label">Responsible Engineer</label>
      <textarea id="inputResponsibleEngineer" class="form-control" rows="1" readonly></textarea>
    </div>

    <div class="d-flex justify-content-end gap-2">
      <button type="button" class="btn btn-secondary" id="cancelBtn">Cancel</button>
      <button type="submit" class="btn btn-primary">Submit</button>
    </div>
  </form>

<script>
  const isInIframe = window.self !== window.top;
  document.getElementById('cancelBtn').addEventListener('click', () => {
    if (isInIframe) {
      window.parent.postMessage({ action: 'closeOnly' }, '*');
    } else {
      window.close();
    }
  });
  
  
  
  window.addEventListener('DOMContentLoaded', async () => {
      const supertypeSelect = document.getElementById('supertype');
      const typeSelect = document.getElementById('type');
      const apnSelect = document.getElementById('APN');
       const subtypeContainer = document.getElementById('subtype-container');
      const variantContainer = document.getElementById('variant-container');
      const descriptionInput = document.getElementById('inputDescription');
      const engineerInput = document.getElementById('inputResponsibleEngineer');
      const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
      if (user) {
          engineerInput.value = user.username || user.name || user.email || '';
      }
      const form = document.getElementById('createPartForm');
      
    let dropdownData = {};

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
        	    const apnKey = apnKeyMap[rawLabel] ||
                Object.keys(apnKeyMap).find(k => k.toLowerCase() === rawLabel.toLowerCase())
                ? apnKeyMap[Object.keys(apnKeyMap).find(k => k.toLowerCase() === rawLabel.toLowerCase()) || rawLabel]
                : null;
 
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
    	
    } catch (error) {
      alert(error.message || 'Failed to load dropdown data.');
      return;
    }

   // supertypeSelect.addEventListener('change', () => {
     // const selectedSuper = supertypeSelect.value;
      //typeSelect.innerHTML = '<option value="">Select</option>';
      //if (selectedSuper === 'AmxControl' && dropdownData.types) {
       // const amxControlType = dropdownData.types[selectedSuper] || [];
       // amxControlType.forEach(type => {
        //  const option = new Option(type, type);
        //  typeSelect.add(option);
        //});
      //}
    //});

    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        const urlParams = new URLSearchParams(window.location.search);
        const objectid = urlParams.get('name');
        if (!objectid) {
            alert('Object ID is missing');
            return;
        }

        const user = JSON.parse(sessionStorage.getItem('loggedInUser'));

        const formData = {
        		ObjectId: objectid,
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


        try {
            const res = await fetch('http://localhost:8080/andromeda/api/datafetchservice/createpartwithconnection', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                credentials: 'include',
                body: new URLSearchParams(formData) 
            });

            const result = await res.json();

            if (!res.ok || result.error) {
                if (result.error && result.error.includes("already exists")) {
                    alert('Error:' +result.error);
                } else {
                    alert('Error: ' + (result.error || 'Failed to create part'));
                }
                return;
            }

            alert('The following object was created successfully!\n' +
                    'SuperType: ' + formData.SuperType + '\n' +
                    'Type: ' + formData.Type + '\n' +
                    'Name: ' + formData.APN + '\n' );

            onPartCreationSuccess();
        } catch (error) {
            alert('Submission failed: ' + error.message);
        }

        function onPartCreationSuccess() {
            window.parent.postMessage({ action: 'closeAndRefresh' }, '*');
        }
    });
  });
</script>
</body>
</html>
