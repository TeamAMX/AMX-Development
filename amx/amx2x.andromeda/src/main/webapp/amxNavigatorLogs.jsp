<!DOCTYPE html>
<!-- BUG-1094 new AI logs tab started by Tharun -->
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Server Log Analysis</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

  <style>
    * { box-sizing: border-box; }
    html,
    body {
        overflow-y: hidden;
        overflow-x: hidden;
    }
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
      display: none !important;
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

    /* Message / text cell (plain text, no link) */
    table.dataTable td.text-cell {
      color: #1f2937;
      font-weight: 600;
      white-space: normal !important;
      max-width: 320px;
    }

    table.dataTable td.wrap-cell {
      white-space: normal !important;
      max-width: 260px;
    }

    /* Location cell */
    .location-cell {
      display: flex;
      align-items: center;
      gap: 6px;
      color: #374151;
    }
    .location-cell i { color: #9ca3af; font-size: 12px; }

    /* ===== SEVERITY BADGES ===== */
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
    .state-badge.ERROR      { background: #fee2e2; color: #b91c1c; }
    .state-badge.SEVERE     { background: #1f2937; color: #ffffff; }
    .state-badge.CRITICAL   { background: #1f2937; color: #ffffff; }
    .state-badge.WARNING    { background: #fef3c7; color: #92400e; }
    .state-badge.INFO       { background: #dbeafe; color: #1d4ed8; }
    .state-badge.EXCEPTION  { background: #fee2e2; color: #b91c1c; }
    .state-badge.DEFAULT    { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }

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
      height: 67vh;
      overflow-y: auto;
      overflow-x: auto;
    }
    .toolbar {
        background: #1f2937;
        height: 40px;
        display: flex;
        align-items: center;
        padding: 0 15px;
        margin: 5px 0;
    }

    .toolbar-icon {
        color: #fff;
        font-size: 24px;
        cursor: pointer;
        padding: 8px;
    }

    .toolbar-icon:hover {
        background: #374151;
        border-radius: 4px;
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
 .table-container {
    position: relative;
    background: #ffffff;
    border-radius: 12px;
    border: 1px solid #e2e5e9;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0,0,0,0.04);
}

.ai-loader-overlay {
    position: absolute;
    inset: 0;
    background: rgba(255, 255, 255, 0.88);
    backdrop-filter: blur(3px);
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 100;
}

.ai-loader {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.ai-scanner {
    position: relative;
    width: 120px;
    height: 120px;
    display: flex;
    justify-content: center;
    align-items: center;
    overflow: hidden;
    border-radius: 16px;
    border: 1px solid rgba(0, 140, 255, 0.3);
    box-shadow: 0 0 15px rgba(0, 140, 255, 0.3),
                inset 0 0 15px rgba(0, 140, 255, 0.2);
}

.ai-loader-image {
    width: 80px;
    height: 80px;
    object-fit: contain;
    filter: drop-shadow(0 0 5px #008cff)
            drop-shadow(0 0 15px rgba(0, 140, 255, 0.8));
    animation: aiImagePulse 1.5s ease-in-out infinite;
}

.scan-line {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 3px;
    background: #00aaff;
    box-shadow: 0 0 8px #00aaff,
                0 0 15px #00aaff;
    z-index: 10;
    animation: aiScanning 2s ease-in-out infinite;
}

.ai-loader-title {
    margin-top: 18px;
    font-size: 25px;
    font-weight: 700;
    letter-spacing: 2px;
    color: #111827;
}

.ai-loader-status {
    margin-top: 8px;
    font-size: 13px;
    color: #6b7280;
}

.ai-dots span {
    color: #008cff;
    font-size: 18px;
    font-weight: bold;
    animation: aiDotAnimation 1.4s infinite;
}

.ai-dots span:nth-child(2) {
    animation-delay: 0.2s;
}

.ai-dots span:nth-child(3) {
    animation-delay: 0.4s;
}

@keyframes aiScanning {
    0% { top: 0; }
    50% { top: 117px; }
    100% { top: 0; }
}

@keyframes aiImagePulse {
    0%, 100% { transform: scale(0.95); }
    50% { transform: scale(1.08); }
}

@keyframes aiDotAnimation {
    0%, 80%, 100% { opacity: 0; }
    40% { opacity: 1; }
}
.ai-header-icon {
       background: linear-gradient(135deg, #2f3137, #acacad);;
    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25);
}

.ai-header-icon i {
    font-size: 22px;
    color: #fff;
}
    
  </style>
</head>
<body>

  <!-- Page Header -->
  <div class="page-header">
    <div class="page-header-left">
      <div class="page-icon ai-header-icon">
    	<i class="fa-solid fa-microchip"></i>
	  </div>
      <div class="page-title">
        <h1>Server Log Analysis</h1>
        <p>View analyzed server log issues and root causes</p>
      </div>
    </div>
    <div class="record-count" id="recordCount">
      <i class="fa-solid fa-list"></i>
      <span>-- Records</span>
    </div>
  </div>

  <div class="toolbar">
    <i class="fa-solid fa-arrows-rotate toolbar-icon"
       id="refreshLogs"
       title="Re-analyze Logs"></i>
  </div>

  <div class="table-container">

    <!-- AI LOADER -->
    <div id="aiLoaderOverlay" class="ai-loader-overlay">
        <div class="ai-loader">
            <div class="ai-scanner">
                <div class="scan-line"></div>

                <img
                    src="images/istockphoto-22101622.png"
                    class="ai-loader-image"
                    alt="AMX AI">
            </div>

            <div class="ai-loader-title">AMX AI</div>

            <div class="ai-loader-status">
                Analyzing server logs
                <span class="ai-dots">
                    <span>.</span><span>.</span><span>.</span>
                </span>
            </div>
        </div>
    </div>

    <!-- TABLE -->
    <div class="table-scroll">
        <table id="logsTable" style="width:100%">
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

  function loadTable(response, enablePaging) {

      const issues = Array.isArray(response) ? response : (response && response.issues ? response.issues : []);

      $('#recordCount span').text(issues.length + ' Records');

      const desiredColumns = ["type", "severity", "message", "class", "method", "file", "line", "probableCause", "suggestedSolution"];

      const $theadTr = $('#logsTable thead tr');
      $theadTr.empty();

      const headerLabels = {
          type: 'Type',
          severity: 'Severity',
          message: 'Message',
          class: 'Class',
          method: 'Method',
          file: 'File',
          line: 'Line',
          probableCause: 'Probable Cause',
          suggestedSolution: 'Suggested Solution'
      };

      const columns = [];

      desiredColumns.forEach(function (key) {

          $theadTr.append('<th>' + (headerLabels[key] || key) + '</th>');

          if (key === 'severity') {

              columns.push({
                  data: 'severity',
                  render: function (data) {

                      if (!data) return '';

                      const cssClass = String(data).toUpperCase().replace(/\s+/g, '');
                      const knownClasses = ['ERROR', 'SEVERE', 'CRITICAL', 'WARNING', 'INFO', 'EXCEPTION'];
                      const badgeClass = knownClasses.includes(cssClass) ? cssClass : 'DEFAULT';

                      return '<span class="state-badge ' + badgeClass + '">' + data + '</span>';
                  }
              });

          } else if (key === 'message') {

              columns.push({
                  data: 'message',
                  render: function (data) {
                      return '<div class="text-cell">' + (data || 'N/A') + '</div>';
                  }
              });

          } else if (key === 'probableCause' || key === 'suggestedSolution') {

              columns.push({
                  data: key,
                  render: function (data) {
                      return '<div class="wrap-cell">' + (data || 'N/A') + '</div>';
                  }
              });

          } else if (key === 'class' || key === 'method' || key === 'file') {

              columns.push({
                  data: key,
                  render: function (data, type, row) {

                      const value = row.location ? row.location[key] : data;

                      if (!value) return 'N/A';

                      return '<div class="location-cell"><i class="fa-regular fa-file-code"></i>' +
                          value +
                          '</div>';
                  }
              });

          } else if (key === 'line') {

              columns.push({
                  data: key,
                  render: function (data, type, row) {

                      const value = row.location ? row.location.line : data;

                      return (value === undefined || value === null) ? 'N/A' : value;
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

      $('#logsTable').DataTable({
          data: issues,
          columns: columns,
          paging: enablePaging,
          pageLength: 10,
          searching: false,
          info: false,
          ordering: true,
          lengthChange: false,
          destroy: true
      });

  }

  function fetchLogs() {
	    $('#aiLoaderOverlay').css('display', 'flex');

	    $.ajax({
	        url: BASIC_URL + '/api/logs/analyze',
	        method: 'GET',
	        dataType: 'json',

	        success: function(response) {
	            const issues = Array.isArray(response)
	                ? response
	                : (response && response.issues ? response.issues : []);

	            if (!issues || issues.length === 0) {
	                $('#errorMessage').text('No log issues found.');
	                loadTable({ issues: [] }, false);
	                return;
	            }

	            $('#errorMessage').text('');
	            loadTable(response, false);
	        },

	        error: function(xhr, status, error) {
	            console.error('Error:', error);
	            $('#errorMessage').text('Failed to fetch log analysis data.');
	        },

	        complete: function() {
	            $('#aiLoaderOverlay').fadeOut(300);
	        }
	    });
	}

  $(document).ready(function () {

      fetchLogs();

      // Re-analyze / refresh logs on toolbar click
      $('#refreshLogs').click(function () {
          fetchLogs();
      });

  });
  </script>
</body>
<!-- BUG-1094 ended -->
</html>
