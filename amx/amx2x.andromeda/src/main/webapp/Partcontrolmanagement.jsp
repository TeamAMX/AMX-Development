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
<title>PartControl Management</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<style>
  body {
    font-family: Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }
  .topbar {
    display: flex;
    background: #f5f7fa;
    border-bottom: 1px solid #cfd3db;
    padding: 6px 12px;
    font-size: 13px;
    color: #333;
  }

  .topbar > div {
    display: flex;
    align-items: center;
    padding: 6px 12px;
    background: #f9fbfd;
    border: 1px solid #cfd3db;
    border-right: none;
    white-space: nowrap;
  }

  .topbar > div:last-child {
    border-right: 1px solid #cfd3db;
  }

  .folder-box {
    background: #e3e7eb;
    border: 1px solid #d1d6dc;
    width: 28px;
    height: 28px;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-right: 8px;
    flex-shrink: 0;
  }

  .folder-box img {
    width: 16px;
    height: 16px;
  }

  .part-number {
    font-weight: 700;
    font-size: 14px;
    padding-right: 13px;
    padding-left:13px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }

  .description {
    font-weight: 600;
    font-size: 13px;
    color: #555;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }

  .state-box {
    font-weight: 600;
    font-size: 13px;
    color: #333;
    display: flex;
    align-items: center;
    gap: 8px;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
  }

  .state-label {
    margin-right: 4px;
  }

  .btn-submit {
    background-color: #5c8bff;
    border: 1px solid #3f70ff;
    color: white;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-submit:hover {
    background-color: #3f70ff;
  }

  .btn-evaluate {
    background-color: #e5e7ea;
    border: 1px solid #c6cad2;
    color: #555;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-evaluate:hover {
    background-color: #c6cad2;
  }

  .info-box {
    font-size: 11px;
    color: #666;
    padding-left: 4px;
    line-height: 1.3;
  }

  .info-box strong {
    color: #444;
  }

  .topbar > div:not(:last-child) {
    margin-right: -1px; 
  }
	
	.vertical-line img {
  height: 20px;  
  width: 1px;   
  margin: 0 10px;
}

  .container {
    display: flex;
    height: calc(100vh - 56px);
    font-size: 13px;
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
  display: block;
  padding: 8px;
  color: #333;
  text-decoration: none;
  margin-bottom: 10px;
  border-radius: 4px;
}

.sidebar a:hover {
  background-color: #e3e7ea; 
}

.sidebar a.active {
  background-color:#808080;
  color: white;
   font-weight: bold;
}
.main-panel {
    flex-grow: 1;
    padding: 20px;
    overflow-y: auto;
    min-width: 0;
    width: 0;
    box-sizing: border-box;
}
.container {
    display: flex;
    height: calc(100vh - 56px);
    overflow: hidden;
    width: 100%;
}

.topbar {
  display: flex;
  background: #f5f7fa;
  border-bottom: 1px solid #cfd3db;
  padding: 6px 12px;
  font-size: 13px;
  color: #333;
}

  .toolbar {
    margin-bottom: 5px;
    padding-left: 2px;
  }
  .toolbar button {
    background: none;
    border: none;
    cursor: pointer;
    margin-right: 6px;
    vertical-align: middle;
    padding: 2px 4px;
  }
  .toolbar button img {
    vertical-align: middle;
    width: 18px;
    height: 18px;
  }
  .toolbar button:hover {
    background-color: #e3f2fd;
    border-radius: 2px;
  }

table.properties {
  width: 100%; 
  border-collapse: collapse;
  border: 1px solid #ddd;
  font-size: 16px;
  font-family: Arial, sans-serif;
  margin: 0 auto;
}

table.properties th,
table.properties td {
  padding: 12px 16px;
  border: 1px solid #ddd; 
  vertical-align: middle;
}

table.properties th {
  background: #fafafa;
  font-weight: bold;
  width: 200px; 
  text-align: left;
}

#partTable {
    white-space: nowrap;
}

#partTable th,
#partTable td {
    white-space: nowrap;
}

.dataTables_wrapper {
    width: 100%;
    overflow-x: auto;
}

  .folder-icon {
    width: 16px;
    height: 16px;
    vertical-align: middle;
    margin-right: 6px;
  }

.properties-container {
  max-height: 600px; 
  overflow-y: auto;
  border: 1px solid #ddd;
  margin-top: 0;
}

  #loadingSpinner {
    display: none;
    position: fixed;
    top: 10px;
    right: 10px;
    font-size: 14px;
    color: #666;
  }
  #errorMessage {
    display: none;
    color: red;
    margin: 10px 0;
    font-weight: bold;
  }
#detailsTable {
   width: 100%;
   border-collapse: collapse;
   margin-top: 10px;
}
th, td {
   border: 1px solid #dee2e6;
   padding: 12px;
   text-align: left;
   font-wrap-mode:nowrap;
}
th {
background-color: #f8f9fa;
width: 200px;
forn-wrap-mode:nowrap;
}
.nav-tabs {
            margin-bottom: 20px;
        }
        .nav-tabs .nav-link.active {
            background-color: #e9ecef;
            font-weight: bold;
        }
        .toolbar {
            background-color: #f8f9fa;
            padding: 6px 10px;
            border: 1px solid #dee2e6;
            border-bottom: none;
            display: flex;
            gap: 10px;
            border-radius: 4px;
            margin-top: 10px;
        }
         #createPanel {
            position: fixed;
            top: 0;
            right: -400px;
            width: 400px;
            height: 100%;
            background: #fff;
            box-shadow: -2px 0 5px rgba(0,0,0,0.3);
            overflow-y: auto;
            transition: right 0.3s ease;
            z-index: 1051;
            padding: 0;
        }
        #createPanel.active {
            right: 0;
        }
        #createPanel iframe {
            border: none;
            width: 100%;
            height: calc(100% - 56px);
        }
  .section-label{
   font-weight:bold;
   font-size:14px;
   margin:10px 0 5px 0;
   color:#333;
  }      
#partSpecificationTable {
    display: none;
}
  .state-box .state-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-weight: 700;
  font-size: 13px;
  color: white;
  margin-left: 8px;
  user-select: none;
  text-transform: uppercase;
  min-width: 80px;
  text-align: center;
}
.state-badge.InWork {
  background-color: #5bc0de;
}

.state-badge.InApproval {
  background-color: #6c757d;
}

.state-badge.Completed {
  background-color: #28a745;
}

.state-badge.Cancelled {
  background-color: #000000;
  color: #ffffff;
}
  
  
</style>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>

<div class="topbar">
    <div class="left-section">
        <div class="image-box">
      <img src="https://img.icons8.com/?size=50&id=WECphWgmeM0g&format=png&color=000000" alt="Folder Icon" />
        </div>
        <div class="part-info">
            <div class="part-number" style="font-weight: 700; font-size: 14px;"></div>
            <div class="part-type" style="font-size: 12px; color: #666; margin-top: 2px; "></div>
        </div>
        <div class="vertical-line"></div>
    </div>
    <div class="right-section">
        <div class="state-box">
            <span class="state-label">State:</span>
   
        </div>
        <div class="vertical-line"></div>
        <div class="info-box"></div>
        <div class="vertical-line"></div>
    </div>
</div>
<div class="container">
    <div class="sidebar">
        <a href="Partcontroldetails.jsp?name=<%= request.getParameter("name") %>" class="nav-link" data-page="Partcontroldetails.jsp">PC-Properties</a>
        <a class="nav-link" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>">History</a>
        <a href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>" class="nav-link" data-page="Partlifecycle.jsp">LifeCycle</a>
        <a href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>" class="nav-link active" data-page="Partcontrolmanagement.jsp">Part Management</a>
    </div>
    <div class="main-panel">
        <div class="toolbar mt-2">
            <button class="btn btn-light" data-bs-toggle="tooltip" title="Create Part" id="openCreatePanelBtn">
               <i class="bi bi-asterisk fs-6" style="color: #9370DB; font-size: 16px;"></i>
            </button>
            <button class="btn btn-light" data-bs-toggle="tooltip" title="Add Existing Part" id="addExistingpart">
                <img src="https://img.icons8.com/?size=100&id=K0l4dwcsMaJa&format=png&color=000000" alt="Add" style="width: 20px; height: 20px;">
            </button>
            <button class="btn btn-light" data-bs-toggle="tooltip" title="Export to Excel" id="excelexport">
            	<img src="https://img.icons8.com/?size=100&id=112690&format=png&color=000000" alt="Add" style="width: 20px; height: 20px;">
        	</button>
        </div>
        <div id="loadingSpinner"></div>
        <div id="errorMessage" class="error"></div>
        <div class="section-label">Part Management Table</div>
    <table class="table table-bordered mt-2" id="partTable">
    <thead>
        <tr>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>
</div>
 <div id="createPanel">
        <iframe id="createIframe" src=""></iframe>
    </div>
    </div>
<script>

function receiveSelectedParts(selectedParts) {
    if (!selectedParts || selectedParts.length === 0) return;

    const invalidItems = selectedParts.filter(function(p) {
        return !p.supertype || p.supertype.toLowerCase() !== 'part';
    });
    if (invalidItems.length > 0) {
        alert('Invalid selection. Please select only Part objects.');
        return;
    }

    const objectid = new URLSearchParams(window.location.search).get('name');
    if (!objectid) {
        alert('No object ID found.');
        return;
    }

    $.ajax({
        url: 'http://localhost:8080/amx2x.andromeda/api/datafetchservice/linkparttocontrol/' + encodeURIComponent(objectid),
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(selectedParts),
        success: function() {
            alert('Part "' + selectedParts[0].objectid + '" linked successfully.');
            loadPartTable();
        },
        error: function(xhr) {
            let msg = 'Failed to link part.';
            try {
                const err = JSON.parse(xhr.responseText);
                if (err.Message) msg = err.Message;
            } catch(e) {
                console.error(e);
            }
            alert(msg);
        }
    });
}

function loadPartTable() {
    $('#errorMessage').text('Loading part controls...');
    $('.section-label:contains("PartTable")').hide();
    const urlParams = new URLSearchParams(window.location.search);
    const objectid = urlParams.get('name');
    if (!objectid) {
        $('#errorMessage').text('Missing object ID.');
        return;
    }
    $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/getlinkedpart',
        data: { objectid: objectid },
        dataType: 'json',
        cache: false,
        success: function(data) {
            $('#errorMessage').text('');

            if (!data || !Array.isArray(data) || data.length === 0 || data.message) {
                $('#errorMessage').text(data ? data.message || 'No part Control found.' : 'Error loading data.');
                if ($.fn.DataTable.isDataTable('#partTable')) {
                    $('#partTable').DataTable().clear().draw();
                }
                $('.section-label:contains("partTable")').hide();
                $('#partTable').hide();
                return;
            }
            $('.section-label:contains("partTable")').show();
            $('#partTable').show();

            const excludedFields = ['objectid', 'linkedobjectid', 'connectionid', 'fts_document'];
            const columns = Object.keys(data[0])  
                .filter(key => !excludedFields.includes(key))
                .map(key => ({
                    data: key,
                    title: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' ')
                }));

            if ($.fn.DataTable.isDataTable('#partTable')) {
                $('#partTable').DataTable().destroy();
            }
            const thead = $('#partTable thead');
            thead.empty();
            const headerRow = $('<tr></tr>');
            columns.forEach(col => {
                headerRow.append(`<th>${col.title}</th>`);
            });
            thead.append(headerRow);

            $('#partTable').DataTable({
                data: data,
                columns: columns,
                order: [[ columns.findIndex(c => c.data === 'createddate') || 0, 'desc' ]],
                responsive: false,
                paging: false,
                searching: false,
                info: false,
                destroy: true
            });
        },
        error: function() {
            $('#errorMessage').text('Failed to load part controls.');
        }
    });
}

    $(document).ready(function() {
        loadPartTable();

	const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
        
        if (partInfo) {
          $('.part-number').text(partInfo.name || 'NA');
          $('.part-type').text(partInfo.type || 'NA');
          $('.state-box .state-label').remove();
          if (partInfo.currentstate) {
      	    $('.state-box .state-label').remove();
      	    const state = partInfo.currentstate;
      	    const badge = $('<span>')
      	        .addClass('state-badge ' + state.replace(/\s/g, ''))
      	        .text(state);
      	    $('<span>')
      	        .addClass('state-label')
      	        .text('State: ')
      	        .append(badge)
      	        .prependTo('.state-box');
      	}
        }
        else {
          $('.part-number').text('NA');
          $('.part-type').text('NA');
        }
        document.getElementById('openCreatePanelBtn').addEventListener('click', function () {
            const urlParams = new URLSearchParams(window.location.search);
            const objectid = urlParams.get('name');

            if (objectid) {
                const panel = document.getElementById('createPanel');
                panel.classList.add('active');
                document.getElementById('createIframe').src = 'CreatePartForControl.jsp?name=' + encodeURIComponent(objectid);
            } else {
                alert('No object ID found!');
            }
        });

    });
    
    $('#addExistingpart').on('click', function () {
        const objectid = new URLSearchParams(window.location.search).get('name');
        if (objectid) {
            window.open(
                'search.jsp?name=' + encodeURIComponent(objectid) + '&mode=part',
                'LinkPartPopup',
                'width=900,height=800,left=100,top=100,resizable=yes'
            );
        } else {
            alert('No object ID found!');
        }
    });
    window.addEventListener('message', function(event) {
        if (!event.data) return;

        if (event.data.action === 'closeOnly') {
            document.getElementById('createPanel').classList.remove('active');
        } else if (event.data.action === 'closeAndRefresh') {
            document.getElementById('createPanel').classList.remove('active');
            loadPartTable(); 
        } else if (event.data && event.data.selectedParts) {
            receiveSelectedParts(event.data.selectedParts);
        }
    });
    function closeCreatePanel() {
        const panel = document.getElementById('createPanel');
        panel.classList.remove('active');
        document.getElementById('createIframe').src = '';
    }
    
    $('#excelexport').on('click', function () {

        const exportData = [];

        const headers = [];

        $('#partTable thead th').each(function () {
            headers.push($(this).text().trim());
        });

        exportData.push(headers);

        $('#partTable tbody tr').each(function () {

            const row = [];

            $(this).find('td').each(function () {

                let cellText = $(this).text()
                    .replace(/\+/g, '')
                    .replace(/−/g, '')
                    .trim();

                row.push(cellText);
            });

            if (row.length > 0) {
                exportData.push(row);
            }
        });

        const worksheet = XLSX.utils.aoa_to_sheet(exportData);

        const workbook = XLSX.utils.book_new();

        XLSX.utils.book_append_sheet(workbook, worksheet, 'LinkedParts');

        XLSX.writeFile(workbook, 'LinkedParts.xlsx');
    });
    
</script>
</body>
</html>
