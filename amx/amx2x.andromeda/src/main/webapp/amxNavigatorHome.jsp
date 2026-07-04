<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>AndromedaHome</title>
  <link rel="icon" type="image/png" href="rr.png">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" crossorigin="anonymous" />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="styles/amxNavigatorHome.css">
  
  <style>
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
	
	.search-icon-btn {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #9ca3af;
    cursor: pointer;
    font-size: 14px;
    z-index: 10;
    display: flex;
    align-items: center;
    padding: 4px;
    transition: color 0.2s;
	}

	.search-icon-btn:hover {
    color: #5ec22e;
	}
	
    .homepage-welcome-overlay p {
      font-family: 'Inter', sans-serif;
      font-size: 1.05rem;
      color: #64748b;
      margin: 0;
      font-weight: 400;
    }

    .right-panel {
      width: 100%;
      height: 100%;
      position: relative;
      z-index: 2;
      background-color: transparent; 
    }

    .navbar-brand {
      cursor: pointer;
      transition: opacity 0.2s ease;
      text-decoration: none;
    }
    
    .navbar-brand:hover {
      opacity: 0.8;
    }
    
    .navbar-brand:hover .brand-text {
      color: #e5e7eb; 
      text-shadow: 0 0 5px rgba(255, 255, 255, 0.3);
    }

    .brand-text {
      color: inherit; 
      transition: color 0.2s ease, text-shadow 0.2s ease;
    }

    .modal-content {
        background-color: white;
        padding: 24px; 
        border-radius: 18px;
        width: 100%;
        max-width: 600px; 
        box-shadow: 0 25px 60px rgba(0,0,0,0.18);
        overflow: hidden;
        border: none;
        position: relative;
    }

    .close-button {
        position: absolute;
        right: 20px;
        top: 20px;
        font-size: 24px;
        cursor: pointer;
        color: #64748b;
        z-index: 50;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: white;
        border-radius: 50%;
        transition: background 0.2s;
    }

    .close-button:hover {
        background: #f1f5f9;
        color: #0f172a;
    }
    
    #sidebarToggle {
    font-size: 22px;
    font-weight: bold;
    line-height: 1;
	}

	.sidebar-arrow-icon {
    width: 26px;
    height: 26px;
    display: inline-block;
    transition: transform 0.25s ease;
	}
	
	.sidebar-toggle {
    background: transparent;
    border: none;
    outline: none;
    box-shadow: none;
    padding: 0;
    display: flex;
    align-items: center;
    justify-content: center;
	}

	.sidebar-toggle:focus,
	.sidebar-toggle:active {
    outline: none;
    box-shadow: none;
	}
	
	.sidebar-arrow-icon.rotated {
    transform: rotate(180deg);
	}
	
  </style>
</head>
<body>

  <nav class="navbar navbar-expand-lg blue-toolbar position-relative">
    <div class="container-fluid">
      <a class="navbar-brand d-flex align-items-center" href="amxNavigatorHome.jsp">
        <img src="rr.png" alt="Logo" class="platform-logo" />
        <b class="ms-2 brand-text">ANDROMEDA</b>
      </a> 
      
      <div class="search-wrapper">
		<div class="input-group search-container" id="searchContainer">
		    <div class="search-scope-trigger" id="searchScopeTrigger">
    		  <span id="searchScopeLabel">All</span>
    			  <i class="fa-solid fa-chevron-up" id="searchScopeChevron"></i>
   			</div>
   	 		<div class="search-scope-divider"></div>
    		<input type="text" id="searchInput" class="form-control search-input" placeholder="Search by parts, persons...">
			<input type="hidden" id="searchFilter" value="">
			<span class="search-icon-btn" id="searchIconBtn">
   				 <i class="fa-solid fa-magnifying-glass"></i>
			</span>
		</div>
		
		 
          
  		<div class="search-scope-dropdown" id="searchScopeDropdown">
    		<div class="scope-label">SEARCH SCOPE</div>
    		<div class="scope-option active" data-value="" data-label="All">
    			<i class="fa-solid fa-globe"></i>
    			<span>All</span>
    		</div>
    		<div class="scope-option" data-value="byParts" data-label="Parts">
      			<i class="fa-solid fa-cubes"></i>
      			<span>Parts</span>
    		</div>
    		<div class="scope-option" data-value="byPersons" data-label="Persons">
      			<i class="fa-solid fa-users"></i>
      			<span>Persons</span>
    		</div>
  		</div>
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
      Create Part Specification
    </a>
  </li>

  <li>
    <a class="dropdown-item" href="#" id="createMPNLink">
      <i class="fa-solid fa-barcode"></i>
      Create MPN
    </a>
  </li>
<!-- BUG-1068 Started by Nageswari -->
<li>
    <a class="dropdown-item" href="#" id="createFileLink">
      <i class="fa-solid fa-file"></i>
      Create File
    </a>
  </li>
<!-- BUG-1068 Ended by Nageswari -->
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
    <div class="sidebar-header">
<!-- BUG-1064 fixing started by koushik -->
    	<button id="sidebarToggle" class="sidebar-toggle" data-tooltip="Close Sidebar">
    		<svg id="sidebarArrow" class="sidebar-arrow-icon" viewBox="0 0 386 386" xmlns="http://www.w3.org/2000/svg">
    			<circle cx="193" cy="193" r="193" fill="#1e293b"/>
    			<path d="M 220 100 L 140 193 L 220 286" stroke="#ffffff" stroke-width="36" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    		</svg>
		</button>
<!-- BUG-1064 fixing ended by koushik -->	
		
	</div>
      <ul class="nav flex-column core-navigation">
        <li class="nav-item">
        	<a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorParts.jsp', this)"><i class="fa-solid fa-cubes"></i>
        		<span class="nav-text">Parts</span>
    		</a>
		</li>
		<li class="nav-item">
        	<a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorPersons.jsp', this)"><i class="fa-solid fa-users"></i>
        		<span class="nav-text">Persons</span>
    		</a>
		</li>
		<li class="nav-item">
        	<a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorPartControl.jsp', this)"><i class="fa-solid fa-sliders"></i>
        		<span class="nav-text">PartControl</span>
    		</a>
		</li>
		<li class="nav-item">
        	<a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorMPN.jsp', this)"><i class="fa-solid fa-barcode"></i>
        		<span class="nav-text"> MPN</span>
    		</a>
		</li>
		
		<li class="nav-item">
        	<a class="nav-link" href="#" onclick="loadRightPanel('amxNavigatorPartSpecification.jsp', this)"><i class="fa-regular fa-file-lines"></i>
        		<span class="nav-text">Part Specification</span>
    		</a>
		</li>
		<!-- Added by Ajay BUG-1072 New Feature Started-->
		<li class="nav-item" >
        	<a class="nav-link" id="sql-btn"  href="#" onclick="loadRightPanel('Files.jsp', this)"><i class="fa-regular fa-file" ></i>
        		<span class="nav-text"> Files</span>
    		</a>
		</li>
		<!-- Added by Ajay BUG-1072New Feature  Ended -->
		<li class="nav-item" >
        	<a class="nav-link" id="sql-btn" href="#" onclick="loadRightPanel('amxRunSql.jsp', this)"><i class="fa-solid fa-terminal" ></i>
        		<span class="nav-text"> RunSQL</span>
    		</a>
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
      <span class="close-button" id="modalCloseBtn">&times;</span>
      
      <div id="nativeFormContainer">
        
      </div>

      <div id="iframeContainer" style="display: none; width: 100%; height: 100%;"></div>

    </div>
  </div>

  <div class="loadingSpinner" id="loadingSpinner"></div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  
  const BASIC_URL = '<%= request.getContextPath() %>';
  function loadPartPropertiesInIframe(objectId) {
	  const iframe = document.getElementById('contentFrame');
	  iframe.src = 'Properties.jsp?name=' + encodeURIComponent(objectId);
	}
  
  const user = JSON.parse(sessionStorage.getItem('loggedInUser'));
  const loggedInUserAccess = user?.access || '';
  if (loggedInUserAccess.trim().toLowerCase() === 'admin' || loggedInUserAccess.trim().toLowerCase() === 'leader') $('#sql-btn').show();

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

    	  fetch(BASIC_URL+'/api/navigatorutilites/login', {
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
    });

    function loadRightPanel(url, element) {
        const iframe = document.getElementById('contentFrame');
        iframe.src = url;

        document.querySelectorAll('.core-navigation .nav-link')
            .forEach(link => link.classList.remove('active'));

        if (element) {
            element.classList.add('active');
        }
    }
  //BUG-1038 Started
    async function getUserAccess() {

        try {

            const response = await fetch(BASIC_URL + "/api/navigatorutilites/getUserAccess", {
                method: "GET",
                credentials: "include"
            });

            const data = await response.json();

            if (data.Status === "Success") {
                return data.Access;
            }

            return "";

        } catch (e) {
            console.error(e);
            return "";
        }
    }
  
    document.getElementById('createPartLink').addEventListener('click', async function (e) {

        e.preventDefault();

        const access = await getUserAccess();

        if (access && access.toLowerCase() === "reader") {
            alert("The current user is not having access to process this functionality. Please check your access level.");
            return;
        }

        loadFormInModal('CreatePartForm.jsp');
    });
    
    document.getElementById('createPartControlLink').addEventListener('click', async function (e) {
        e.preventDefault();
        const access = await getUserAccess();
//Bug-1039 start
        if (access &&(access.toLowerCase() === "reader" ||access.toLowerCase() === "author")) {
    	    alert("The current user is not having access to process this functionality. Please check your access level.");
    	    return;
    	}
    	//Bug-1039 End

        loadFormInModal('CreatePartControl.jsp');
    });

    document.getElementById('createPartSpecificationLink').addEventListener('click',async function(e){
        e.preventDefault();
        const access = await getUserAccess();
//BUG-1039 Start
        if (access &&(access.toLowerCase() === "reader" ||access.toLowerCase() === "author")) {
        	    alert("The current user is not having access to process this functionality. Please check your access level.");
        	    return;
        	}
//Bug-1039 End

        loadFormInModal('CreatePartSpecification.jsp');
    });

    document.getElementById('createMPNLink').addEventListener('click', async function (e) {
        e.preventDefault();
        const access = await getUserAccess();

        if (access && access.toLowerCase() === "reader") {
            alert("The current user is not having access to process this functionality. Please check your access level.");
            return;
        }

        loadFormInModal('CreateMPNForm.jsp');
    });  
 //Bug-1038 Ended
/* BUG-1068 started by Nageswari */
 document.getElementById('createFileLink').addEventListener('click', async function (e) {

        e.preventDefault();

        const access = await getUserAccess();

        if (access && access.toLowerCase() === "reader") {
            alert("The current user is not having access to process this functionality. Please check your access level.");
            return;
        }

        loadFormInModal('CreateFileForm.jsp');
    });
 /* BUG-1068 Ended by Nageswari */
    function loadFormInModal(url) {
        const modal = document.getElementById('myModal');
        document.getElementById('nativeFormContainer').style.display = 'none';
        const iframeContainer = document.getElementById('iframeContainer');
        iframeContainer.style.display = 'block';
        
        iframeContainer.innerHTML = '<iframe src="' + url + '" style="width:100%; height:75vh; max-height: 600px; border:none; border-radius:8px;"></iframe>';
        modal.style.display = 'flex';
    }
    
    document.getElementById('modalCloseBtn').addEventListener('click', function() {
        document.getElementById('myModal').style.display = 'none';
        document.getElementById('iframeContainer').innerHTML = '';
    });
    
  function showLoadingSpinner(show) {
      const spinner = document.getElementById('loadingSpinner');
      spinner.style.display = show ? 'block' : 'none';
  }

  const scopeTrigger = document.getElementById('searchScopeTrigger');
  const scopeDropdown = document.getElementById('searchScopeDropdown');
  const scopeLabel = document.getElementById('searchScopeLabel');
  const searchFilterInput = document.getElementById('searchFilter');

  scopeTrigger.addEventListener('click', (e) => {
    e.stopPropagation();
    const isOpen = scopeDropdown.classList.toggle('open');
    scopeTrigger.classList.toggle('open', isOpen);
  });

  document.querySelectorAll('.scope-option').forEach(option => {
    option.addEventListener('click', () => {

      document.querySelectorAll('.scope-option').forEach(o => o.classList.remove('active'));
      option.classList.add('active');

      scopeLabel.textContent = option.getAttribute('data-label');
      searchFilterInput.value = option.getAttribute('data-value');

      scopeDropdown.classList.remove('open');
      scopeTrigger.classList.remove('open');
    });
  });

  document.addEventListener('click', (e) => {
    if (!e.target.closest('.search-wrapper')) {
      scopeDropdown.classList.remove('open');
      scopeTrigger.classList.remove('open');
    }
  });
  document.getElementById('searchInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      const query = this.value.trim();
      const filter = searchFilterInput.value;

      if (query.length < 2) { alert('Please enter at least 2 characters'); return; }

      showLoadingSpinner(true);
      const loadingTimeout = setTimeout(() => showLoadingSpinner(false), 10000);

      const iframe = document.getElementById('contentFrame');
      iframe.src = 'searchResults.jsp?query=' + encodeURIComponent(query) + '&filter=' + encodeURIComponent(filter);
      this.value = '';

      iframe.onload = function() {
        clearTimeout(loadingTimeout);
        showLoadingSpinner(false);
      };
    }
  });
//BUG-1047 fixing started by koushik
 document.getElementById('searchIconBtn').addEventListener('click', function () {
	    const query = document.getElementById('searchInput').value.trim();
	    const filter = document.getElementById('searchFilter').value;
	    document.getElementById('contentFrame').src ='searchResults.jsp?query=' +encodeURIComponent(query) +'&filter=' +encodeURIComponent(filter);});
 //BUG-1047 fixing ended by koushik
 
  window.addEventListener('message', function(event) {
    if (!event.data) return;

    if (event.data.action === 'closeOnly') {
      const modal = document.getElementById('myModal');
      if (modal) modal.style.display = 'none';
      
      const iframeContainer = document.getElementById('iframeContainer');
      if (iframeContainer) iframeContainer.innerHTML = '';
    }

    if (event.data.action === 'loadProperties') {

      const modal = document.getElementById('myModal');
      if (modal) modal.style.display = 'none';

      const iframeContainer = document.getElementById('iframeContainer');
      if (iframeContainer) iframeContainer.innerHTML = '';

      const homepage = document.getElementById('homepageWelcome');
      if (homepage) homepage.style.display = 'none';

      const contentFrame = document.getElementById('contentFrame');
      if (contentFrame && event.data.id) {
        const id = encodeURIComponent(event.data.id);
        
        if (event.data.type === 'part') {
            contentFrame.src = 'Properties.jsp?name=' + id;
        } else if (event.data.type === 'partcontrol') {
            contentFrame.src = 'Partcontroldetails.jsp?name=' + id;
            
        }
      //BUG-1055 Started By Nageswari
        else if (event.data.type === 'partspecification') {
            contentFrame.src = 'PartSpecificationdetails.jsp?name=' + id;
        }
        //BUG-1055 Ended by Nageswari
        else if (event.data.type === 'mpn') {
            contentFrame.src = 'MPNProperties.jsp?name=' + id;
        }
        //Added by Ajay BUG-1070 New Feature
        else if (event.data.type === 'file') {
            contentFrame.src = 'FileProperties.jsp?name=' + id;
        }
        //Added by Ajay BUG-1070 New Feature
      }
    }
  });
  
  const tooltip = document.createElement('div');
  tooltip.className = 'sidebar-tooltip';
  document.body.appendChild(tooltip);

  const toggleBtn = document.getElementById('sidebarToggle');

  toggleBtn.addEventListener('mouseenter', () => {
      const rect = toggleBtn.getBoundingClientRect();
      tooltip.textContent = toggleBtn.getAttribute('data-tooltip');
      tooltip.style.left = (rect.right + 10) + 'px';
      tooltip.style.top = (rect.top + rect.height / 2 - 13) + 'px';
      tooltip.classList.add('visible');
  });

  toggleBtn.addEventListener('mouseleave', () => {
      tooltip.classList.remove('visible');
  });
//BUG-1064 Started fixing by koushik
  const arrow = document.getElementById("sidebarArrow");
	toggleBtn.addEventListener('click', () => {
    const sidebar = document.querySelector('.left-panel');
    sidebar.classList.toggle('collapsed');
    tooltip.classList.remove('visible');
    if (sidebar.classList.contains('collapsed')) {
        arrow.classList.add('rotated');
        toggleBtn.setAttribute('data-tooltip', 'Open Sidebar');
    } else {
        arrow.classList.remove('rotated');
        toggleBtn.setAttribute('data-tooltip', 'Close Sidebar');
    }
  });
 //BUG-1064 ended fixing by koushik
  </script>
</body>
</html>