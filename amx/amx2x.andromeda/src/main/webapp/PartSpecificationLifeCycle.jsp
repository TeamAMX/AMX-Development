<!-- BUG-1067 Fixing started by koushik -->
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
<title>Part Specification LifeCycle</title>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>
  * { box-sizing: border-box; }

  body {
    font-family: 'Inter', Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }

  /* ===== TOPBAR ===== */
  .topbar {
    display: flex;
    background: #ffffff;
    border-bottom: 1px solid #e2e5e9;
    padding: 12px 20px;
    align-items: center;
    justify-content: space-between;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  }
  .topbar-left { display: flex; align-items: center; gap: 14px; }
  .topbar-icon {
    width: 42px; height: 42px;
    border-radius: 10px; background: #f1f5f9;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px; color: #4b5563; flex-shrink: 0;
  }
  .topbar-name { font-size: 16px; font-weight: 700; color: #111827; margin: 0 0 2px 0; }
  .topbar-type { font-size: 12px; color: #6b7280; margin: 0; }
  .topbar-right {
    display: flex; align-items: center; gap: 8px;
    font-size: 13px; font-weight: 500; color: #374151;
  }

  /* ===== STATE BADGE ===== */
  .state-badge {
    display: inline-flex; align-items: center; justify-content: center;
    padding: 4px 12px; border-radius: 999px;
    font-size: 11px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.3px;
  }
  .state-badge.InWork   { background: #dbeafe; color: #1d4ed8; }
  .state-badge.Frozen   { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
  .state-badge.Released { background: #dcfce7; color: #166534; }
  .state-badge.Draft { background: #fef9c3; color: #854d0e; }

  /* ===== LAYOUT ===== */
  .page-container {
    display: flex;
    height: calc(100vh - 65px);
    overflow: hidden;
  }

  /* ===== SIDEBAR ===== */
  .sidebar {
    width: 19%;
    min-width: 180px;
    flex-shrink: 0;
    background-color: #f8f9fa;
    border-right: 1px solid #ddd;
    padding: 20px;
    box-sizing: border-box;
    overflow-y: auto; overflow-x: hidden;
  }
  .sidebar a {
    display: flex; align-items: center; gap: 10px;
    padding: 10px 12px; color: #4b5563;
    text-decoration: none; margin-bottom: 6px;
    border-radius: 8px; font-size: 13px; font-weight: 500;
    transition: all 0.2s ease;
  }
  .sidebar a:hover { background-color: #e3e7ea; color: #111827; }
  .sidebar a.active { background-color: #4b5563; color: white; font-weight: 600; }
  .sidebar a i { width: 16px; font-size: 13px; color: #6b7280; }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
    flex-grow: 1;
    padding: 0;
    overflow-y: auto; min-width: 0;
    box-sizing: border-box;
    display: flex; flex-direction: column;
  }

  /* ===== TOOLBAR ===== */
  .toolbar {
    background-color: #000000;
    padding: 8px 14px;
    display: flex; align-items: center; gap: 10px;
    border-bottom: 1px solid #334155;
    margin: 0;
  }
  .toolbar h4 {
    margin: 0;
    font-size: 13px; font-weight: 600;
    color: #e2e8f0; letter-spacing: 0.5px;
    text-transform: uppercase;
  }
  .lifecycle-icon { width: 18px; height: 18px; filter: invert(1); }

  /* ===== LIFECYCLE AREA ===== */
  .lifecycle-wrapper {
    padding: 32px 24px;
    flex: 1;
    overflow-y: auto;
  }

  .lifecycle-section-title {
    font-size: 11px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.8px;
    color: #9ca3af; margin-bottom: 24px;
  }

  .lifecycle-flow {
    display: flex;
    align-items: center;
    gap: 0;
    flex-wrap: nowrap;
  }

  .state-node {
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

  #stateInWork   { background: #5bc0de; }
  #stateFrozen   { background: #6c757d; }
  #stateReleased { background: #28a745; }
  #stateDraft { background: #ffc107; color: #000; }

  .arrow {
    margin: 0 12px;
    font-size: 20px;
    color: #d1d5db;
    flex-shrink: 0;
  }

  #stateMessages {
    margin: 20px 24px 0 24px;
    font-size: 13px; font-weight: 500;
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

  #loadingSpinner {
    display: none;
    width: 20px; height: 20px;
    border: 3px solid #e2e5e9;
    border-top: 3px solid #4b5563;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 16px 24px;
  }
  @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

  #errorMessage {
    margin: 12px 24px;
    font-size: 13px; color: #c0392b; font-weight: 500;
  }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>

<div class="topbar">
  <div class="topbar-left">
    <div class="topbar-icon"><i class="fa-solid fa-sliders"></i></div>
    <div>
      <div class="topbar-name" id="partSpecificationName">Part Specification LifeCycle</div>
      <div class="topbar-type" id="patrSpecificationType">Part Specification Assembly</div>
    </div>
  </div>
  <div class="topbar-right">
    <span>State:</span>
    <div id="stateBadgeWrapper"></div>
  </div>
</div>

<div class="page-container">
  <div class="sidebar">
    <a class="nav-link" href="PartSpecificationdetails.jsp?name=<%= request.getParameter("name") %>">
      <i class="fa-solid fa-sliders"></i> PSAP Properties
    </a>
    <!--  -->
    <a class="nav-link" href="PartSpecificationFiles.jsp?name=<%= request.getParameter("name") %>">
      <i class="fa-regular fa-file"></i> Files
    </a>
    <!--  -->
    <a class="nav-link" href="PartSpecificationLifeCycle.jsp?name=<%= request.getParameter("name") %>">
      <i class="fa-solid fa-arrows-rotate"></i> LifeCycle
    </a>
  </div>

  <div class="main-panel">
    <div class="toolbar">
      <img src="lifecycle.gif" alt="Lifecycle Icon" class="lifecycle-icon" />
      <h4>Life Cycle</h4>
    </div>
    <div class="lifecycle-wrapper">
      <div class="lifecycle-section-title">Click a state to transition</div>
      <div class="lifecycle-flow">
        <div class="state-node" id="stateDraft" data-state="Draft">Draft </div>
        <div class="arrow">➝</div>
        <div class="state-node" id="stateInWork"   data-state="InWork">In Work</div>
        <div class="arrow">➝</div>
        <div class="state-node" id="stateFrozen"   data-state="Frozen">Frozen</div>
        <div class="arrow">➝</div>
        <div class="state-node" id="stateReleased" data-state="Released">Released</div>
        
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

function highlightCurrentState(state) {
    $('.state-node').removeClass('active');
    $('.state-node').each(function() {
        if ($(this).data('state').toLowerCase() === state.toLowerCase()) {
            $(this).addClass('active');
        }
    });
}

function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
}

function showMessage(msg, isError = false) {
    const container = $("#stateMessages");
    container.text(msg);
    container.removeClass('error');
    if (isError) container.addClass('error');
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

        url: BASIC_URL+'/api/navigatorutilites/updatepartspecificationstate/' + encodeURIComponent(objectId),
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            setLoading(false);
            if (response.currentState) {
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

    $.ajax({
        url: BASIC_URL + '/api/navigatorutilites/updatepartspecificationstate/' + encodeURIComponent(objectId),
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            if(response.currentState){
                const state = response.currentState;
                const cls = state.replace(/\s/g,'');
                $('#stateBadgeWrapper').html('<span class="state-badge '+cls+'">'+state+'</span>');
                highlightCurrentState(state);
            }
        }
    });
    
    $("#currentState").text("Loading...");
    setLoading(false);

    $('.state-node').on('click', function() {
        const selectedState = $(this).data('state');
        const objectId = getQueryParam("name");

        if (!objectId || !selectedState) return;

        setLoading(true);

        $.ajax({

            url:BASIC_URL+'/api/navigatorutilites/updatepartspecificationstate/' + encodeURIComponent(objectId),
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

            url: BASIC_URL+'/api/navigatorutilites/updatepartspecificationstate/' + encodeURIComponent(objectId),
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
                if (xhr.status === 404) {
                    $("#errorMessage").text("Part specification not found with objectId: " + objectId);
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
<!-- BUG-1067 Fixing ended by koushik -->