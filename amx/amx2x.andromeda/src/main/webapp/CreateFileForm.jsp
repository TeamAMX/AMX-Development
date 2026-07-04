<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Create File</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<style>

* { box-sizing: border-box; margin: 0; padding: 0; }

html, body {
    height: 100%;
    overflow: hidden; 
    font-family: 'Inter', -apple-system, sans-serif;
    margin: 0;
    background: transparent;
}

#createFileForm {
    width: 100%;
    height: 100vh;
    background: #ffffff;
    border-radius: 18px;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    border: none;
    box-shadow: none;
}

h2 {
    margin: 0;
    padding: 24px 30px 16px;
    font-size: 24px;
    font-weight: 700;
    border-bottom: 1px solid #eef2f7;
    color: #111827;
    flex: 0 0 auto; 
    background: #ffffff;
    z-index: 10;
}

.form-body {
    flex: 1 1 auto; 
    min-height: 0; 
    overflow-y: auto; 
    padding: 24px 30px;
    display: flex;
    flex-direction: column;
    gap: 18px;
}

.form-body::-webkit-scrollbar {
    width: 8px;
}
.form-body::-webkit-scrollbar-track {
    background: transparent;
}
.form-body::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 10px;
}
.form-body::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}

.form-footer {
    padding: 16px 30px;
    border-top: 1px solid #eef2f7;
    background: #ffffff; 
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    flex: 0 0 auto; 
    z-index: 10;
}

.btn-submit {
    min-width: 110px;
    padding: 0 20px;
    height: 40px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 600;
    border: none;
    cursor: pointer;
    background: #0f172a; 
    color: white;
    transition: background 0.2s;
}
.btn-submit:hover { background: #334155; }

.btn-cancel {
    min-width: 110px;
    height: 40px;
    padding: 0 20px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    background: #f1f5f9; 
    color: #475569;
    border: none;
    transition: background 0.2s;
}
.btn-cancel:hover { background: #e2e8f0; }

.mb-3 { margin-bottom: 0; }

label {
    font-size: 13px;
    font-weight: 600;
    color: #334155;
    margin-bottom: 6px;
    display: block;
}

select, textarea, input {
    background-color: #f8fafc !important;
    border: 1px solid #cbd5e1 !important;
    color: #0f172a !important;
    border-radius: 6px !important;
    padding: 10px 14px !important;
    font-size: 14px !important;
    transition: all 0.2s ease;
    width: 100%;
}

select:focus, textarea:focus, input:focus { 
    border-color: #6b7280 !important; 
    box-shadow: 0 0 0 3px rgba(0, 0, 0, 0.1) !important;
    outline: none;
}

input[readonly], textarea[readonly] {
    background-color: #e2e8f0 !important;
    color: #64748b !important;
    cursor: not-allowed;
}

#inputDescription { min-height: 80px; resize: vertical; }
#inputResponsibleEngineer { resize: none; }

/* ===== Responsible Engineer Search Dropdown ===== */
.re-wrapper {
    position: relative;
    width: 100%;
}

.re-search-box {
    display: block;
    position: relative;
    width: 100%;
    background: #ffffff;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    box-shadow: none;
    z-index: 1;
    overflow: hidden;
}

.re-search-input-wrap {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 14px;
    border-bottom: 1px solid #e2e8f0;
}

.re-search-input-wrap i {
    flex-shrink: 0;
    color: #94a3b8;
}

.re-search-input-wrap input {
    border: none !important;
    background: transparent !important;
    box-shadow: none !important;
    padding: 0 !important;
    font-size: 14px !important;
    color: #0f172a !important;
    width: 100%;
    outline: none;
}

.re-list {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.2s ease;
}

.re-search-box.open .re-list {
    max-height: 200px;
    overflow-y: auto;
}

.re-list-item {
    padding: 6px 16px;
    font-size: 14px;
    color: #0f172a;
    cursor: pointer;
    transition: background 0.15s;
}

.re-list-item:hover {
    background: #f1f5f9;
}

.re-list-item.no-results {
    color: #94a3b8;
    cursor: default;
}

.re-list::-webkit-scrollbar { width: 6px; }
.re-list::-webkit-scrollbar-track { background: transparent; }
.re-list::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
.upload-box{
    border:2px dashed #d1d5db;
    border-radius:10px;
    height:250px;
    display:flex;
    flex-direction:column;
    justify-content:center;
    align-items:center;
    text-align:center;
    background:#fff;
}

.upload-icon{
    font-size:55px;
    color:#94a3b8;
    margin-bottom:15px;
}

.upload-box h5{
    font-weight:700;
    margin-bottom:10px;
}

.upload-box p{
    color:#6b7280;
    margin-bottom:8px;
}

.upload-box span{
    margin-bottom:8px;
    color:#6b7280;
}

.upload-box a{
    text-decoration:none;
    font-weight:600;
}

#addFileBtn{
    width:120px;
    margin-top:8px;
}
.upload-section{
    display:flex;
    gap:30px;
    align-items:flex-start;
}

.left-panel{
    flex:1;
}

.right-panel{
    flex:1;
}

#addFileBtn{
    width:120px;
    margin-top:12px;
}

.upload-box{
    width:100%;
    height:260px;
}
</style>
</head>
<body>
   <form id="createFileForm">
    <h2>Create File</h2>
   <div class="form-body">

   <div class="upload-section">

    <!-- Left -->
    <div class="left-panel">

        <div class="mb-3">
            <label>File Name</label>
            <input type="text"
                   id="fileName"
                   class="form-control"
                   placeholder="No file selected"
                   readonly>
        </div>

        <button type="button"
                class="btn btn-outline-secondary"
                id="addFileBtn">
            Add File
        </button>

        <input type="file" id="fileInput" hidden>

    </div>

    <!-- Right -->
    <div class="right-panel">

        <div class="upload-box" id="dropArea">

            <i class="fa-regular fa-file-lines upload-icon"></i>

            <h5>Drag & Drop</h5>

            <p>Drop file here</p>

            <span>OR</span>

            <a href="#" id="browseFile">Click to Browse</a>

        </div>

    </div>

</div>

    <div class="mb-3 mt-4">
        <label>Description</label>

        <textarea id="inputDescription"
                  class="form-control"
                  rows="4"
                  placeholder="Enter description" required></textarea>
    </div>

</div>
    <div class="form-footer">
      <button type="button" class="btn-cancel" id="cancelFileBtn">Cancel</button>
      <button type="submit" class="btn-submit">Submit</button>
    </div>
  </form>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script>
  
  const BASIC_URL = '<%= request.getContextPath() %>';
    /* BUG-1061  by Nageswari */
    window.addEventListener('DOMContentLoaded', async () => {
    	const fileInput = document.getElementById("fileInput");
    	const addFileBtn = document.getElementById("addFileBtn");
    	const browseFile = document.getElementById("browseFile");
    	const dropArea = document.getElementById("dropArea");
    	const fileName = document.getElementById("fileName");
    	
        function disableUpload() {

            addFileBtn.disabled = true;

            browseFile.style.pointerEvents = "none";
            browseFile.style.color = "#9ca3af";

            dropArea.style.pointerEvents = "none";
            dropArea.style.opacity = "0.6";

            fileInput.disabled = true;
        }
    	
    	// Add File button
    	addFileBtn.addEventListener("click", () => {
    	    fileInput.click();
    	});

    	// Click to Browse
    	browseFile.addEventListener("click", (e) => {
    	    e.preventDefault();
    	    fileInput.click();
    	});

    	// When a file is selected
    	
    	
    	fileInput.addEventListener("change", () => {

    if (fileInput.files.length > 0) {

        fileName.value = fileInput.files[0].name;
      
        disableUpload();
    
    }

});

    	// Drag events
    	dropArea.addEventListener("dragover", (e) => {
    	    e.preventDefault();
    	});

    	dropArea.addEventListener("drop", (e) => {

    	    e.preventDefault();
			
    	    if (e.dataTransfer.files.length > 1) {
    	        alert("Only one file is allowed.");
    	        return;
    	    }
			
			
    	    fileInput.files = e.dataTransfer.files;

    	    fileName.value = e.dataTransfer.files[0].name;

    	   
    	    disableUpload();
    	   

    	});

      const descriptionInput = document.getElementById('inputDescription');
      
      const cancelBtn = document.getElementById('cancelFileBtn');

      // Updated Cancel Logic using postMessage
      cancelBtn.addEventListener('click', () => {
          const isInIframe = window.self !== window.top;
          if (isInIframe) {
              window.parent.postMessage({ action: 'closeOnly' }, '*');
          } else {
              window.close();
          }
      });
      document.getElementById("createFileForm").addEventListener("submit", function(e) {

    	    e.preventDefault();

    	    if (fileInput.files.length === 0) {
    	        alert("Please select a file.");
    	        return;
    	    }

    	    const file = fileInput.files[0];
    	    const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB

    	    if (file.size > MAX_FILE_SIZE) {
    	        alert("File size should not exceed 10 MB.");
    	        return;
    	    }
    	    const reader = new FileReader();

    	    reader.onload = function(event) {

    	        const base64 = event.target.result.split(",")[1];

    	        const payload = {
    	            fileName: file.name,
    	            fileSize: file.size,
    	            description: descriptionInput.value.trim(),
    	            fileContentBase64: base64
    	            /* BUG-1061  by Nageswari */

    	        };

    	        $.ajax({

    	            url: BASIC_URL + "/api/datafetchservice/createfile",

    	            type: "POST",

    	            contentType: "application/json",

    	            data: JSON.stringify(payload),
    	            success: function(response) {

    	            	let res = (typeof response === "string")
                        ? JSON.parse(response)
                        : response;
				
                const fileObjectId = res.ObjectId || res.Name;//Added by Ajay BUG-1070 New Feature

    	                function formatFileSize(bytes) {
    	                    bytes = Number(bytes);

    	                    if (bytes < 1024)
    	                        return bytes + " B";
    	                    else if (bytes < 1024 * 1024)
    	                        return (bytes / 1024).toFixed(2) + " KB";
    	                    else
    	                        return (bytes / (1024 * 1024)).toFixed(2) + " MB";
    	                }

    	                alert(
        	                    "The following File was created successfully!\n\n" +
        	                    "File Name : " + file.name + "\n" +
        	                    "Name : " + res.Name + "\n" +
        	                    "Size : " + formatFileSize(file.size)
        	                );
							//Added by Ajay BUG-1070 New Feature started
        	                if (window.self !== window.top) {
        	                    window.parent.postMessage(
        	                        { action: "loadProperties", type: "file", id: fileObjectId },
        	                        "*"
        	                    );
        	                } else {
        	                    window.location.href = BASIC_URL
        	                        + "/FileProperties.jsp?name=" + encodeURIComponent(fileObjectId);
        	                }
							//Added by Ajay BUG-1070 New Feature Ended

    	            },

    	            error: function(xhr) {

    	                alert("Error : " + xhr.responseText);

    	            }

    	        });

    	    };

    	    reader.readAsDataURL(file);

    	});
    });

        </script>
</body>
</html>