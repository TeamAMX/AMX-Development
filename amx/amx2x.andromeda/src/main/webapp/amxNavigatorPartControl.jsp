<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Part Control List</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

  <style>
    * { box-sizing: border-box; }
	  html,
/* BUG-1074 started by Tharun  */	  
body {
    overflow-y: hidden;
    overflow-x:hidden;
}
/* BUG-1074 ended by Tharun  */
    body {
      font-family: 'Inter', sans-serif;
      padding: 24px;
      background-color: #f7f9fa;
      margin: 0;
      color: #333;
    }

    /* ===== HEADER ===== */
    .page-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 20px;
    }

    .page-header-left {
      display: flex;
      align-items: center;
      gap: 16px;
    }

    .page-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      background: linear-gradient(135deg, #1f2937, #374151);
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 20px;
      flex-shrink: 0;
    }

    .page-title h1 {
      margin: 0 0 2px 0;
      font-size: 18px;
      font-weight: 700;
      color: #111827;
    }

    .page-title p {
      margin: 0;
      font-size: 12px;
      color: #6b7280;
    }

    .record-count {
      display: flex;
      align-items: center;
      gap: 6px;
      background: #f3f4f6;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 6px 14px;
      font-size: 12px;
      font-weight: 600;
      color: #374151;
    }

    /* ===== TABLE CONTAINER ===== */
    .table-container {
  background: #ffffff;
  border-radius: 12px;
  border: 1px solid #e2e5e9;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
}

    table.dataTable {
  width: 100% !important;
  min-width: 1100px;
  border-collapse: collapse !important;
  margin: 0 !important;
}

    /* Header */
    table.dataTable thead th {
   	  position: sticky;
  	  top: 0;
  	  z-index: 2;
      background-color: #1f2937 !important;
      color: #e2e8f0 !important;
      font-family: 'Inter', sans-serif !important;
      font-size: 11px !important;
      font-weight: 700 !important;
      text-transform: uppercase !important;
      letter-spacing: 0.5px !important;
      padding: 11px 26px 11px 14px !important;
      border-bottom: 2px solid #334155 !important;
      border-right: 1px solid #334155 !important;
      border-top: none !important;
      border-left: none !important;
      white-space: nowrap !important;
    }

    /* Sort arrows white */
    table.dataTable thead .sorting:before,
    table.dataTable thead .sorting:after,
    table.dataTable thead .sorting_asc:before,
    table.dataTable thead .sorting_asc:after,
    table.dataTable thead .sorting_desc:before,
    table.dataTable thead .sorting_desc:after {
      color: rgba(255,255,255,0.75) !important;
      opacity: 1 !important;
      display:none !important;
    }

    /* Body rows */
    table.dataTable tbody tr {
      border-bottom: 1px solid #f1f5f9 !important;
    }
    table.dataTable tbody tr:last-child {
      border-bottom: none !important;
    }
    table.dataTable tbody tr:hover {
      background-color: #f8fafc !important;
      cursor: pointer;
    }
    table.dataTable tbody td {
      font-family: 'Inter', sans-serif !important;
      font-size: 13px !important;
      color: #2b303a !important;
      padding: 10px 14px !important;
      vertical-align: middle !important;
      border-top: none !important;
      border-left: none !important;
      border-right: none !important;
      background-color: transparent !important;
      white-space: nowrap !important;
    }

    /* Name link */
    table.dataTable a.part-link {
      color: #1f2937;
      text-decoration: none;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    table.dataTable a.part-link:hover {
      color: #374151;
      text-decoration: underline;
    }
    table.dataTable a.part-link i {
      color: #6b7280;
      font-size: 12px;
    }

    /* Owner / Assignee cell */
    .person-cell {
      display: flex;
      align-items: center;
      gap: 6px;
      color: #374151;
    }
    .person-cell i { color: #9ca3af; font-size: 12px; }

    /* Email cell */
    .email-cell {
      display: flex;
      align-items: center;
      gap: 6px;
      color: #374151;
    }
    .email-cell i { color: #9ca3af; font-size: 12px; }

    /* ===== STATE BADGES ===== */
    .state-badge {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 3px 10px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.3px;
      min-width: 80px;
    }
    .state-badge.InWork      { background: #dbeafe; color: #1d4ed8; }
    .state-badge.InApproval  { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
    .state-badge.Completed   { background: #dcfce7; color: #166534; }
    .state-badge.Cancelled   { background: #1f2937; color: #ffffff; }

    /* ===== HIDE DATATABLES UI ===== */
    .dataTables_info,
    .dataTables_length,
    .dataTables_filter { display: none !important; }

    .error {
      text-align: center;
      margin-top: 20px;
      color: #c0392b;
      font-size: 13px;
    }
    .table-scroll {
    /* BUG-1074 started by Tharun*/
  height: 67vh;
  /*BUG-1074 ended by Tharun*/
  overflow-y: auto;
  overflow-x: auto;
}
/* BUG-1046 Started by Nageswari */
.toolbar{
    background:#1f2937;
    height:40px;
    display:flex;
    align-items:center;
    padding:0 15px;
    margin:5px 0;
}

.toolbar-icon{
    color:#fff;
    font-size:24px;
    cursor:pointer;
    padding:8px;
}

.toolbar-icon:hover{
    background:#374151;
    border-radius:4px;
}
/* Pagination Style */
.dataTables_wrapper .dataTables_paginate {
    font-size: 12px !important;
    margin-top: 10px;
}

.dataTables_wrapper .dataTables_paginate .paginate_button {
    font-size: 12px !important;
    padding: 3px 8px !important;
    margin: 0 2px;
}

.dataTables_wrapper .dataTables_paginate .paginate_button.current {
    font-weight: 600;
}
/* BUG-1046 Ended by Nageswari */
  </style>
</head>
<body>

  <!-- Page Header -->
  <div class="page-header">
    <div class="page-header-left">
      <div class="page-icon">
        <i class="fa-solid fa-sliders"></i>
      </div>
      <div class="page-title">
        <h1>Part Control List</h1>
        <p>View and manage part control information</p>
      </div>
    </div>
    <div class="record-count" id="recordCount">
      <i class="fa-solid fa-list"></i>
      <span>-- Records</span>
    </div>
  </div>
<!-- BUG-1046 Started By Nageswari -->
<div class="toolbar">
    <i class="fa-solid fa-address-card toolbar-icon"
       id="showMyPartControls"
       title="Show All My Part Controls"></i>
</div>
<!-- BUG-1046 Ended By Nageswari -->
  <!-- Table -->
  <div class="table-container">
  <div class="table-scroll">
    <table id="partsTable" style="width:100%">
      <thead><tr></tr></thead>
      <tbody></tbody>
    </table>
  </div>
  <div class="error" id="errorMessage"></div>
</div>

  <script>
  
  const BASIC_URL = '<%= request.getContextPath() %>';
  /* BUG-1046 Started by Nageswari */
  function loadTable(response,enablePaging) {

	    $('#recordCount span').text(response.length + ' Records');

	    const desiredColumns = ["name", "supertype", "type", "description", "createddate", "owner", "email", "assignee", "currentstate"];

	    const $theadTr = $('#partsTable thead tr');
	    $theadTr.empty();

	    const headerLabels = {
	        name: 'Name',
	        supertype: 'Supertype',
	        type: 'Type',
	        description: 'Description',
	        createddate: 'Created Date',
	        owner: 'Owner',
	        email: 'Email',
	        assignee: 'Assignee',
	        currentstate: 'Status'
	    };

	    const columns = [];

	    desiredColumns.forEach(function (key) {

	        $theadTr.append('<th>' + (headerLabels[key] || key) + '</th>');

	        if (key === 'name') {

	            columns.push({
	                data: 'name',
	                render: function (data, type, row) {

	                    if (!data) return '';

	                    return '<a href="Partcontroldetails.jsp?name=' +
	                        encodeURIComponent(row.objectid) +
	                        '" class="part-link"><i class="fa-regular fa-file-lines"></i>' +
	                        data + '</a>';
	                }
	            });

	        } else if (key === 'createddate') {

	            columns.push({
	                data: 'createddate',
	                render: function (data) {

	                    const date = new Date(data);

	                    return !isNaN(date.getTime())
	                        ? date.toLocaleString()
	                        : (data || '');
	                }
	            });

	        } else if (key === 'owner' || key === 'assignee') {

	            columns.push({
	                data: key,
	                render: function (data) {

	                    if (!data) return 'N/A';

	                    return '<div class="person-cell"><i class="fa-regular fa-user"></i>' +
	                        data +
	                        '</div>';
	                }
	            });

	        } else if (key === 'email') {

	            columns.push({
	                data: 'email',
	                render: function (data) {

	                    if (!data) return 'N/A';

	                    return '<div class="email-cell"><i class="fa-regular fa-envelope"></i>' +
	                        data +
	                        '</div>';
	                }
	            });

	        } else if (key === 'currentstate') {

	            columns.push({
	                data: 'currentstate',
	                render: function (data) {

	                    if (!data) return '';

	                    return '<span class="state-badge ' +
	                        data.replace(/\s+/g, '') +
	                        '">' +
	                        data +
	                        '</span>';
	                }
	            });

	        } else {

	            columns.push({
	                data: key,
	                render: function (data) {
	                    return data || 'N/A';
	                }
	            });

	        }

	    });

	    $('#partsTable').DataTable({
	        data: response,
	        columns: columns,
	        /* BUG-1046 Started by Nageswari */
	        paging: enablePaging,
	        pageLength: 10,
	        /* BUG-1046 Ended by Nageswari */
	        searching: false,
	        info: false,
	        ordering: true,
	        lengthChange: false,
	        destroy: true
	    });

	}
  /* BUG-1046 Ended by Nageswari */
  $(document).ready(function () {

	    // Load all Part Controls on page load
	    $.ajax({
	        url: BASIC_URL + '/api/datafetchservice/getallpartcontrol',
	        method: 'GET',
	        dataType: 'json',

	        success: function (response) {

	            if (!Array.isArray(response) || response.length === 0) {
	                $('#errorMessage').text('No part control data found.');
	                return;
	            }

	            loadTable(response,false);
	        },

	        error: function (xhr, status, error) {
	            console.error('Error:', error);
	            $('#errorMessage').text('Failed to fetch part control data.');
	        }
	    });

	    // BUG-1046 Started By Nageswari
	    $('#showMyPartControls').click(function () {

	        $.ajax({
	            url: BASIC_URL + '/api/datafetchservice/mypartcontrols',
	            method: 'GET',
	            dataType: 'json',

	            success: function (response) {

	                if (!Array.isArray(response)) {
	                    $('#errorMessage').text('No part control data found.');
	                    return;
	                }

	                loadTable(response,true);

	                if (response.length === 0) {
	                    alert("No records to display for the current user.");
	                }
	            },

	            error: function (xhr, status, error) {
	                console.error('Error:', error);
	                $('#errorMessage').text('Failed to fetch current user part controls.');
	            }

	        });

	    });
	    // BUG-1046 Ended By Nageswari

	});
  </script>
</body>
</html>