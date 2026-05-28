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
<title>LifeCycle</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<style>
  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }

  /* ===== TOPBAR ===== */
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
  .topbar > div:last-child { border-right: 1px solid #cfd3db; }
  .topbar > div:not(:last-child) { margin-right: -1px; }
  .part-number {
    font-weight: 700;
    font-size: 14px;
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
  .state-label { margin-right: 4px; }
  .info-box {
    font-size: 11px;
    color: #666;
    padding-left: 4px;
    line-height: 1.3;
  }
  .vertical-line img { height: 20px; width: 1px; margin: 0 10px; }

  /* ===== LAYOUT ===== */
  .container {
    display: flex;
    height: calc(100vh - 56px);
    overflow: hidden;
    width: 100%;
    font-size: 13px;
  }

  /* ===== SIDEBAR ===== */
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
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    color: #4b5563;
    text-decoration: none;
    margin-bottom: 6px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 500;
    transition: all 0.15s ease;
  }
  .sidebar a:hover {
    background-color: #e3e7ea;
    color: #111827;
  }
  .sidebar a.active {
    background-color: #4b5563;
    color: white;
    font-weight: 600;
  }
  .sidebar a i {
    width: 16px;
    font-size: 13px;
    color: #6b7280;
  }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
    flex-grow: 1;
    padding: 0;
    overflow-y: auto;
    min-width: 0;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
  }

  /* ===== TOOLBAR ===== */
  .toolbar {
    background-color: #000000;
    padding: 8px 14px;
    display: flex;
    align-items: center;
    gap: 10px;
    border-bottom: 1px solid #334155;
    margin: 0;
  }
  .toolbar h4 {
    margin: 0;
    font-size: 13px;
    font-weight: 600;
    color: #e2e8f0;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }
  .toolbar .lifecycle-icon {
    width: 18px;
    height: 18px;
    filter: invert(1);
  }

  /* ===== STATE BADGES (topbar) ===== */
  .state-box .state-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 999px;
    font-weight: 600;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    text-align: center;
  }
  .state-badge.InWork   { background: #dbeafe; color: #1d4ed8; }
  .state-badge.Frozen   { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
  .state-badge.Released { background: #dcfce7; color: #166534; }
  .state-badge.Obsolete { background: #fef9c3; color: #854d0e; }

  /* ===== LIFECYCLE AREA ===== */
  .lifecycle-wrapper {
    padding: 32px 24px;
  }

  .lifecycle-section-title {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    color: #9ca3af;
    margin-bottom: 24px;
  }

  .lifecycle-flow {
  display: flex;
  align-items: center;
  gap: 0;
  flex-wrap: nowrap;
  overflow-x: visible;
}
  .state-node {
    position: relative;
    padding: 10px 18px;
    color: white;
    border-radius: 8px;
    font-weight: 600;
    font-size: 12px;
    text-align: center;
    min-width: 90px;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 0 2px 6px rgba(0,0,0,0.15);
    user-select: none;
  }

  .state-node:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(0,0,0,0.2);
  }

  .state-node.active {
  box-shadow: 0 0 0 3px #1f2937, 0 0 0 5px rgba(31,41,55,0.15);
}

  /* State colors — same as existing */
  #stateInWork   { background: #5bc0de; }
  #stateFrozen   { background: #6c757d; }
  #stateReleased { background: #28a745; }
  #stateObsolete { background: #ffc107; color: #000; }

  /* Arrow */
  .arrow {
    margin: 0 12px;
    font-size: 20px;
    color: #d1d5db;
    flex-shrink: 0;
  }

  @keyframes arrowPulse {
    0%   { color: #d1d5db; transform: scale(1); }
    50%  { color: #6b7280; transform: scale(1.4); }
    100% { color: #d1d5db; transform: scale(1); }
  }
  .arrow.animate { animation: arrowPulse 0.8s ease-in-out; }

  /* State message */
  #stateMessages {
    margin-top: 20px;
    font-size: 13px;
    font-weight: 500;
    color: #166534;
    background: #dcfce7;
    border: 1px solid #a8d5b0;
    border-radius: 6px;
    padding: 10px 14px;
    display: none;
  }
  #stateMessages.error {
    color: #c0392b;
    background: #fde8e8;
    border-color: #f5b0aa;
  }

  /* Loading spinner */
  #loadingSpinner {
    display: none;
    width: 20px;
    height: 20px;
    border: 3px solid #e2e5e9;
    border-top: 3px solid #4b5563;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin-top: 16px;
  }
  @keyframes spin {
    0%   { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  #errorMessage {
    margin-top: 12px;
    font-size: 13px;
    color: #c0392b;
    font-weight: 500;
  }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
<div class="topbar">
  <div class="left-section">
    <div class="image-box">
            <img id="typeIcon" src="" alt="Type Icon" />
      </div>
    <div class="part-info">
      <div class="part-number" style="font-weight: 700; font-size: 14px;"></div>
      <div class="part-type" style="font-size: 12px; color: #666; margin-top: 2px;"></div>
    </div>
    <div class="vertical-line"></div>
  </div>
  <div class="right-section">
    <div class="state-box">
      <span class="state-label">State:</span>
    </div>
    <div class="vertical-line"></div>
    <div class="info-box">
    </div>
    <div class="vertical-line"></div>
  </div>
</div>
<div class="container">
  <div class="sidebar">
  <a href="Properties.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-tag"></i> Part Properties</a>
  <a href="EngineeringBOM.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-sitemap"></i> Engineering BOM</a>
  <a href="APNEquivalents.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-code-compare"></i> Equivalents</a>
  <a href="Parthistory.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clock"></i> History</a>
  <a href="Lifecycle.jsp?name=<%= request.getParameter("name") %>" class="active"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
  <a href="ControlManagement.jsp?name=<%= request.getParameter("name") %>"><i class="fa-solid fa-shield-halved"></i> Control Management</a>
  <a href="PartSpecification.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clipboard"></i> PartSpecification</a>
  <a href="SpecificationDocumentUpload.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-file"></i> SpecificationDocument</a>
</div>

  <div class="main-panel">
  <div class="toolbar">
    <img src="lifecycle.gif" alt="Lifecycle Icon" class="lifecycle-icon" />
    <h4>Life Cycle</h4>
  </div>

  <div class="lifecycle-wrapper">
    <div class="lifecycle-section-title">Click a state to transition</div>

    <div class="lifecycle-flow">
      <div class="state-node" id="stateInWork" data-state="InWork" title="Click to change to 'In Work'">In Work</div>
      <div class="arrow" id="arrow-InWork-Frozen">➝</div>
      <div class="state-node" id="stateFrozen" data-state="Frozen" title="Click to change to 'Frozen'">Frozen</div>
      <div class="arrow" id="arrow-Frozen-Released">➝</div>
      <div class="state-node" id="stateReleased" data-state="Released" title="Click to change to 'Released'">Released</div>
      <div class="arrow" id="arrow-Released-Obsolete">➝</div>
      <div class="state-node" id="stateObsolete" data-state="Obsolete" title="Click to change to 'Obsolete'">Obsolete</div>
    </div>

    <div id="stateMessages"></div>
    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>
  </div>
</div>
</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>

const BASIC_URL = '<%= request.getContextPath() %>';
function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
}

function showMessage(msg, isError = false) {
    const container = $("#stateMessages");
    container.text(msg);
    container.toggleClass('error', isError);
    container.show();
    setTimeout(() => container.fadeOut(), 4000);
}

function setLoading(loading) {
    if (loading) {
        $("#loadingSpinner").show();
        $("#nextStateBtn").prop("disabled", true);
        $("#errorMessage").text("");
    } else {
        $("#loadingSpinner").hide();
        $("#nextStateBtn").prop("disabled", false);
    }
}
function fetchStateOnly(objectId) {
    setLoading(true);
    $.ajax({
    	url: BASIC_URL+'/api/datafetchservice/updatestate/' + encodeURIComponent(objectId),
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            setLoading(false);
            if(response.currentState) {
                $("#currentState").text(response.currentState);
                highlightCurrentState(response.currentState); 
            } else {
                $("#currentState").text("Unknown");
            }
        },
        error: function() {
            setLoading(false);
            $("#currentState").text("Error fetching state");
        }
    });
}

$(document).ready(function() {
    const objectId = getQueryParam("name");
	const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
	 if (partInfo) {
         $('.part-number').text(partInfo.name || '');
         $('.part-type').text(partInfo.type || '');
         const icon = (partInfo.type && partInfo.type.toLowerCase() === 'fastener') 
             ? 'https://img.icons8.com/?size=50&id=20544&format=png&color=000000' 
             : 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000';

         $('#typeIcon').attr('src', icon);
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
     } else {
         $('.part-number').text('');
         $('.part-type').text('');
         $('#typeIcon').attr('src', 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000');
         $('.state-box .state-label').remove();
     }
    if (!objectId) {
        $("#errorMessage").text("No objectId provided in URL");
        $("#nextStateBtn").prop("disabled", true);
        $("#currentState").text("-");
        return;
    }
    $("#currentState").text("Loading...");
    setLoading(false);

    function highlightCurrentState(state) {
    	  $('.state-node').removeClass('active');
    	  $('.state-node').each(function () {
    	    if ($(this).data('state').toLowerCase() === state.toLowerCase()) {
    	      $(this).addClass('active');
    	    }
    	  });
    	}
    
    $('.state-node').on('click', function () {
        const selectedState = $(this).data('state');
        const objectId = getQueryParam("name");

        if (!objectId || !selectedState) return;

        setLoading(true);

        $.ajax({
            url: BASIC_URL+'/api/datafetchservice/updatestate/' +encodeURIComponent(objectId),
            type: 'PUT',
            contentType: "application/json",
            data: JSON.stringify({ state: selectedState }),
            success: function(response) {
                setLoading(false);
                if (response.error) {
                    showMessage(response.error, true); 
                    return;
                }
                highlightCurrentState(selectedState);
                showMessage("State successfully changed to " + selectedState);
            },
           error: function(xhr) {
                 setLoading(false);
                $("#errorMessage").text("Failed to change state: " + xhr.responseText);
            }
        });
    });
    $("#nextStateBtn").on("click", function() {
        setLoading(true);
        $.ajax({
        	url: BASIC_URL+'/api/datafetchservice/updatestate/' +encodeURIComponent(objectId),
            type: 'PUT',
            contentType: "application/json",
            success: function(response) {
                setLoading(false);
                if (response.newState) {
                    $("#currentState").text(response.newState);
                    highlightCurrentState(response.newState);
                    showMessage("State updated to " + response.newState);
                } else if (response.message) {
                    showMessage(response.message);
                } else {
                    showMessage("State updated");
                }
            },
            error: function(xhr) {
                setLoading(false);
                if(xhr.status === 404) {
                    $("#errorMessage").text("Part not found with objectId: " + objectId);
                } else {
                    $("#errorMessage").text("Error updating state: " + xhr.responseText);
                }
            }
        });
    });
});
</script>
</body>
</html>