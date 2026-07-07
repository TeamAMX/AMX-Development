<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userAccess = (String) session.getAttribute("userAccess");
String username = (String) session.getAttribute("username");
    if (userAccess == null) {
        userAccess = "Admin";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Part Control LifeCycle</title>
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
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  background: #ffffff;
  border-bottom: 1px solid #eef2f7;
  box-shadow: 0 1px 2px rgba(15,23,42,0.04);
}
  .topbar-left {
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .topbar-icon {
    width: 42px;
    height: 42px;
    border-radius: 10px;
    background: #f1f5f9;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    color: #4b5563;
    flex-shrink: 0;
  }
  .topbar-name {
    font-size: 16px;
    font-weight: 700;
    color: #111827;
    margin: 0 0 2px 0;
  }
  .topbar-type {
    font-size: 12px;
    color: #6b7280;
    margin: 0;
  }
  .topbar-right {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    font-weight: 500;
    color: #374151;
  }

  /* ===== STATE BADGES ===== */
  .state-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 4px 12px;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }
  .state-badge.InWork      { background: #dbeafe; color: #1d4ed8; }
  .state-badge.InApproval  { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
  .state-badge.Completed   { background: #dcfce7; color: #166534; }
  .state-badge.Cancelled   { background: rgb(254, 235, 19rgb(255, 0, 0), 0, 0)or: #ffffff; }

  /* ===== LAYOUT ===== */
  .container {
    display: flex;
    height: calc(100vh - 65px);
    overflow: hidden;
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
  .sidebar a:hover { background-color: #e3e7ea; color: #111827; }
  .sidebar a.active { background-color: #4b5563; color: white; font-weight: 600; }
  .sidebar a i { width: 16px; font-size: 13px; color: #6b7280; }
  .sidebar a.active i { color: #ffffff; }

  /* ===== MAIN PANEL ===== */
  .main-panel {
    flex-grow: 1;
    padding: 0;
    min-width: 0;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    overflow: hidden;
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
  .lifecycle-icon {
    width: 18px;
    height: 18px;
    filter: invert(1);
  }

  /* ===== LIFECYCLE AREA ===== */
  .lifecycle-wrapper {
    padding: 32px 24px;
    flex: 1;
    overflow-y: auto;
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

  /* State colors */
  #stateInWork      { background: #5bc0de; }
  /*BUG-1082 started by Tharun */
  #stateInApproval  { 
  white-space: nowrap;
  background: #6c757d; }
  /*BUG-1082 ended */
  #stateCompleted   { background: #28a745; }
  #stateCancelled   { background: #f23535; color: #ffffff; }

  .arrow {
    margin: 0 12px;
    font-size: 20px;
    color: #d1d5db;
    flex-shrink: 0;
  }
  /*BUG-1082 started by Tharun */
  .arrow_gap{
  	margin: 0 12px;
    font-size: 20px;
    color: #d1d5db;
    flex-shrink: 0;
}
/*BUG-1082 ended */
  .arrow.no-gap { margin: 0; }

  .arrow-segment {
    display: flex;
    align-items: center;
  }
  .arrow-segment .line {
  /*BUG-1082 started by Tharun */
  	margin-top: 14px;
    height: 2px;
    background-color: #d1d5db;
    width: 12px;
  }
  .popup-icon {
    width: 20px;
    height: 20px;
    cursor: pointer;
    /*BUG-1082 Tharun */
    margin: 5px 4px;
    /*BUG-1082 end */
  }

  /* State message */
  #stateMessages {
    margin: 20px 24px 0 24px;
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

  #loadingSpinner {
    display: none;
    width: 20px;
    height: 20px;
    border: 3px solid #e2e5e9;
    border-top: 3px solid #4b5563;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 16px 24px;
  }
  @keyframes spin {
    0%   { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  #errorMessage {
    margin: 12px 24px;
    font-size: 13px;
    color: #c0392b;
    font-weight: 500;
  }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>

<div class="topbar">
  <div class="topbar-left">
    <div class="topbar-icon">
      <i class="fa-solid fa-sliders"></i>
    </div>
    <div>
      <div class="topbar-name" id="pcName">Part Control</div>
      <div class="topbar-type" id="pcType">PartControl</div>
    </div>
  </div>
  <div class="topbar-right">
    <span>State:</span>
    <div id="stateBadgeWrapper"></div>
  </div>
</div>

<div class="container">
  <div class="sidebar">
  <a href="Partcontroldetails.jsp?name=<%= request.getParameter("name") %>" class="nav-link"><i class="fa-solid fa-sliders"></i> PC-Properties</a>
  <a class="nav-link" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>"><i class="fa-regular fa-clock"></i> History</a>
  <a href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>" class="nav-link active"><i class="fa-solid fa-arrows-rotate"></i> LifeCycle</a>
  <a href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>" class="nav-link"><i class="fa-solid fa-shield-halved"></i> Part Management</a>
</div>

<div class="main-panel">
  <div class="toolbar">
    <img src="lifecycle.gif" alt="Lifecycle Icon" class="lifecycle-icon" />
    <h4>Life Cycle</h4>
  </div>
  <div class="lifecycle-wrapper">
    <div class="lifecycle-section-title">Click a state to transition</div>
    <div class="lifecycle-flow">
      <div class="state-node" id="stateInWork" data-state="InWork">In Work</div>
      <div class="arrow" id="arrow-InWork-InApproval">➝</div>
      <div class="state-node" id="stateInApproval" data-state="InApproval">In Approval</div>
      <div class="arrow-segment">
      <!-- BUG-1082 fix by Tharun  -->
      <div class= "before_route1">
      	<div class="arrow_gap">➝</div>
      </div>
      <div class= "route1" style="display:none;">
        <div class="line"></div>
        <img id="reviewIconInApproval" src="https://img.icons8.com/?size=100&id=103521&format=png&color=000000" alt="Review Icon" class="popup-icon" title="Open RoutePopup Page" onclick="openPopup('InApproval')" />
        <div class="arrow no-gap">➝</div>
      </div>
      
      </div>
      <div class="state-node" id="stateCompleted" data-state="Completed">Completed</div>
      <div class="arrow-segment">
      
      <div class= "before_route2">
      	<div class="arrow_gap">➝</div>
      </div>
      <div class= "route2" style="display:none;">
      	<div class="line"></div>
        <img id="reviewIconCompleted" src="https://img.icons8.com/?size=100&id=103521&format=png&color=000000" alt="Review Icon" class="popup-icon" title="Open RouteStatePopup Page" onclick="openPopup('Completed')" />
        <div class="arrow no-gap">➝</div>
      </div>
        
      </div>
      <!-- BUG-1082 end -->
      <div class="state-node" id="stateCancelled" data-state="Cancelled">Cancelled</div>
    </div>
    <div id="stateMessages"></div>
    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>
  </div>
</div>

</div>
<script>
    const loginUser = "<%= username %>";
</script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>

const BASIC_URL = '<%= request.getContextPath() %>';
let attemptedPromotionState = null;

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
            if (response.currentState) {
                $("#currentState").text(response.currentState);
                highlightCurrentState(response.currentState); 
                showReviewIcon(response.currentState);
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

function highlightCurrentState(state) {
    $('.state-node').removeClass('active');
    $('.state-node').each(function () {
        if ($(this).data('state').toLowerCase() === state.toLowerCase()) {
            $(this).addClass('active');
        }
    });
}

function showReviewIcon(currentState) {
	//BUG-1082 fix by Tharun
    document.querySelector(".route1").style.display="none";
    document.querySelector(".route2").style.display="none";
	//BUG-1082 end
    if (!currentState) return;

    if (currentState.toLowerCase() === "inapproval") {
    //BUG-1082 fix by Tharun
    	document.querySelector(".route1").style.display="flex";
    	document.querySelector(".before_route1").style.display="none";
    //BUG-1082 end
    } else if (currentState.toLowerCase() === "completed") {
    //BUG-1082 fix by Tharun
    	document.querySelector(".route2").style.display="flex";
    	document.querySelector(".before_route2").style.display="none";
    //BUG-1082 end	
    }
}

function promoteToInApproval(objectId, targetState) {
    setLoading(true);
    $.ajax({
        url: BASIC_URL+'/api/datafetchservice/promote/' + encodeURIComponent(objectId),
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ selectedState: targetState }),
       
        success: function(response) {
            setLoading(false);
            try {
                if (typeof response === 'string') {
                    response = JSON.parse(response);
                }
            } catch (e) {
                showMessage("Unexpected response format", true);
                return;
            }
            if (response.error) {
                showMessage(response.error, true);
                return;
            }
            highlightCurrentState(targetState);
            showMessage(response.message || "Promoted to state successfully");
            let partInfo = JSON.parse(sessionStorage.getItem('partInfo')) || {};
            partInfo.currentstate = targetState;
            sessionStorage.setItem('partInfo', JSON.stringify(partInfo));
            showReviewIcon(targetState); 
        },
        
        error: function(xhr) {
            setLoading(false);
            let errorText = "Promotion failed";
            if (xhr.responseText) {
                try {
                    const errorObj = JSON.parse(xhr.responseText);
                    errorText += ": " + (errorObj.error || xhr.responseText);
                } catch {
                    errorText += ": " + xhr.responseText;
                }
            }
            showMessage(errorText, true);
        }
    });
}

$(document).ready(function() {
    
    const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
    const objectId = getQueryParam("name");

    if (!partInfo && objectId) {
        $.ajax({
            url: BASIC_URL + '/api/datafetchservice/getinfospc',
            method: 'GET',
            data: { objectId: objectId },
            dataType: 'json',
            success: function(data) {
                if (data && !$.isEmptyObject(data)) {
                    sessionStorage.setItem('partInfo', JSON.stringify(data));
                    $('#pcName').text(data.name || '');
                    $('#pcType').text(data.type || '');
                    if (data.currentstate) {
                        const state = data.currentstate;
                        const cls = state.replace(/\s/g, '');
                        $('#stateBadgeWrapper').html('<span class="state-badge ' + cls + '">' + state + '</span>');
                        highlightCurrentState(state);
                        showReviewIcon(state);
                    }
                }
            }
        });
    }
    
    if (partInfo) {
        $('#pcName').text(partInfo.name || '');
        $('#pcType').text(partInfo.type || '');
        if (partInfo.currentstate) {
            const state = partInfo.currentstate;
            const cls = state.replace(/\s/g, '');
            $('#stateBadgeWrapper').html('<span class="state-badge ' + cls + '">' + state + '</span>');
            highlightCurrentState(state);
            showReviewIcon(state);
        }
    }

    if (!objectId) {
        $("#errorMessage").text("No objectId provided in URL");
        $("#nextStateBtn").prop("disabled", true);
        $("#currentState").text("-");
        return;
    }

    $("#currentState").text("Loading...");
    setLoading(false);

    $('.state-node').on('click', function () {
        attemptedPromotionState = $(this).data('state'); 
        const selectedState = attemptedPromotionState;
        const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
        const currentState = partInfo?.currentstate;

        if (!objectId || !selectedState) return;

        if (currentState === "InWork" && selectedState === "InApproval") {
            promoteToInApproval(objectId, selectedState);
        } else {
            setLoading(true);
            $.ajax({
                url: BASIC_URL+'/api/datafetchservice/updatestate/' + encodeURIComponent(objectId),
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
                    let partInfo = JSON.parse(sessionStorage.getItem('partInfo')) || {};
                    partInfo.currentstate = selectedState;
                    sessionStorage.setItem('partInfo', JSON.stringify(partInfo));
                    showReviewIcon(selectedState);
                },
                error: function(xhr) {
                    setLoading(false);
                    $("#errorMessage").text("Failed to change state: " + xhr.responseText);
                }
            });
        }
    });

    fetchStateOnly(objectId);
});

function openPopup(state) {
    const objectId = getQueryParam("name");
    if (!objectId) {
        alert("No object ID specified");
        return;
    }
    if(state === "InApproval") {
        const approveUrl = "RoutePopup.jsp?name=" + encodeURIComponent(objectId);
        window.open(approveUrl, 'RoutePopup', 'width=900,height=800,position=center,left=100,top=100,resizable=yes');
    } else {
        const stateUrl = "RouteStatePopup.jsp?name=" + encodeURIComponent(objectId);
        window.open(stateUrl,'RouteStatePopup','width=650,height=550,position=center,left=100,top=100,resizable=yes');
    }
}


</script>
</body>
</html>