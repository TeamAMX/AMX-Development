<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Andromeda Parts</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
  <link rel="stylesheet" href="styles/amxNavigatorParts.css" />
  
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<!--   BUG-1046 started by Nageswari -->
  <style>
    html,
body {
    overflow-y: hidden;
    overflow-x:hidden;
}
  .toolbar{
    background:#1f2937;
    height:40px;
    display:flex;
    align-items:center;
    padding:0 15px;
     margin:5px 0 5px 0;
}

.toolbar-icon{
    color:#fff;
    font-size:24px;
    cursor:pointer;	
    padding:8px;
}

.toolbar-icon:hover{
    background:#666;
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
/* BUG-1074 started by Tharun */
 .table-scroll {
    height: 67vh;
    overflow-y: auto;
    overflow-x: auto;
}
 /* BUG-1074 ended by Tharun */
</style>
<!-- BUG-1046 Ended by Nageswari -->
</head>
<body>

  <div class="page-header">
  <div class="header-left">
    <div class="header-icon">
      <i class="fa-solid fa-cubes"></i>
    </div>
    <div class="header-content">
      <div class="header-title">Parts List</div>
      <div class="header-subtitle">
        View and manage part information
      </div>
    </div>
  </div>
  <div class="header-right">
    <i class="fa-solid fa-list"></i>
    <span id="recordCount">0 Records</span>
  </div>
</div>
<!-- BUG-1046 started by Nageswari -->
<div class="toolbar">
    <i class="fa-solid fa-address-card toolbar-icon"
       id="showAllParts"
       title="Show All My Parts"></i>
</div>
<!-- BUG-1046 Ended by Nageswari -->
  <div class="table-container shadow-sm">
  <div class="table-scroll">
    <table id="partsTable" class="table table-hover m-0" style="width:100%">
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
//BUG-1046 Started By Nageswari
var desiredHeaders = ['name', 'apn', 'supertype', 'type', 'description', 'createddate', 'owner', 'email', 'currentstate'];

function loadTable(data,enablePaging) {

    $('#recordCount').text(data.length + ' Records');

    $('#partsTable thead tr').empty();
    $('#partsTable tbody').empty();

    desiredHeaders.forEach(header => {
        const displayName = header.charAt(0).toUpperCase() + header.slice(1);
        $('#partsTable thead tr').append('<th>' + displayName + '</th>');
    });

    const dtColumns = desiredHeaders.map(field => {

        if (field === 'name') {
            return {
                data: field,
                render: function (data, type, row) {
                    return '<a href="Properties.jsp?name=' +
                        encodeURIComponent(row.objectid) +
                        '" class="part-link">' + data + '</a>';
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
                    return '<span class="state-badge ' +
                        data.replace(/\s/g,'') +
                        '">' + data + '</span>';
                }
            };
        }

        return {
            data: field,
            defaultContent: ''
        };
    });

    $('#partsTable').DataTable({
        data:data,
        columns:dtColumns,
        paging:enablePaging,
        pageLength:10,
        searching:false,
        info:false,
        ordering:true,
        lengthChange:false,
        destroy:true
    });
}
//BUG-1046 Ended By Nageswari
  $(document).ready(function () {
    
    $.ajax({
      url: BASIC_URL+'/api/datafetchservice/latestparts',
      method: 'GET',
      dataType: 'json',
      success: function (data) {
    	  if (!Array.isArray(data)) {
    	        $('#errorMessage').text('No parts data found.');
    	        return;
    	    }

    	    loadTable(data,false);
      },
      error: function (xhr, status, error) {
        console.error('Error fetching parts:', error);
        $('#errorMessage').text('Failed to fetch parts data.');
      }
    });
    //BUG-1046 Started By Nageswari
    $('#showAllParts').click(function () {

        $.ajax({
            url: BASIC_URL + '/api/datafetchservice/mycreatedparts',
            method: 'GET',
            dataType: 'json',

            success: function (data) {

                if (!Array.isArray(data)) {
                    $('#errorMessage').text('No parts data found.');
                    return;
                }

                loadTable(data,true);

                if (data.length === 0) {
                    alert("No records to display for the current user.");
                }
            },

            error: function (xhr, status, error) {
                console.error('Error fetching current user parts:', error);
                $('#errorMessage').text('Failed to fetch current user parts.');
            }
        });

    });

    //BUG-1046 Ended By Nageswari
    $(document).on('click', 'a.part-link', function (e) {
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
