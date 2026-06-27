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
  <title>ASQL Runner - Minimal</title>
  
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet" />
  <script>var loggedInUserAccess = '<%= userAccess.trim() %>';</script>

  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap');

    :root {
      
      --bg-body: #f7f7f8;        
      --bg-surface: #ffffff;     
      --dark-element: #111827;  
      --dark-hover: #374151;     
      --text-main: #111827;      
      --text-muted: #6b7280; 
      --border-light: #e5e7eb;   
      --border-focus: #111827;     
      --radius: 8px;
      --font-sans: 'Inter', system-ui, sans-serif;
      --font-mono: 'JetBrains Mono', monospace;
      --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
      --shadow-modal: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      background-color: #e3e3f4;
      font-family: var(--font-sans);
      color: var(--text-main);
      display: flex;
      flex-direction: column;
      height: 100vh;
      overflow: hidden;
      -webkit-font-smoothing: antialiased;
    }

    .app-header {
      padding: 12px 32px;
      background-color: var(--bg-surface);
      border-bottom: 1px solid var(--border-light);
      display: flex;
      align-items: center;
      justify-content: space-between;
      z-index: 10;
    }

    .app-title {
      font-size: 16px;
      font-weight: 600;
      color: var(--dark-element);
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .app-title i { font-size: 18px; color: var(--dark-element); }

    .btn-header {
      background: transparent;
      border: 1px solid var(--border-light);
      color: var(--dark-element);
      padding: 6px 14px;
      border-radius: var(--radius);
      font-size: 13px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 6px;
      transition: all 0.2s;
    }

    .btn-header:hover {
      background: #f3f4f6;
      border-color: #d1d5db;
    }

    .workspace {
      display: flex;
      flex: 1;
      overflow: hidden;
    }

    .main-content {
      flex: 1;
      display: flex;
      flex-direction: column;
      padding: 24px 40px;
      gap: 20px;
      max-width: 1200px;
      margin: 0 auto;
      width: 100%;
    }

    .panel {
      background: var(--bg-surface);
      border-radius: var(--radius);
      border: 1px solid var(--border-light);
      display: flex;
      flex-direction: column;
      overflow: hidden;
      box-shadow: var(--shadow-sm);
    }

    .panel-header {
      padding: 12px 20px;
      background: var(--bg-surface);
      border-bottom: 1px solid var(--border-light);
      color: var(--dark-element);
      font-size: 13px;
      font-weight: 600;
    }

    .editor-panel { flex-shrink: 0; }

    .editor-body {
      display: flex;
      padding: 20px;
      gap: 12px;
      align-items: center;
    }

    .input-wrapper {
      flex: 1;
      background: var(--bg-surface);
      border-radius: var(--radius);
      padding: 10px 16px;
      display: flex;
      align-items: center;
      border: 1px solid var(--border-light);
      transition: all 0.2s ease;
    }

    .input-wrapper:focus-within {
      border-color: var(--border-focus);
      box-shadow: 0 0 0 1px var(--border-focus);
    }

    #inputField {
      width: 100%;
      background: transparent;
      border: none;
      color: var(--text-main);
      font-family: var(--font-mono);
      font-size: 14px;
      outline: none;
    }
    
    #inputField::placeholder { color: var(--text-muted); }

    .btn-group { display: flex; gap: 8px; }

    .btn-secondary {
      background: var(--bg-surface);
      border: 1px solid var(--border-light);
      color: var(--text-main);
      width: 42px;
      border-radius: var(--radius);
      font-size: 16px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: background 0.2s;
    }

    .btn-secondary:hover { background: #f3f4f6; }

    .btn-primary {
      background: var(--dark-element);
      color: #ffffff;
      border: none;
      padding: 0 24px;
      height: 42px;
      border-radius: var(--radius);
      font-size: 13px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: background 0.2s;
    }

    .btn-primary:hover { background: var(--dark-hover); }

    .results-panel {
      flex: 1;
      min-height: 0;
    }

    .terminal-container {
      flex: 1;
      position: relative;
      height: 100%;
    }

    #textArea {
      width: 100%;
      height: 100%;
      background: transparent;
      color: var(--text-main);
      border: none;
      padding: 20px;
      font-family: var(--font-mono);
      font-size: 13px;
      line-height: 1.6;
      resize: none;
      outline: none;
    }

    ::-webkit-scrollbar { width: 8px; height: 8px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: #9ca3af; }

    .modal-overlay {
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(17, 24, 39, 0.4);
      backdrop-filter: blur(2px);
      display: none; 
      justify-content: center;
      align-items: center;
      z-index: 50;
      opacity: 0;
      transition: opacity 0.2s ease;
    }

    .modal-overlay.show {
      display: flex;
      opacity: 1;
    }
   /*  Added by Ajay  Enhancement FIX BUG-1036 Starts  */
    .modal-box {
      background: var(--bg-surface);
      width: 900px;
      max-width: 95%;
      max-height: 80vh;
      border-radius: 12px;
      box-shadow: var(--shadow-modal);
      display: flex;
      flex-direction: column;
      transform: translateY(20px);
      transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    }
   /*  Added by Ajay  Enhancement FIX BUG-1036  Ended */    
 .modal-overlay.show .modal-box {
      transform: translateY(0);
    }

    .modal-header {
      padding: 16px 24px;
      border-bottom: 1px solid var(--border-light);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .modal-header h3 {
      font-size: 15px;
      font-weight: 600;
      color: var(--dark-element);
    }

    #closeModalBtn {
      background: transparent;
      border: none;
      font-size: 20px;
      color: var(--text-muted);
      cursor: pointer;
      transition: color 0.2s;
    }

    #closeModalBtn:hover { color: var(--dark-element); }

    .modal-body {
      padding: 24px;
      overflow-y: auto;
    }

    #fileTextContent {
      font-family: var(--font-mono);
      font-size: 13px;
      color: var(--text-main);
      line-height: 1.6;
      white-space: pre-wrap;
      background: #f9fafb;
      padding: 16px;
      border-radius: var(--radius);
      border: 1px solid var(--border-light);
    }

    #loadingSpinnerOverlay {
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(255, 255, 255, 0.7);
      display: none;
      justify-content: center;
      align-items: center;
      z-index: 10;
    }
    
    .spinner {
      width: 24px; height: 24px;
      border: 3px solid var(--border-light);
      border-top: 3px solid var(--dark-element);
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }

    @keyframes spin { 100% { transform: rotate(360deg); } }
  </style>
</head>
<body>

  <header class="app-header">
    <div class="app-title">
      <i class="bi bi-terminal"></i> ASQL Runner
    </div>
    <button id="queriesDoc" class="btn-header">
      <i class="bi bi-journal-text"></i> Reference Guide
    </button>
  </header>

  <div class="workspace">
    <div class="main-content">
      
      <div class="panel editor-panel">
        <div class="panel-header">Command Input</div>
        <div class="editor-body">
          <div class="input-wrapper">
            <textarea id="inputField" placeholder="SELECT * FROM table_name WHERE..." autocomplete="off" autofocus rows="5"></textarea>
          </div>
          <div class="btn-group">
            <button id="refreshPage" class="btn-secondary" title="Clear input">
              <i class="bi bi-eraser"></i>
            </button>
            <button id="submitBtn" class="btn-primary">
              <i class="bi bi-play-fill"></i> Execute
            </button>
          </div>
        </div>
      </div>

      <div class="panel results-panel">
        <div class="panel-header">Console Output</div>
        <div class="terminal-container">
      <!--   Added by Ajay Enhancement Fix BUG-1037 Starts -->
          <textarea id="textArea" placeholder="Results will be displayed here..." readonly oncontextmenu="return false;"></textarea>
      <!--   Added by Ajay Enhancement Fix BUG-1037 Ends -->
          <div id="loadingSpinnerOverlay">
              <div class="spinner"></div>
          </div>
        </div>
      </div>

    </div>

    <div id="refModalOverlay" class="modal-overlay">
      <div class="modal-box">
        <div class="modal-header">
          <h3>SQL Reference Guide</h3>
          <button id="closeModalBtn"><i class="bi bi-x"></i></button>
        </div>
        <div class="modal-body">
          <pre id="fileTextContent">Loading...</pre>
        </div>
      </div>
    </div>
  </div>

  <script>
    const BASIC_URL = '<%= request.getContextPath() %>';
    
    $(document).ready(function () {

      function runQuery(query) {
        $("#loadingSpinnerOverlay").css('display', 'flex');
        const minSpinnerTime = 600; 
        const spinnerStartTime = Date.now();

        $.ajax({
          url: BASIC_URL+'/api/datafetchservice/executequery',
          type: "GET",
          data: { sql: query, _: new Date().getTime() },
          success: function (response) {
            let resultText = typeof response === "object" ? JSON.stringify(response, null, 2) : response.trim();
            runQuery.resultText = resultText || "No data found for the given query.";
          },
          error: function (xhr) {
            let errorMessage = "Error executing query.";
            if (xhr.responseJSON && xhr.responseJSON.error) {
              errorMessage = "Error: " + xhr.responseJSON.error;
            }
            runQuery.resultText = errorMessage;
            setTimeout(() => $("#textArea").val(""), 4000);
          },
          complete: function () {
            const elapsed = Date.now() - spinnerStartTime;
            const remaining = minSpinnerTime - elapsed;

            if (remaining > 0) {
              setTimeout(() => {
                $("#loadingSpinnerOverlay").hide();
                $("#textArea").val(runQuery.resultText);
              }, remaining);
            } else {
              $("#loadingSpinnerOverlay").hide();
              $("#textArea").val(runQuery.resultText);
            }
          },
        });
      }

      $("#submitBtn").click(() => {
        const query = $("#inputField").val().trim();
        if (query) runQuery(query);
      });

    /*   $("#inputField").keypress((event) => {
        if (event.which === 13) {
          event.preventDefault();
          const query = $("#inputField").val().trim();
          if (query) runQuery(query);
        }
      }); */

      $("#refreshPage").click(function () {
        $("#inputField").val("");
        $("#textArea").val("");
      });

      const $modalOverlay = $("#refModalOverlay");

      $("#queriesDoc").click(function () {
        $modalOverlay.addClass('show');
        $.ajax({
          url: BASIC_URL+"/queries.txt",
          type: "GET",
          success: function (data) {
            $("#fileTextContent").text(data);
          },
          error: function () {
            $("#fileTextContent").text("Error loading the document.");
          },
        });
      });

      function closeModal() {
        $modalOverlay.removeClass('show');
      }

      $("#closeModalBtn").click(closeModal);

      $modalOverlay.click(function(e) {
        if (e.target === this) {
          closeModal();
        }
      });
    });
  </script>
</body>
</html>