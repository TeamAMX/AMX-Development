<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Results</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" rel="stylesheet" />

<style>

/*  BUG-1073 started by Tharun   */
html,
body {
    overflow-y: hidden;
    overflow-x:hidden;
}
  body {
    font-family: 'Inter', sans-serif;
    padding: 16px;
    background-color: #f7f9fa;
  }
/*  BUG-1073 ended by Tharun   */
.spinner-container {
  position: relative;
  width: 80px;
  height: 80px;
  margin: 40px auto 10px auto;
}

.spinner-ring {
  box-sizing: border-box;
  position: absolute;
  width: 80px;
  height: 80px;
  border: 6px solid #f3f3f3;
  border-top: 6px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  top: 0;
  left: 0;
}
  .spinner-overlay {
  position: fixed;      
  top: 0; left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(255, 255, 255, 0.7); 
  display: flex;
  flex-direction: column;   
  justify-content: center;  
  align-items: center;      
  gap: 10px;
  z-index: 9999;
}

.spinner-image {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loadingText {
  font-weight: bold;
  font-size: 1.1rem;
  color: #3498db;
}
/* commeneted for BUG-1073 by Tharun
a.apn-link {
cursor: pointer;
color: blue;
text-decoration: underline;
}
*/
.noResults {
  display: none;
  position: fixed; 
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%); 
  text-align: center;
  font-size: 18px;
  color: #555;
  background-color: transparent;
  border: none;
  box-shadow: none;
  padding: 0;
  margin: 0;
  width: auto;
  max-width: 90%;
  z-index: 10000; 
}
.noResults ul {
list-style: none;
padding: 0;
 }
.noResults li {
font-size: 16px;
color: #555;
}
/*  Commented by Tharun for BUG-1073
.table-wrapper {
text-wrap-mode : nowrap;
position: relative;
min-height: 200px;
}
*/
/* BUG-1073 started by Tharun */
.table-container{
	text-wrap-mode : nowrap;
	background: #ffffff;
    border-radius: 12px;
    border: 1px solid #e2e5e9;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}
.table-scroll {
    height: 95vh;
    overflow-y: auto;
    overflow-x: auto;
}
#resultsTable thead th {
    position: sticky !important;
    top: 0;
    z-index: 100;
    background: #020913 !important;
    box-shadow: 0 1px 0 rgba(255, 255, 255, 0.06);
}
table.dataTable thead th {
    background: #1e293b !important;
    color: #ffffff !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 14px 16px !important;
    border-bottom: none !important;
    /*border-right: 1px solid rgba(255, 255, 255, 0.08);*/
    white-space: nowrap;
    padding-right: 30px !important;
    position: relative;
}
table.dataTable thead .sorting:before,
  table.dataTable thead .sorting:after,
  table.dataTable thead .sorting_asc:before,
  table.dataTable thead .sorting_asc:after,
  table.dataTable thead .sorting_desc:before,
  table.dataTable thead .sorting_desc:after {
    color: rgba(255,255,255,0.75) !important;
    opacity: 1 !important;
    display: none!important;
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
    font-weight:500 !important;
}
.apn-link{
    color:black;
    text-decoration:none;
    font-weight:600;
}

.apn-link:hover{
    color:black;
    text-decoration:underline;
}
tbody tr:nth-child(even){
    background:#fafafa;
}

tbody tr:hover{
    background:#F4F8FD;
}
tbody tr.selected{
    background:#E9F2FF;
}
::-webkit-scrollbar{
    width:8px;
    height:8px;
}

::-webkit-scrollbar-thumb{
    background:#b9bec6;
    border-radius:10px;
}
thead th{
    background:#ffffff;
    color:#5E6C84;
    border-bottom:2px solid #DFE1E6;
}
/* BUG-1073 ended by Tharun  */
.resultsTable thead th {
background-color: #f8f9fa;
}
.inline-bullets {
  padding: 0;
  margin: 0;
  list-style-type: none; 
}

.inline-bullets li {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
  font-size: 16px; 
}

.inline-bullets li::before {
  content: '•';  
  font-size: 20px;  
  margin-right: 3px;  
}

.tight-columns td, .tight-columns th {
    padding: 2px 4px !important; /* reduce padding */
}
#resultsTable {
    border-collapse: collapse !important;
    table-layout: auto;
}
/*  Commented for BUG-1073 by Tharun
#resultsTable thead th {
    padding: 2px 8px !important;
    font-size: 12px !important;
    line-height: 1 !important;
    vertical-align: middle !important;
    height: 28px !important;
}
*/

</style>
</head>
<!-- BUG-1073 started -->
<body>
<!-- BUG-1073 ended -->
    <!-- Loading Spinner -->
<div id="spinnerOverlay" class="spinner-overlay" style="display: flex; flex-direction: column; gap: 10px; align-items: center;">
  <div class="spinner-container" style="position: relative; width: 80px; height: 80px;">
    <div class="spinner-ring"></div>
    <img src="logo.png" alt="loading image" class="spinner-image" /></div>
  <div id="loadingText" class="loadingText" style="font-weight: bold;">Loading...</div></div>
  
    <div id="errorMessage" class="alert alert-danger" style="display:none;"></div>
    <div id="contextMenu" style="display:none; position:absolute; background:#fff; border:1px solid #ccc; box-shadow:0 2px 6px rgba(0,0,0,0.2); z-index:1000;">
        <ul style="list-style:none; margin:0; padding:5px 0; width:100px;">
            <li id="openMenuItem" style="padding:8px 15px; cursor:pointer;">Open</li>
        </ul>
    </div>

    <div id="noResults" class="noResults">
    <h2 style="font-weight: bold; font-size:32px;">No Result Found</h2>
    <h4>Suggestions:</h4>
    <ul class="inline-bullets">
        <li>Make sure all words are spelled correctly</li>
        <li>Try different keywords.</li>
        <li>Try more general keywords.</li>
    </ul>
</div>
<!-- BUG-1073 started by Tharun -->
    <div class="table-container">
    <div class="table-scroll">
    <!-- BUG-1073 ended by Tharun -->
        <table id="resultsTable" class="display table table-striped" style="width:100%; display:none;">
            <thead>
                <tr id="tableHeaderRow">
                    
                </tr>
            </thead>
            <tbody id="resultsBody">
                
            </tbody>
        </table>
      </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script>
    
    const BASIC_URL = '<%= request.getContextPath() %>';
    document.addEventListener('DOMContentLoaded', async function () {
        const urlParams = new URLSearchParams(window.location.search);
        const query = urlParams.get('query');
        const filter = urlParams.get('filter') || 'all';

        const errorMessage = document.getElementById('errorMessage');
        const resultsTable = $('#resultsTable');
        const resultsBody = document.getElementById('resultsBody');
        const tableHeaderRow = document.getElementById('tableHeaderRow');
        const contextMenu = document.getElementById('contextMenu');
        const noResultsDiv = document.getElementById('noResults'); 
        let selectedObjectId = null;
        function showLoading(show) {
            const spinnerOverlay = document.getElementById('spinnerOverlay');
            const loadingText = document.getElementById('loadingText');
            if (show) {
                spinnerOverlay.style.display = 'flex';
                loadingText.style.display = 'block';
            } else {
                spinnerOverlay.style.display = 'none';
                loadingText.style.display = 'none';
            }
        }
        function showError(msg) {
            errorMessage.textContent = msg;
            errorMessage.style.display = 'block';
            showLoading(false);
            resultsTable.hide();
        }
        function isValidPartNumber(query) {
            const regex = /^[0-9]{3}(-\d{3})?(-APN)?$/;
            return regex.test(query);
        }
        function isOnlyNumbers(query) {
            return /^\d+$/.test(query);
        }

        if (!query) {
            showError("Please enter a search value.");
            return;
        }

        const searchQuery = query.trim().toLowerCase();

        if (filter === "all") {
            const isNumericLike = /^[0-9]+(-[0-9]*)?$/.test(searchQuery);
            const isAlphaLike = /^[a-z]+(-[a-z0-9]*)?$/.test(searchQuery);
            
            if (!isNumericLike && !isAlphaLike) {
                showError("Invalid input format. Use values like '900', '900-001', 'pc', or 'pc-000'.");
                return;
            }
            if (searchQuery.length < 2) {
                showError("Please enter at least 2 characters.");
                return;
            }
        } else if (filter === "byparts") {
            if (isOnlyNumbers(searchQuery)) {
                showError("Please enter a valid part name, not just a number.");
                return;
            }
            if (searchQuery.length < 2) {
                showError("Please enter at least 2 characters for part name.");
                return;
            }
        } else {
            if (searchQuery.length < 2) {
                showError("Please enter at least 2 characters.");
                return;
            }
        }
        try {
            showLoading(true);
            errorMessage.style.display = 'none';
            resultsTable.hide();
            noResultsDiv.style.display = 'none';  
            const formData = new URLSearchParams();
            formData.append("name", query);
            formData.append("filter", filter);
            const response = await fetch(BASIC_URL+"/api/navigatorutilites/amxfullsearch?" + formData.toString(), {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            if (!response.ok) {
                if (response.status === 404) {
                    renderNoResults();
                    showLoading(false);
                    return;
                } else {
                    const errText = await response.text();
                    throw new Error(errText);
                }
            }
            const data = await response.json();
            if (data.Status === "Success" && Array.isArray(data.Results) && data.Results.length > 0) {
                renderResults(data.Results);
            } else {
                renderNoResults();
            }
        } catch (error) {
            console.error("Error fetching results:", error);
            showError("There was an issue fetching results.");
        } finally {
            showLoading(false);
        }
        function renderResults(results) {
            resultsTable.show();
            noResultsDiv.style.display = 'none';
            errorMessage.style.display = 'none';
            resultsBody.innerHTML = '';
            tableHeaderRow.innerHTML = '';
			//BUG-1043 fixing stated by koushik
            const isPCNumberSearch = searchQuery === 'pc-0000' || /^pc-0000[0-9]+$/.test(searchQuery);//BUG-1089 fixed by koushik
            const isMPNQuery = searchQuery === 'mpn' || /^mpn[-_]/.test(searchQuery);
            const isMPNNumberSearch = /^mpn[-_]\d+$/.test(searchQuery);
            let headerMap;
            if (isPCNumberSearch) {
                headerMap = {"Name": "name","SuperType": "supertype","Type": "type","Description": "description",
                    "Createddate": "createddate","Owner": "owner","Email": "email","Assignee": "assignee","Currentstate": "currentstate"
                };
            } else if (searchQuery === 'pc' || searchQuery === 'pc-' || searchQuery === 'pc-000') {
            //BUG-1043 fixing ended by koushik
                headerMap = {"Name": "name","SuperType": "supertype","Type": "type","Description": "description",
                    "Createddate": "createddate","Owner": "owner","Email": "email","Assignee": "assignee","Currentstate": "currentstate"
                };
            } 
            //BUG-1089 fixing started by koushik
			else if (isMPNQuery) {
   				 headerMap = {"Name": "name","SuperType": "supertype","Type": "type","Description": "description",
       			 "Createddate": "createddate","Owner": "owner","Email": "email","Currentstate": "currentstate"
   				 };
			}

           //BUG-1089 fixing ended by koushik
            //BUG-1065 Started by Nageswari
            else if (searchQuery === 'pasp'|| searchQuery === 'pasp-' || searchQuery === 'pasp-000') {

   				 headerMap = {"Name": "name","SuperType": "supertype","Type": "type","Description": "description","CreatedDate": "createdtime","Owner": "owner","Email": "email","CurrentState": "currentstate"
    			 };

			}
            //BUG-1065 ended by Nageswari
            else if (filter === "byPersons") {
                headerMap = {"Username": "username","First Name": "firstname","Last Name": "lastname","Country": "country",
                    "Email": "email","Access": "access"
                };
            } else if (filter === "byParts") {
                headerMap = {"APN": "apn","Name": "name","SuperType": "supertype","Type": "type","Description": "description"
                };
            } else {
                headerMap = {"APN": "apn","Name": "name","SuperType": "supertype","Type": "type","Description": "description",
                    "CreatedDate": "createddate","Owner": "owner","Email": "email"
                };
            }
            Object.keys(headerMap).forEach(header => {
                const th = document.createElement('th');
                th.textContent = header;
                tableHeaderRow.appendChild(th);
            });

            results.forEach((item, index) => {
                const tr = document.createElement('tr');
                const rowClass = index % 2 === 0 ? 'even' : 'odd';
                tr.classList.add(rowClass);

                if (item.objectid) {
                    const safeObjectIdClass = 'id-' + item.objectid.replace(/[^a-zA-Z0-9\-_]/g, '-');
                    tr.classList.add(safeObjectIdClass);
                    tr.setAttribute('ObjectId', item.objectid);
                }

                Object.entries(headerMap).forEach(([header, key]) => {
                    const td = document.createElement('td');
                    if (header === 'APN') {
                        const a = document.createElement('a');
                        a.href = '#';
                        a.classList.add('apn-link');
                        a.textContent = item[key] != null ? item[key] : '';
                        a.setAttribute('ObjectId', item.objectid);
                        a.setAttribute('data-type', 'apn');
                        td.appendChild(a);
                    }
                    //BUG-1065 Started by Nageswari
                    else if (
                    	    header === 'Name' &&
                    	    (
                    	        searchQuery === 'pasp' ||
                    	        searchQuery === 'pasp-' ||
                    	        searchQuery === 'pasp-0' ||
                    	        searchQuery === 'pasp-00' ||
                    	        searchQuery === 'pasp-000' ||
                    	        searchQuery === 'pasp-0000' ||
                    	        
                    	        searchQuery === 'pc' ||
                    	        searchQuery === 'pc-' ||
                    	        searchQuery === 'pc-0' ||
                    	        searchQuery === 'pc-00' ||
                    	        searchQuery === 'pc-000' ||
                    	        searchQuery === 'pc-0000' ||
                    	        searchQuery === 'pc-0000' ||
                    	        /^pc-0000[0-9]+$/.test(searchQuery) ||
                    	        //BUG-1089 started by koushik
								isMPNQuery
                    	        //BUG-1089 ended by koushik
                    	    )
                    	)
                    	{
                    	//BUG-1065 Ended by Nageswari
                    	const a = document.createElement('a');
                        a.href = '#';
                        a.classList.add('apn-link');
                        a.textContent = item[key] != null ? item[key] : '';
                        a.setAttribute('ObjectId', item.objectid);
                        /* BUG-1065 started by Nageswari */
                        if (searchQuery === 'pasp') {
                            a.setAttribute('data-type', 'ps-name');
                        }
                        //BUG-1089 Started by koushik
						else if (isMPNQuery) {
  						  a.setAttribute('data-type', 'mpn-name');
						}
                        //BUG-1089 ended by koushik
                        else {
                            a.setAttribute('data-type', 'pc-name');
                        }
                        /* BUG-1065 Ended by Nageswari */
                        td.appendChild(a);
                    	}
                     else if (header === 'Username' && filter === 'byPersons') {
                        const a = document.createElement('a');
                        a.href = '#';
                        a.classList.add('apn-link');
                        a.textContent = item[key] != null ? item[key] : '';
                        a.setAttribute('ObjectId', item.objectid);
                        a.setAttribute('data-type', 'person-username');
                        td.appendChild(a);

                    } else {
                        td.textContent = item[key] != null ? item[key] : '';
                    }
                    tr.appendChild(td);
                });

                resultsBody.appendChild(tr);
            });
			//BUG-1043 fixing started by koushik
           const dt = resultsTable.DataTable({
                paging: false,
                info: false,
                lengthChange: false,
                //BUG-1073 started by Tharun
                ordering: true,
                searching: false
                //BUG-1073 ended
            });
            if (isPCNumberSearch || isMPNNumberSearch) {
                $('.dataTables_filter').hide();
            }
          //BUG-1043 fixing ended by koushik
        }

        function renderNoResults() {
            resultsTable.hide();
            noResultsDiv.style.display = 'block'; 

            resultsBody.innerHTML = '';
            tableHeaderRow.innerHTML = '';

            const headers = ["APN", "Name", "SuperType", "Type", "Description", "CreatedDate", "Owner", "Email"];
            headers.forEach(header => {
                const th = document.createElement('th');
                th.textContent = header;
                tableHeaderRow.appendChild(th);
            });
        }
        document.body.addEventListener('click', function(e) {
            if (e.target && e.target.classList.contains('apn-link')) {
                e.preventDefault();
                e.stopPropagation();
                selectedObjectId = e.target.getAttribute('ObjectId');
                if (!selectedObjectId) return;

                // Show context menu at mouse position
                contextMenu.style.top = e.pageY + 'px';
                contextMenu.style.left = e.pageX + 'px';
                contextMenu.style.display = 'block';

                // Store selected id and type for use on menu click
                contextMenu.setAttribute('data-selected-objectid', selectedObjectId);
                contextMenu.setAttribute('data-selected-type', e.target.getAttribute('data-type'));
            } else if (!contextMenu.contains(e.target)) {
                contextMenu.style.display = 'none';
            }
        });

        document.getElementById('openMenuItem').addEventListener('click', function() {
            contextMenu.style.display = 'none';
            const objectId = contextMenu.getAttribute('data-selected-objectid');
            const type = contextMenu.getAttribute('data-selected-type');
            if (!objectId) return;
            let propertiesUrl = '';
            if (type === 'apn') {
                propertiesUrl = BASIC_URL+'/Properties.jsp?name=' + encodeURIComponent(objectId);
            } else if (type === 'pc-name') {
                propertiesUrl = BASIC_URL+'/Partcontroldetails.jsp?name=' + encodeURIComponent(objectId);
            } 
            //BUG-1065 Started by Nageswari
            else if (type === 'ps-name') {
    			propertiesUrl = BASIC_URL+'/PartSpecificationdetails.jsp?name=' + encodeURIComponent(objectId);
			}
            //BUG-1065 ended by Nageswari
            //BUG-1089 started by koushik
			else if (type === 'mpn-name') {
 			   propertiesUrl = BASIC_URL+'/MPNProperties.jsp?name=' + encodeURIComponent(objectId);
			}
            //BUG-1089 ended by koushik
            else if (type === 'person-username') {
                propertiesUrl = BASIC_URL+'/PersonProperties.jsp?name=' + encodeURIComponent(objectId);
            } else {
                propertiesUrl = BASIC_URL+'/Properties.jsp?name=' + encodeURIComponent(objectId);
            }

            window.location.href = propertiesUrl;
        });
    });
</script>
</body>
</html>
