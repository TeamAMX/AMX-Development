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
  <style>
</style>
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

  <div class="table-container shadow-sm">
    <table id="partsTable" class="table table-hover m-0" style="width:100%">
      <thead>
        <tr></tr>
      </thead>
      <tbody></tbody>
    </table>
    <div class="error" id="errorMessage"></div>
  </div>
<script>

const BASIC_URL = '<%= request.getContextPath() %>';
  $(document).ready(function () {
    const desiredHeaders = ['name', 'apn', 'supertype', 'type', 'description', 'createddate', 'owner', 'email', 'currentstate'];

    $.ajax({
      url: BASIC_URL+'/api/datafetchservice/latestparts',
      method: 'GET',
      dataType: 'json',
      success: function (data) {
    	  $('#recordCount').text(data.length + ' Records');
        if (!Array.isArray(data) || data.length === 0) {
          $('#errorMessage').text('No parts data found.');
          return;
        }

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
                return '<a href="Properties.jsp?name=' + encodeURIComponent(row.objectid) + '" class="part-link">' + data + '</a>';
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
                return '<span class="state-badge ' + stateClass + '">' + data + '</span>';
              }
            };
          }
          return {
            data: field,
            defaultContent: ''
          };
        });

        $('#partsTable').DataTable({
          data: data,
          columns: dtColumns,
          paging: false,
          searching: false,
          info: false,
          ordering: true,
          lengthChange: false,
          destroy: true
        });
      },
      error: function (xhr, status, error) {
        console.error('Error fetching parts:', error);
        $('#errorMessage').text('Failed to fetch parts data.');
      }
    });

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
