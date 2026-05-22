<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>AndromedaHome</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" crossorigin="anonymous" />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="styles/amxNavigatorHome.css">
  
  <style>
    /* Premium style layout matching the reference dashboard precisely */
    .right-panel-frame-wrapper {
      flex: 1;
      height: 100%;
      position: relative;
      background-color: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      overflow: hidden;
    }

    .homepage-welcome-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      background-color: #ffffff;
      z-index: 1;
      transition: opacity 0.2s ease;
    }

    .homepage-welcome-overlay .image-container {
      max-width: 550px;
      width: 90%;
      margin-bottom: 25px;
      display: flex;
      justify-content: center;
    }

    .homepage-welcome-overlay img {
      width: 100%;
      height: auto;
      object-fit: contain;
      border-radius: 4px;
    }

    .homepage-welcome-overlay h1 {
      font-family: 'Inter', sans-serif;
      font-weight: 700;
      font-size: 2.2rem;
      color: #000000;
      letter-spacing: 3px;
      margin: 0 0 8px 0;
      text-transform: uppercase;
    }

    .homepage-welcome-overlay p {
      font-family: 'Inter', sans-serif;
      font-size: 1.05rem;
      color: #64748b;
      margin: 0;
      font-weight: 400;
    }

    /* Transparent on load so the overlay branding shows right through */
    .right-panel {
      width: 100%;
      height: 100%;
      position: relative;
      z-index: 2;
      background-color: transparent; 
    }
  </style>
</head>
<body>

  <nav class="navbar navbar-expand-lg blue-toolbar position-relative">
    <div class="container-fluid">
      <div class="navbar-brand d-flex align-items-center">
        <img src="rr.png" alt="Logo" class="platform-logo" />
        <b class="ms-2 brand-text">ANDROMEDA</b>
      </div> 
      
      <div class="search-wrapper">
        <form id="searchForm">
          <div class="input-group search-container">
            <select id="searchFilter" class="form-select search-filter">
              <option value="">All</option>
              <option value="byParts">byParts</option>
              <option value="byPersons">byPersons</option>
            </select>
            <input type="text" id="searchInput" class="form-control search-input" placeholder="Search parts, persons...">
          </div>
          <button type="submit" id="searchButton" style="display: none;">Search</button>
        </form>
      </div>

      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#headerComponents" aria-controls="headerComponents" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="headerComponents">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0 align-items-center"></ul>
        <ul class="navbar-nav mb-2 mb-lg-0 align-items-center header-right-actions">
          <li class="nav-item ms-3">
            <a class="nav-link" href="amxNavigatorHome.jsp"><i class="fas fa-house"></i></a>
          </li>
          <li class="nav-item ms-3 dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="plusDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
              <i class="fas fa-plus"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="plusDropdown">
               <li>
    <a class="dropdown-item" href="#" id="createPartLink">
      <i class="fa-solid fa-cube"></i>
      Create Part
    </a>
  </li>

  <li>
    <a class="dropdown-item" href="#" id="createPartControlLink">
      <i class="fa-solid fa-sliders"></i>
      Create Part Control
    </a>
  </li>

  <li>
    <a class="dropdown-item" href="#" id="createPartSpecificationLink">
      <i class="fa-regular fa-file-lines"></i>
      Create Specification
    </a>
  </li>

  <li>
    <a class="dropdown-item" href="#" id="createMPNLink">
      <i class="fa-solid fa-barcode"></i>
      Create MPN
    </a>
  </li>

            </ul>
          </li>
          <li class="nav-item ms-3 position-relative">
            <a class="nav-link user-profile-trigger" href="#" onclick="toggleProfileDropdown(event)">
              <i class="fas fa-circle-user"></i>
            </a>
            <div class="profile-dropdown" id="profileDropdown">

    <div class="profile-header">

        <div class="profile-avatar" id="profileAvatar"></div>

        <div class="profile-user-info">
            <h4 id="usernameDisplay"></h4>
            <p id="emailDisplay"></p>
        </div>

    </div>

    <div class="profile-section">

        <div class="profile-row">
            <div class="profile-icon">
                <i class="fa-regular fa-user"></i>
            </div>

            <div class="profile-row-content">
                <span>Username</span>
                <strong id="usernameDisplay2"></strong>
            </div>
        </div>

        <div class="profile-row">
            <div class="profile-icon">
                <i class="fa-regular fa-envelope"></i>
            </div>

            <div class="profile-row-content">
                <span>Email</span>
                <strong id="emailDisplay2"></strong>
            </div>
        </div>

        <div class="profile-row">
            <div class="profile-icon">
                <i class="fa-solid fa-shield-halved"></i>
            </div>

            <div class="profile-row-content">
                <span>Access Level</span>
                <div class="access-badge" id="accessDisplay"></div>
            </div>
        </div>

    </div>

    <div class="profile-footer" onclick="logout()">

        <div class="profile-icon">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
        </div>

        <div class="profile-row-content">
            <strong>Sign out</strong>
            <span>Logout from Andromeda</span>
        </div>

    </div>

</div>
          </li>
          <li class="nav-item ms-3">
            <a class="nav-link logout-icon" href="#" onclick="logout()" title="Logout">
              <i class="fa-solid fa-arrow-right-from-bracket"></i>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </nav>

  <div class="panels-container">
    <div class="left-panel">
      <ul class="nav flex-column core-navigation">
        <li class="nav-item">
          <a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorParts.jsp', this)"><i class="fa-solid fa-cubes"></i> Parts</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorPersons.jsp', this)"><i class="fa-solid fa-users"></i> Persons</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorPartControl.jsp', this)"><i class="fa-solid fa-sliders"></i> PartControl</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorMPN.jsp', this)"><i class="fa-solid fa-barcode"></i> MPN</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="#" onclick="loadRightPanel('amxRunSql.jsp', this)"><i class="fa-solid fa-terminal"></i> RunSQL</a>
        </li>
      </ul>
    </div>
    
    <div class="right-panel-frame-wrapper" id="mainWorkspaceWrapper">
      <div class="homepage-welcome-overlay" id="homepageWelcome">
        <div class="image-container">
          <img src="kindpng_100351.png" alt="Andromeda Car Graphic" onerror="this.src='./kindpng_100351.png';" />
        </div>
        <h1>ANDROMEDA</h1>
        <p>Automotive Engineering Platform Context Suite</p>
      </div>
      
      <iframe class="right-panel" id="contentFrame" name="contentFrame" src="" frameborder="0" allowtransparency="true"></iframe>
    </div>
  </div>

  <div id="myModal" class="modal">
    <div class="modal-content">
      <span class="close-button">&times;</span>
      <form id="createPartForm">
        <h2 class="mb-4 form-heading">Create Part</h2>
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
        <div class="mb-3">
          <label for="inputDescription" class="form-label">Description</label>
          <textarea id="inputDescription" class="form-control" rows="4" placeholder="Enter description"></textarea>
        </div>
        <div class="mb-3">
          <label for="inputResponsibleEngineer" class="form-label">Responsible Engineer</label>
          <textarea id="inputResponsibleEngineer" class="form-control" rows="1" placeholder="username" readonly></textarea>
        </div>
        <div class="d-flex justify-content-end gap-2 mt-3">
          <button type="button" class="btn btn-secondary-dx" id="cancelBtn">Cancel</button>
          <button type="submit" class="btn btn-primary-dx">Submit</button>
        </div>
      </form>
    </div>
  </div>

  <div class="loadingSpinner" id="loadingSpinner"></div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  function loadPartPropertiesInIframe(objectId) {
	  const iframe = document.getElementById('contentFrame');
	  iframe.src = 'Properties.jsp?name=' + encodeURIComponent(objectId);
	}

  function loadPartControlDetailsInIframe(partcontrolId) {
	    const iframe = document.getElementById('contentFrame');
	    iframe.src =
	        'Partcontroldetails.jsp?name=' +
	        encodeURIComponent(partcontrolId);
	}
  function loadMPNPropertiesInIframe(objectId) {
	  const iframe = document.getElementById('contentFrame');
	  iframe.src = 'MPNProperties.jsp?name=' + encodeURIComponent(objectId);
	}
  
    // Profile dropdown toggle and logout
    function toggleProfileDropdown(event) {
      event.preventDefault();
      const dropdown = document.getElementById('profileDropdown');
      dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function(event) {
      const dropdown = document.getElementById('profileDropdown');
      const profileIcon = event.target.closest('.fa-circle-user');
      if (!profileIcon && !dropdown.contains(event.target)) {
        dropdown.style.display = 'none';
      }
    });
    function logout() {
      sessionStorage.removeItem('loggedInUser');
      window.location.href = 'amxNavigatorLogin.jsp';
    }
    function updateProfileDropdown() {
    	  const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
    	  if (!user) {
    	    window.location.href = 'amxNavigatorLogin.jsp';
    	    return;
    	  }
    	  document.getElementById('usernameDisplay').textContent = user.username || '';
    	  document.getElementById('emailDisplay').textContent = user.email || '';
    	  document.getElementById('accessDisplay').textContent = user.access || '';

    	  document.getElementById('usernameDisplay2').textContent = user.username || '';
    	  document.getElementById('emailDisplay2').textContent = user.email || '';

    	  document.getElementById('profileAvatar').textContent =
    	      (user.username || 'U').charAt(0).toUpperCase();

    	  fetch('http://localhost:8080/andromeda/api/navigatorutilites/login', {
    	    method: 'POST',
    	    headers: {
    	      'Content-Type': 'application/x-www-form-urlencoded'
    	    },
    	    credentials: 'include',
    	    body: new URLSearchParams({ username: user.username })
    	  })
    	  .then(res => res.json())
    	  .then(data => {
    	  })
    	  .catch(err => {
    	    console.error('Login error:', err);
    	    alert('Backend login failed. Please re-login.');
    	    window.location.href = 'amxNavigatorLogin.jsp';
    	  });
    	}
    window.addEventListener('DOMContentLoaded', async () => {
    	  updateProfileDropdown();

    	  const supertypeSelect = document.getElementById('supertype');
    	  const typeSelect = document.getElementById('type');
    	  const apnSelect = document.getElementById('APN');
    	  const descriptionInput = document.getElementById('inputDescription');
    	  const engineerInput = document.getElementById('inputResponsibleEngineer');
    	  const form = document.getElementById('createPartForm');
    	  const modal = document.getElementById('myModal');

    	  let dropdownData = {};

    	  try {
    	    const response = await fetch('http://localhost:8080/andromeda/api/db/dropdowns');
    	    dropdownData = await response.json();

    	    dropdownData.superTypes.forEach(supertype => {
    	      const option = new Option(supertype, supertype);
    	      supertypeSelect.add(option);
    	    });

    	    supertypeSelect.addEventListener('change', () => {
    	      const selectedSuper = supertypeSelect.value;
    	      typeSelect.innerHTML = '<option value="">Select</option>';
    	      apnSelect.innerHTML = '<option value="">Select</option>';
    	      descriptionInput.value = '';

    	      if (selectedSuper && dropdownData.types[selectedSuper]) {
    	        dropdownData.types[selectedSuper].forEach(type => {
    	          const option = new Option(type, type);
    	          typeSelect.add(option);
    	        });
    	      }
    	    });

    	    typeSelect.addEventListener('change', () => {
    	    	  const selectedType = typeSelect.value;
    	    	  apnSelect.innerHTML = '<option value="">Select</option>';
    	    	  descriptionInput.value = '';

    	    	  const normalizedKey = selectedType.replace(/\s+/g, '').toLowerCase();
    	    	  const apnList = dropdownData.apn && dropdownData.apn[normalizedKey];

    	    	  if (Array.isArray(apnList)) {
    	    	    apnList.forEach(apnWithLabel => {
    	    	      const label = apnWithLabel.trim();
    	    	      const option = new Option(label, label); 
    	    	      apnSelect.add(option);
    	    	    });
    	    	  }
    	    	});
    	    apnSelect.addEventListener('change', () => {
    	    });


    	  } catch (err) {
    	    console.error('Error loading dropdown data:', err);
    	    alert('Failed to load dropdown data.');
    	  }


    	  const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
    	  if (user) {
    	    engineerInput.value = user.username || '';
    	  }

    	  const openModalBtn = document.getElementById('openModalBtn');
    	    if (openModalBtn) {
    	      openModalBtn.addEventListener('click', e => {
    	        e.preventDefault();
    	        modal.style.display = 'block';
    	      });
    	    }
    	    
    	  document.querySelector('.close-button').addEventListener('click', () => modal.style.display = 'none');
    	  document.getElementById('cancelBtn').addEventListener('click', () => modal.style.display = 'none');
    	  window.addEventListener('click', (event) => {
    	    if (event.target === modal) modal.style.display = 'none';
    	  });

    	  form.addEventListener('submit', async (e) => {
    	    e.preventDefault();
    	    const formData = {
    	      SuperType: supertypeSelect.value.trim(),
    	      Type: typeSelect.value.trim(),
    	      APN: apnSelect.value.trim(),
    	      Description: descriptionInput.value.trim(),

    	    };

    	    if (!formData.SuperType || !formData.Type || !formData.APN || !formData.Description) {
    	      alert('Please fill in all required fields.');
    	      return;
    	    }

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

    	      alert('Part created successfully!');
    	      modal.style.display = 'none';
    	      form.reset();

    	    } catch (error) {
    	      alert('Submission failed: ' + error.message);
    	    }
    	  });
    	});

    
    function loadRightPanel(url, element) {

        const iframe = document.getElementById('contentFrame');
        iframe.src = url;

        // Remove active class from all sidebar links
        document.querySelectorAll('.core-navigation .nav-link')
            .forEach(link => link.classList.remove('active'));

        // Add active class to clicked link
        if (element) {
            element.classList.add('active');
        }

        if (url === 'amxDataFetch.jsp') {
            iframe.style.backgroundImage = 'none';
            iframe.style.backgroundColor = 'white';
        } else {
            iframe.style.backgroundImage = "url('andromeda.png')";
            iframe.style.backgroundColor = '';
        }
    }
    
    document.getElementById('createPartLink').addEventListener('click', function (e) {
        e.preventDefault();

        document.getElementById('homepageWelcome').style.display = 'none';

        const iframe = document.getElementById('contentFrame');
        iframe.src = 'CreatePartForm.jsp';
    }); 
    
    document.getElementById('createPartControlLink').addEventListener('click', function (e) {
  	  e.preventDefault();
  	document.getElementById('homepageWelcome').style.display = 'none';

  	const iframe = document.getElementById('contentFrame');
  	iframe.src = 'CreatePartControl.jsp';
  	});  
    
  document.getElementById('createPartSpecificationLink').addEventListener('click',function(e){
	  e.preventDefault();
	  document.getElementById('homepageWelcome').style.display = 'none';

	  const iframe = document.getElementById('contentFrame');
	  iframe.src = 'CreatePartSpecification.jsp';    
  });
  document.getElementById('createMPNLink').addEventListener('click', function (e) {
	  e.preventDefault();
	  document.getElementById('homepageWelcome').style.display = 'none';

	  const iframe = document.getElementById('contentFrame');
	  iframe.src = 'CreateMPNForm.jsp';
	});  
 
 
    //search
  function showLoadingSpinner(show) {
  const spinner = document.getElementById('loadingSpinner');
  spinner.style.display = show ? 'block' : 'none';
}

  document.getElementById('searchForm').addEventListener('submit', function(event) {
	    event.preventDefault();

	    const searchInput = document.getElementById('searchInput');
	    const filterSelect = document.getElementById('searchFilter');
	    const searchQuery = searchInput.value.trim();
	    const filterValue = filterSelect.value.trim();

	    if (searchQuery.length < 2) {
	        alert('Please enter at least 2 characters');
	        return;
	    }
	    if (filterValue === null || filterValue === undefined) {
	    	  alert('Please select a filter');
	    	  return;
	    	}
	    showLoadingSpinner(true);

	    const loadingTimeout = setTimeout(() => {
	        showLoadingSpinner(false);
	    }, 10000);

	    const iframe = document.getElementById('contentFrame');
	    iframe.src = 'searchResults.jsp?query=' + encodeURIComponent(searchQuery) + '&filter=' + encodeURIComponent(filterValue);

	    searchInput.value = '';
	    iframe.style.backgroundImage = 'none';

	    iframe.onload = function() {
	        clearTimeout(loadingTimeout);
	        showLoadingSpinner(false);
	    };
	});
  </script>
</body>
</html>
