<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Files</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>
  * { box-sizing: border-box; }

  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #f7f9fa;
    color: #333;
  }

  .page-wrapper {
    padding: 24px;
  }

  /* ===== HEADER CARD ===== */
  .list-header-card {
    background: #ffffff;
    border: 1px solid #e2e5e9;
    border-radius: 12px;
    padding: 22px 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  }
  .list-header-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .list-header-icon {
    width: 48px;
    height: 48px;
    border-radius: 10px;
    background: #111827;
    color: #ffffff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
  }
  .list-header-title {
    font-size: 1.4rem;
    font-weight: 700;
    color: #111827;
    margin: 0 0 2px 0;
  }
  .list-header-subtitle {
    font-size: 0.85rem;
    color: #6b7280;
    margin: 0;
  }
  .list-count-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: #f3f4f6;
    border: 1px solid #e5e7eb;
    color: #374151;
    font-size: 13px;
    font-weight: 600;
    padding: 8px 16px;
    border-radius: 10px;
    white-space: nowrap;
  }

  /* ===== TABLE CARD ===== */
  .files-table-card {
    background: #ffffff;
    border: 1px solid #e2e5e9;
    border-radius: 0 0 12px 12px;   /* Top corners square */
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0,0,0,0.04);
}
/* BUG-1086 Started by Nageswari */
 .files-toolbar {
    background-color: #101c33;
    padding: 10px 16px;
    display: flex;
    align-items: center;
    gap: 10px;

    margin-bottom: 2px;
    /* margin-bottom: 4px; */
    border-radius: 0; 
}
 .files-toolbar i {
    color: #ffffff;
    font-size: 24px;
    cursor: pointer;
}
/* BUG-1086 Ended by Nageswari */


  .files-table-scroll {
    width: 100%;
    overflow-x: auto;
  }
 #filesTable {
    width: 100% !important;
    white-space: nowrap;
    border-collapse: separate;
    border-spacing: 0;
}
  /* BUG-1086 Started by Nageswari */
  #filesTable thead th {
    background: #ffffff !important;
    color: #111827 !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.5px !important;
    padding: 12px 26px 12px 12px !important;
    border-bottom: 2px solid #1f2937 !important;
    border-right: none !important;
    white-space: nowrap !important;
    text-align: left;
}
#filesTable thead th:first-child {
    border-top-left-radius: 8px;
}

#filesTable thead th:last-child {
    border-top-right-radius: 8px;
}
/* BUG-1086 Ended by Nageswari */
  #filesTable tbody td {
    padding: 10px 12px !important;
    border-bottom: 1px solid #f1f5f9 !important;
    border-right: none !important;
    vertical-align: middle !important;
    color: #111111 !important;
    background: #ffffff !important;
    font-size: 13px !important;
  }
  #filesTable tbody tr:hover td { background: #E8EAEB !important; }
 #filesTable tbody td.file-name-cell a {
    color: inherit;
    text-decoration: none;
    font-weight: 600;
  }
  #filesTable tbody td.file-name-cell a:hover {
    text-decoration: underline;
  }
  #noFilesMsg {
    padding: 24px;
    text-align: center;
    color: #9ca3af;
    font-size: 13px;
  }

  /* Loading / Error */
  #loadingSpinner {
    display: none;
    width: 36px;
    height: 36px;
    border: 3px solid #e2e5e9;
    border-top: 3px solid #4b5563;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 40px auto;
  }
  @keyframes spin {
    0%   { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  #errorMessage {
    color: #c0392b;
    margin: 20px;
    text-align: center;
    font-size: 13px;
    display: none;
  }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>

<body>

<div class="page-wrapper">

  <div class="list-header-card">
    <div class="list-header-left">
      <div class="list-header-icon"><i class="fa-regular fa-file"></i></div>
      <div>
        <div class="list-header-title">Files</div>
        <div class="list-header-subtitle">View and manage file information</div>
      </div>
    </div>
    <div class="list-count-badge" id="recordCountBadge">
      <i class="fa-solid fa-list"></i>
      <span id="recordCountText">0 Records</span>
    </div>
  </div>

  <div id="loadingSpinner"></div>
  <div id="errorMessage"></div>

  <div class="files-table-card">
  <!-- BUG-1087 Started by Nageswari -->
<div class="files-toolbar">
    <i class="fa-solid fa-address-card"
       id="showMyFiles"
       title="Show All My Files"></i>
</div>
<!-- BUG-1087 Ended by Nageswari -->
    <div class="files-table-scroll">
      <table id="filesTable">
        <thead><tr></tr></thead>
        <tbody></tbody>
      </table>
    </div>
    <div id="noFilesMsg" style="display:none;">No files found.</div>
  </div>

</div>

<script>
const BASIC_URL = '<%= request.getContextPath() %>';

$(document).ready(function () {
  loadFilesTable();
  $("#showMyFiles").click(function () {
	    loadMyFilesTable();
	});

  function showLoading(show) {
    $('#loadingSpinner').css('display', show ? 'block' : 'none');
  }

  function showError(msg) {
    $('#errorMessage').text(msg).show();
    showLoading(false);
  }

  function loadFilesTable() {
    $('#filesTable thead tr').empty();
    $('#filesTable tbody').empty();
    $('#noFilesMsg').hide();
    showLoading(true);

    $.ajax({
      url: BASIC_URL + '/api/datafetchservice/getfilesforpartspec',
      method: 'GET',
      dataType: 'json',
      success: function (files) {
        if (!files || !Array.isArray(files) || files.length === 0) {
          $('#noFilesMsg').show();
          $('#recordCountText').text('0 Records');
          return;
        }

        $('#recordCountText').text(files.length + (files.length === 1 ? ' Record' : ' Records'));

        const excludedFields = ['objectid', 'connectionid', 'linkedobjectid', 'fts_document', 'filedata', 'filename'];
        const allKeys = Object.keys(files[0]).filter(k => !excludedFields.includes(k));

        // Preferred order first, then any remaining columns not explicitly listed
        const preferredOrder = ['name', 'title', 'owner', 'filesize'];
        const keys = preferredOrder.filter(k => allKeys.includes(k))
          .concat(allKeys.filter(k => !preferredOrder.includes(k)));

        const headerRow = $('#filesTable thead tr');
        keys.forEach(function (key) {
          headerRow.append('<th>' + key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' ') + '</th>');
        });
		//Added by Ajay BUG-1088 Enhancement Started
       function formatFileSize(bytes) {
    	                    bytes = Number(bytes);
    	                    if (isNaN(bytes)) return '';
    	                    if (bytes < 1024)
    	                        return bytes + " B";
    	                    else if (bytes < 1024 * 1024)
    	                        return (bytes / 1024).toFixed(2) + " KB";
    	                    else
    	                        return (bytes / (1024 * 1024)).toFixed(2) + " MB";
    	                }

        const tbody = $('#filesTable tbody');
        files.forEach(function (file) {
          let tr = '<tr>';
          keys.forEach(function (key, idx) {
            let value = file[key] || '';
            if (key === 'filesize') {
              value = formatFileSize(value);
            }
            if (idx === 0) {
              const link = 'FileProperties.jsp?name=' + encodeURIComponent(file.objectid || '');
              tr += '<td class="file-name-cell"><a href="' + link + '">' + value + '</a></td>';
            } else {
              tr += '<td>' + value + '</td>';
            }
          });
          tr += '</tr>';
          tbody.append(tr);
        });
		//Added by Ajay BUG-1088 Enhancement Ended

      },
      error: function () {
        showError('Failed to load files.');
      },
      complete: function () {
        showLoading(false);
      }
    });
  }
  function loadMyFilesTable() {

	    $('#filesTable thead tr').empty();
	    $('#filesTable tbody').empty();
	    $('#noFilesMsg').hide();
	    showLoading(true);

	    $.ajax({
	        url: BASIC_URL + '/api/datafetchservice/myfiles',
	        method: 'GET',
	        dataType: 'json',

	        success: function(files) {

	            if (!files || files.length === 0) {
	                $('#noFilesMsg').show();
	                $('#recordCountText').text('0 Records');
	                return;
	            }

	            $('#recordCountText').text(files.length + (files.length === 1 ? ' Record' : ' Records'));

	            const excludedFields = ['objectid','connectionid','linkedobjectid','fts_document','filedata','filename'];
	            const allKeys = Object.keys(files[0]).filter(k => !excludedFields.includes(k));

	            const preferredOrder = ['name','title','owner','filesize'];
	            const keys = preferredOrder.filter(k => allKeys.includes(k))
	                    .concat(allKeys.filter(k => !preferredOrder.includes(k)));

	            const headerRow = $('#filesTable thead tr');

	            keys.forEach(function(key){
	                headerRow.append('<th>' + key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g,' ') + '</th>');
	            });

	            const tbody = $('#filesTable tbody');

	            files.forEach(function(file){

	                let tr = "<tr>";

	                keys.forEach(function(key,index){

	                    if(index==0){
	                        tr += '<td class="file-name-cell">'+(file[key]||"")+'</td>';
	                    }else{
	                        tr += '<td>'+(file[key]||"")+'</td>';
	                    }

	                });

	                tr+="</tr>";

	                tbody.append(tr);

	            });

	           

	        },
	        error: function(xhr, status, error) {
	            console.log(xhr.responseText);
	            console.log(status);
	            console.log(error);
	            showError("Failed to load My Files.");
	        },
	        complete:function(){
	            showLoading(false);
	        }
	    });

	}
});
</script>
</body>
</html>
