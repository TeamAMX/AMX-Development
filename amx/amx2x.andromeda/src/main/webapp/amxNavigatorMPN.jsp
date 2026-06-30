<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Andromeda MPNs</title>

  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

  <style>
  /* BUG-1032 Started by Nageswari */
  html,
body {
    overflow-y: hidden;
    overflow-x:hidden;
}
/* BUG-1032 Ended by Nageswari */
    body {
  font-family: 'Inter', sans-serif;
  padding: 28px 24px;
  background-color: #f7f9fa;
  color: #333333;
  font-size: 13px;
}

    .error {
      text-align: center;
      margin-top: 20px;
      color: red;
    }

    table.dataTable a {
      color: #007bff;
      text-decoration: none;
      text-wrap-mode: nowrap;
    }

    table.dataTable a:hover {
      text-decoration: underline;
    }

    .state-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  min-width: 92px;
}
.state-badge.InWork {
  background: #dbeafe;
  color: #1d4ed8;
}

.state-badge.Frozen {
  background: #e5e7eb;
  color: #374151;
}

.state-badge.Released {
  background: #dcfce7;
  color: #166534;
}

.state-badge.Obsolete {
  background: #fef3c7;
  color: #92400e;
}
    /* ===== PAGE HEADER ===== */

.page-header {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 14px 14px 0 0;
  padding: 20px 24px;
  border-bottom: none;
  box-sizing: border-box;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 14px;
}

.header-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 17px;
  flex-shrink: 0;
}

.header-content {
  display: flex;
  flex-direction: column;
}

.header-title {
  font-size: 24px;
  font-weight: 700;
  color: #111827;
  line-height: 1.1;
  margin-bottom: 4px;
}

.header-subtitle {
  font-size: 13px;
  color: #6b7280;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  padding: 8px 14px;
  border-radius: 10px;
  font-size: 13px;
  color: #374151;
  font-weight: 600;
  white-space: nowrap;
}

.table-container {
  width: 100%;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-top: none;
  border-radius: 0 0 14px 14px;
  overflow: hidden;
}
/* BUG-1032 Started by Nageswari */
.table-scroll {
  max-height:315px;
  overflow-y: auto;
  overflow-x: scroll;
  position: relative;
}
/* BUG-1032 Ended by Nageswari */
#mpnTable thead th {
  position: sticky !important;
  top: 0;
  z-index: 100;
  background: #1e293b !important;
  box-shadow: 0 1px 0 rgba(255,255,255,0.06);
}


/* ===== MODERN TABLE STYLE ===== */

table.dataTable,
table.dataTable.no-footer {
  border: none !important;
  margin: 0 !important;
}

table.dataTable thead th {
  background: #1e293b !important;
  color: #ffffff !important;
  font-size: 11px !important;
  font-weight: 700 !important;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 14px 16px !important;
  border-bottom: none !important;
  border-right: 1px solid rgba(255,255,255,0.08);
  white-space: nowrap;
  padding-right: 30px !important; 
  position: relative;
}
.filter-input {
    display: block;
    width: 100%;
    margin-top: 5px;
    font-weight: normal;
    padding: 2px 5px;
}

table.dataTable thead th:first-child {
  border-top-left-radius: 10px;
}

table.dataTable thead th:last-child {
  border-top-right-radius: 10px;
}

table.dataTable tbody td {
  font-family: 'Inter', sans-serif !important;
  padding: 8px 16px !important;
  border-bottom: 1px solid #eef2f7 !important;
  font-size: 13px !important;
  color: rgb(0, 0, 0) !important;
  vertical-align: middle;
  white-space: nowrap;
}

table.dataTable tbody tr {
  transition: background 0.15s ease;
}

table.dataTable tbody tr:hover {
  background: #f8fafc !important;
}

/* Links */

table.dataTable a.mpn-link {
  color:black !important;
  font-weight: 600;
  text-decoration: none;
}

table.dataTable a.mpn-link:hover {
  text-decoration: underline;
}

/* Sort icons */

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

/* Remove default DataTables spacing */

.dataTables_wrapper .dataTables_length,
.dataTables_wrapper .dataTables_filter,
.dataTables_wrapper .dataTables_info {
  display: none !important;
}
    /* BUG-1046 Started By Nageswari */
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
/* BUG-1046 Ended By Nageswari */
  </style>
</head>
<body>
  <div class="page-header">

  <div class="header-left">
    <div class="header-icon">
      <i class="fa-solid fa-barcode"></i>
    </div>
    <div class="header-content">
      <div class="header-title">MPN List</div>
      <div class="header-subtitle">
        View and manage manufacturer part information
      </div>
    </div>
  </div>
  <div class="header-right">
    <i class="fa-solid fa-list"></i>
    <span id="recordCount">0 Records</span>
  </div>
</div>
<!-- BUG-1046 Started By Nageswari -->
<div class="toolbar">
    <i class="fa-solid fa-address-card toolbar-icon"
       id="showMyMPNs"
       title="Show All My MPNs"></i>
</div>
<!-- BUG-1046 Ended By Nageswari -->
<div class="table-container">
  <div class="table-scroll">
    <table id="mpnTable" class="display" style="width:100%">
      <thead>
        <tr></tr>
      </thead>
      <tbody></tbody>
    </table>
    </div>
    <div class="error" id="errorMessage"></div>
  </div>

  <script>
  const BASIC_URL = '<%= request.getContextPath() %>';
  const desiredHeaders = ['name', 'manufacturer', 'supertype', 'type', 'description', 'createddate', 'owner', 'email', 'currentstate'];

  /* BUG-1046 Started By Nageswari */
  function loadTable(data,enablePaging) {

      $('#recordCount').text(data.length + ' Records');

      $('#mpnTable thead tr').empty();
      $('#mpnTable tbody').empty();

      desiredHeaders.forEach(header => {
          const displayName = header.charAt(0).toUpperCase() + header.slice(1);
          $('#mpnTable thead tr').append('<th>' + displayName + '</th>');
      });

      const dtColumns = desiredHeaders.map(field => {

          if (field === 'name') {
              return {
                  data: field,
                  render: function (data, type, row) {
                      return '<a href="MPNProperties.jsp?name=' +
                          encodeURIComponent(row.objectid) +
                          '" class="mpn-link">' + data + '</a>';
                  }
              };
          }

          if (field === 'createddate') {
              return {
                  data: field,
                  render: function (data) {
                      if (!data) return '';
                      const date = new Date(data);
                      if (isNaN(date.getTime())) return data;
                      return date.toLocaleDateString();
                  }
              };
          }

          if (field === 'currentstate') {
              return {
                  data: field,
                  render: function (data) {
                      if (!data) return '';
                      const stateClass = data.replace(/\s/g, '');
                      return '<span class="state-badge ' +
                          stateClass +
                          '">' +
                          data +
                          '</span>';
                  }
              };
          }

          return {
              data: field,
              defaultContent: ''
          };
      });

      $('#mpnTable').DataTable({
          data: data,
          columns: dtColumns,

          // BUG-1046 Started By Nageswari
          paging: enablePaging,
          pageLength: 10,
          // BUG-1046 Ended By Nageswari

          searching: false,
          info: false,
          ordering: true,
          lengthChange: false,
          destroy: true
      });

  }
  /* BUG-1046 Ended By Nageswari */
    $(document).ready(function () {
      
      $.ajax({
        url: BASIC_URL+'/api/datafetchservice/latestmpns',
        method: 'GET',
        dataType: 'json',
        success: function (data) {
        	
        	if (!Array.isArray(data)) {
        	    data = [];
        	}

        	loadTable(data,false);
        },
        error: function (xhr, status, error) {
          console.error('Error fetching MPNs:', error);
          $('#errorMessage').text('Failed to fetch MPN data.');
        }
      });
   // BUG-1046 Started By Nageswari
      $('#showMyMPNs').click(function () {

          $.ajax({
              url: BASIC_URL + '/api/datafetchservice/mympns',
              method: 'GET',
              dataType: 'json',

              success: function (data) {

            	  if (!Array.isArray(data)) {
            		    data = [];
            		}

            		loadTable(data,true);

            		if (data.length === 0) {
            		    alert("No records to display for the current user.");
            		}
              },

              error: function (xhr, status, error) {
                  console.error(error);
                  $('#errorMessage').text('Failed to fetch current user MPNs.');
              }

          });

      });
      // BUG-1046 Ended By Nageswari
      $(document).on('click', 'a.mpn-link', function (e) {
        e.preventDefault();
        const url = $(this).attr('href');
        if (window.parent && window.parent.document) {
          const iframe = window.parent.document.querySelector('iframe[name="contentFrame"]');
          if (iframe) {
            iframe.src = url;
          } else {
            console.warn('Iframe not found in parent window.');
          }
        }
      });
    });
  </script>
</body>
</html>
