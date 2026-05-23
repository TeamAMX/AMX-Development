<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>AMX Navigator Persons</title>

  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

 <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
  body {
    font-family: 'Inter', sans-serif;
    padding: 28px 24px;
    background-color: #f7f9fa;
  }

  h1 {
    text-align: center;
    font-size: 22px;
    font-weight: 700;
    color: #2b303a;
    margin-bottom: 24px;
  }

  .container {
    background: #ffffff;
    border: 1px solid #e2e5e9;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  }

  /* Header row */
  table.dataTable thead tr {
    background-color: #1f2937 !important;
  }
  table.dataTable thead th {
    font-family: 'Inter', sans-serif !important;
    font-size: 11.5px !important;
    font-weight: 700 !important;
    color: #ffffff !important;
    letter-spacing: 0.6px !important;
    text-transform: uppercase !important;
    padding: 14px 18px !important;
    border-bottom: none !important;
    background-color: #1f2937 !important;
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
  }

  /* Body rows */
  table.dataTable tbody tr {
    border-bottom: 1px solid #e2e5e9 !important;
  }
  table.dataTable tbody tr:last-child {
    border-bottom: none !important;
  }
  table.dataTable tbody tr:hover {
    background-color: #f3f4f6 !important;
  }
  table.dataTable tbody td {
    font-family: 'Inter', sans-serif !important;
    font-size: 13px !important;
    color: #2b303a !important;
    padding: 10px 18px !important;
    vertical-align: middle !important;
    border-top: none !important;
    background-color: transparent !important;
  }

  /* Username link */
  table.dataTable a {
    color: #374151;
    text-decoration: none;
    font-weight: 500;
  }
  table.dataTable a:hover {
    text-decoration: underline;
    color: #111827;
  }

  /* Country flag + name */
  .country-cell {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  /* Access badges */
  .badge-access {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 4px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
    border: 1.5px solid transparent;
  }
  .badge-reader { background: #e8f0f7; color: #005686;  border-color: #b3cfe8; }
  .badge-leader { background: #e6f4ea; color: #1e7e34;  border-color: #a8d5b0; }
  .badge-admin  { background: #fde8e8; color: #c0392b;  border-color: #f5b0aa; }
  .badge-author { background: #fff4e5; color: #b76e00; border-color: #f5c98a; }
  .badge-default{ background: #f1f3f5; color: #626974;  border-color: #d1d5db; }

  .error { text-align: center; margin: 20px 0; color: #c0392b; }

  /* Hide default DataTables UI */
  .dataTables_info,
  .dataTables_paginate,
  .dataTables_length,
  .dataTables_filter { display: none !important; }
</style>

</head>
<body>
  <h1>Persons List</h1>
  <div class="container">
    <table id="personsTable" class="display" style="width:100%">
      <thead>
        <tr>
          <th>Username</th>
          <th>Firstname</th>
          <th>Lastname</th>
          <th>Country</th>
          <th>Email</th>
          <th>Access</th>
        </tr>
      </thead>
      <tbody></tbody>
    </table>
    <div class="error" id="errorMessage"></div>
  </div>

  <script>
    $(document).ready(function () {
      $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/persons',
        method: 'GET',
        dataType: 'json',
        success: function (data) {
          if (!Array.isArray(data) || data.length === 0) {
            $('#errorMessage').text('No persons data found.');
            return;
          }

          $('#personsTable').DataTable({
    		data: data,
    		columns: [
        {
            data: 'Username',
            render: function (data, type, row) {
                return '<a href="PersonProperties.jsp?name=' + encodeURIComponent(row.ObjectId) + '" class="part-link">' + data + '</a>';
            }
        },
        { data: 'Firstname' },
        { data: 'Lastname' },
        {
        	  data: 'Country',
        	  render: function (data, type) {
        		  if (type === 'display') {
        		    const flagCodes = {
        		      'australia':     'au',
        		      'canada':        'ca',
        		      'germany':       'de',
        		      'india':         'in',
        		      'united states': 'us'
        		    };
        		    const code = flagCodes[(data || '').toLowerCase()];
        		    const flagImg = code
        		      ? '<img src="https://flagcdn.com/20x15/' + code + '.png" width="20" height="15" style="border-radius:2px; vertical-align:middle;" />'
        		      : '';
        		    return '<div class="country-cell">' + flagImg + '<span>' + (data || '') + '</span></div>';
        		  }
        		  return data;
        		}
        	},
        { data: 'Email' },
        {
        	  data: 'Access',
        	  render: function (data, type) {
        	    if (type === 'display') {
        	    	const cls = {
        	    			  reader: 'badge-reader',
        	    			  author: 'badge-author',
        	    			  leader: 'badge-leader',
        	    			  admin:  'badge-admin'
        	    			};
        	      const badge = cls[(data || '').toLowerCase()] || 'badge-default';
        	      return '<span class="badge-access ' + badge + '">' + (data || '') + '</span>';
        	    }
        	    return data;
        	  }
        	}
    ],
    paging: false,
    searching: false,
    info: false,
    ordering: true,
    lengthChange: false,
    destroy: true
});
},
        error: function (xhr, status, error) {
          console.error('Error fetching persons:', error);
          $('#errorMessage').text('Failed to fetch persons data.');
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
            window.location.href = url;
          }
        } else {
          window.location.href = url; 
        }
      });
    });
  </script>
</body>
</html>
