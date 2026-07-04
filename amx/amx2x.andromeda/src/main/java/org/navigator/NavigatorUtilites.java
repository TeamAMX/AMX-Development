package org.navigator;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONObject;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.FormParam;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;

/**
* @Usage
*This endpoint is used for the connecting of the other endpoints.
* This makes the connection of the rest webservice endpoints for that class

*/

@Path("/navigatorutilites")
public class NavigatorUtilites {

    public static final String url = DBConfig.getUrl();
    public static final String user = "postgres";
    public static final String db_password = "admin@1234";

    public static final SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    static {
        try {
            Class.forName("org.postgresql.Driver");
//            System.out.println("PostgreSQL JDBC Driver Registered!");
        } catch (ClassNotFoundException e) {
//            System.err.println("PostgreSQL JDBC Driver not found. Include it in your library path!");
            e.printStackTrace();
        }
    }
    
/**
 * @args  String username and password in form params
 * @return Response
 * @usage This method handles user login by validating the username and creating a session attribute.
 */

 //login
    @POST
    @Path("/login")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response login( @FormParam("username") String username, @Context HttpServletRequest request) {
    	
        JSONObject resp = new JSONObject();
        if (username == null || username.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "Username is required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
        request.getSession(true).setAttribute("username", username);
        resp.put("Status", "Success").put("Message", "User logged in.").put("Username", username);
        return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();
    }
	/**
	* @args form parameters: String SuperType, Type, APN, Description, FastenerSubPart, Variant
	* @return Response
	* @usage This method creates a new part record in the database after validating user session and input data.
	*        It generates a unique name and object ID, inserts the record, and logs the creation in the part history.
	*        Requires user to be logged in. FastenerSubPart and Variant are mandatory if Type is Fastener.
	*/	
    //create
    @POST
    @Path("/create")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createPart(@FormParam("SuperType") String supertype,@FormParam("Type") String type,@FormParam("APN") String apn,
                 @FormParam("Description") String description,@FormParam("FastenerSubPart") String fastenerSubPart,
              @FormParam("Variant") String variant, @FormParam("ResponsibleEngineer") String responsibleEngineer,@Context HttpServletRequest request) {//BUG-1048 fixing done by koushik
    	
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
    	
        JSONObject resp = new JSONObject();
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;
        if (username == null) {
            resp.put("Status", "Failed").put("Message", "User not logged in.");
            return Response.status(Response.Status.UNAUTHORIZED).entity(resp.toString()).build();
        }

        boolean isFastener = "Fastener".equalsIgnoreCase(type);

        if (supertype == null || type == null || apn == null || description == null ||
                supertype.trim().isEmpty() || type.trim().isEmpty() || apn.trim().isEmpty() || description.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "Missing required fields.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        if (isFastener) {
            if (fastenerSubPart == null || fastenerSubPart.trim().isEmpty() || variant == null || variant.trim().isEmpty()) {
                resp.put("Status", "Failed").put("Message", "FastenerSubPart and Variant are required when Type is Fastener.");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }
        } else {
            if (fastenerSubPart == null) fastenerSubPart = "";
            if (variant == null) variant = "";
        }

        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password)) {
            String firstState = "InWork"; 
            try (PreparedStatement psState = conn.prepareStatement("SELECT rulevalue FROM amxschemarules WHERE rulename = 'PartStates'")) {
                ResultSet rsState = psState.executeQuery();
                if (rsState.next()) {
                    String states = rsState.getString("rulevalue");
                    if (states != null && !states.isEmpty()) {
                        firstState = states.split("\\|")[0]; 
                    }
                }
                rsState.close();
            }

            String[] apnParts = apn.split("-");
            if (apnParts.length != 2) {
                resp.put("Status", "Failed").put("Message", "APN format should be like '500-Engine'");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }
            String prefix = apnParts[0];
            String suffix = apnParts[1];

            String query = "SELECT name FROM amxcorepartdata WHERE apn = ?";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, apn);
            ResultSet rs = ps.executeQuery();

            int maxNum = 0;
            while (rs.next()) {
                String existingName = rs.getString("name");
                String[] parts = existingName.split("-");
                if (parts.length == 3 && parts[0].equals(prefix) && parts[2].equals(suffix)) {
                    try {
                        int num = Integer.parseInt(parts[1]);
                        if (num > maxNum) maxNum = num;
                    } catch (NumberFormatException ignored) {}
                }
            }
            rs.close();
            ps.close();

            int newNum = maxNum + 1;
            String name = String.format("%s-%07d-%s", prefix, newNum, suffix);

            SecureRandom random = new SecureRandom();
            StringBuilder objectIdBuilder = new StringBuilder();
            for (int i = 0; i < 4; i++) {
                objectIdBuilder.append(String.format("%04X", random.nextInt(0x10000)));
                if (i < 3) objectIdBuilder.append(".");
            }
            String objectId = objectIdBuilder.toString() + ".APN";

            String createdDate = sf.format(new java.util.Date());

            String insertSQL = "INSERT INTO amxcorepartdata(objectid, apn, name, type, supertype, description, createddate, owner, email, fastenersubpart, variant, connectionid, currentstate, responsibleengineer) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";//BUG-1048 fixing done by koushik

            try (PreparedStatement insertPS = conn.prepareStatement(insertSQL)) {
                insertPS.setString(1, objectId);
                insertPS.setString(2, apn);
                insertPS.setString(3, name);
                insertPS.setString(4, type);
                insertPS.setString(5, supertype);
                insertPS.setString(6, description);
                insertPS.setTimestamp(7, Timestamp.valueOf(createdDate));
                insertPS.setString(8, username);
                insertPS.setString(9, username + "@apn.com");
                insertPS.setString(10, fastenerSubPart);
                insertPS.setString(11, variant);
                insertPS.setString(12, "");
                insertPS.setString(13, firstState); 
                insertPS.setString(14, responsibleEngineer);//BUG-1048 fixing done by koushik
                insertPS.executeUpdate();
            }

            String historyMsg = "Created by " + username + " at " + createdDate;
            try (PreparedStatement hSel = conn.prepareStatement("SELECT history FROM parthistory WHERE objectid = ?")) {
                hSel.setString(1, objectId);
                ResultSet hRs = hSel.executeQuery();
                if (hRs.next()) {
                    String existing = hRs.getString("history");
                    String updated = existing + " | " + historyMsg;
                    try (PreparedStatement hUpd = conn.prepareStatement("UPDATE parthistory SET history = ? WHERE objectid = ?")) {
                        hUpd.setString(1, updated);
                        hUpd.setString(2, objectId);
                        hUpd.executeUpdate();
                    }
                } else {
                    try (PreparedStatement hIns = conn.prepareStatement("INSERT INTO parthistory (objectid, history) VALUES (?, ?)")) {
                        hIns.setString(1, objectId);
                        hIns.setString(2, historyMsg);
                        hIns.executeUpdate();
                    }
                }
            }

            resp.put("Status", "Success")
                    .put("ObjectId", objectId)
                    .put("Name", name)
                    .put("CreatedDate", createdDate)
                    .put("Owner", username)
                    .put("FastenerSubPart", fastenerSubPart)
                    .put("Variant", variant)
                    .put("CurrentState", firstState);  

            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
	/**
	* @args None
	* @return Response
	* @usage This method loads and returns all distinct SuperType and Type values
	*      from the amxcorepartdata table as JSON arrays.
	*/
//loadall
    @POST
    @Path("/loadAll")
    @Produces(MediaType.APPLICATION_JSON)
    public Response loadAllTypes() {
        JSONObject resp = new JSONObject();
        Set<String> superTypes = new HashSet<>();
        Set<String> types = new HashSet<>();

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT DISTINCT supertype, type FROM amxcorepartdata")) {

            while (rs.next()) {
                String st = rs.getString("supertype");
                String t  = rs.getString("type");
                if (st != null && !st.trim().isEmpty()) superTypes.add(st);
                if (t  != null && !t.trim().isEmpty()) types.add(t);
            }
            resp.put("SuperType", new JSONArray(superTypes));
            resp.put("Type", new JSONArray(types));
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();
        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
    /**
 * @author Latha
 * @args Query parameters: name (String), filter (String)
 * @return Response
 * @usage This method performs a full-text search based on the filter type:
 *        - 'byparts': searches amxcorepartdata by part name (requires 'name')
 *        - 'bypersons': searches amxcorepersondata by person name (requires 'name')
 *        - 'all': searches both part and control data, requires 'name'
 *        Returns matching results as JSON array or appropriate error messages.
 */
//search
    @GET
    @Path("/amxfullsearch")
    @Produces(MediaType.APPLICATION_JSON)
    public Response search(@QueryParam("name") String name, @QueryParam("filter") String filter,@Context HttpServletRequest request) {
    	
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
    	
        JSONObject resp = new JSONObject();

        if (filter == null || filter.trim().isEmpty()) {
            filter = "all";
        }
        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password)) {
            JSONArray results = new JSONArray();
            if ("byparts".equalsIgnoreCase(filter)) {
                if (name == null || name.trim().isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "Part name is required for 'byParts'.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }
                String sql = "SELECT * FROM amxcorepartdata WHERE fts_document @@ to_tsquery(?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name.toLowerCase() + ":*");
                    try (ResultSet rs = ps.executeQuery()) {
                        ResultSetMetaData meta = rs.getMetaData();
                        while (rs.next()) {
                            JSONObject obj = new JSONObject();
                            for (int i = 1; i <= meta.getColumnCount(); i++) {
                                obj.put(meta.getColumnName(i), rs.getString(i));
                            }
                            results.put(obj);
                        }
                    }
                }
            } else if ("bypersons".equalsIgnoreCase(filter)) {
                if (name == null || name.trim().isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "Person name is required for 'byPersons'.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }
                String sql = "SELECT * FROM amxcorepersondata WHERE fts_document @@ to_tsquery(?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name.toLowerCase() + ":*");
                    try (ResultSet rs = ps.executeQuery()) {
                        ResultSetMetaData meta = rs.getMetaData();
                        while (rs.next()) {
                            JSONObject obj = new JSONObject();
                            for (int i = 1; i <= meta.getColumnCount(); i++) {
                                obj.put(meta.getColumnName(i), rs.getString(i));
                            }
                            results.put(obj);
                        }
                    }
                }
            } else if ("all".equalsIgnoreCase(filter)) {
                if (name == null || name.trim().isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "Search term is required for 'all'.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }

                String searchTerm = name.trim().toLowerCase();

                // Updated pattern for numeric part numbers like 900, 900-001
                if (searchTerm.matches("^[0-9]+(-[0-9]*)?$")) {
                    String sql = "SELECT * FROM amxcorepartdata WHERE fts_document @@ to_tsquery(?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
//                        ps.setString(1, searchTerm + ":*");
                    	
                    	String[] tokens = searchTerm.split("-");
                    	List<String> tsParts = new ArrayList<>();
                    	for (String token : tokens) {
                    	    tsParts.add(token + ":*");
                    	}
                    	String tsQuery = String.join(" & ", tsParts);
                    	ps.setString(1, tsQuery);
                    
                        try (ResultSet rs = ps.executeQuery()) {
                            ResultSetMetaData meta = rs.getMetaData();
                            while (rs.next()) {
                                JSONObject obj = new JSONObject();
                                for (int i = 1; i <= meta.getColumnCount(); i++) {
                                    obj.put(meta.getColumnName(i), rs.getString(i));
                                }
                                results.put(obj);
                            }
                        }
                    }
                } else {
                	//BUG-1089 fixing started by koushik
                	String[] parts = searchTerm.split("[^a-zA-Z0-9]+");
                	List<String> tsParts = new ArrayList<>();
                	for (String part : parts) {
                	    if (!part.trim().isEmpty()) {
                	        if (part.matches("\\d+")) {
                	            tsParts.add("(" + part + ":* | -" + part + ":*)");
                	        } else {
                	            tsParts.add(part + ":*");
                	        }
                	    }
                	}
                	//BUG-1089 fixing ended by koushik
                	String tsQuery = String.join(" & ", tsParts);
                	//BUG-1065 started by Nageswari
                	String sql;

                	if (searchTerm.equalsIgnoreCase("PASP") || searchTerm.startsWith("pasp-")) {

                	    sql = "SELECT * FROM amxpartspecificationdata WHERE fts_document @@ to_tsquery(?)";

                	}
                	//BUG-1089 fixing started by koushik
                	else if(searchTerm.equalsIgnoreCase("mpn") || searchTerm.matches("^mpn[-_].*")) {
                		sql = "SELECT * FROM amxcorempndetails WHERE fts_document @@ to_tsquery(?)";
                	}
                	//BUG-1089 fixing ended by koushik
                	else {

                	    sql = "SELECT * FROM amxpartcontroldata WHERE fts_document @@ to_tsquery(?)";

                	}
                	//BUG-1065 ended by Nageswari
                	try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, tsQuery);
                        try (ResultSet rs = ps.executeQuery()) {
                            ResultSetMetaData meta = rs.getMetaData();
                            while (rs.next()) {
                                JSONObject obj = new JSONObject();
                                for (int i = 1; i <= meta.getColumnCount(); i++) {
                                    obj.put(meta.getColumnName(i), rs.getString(i));
                                }
                                results.put(obj);
                            }
                        }
                    }
                }
            }

            else {
                resp.put("Status", "Failed").put("Message", "Invalid filter value.");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }
            resp.put("Status", "Success").put("Results", results);
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
	
/**
 * @author Latha
 * @args None
 * @return Response
 * @usage This method retrieves the latest 10 parts ordered by creation date from the database
 *        and returns them as a JSON array.
 */
	
//latestpart
    @POST
    @Path("/latest")
    @Produces(MediaType.APPLICATION_JSON)
    public Response latest() {
        JSONObject resp = new JSONObject();

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM amxcorepartdata ORDER BY createddate DESC LIMIT 10");
             ResultSet rs = ps.executeQuery()) {

            JSONArray arr = new JSONArray();
            ResultSetMetaData meta = rs.getMetaData();
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    obj.put(meta.getColumnName(i), rs.getString(i));
                }
                arr.put(obj);
            }

            resp.put("Status", "Success").put("LatestParts", arr);
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
	/**
	* @args Form parameters: objectid (String), Description (String)
	* @return Response
	* @usage This method updates the description of a part identified by objectid.
	* It also records the update event in the part history table.
	* Returns error if parameters are missing or objectid is not found.
	*/
	
	
//update
    @POST
    @Path("/update")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response update(@FormParam("objectid") String objectId,@FormParam("Description") String description) {
        JSONObject resp = new JSONObject();
        if (objectId == null || objectId.trim().isEmpty()
                || description == null || description.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "objectid and description are required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
        String updatedDate = sf.format(new Date());
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE amxcorepartdata SET description = ?, createddate = ? WHERE objectid = ?")) {
            ps.setString(1, description);
            ps.setTimestamp(2, Timestamp.valueOf(updatedDate));
            ps.setString(3, objectId);
            int count = ps.executeUpdate();
            if (count == 0) {
                resp.put("Status", "Failed").put("Message", "objectid not found.");
                return Response.status(Response.Status.NOT_FOUND).entity(resp.toString()).build();
            }
//add history
            String historyMsg = "Updated description at " + updatedDate;
            try (PreparedStatement psSel = conn.prepareStatement("SELECT history FROM part_history WHERE objectid = ?")) {
                psSel.setString(1, objectId);
                try (ResultSet rs = psSel.executeQuery()) {
                    if (rs.next()) {
                        String existing = rs.getString("history");
                        String updated = existing + " | " + historyMsg;
                        try (PreparedStatement psUpd = conn.prepareStatement("UPDATE part_history SET history = ? WHERE objectid = ?")) {
                            psUpd.setString(1, updated);
                            psUpd.setString(2, objectId);
                            psUpd.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO part_history (objectid, history) VALUES (?, ?)")) {
                            psIns.setString(1, objectId);
                            psIns.setString(2, historyMsg);
                            psIns.executeUpdate();
                        }
                    }
                }
            }

            resp.put("Status", "Success").put("Message", "Part updated.");
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }

	/**
	* @args Form parameter: objectid (String)
	* @return Response
	* @usage This method deletes a part identified by objectid from the database.
	*        It records the deletion event in the part history table.
	*        Returns error if objectid is missing or not found.
	*/
    //delete
    @POST
    @Path("/delete")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response delete(@FormParam("objectid") String objectId) {
        JSONObject resp = new JSONObject();
        if (objectId == null || objectId.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "objectid is required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement("DELETE FROM amxcorepartdata WHERE objectid = ?")) {
            ps.setString(1, objectId);
            int count = ps.executeUpdate();

            if (count == 0) {
                resp.put("Status", "Failed").put("Message", "objectid not found.");
                return Response.status(Response.Status.NOT_FOUND).entity(resp.toString()).build();
            }

            String deletedDate = sf.format(new Date());
            String historyMsg = "Deleted at " + deletedDate;
            try (PreparedStatement psSel = conn.prepareStatement("SELECT history FROM part_history WHERE objectid = ?")) {
                psSel.setString(1, objectId);
                try (ResultSet rs = psSel.executeQuery()) {
                    if (rs.next()) {
                        String existing = rs.getString("history");
                        String updated = existing + " | " + historyMsg;
                        try (PreparedStatement psUpd = conn.prepareStatement("UPDATE part_history SET history = ? WHERE objectid = ?")) {
                            psUpd.setString(1, updated);
                            psUpd.setString(2, objectId);
                            psUpd.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO part_history (objectid, history) VALUES (?, ?)")) {
                            psIns.setString(1, objectId);
                            psIns.setString(2, historyMsg);
                            psIns.executeUpdate();
                        }
                    }
                }
            }

            resp.put("Status", "Success").put("Message", "Part deleted.");
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
	
	/**
	* @args Query parameter: objectid (String)
	* @return Response
	* @usage This method retrieves the history log for a part control identified by objectid.
	* Returns the history as a JSON array if found, or an error message if not.
	*/

    //history 
    @GET
    @Path("/partcontrolhistory")
    @Produces(MediaType.APPLICATION_JSON)
    public Response partControlHistory(@QueryParam("objectid") String objectId) {
        JSONObject resp = new JSONObject();
        if (objectId == null || objectId.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "objectid is required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        String sql = "SELECT history FROM partcontrolhistory WHERE objectid = ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, objectId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String history = rs.getString("history");
                    String[] entries = history != null ? history.split(" \\| ") : new String[0];
                    resp.put("Status", "Success").put("History", new JSONArray(entries));
                } else {
                    resp.put("Status", "Failed").put("Message", "No history found.");
                }
            }
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
    
    
    @POST
    @Path("/createMPN")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createMPN(@FormParam("SuperType") String supertype, @FormParam("Type") String type, @FormParam("MPNTitle") String mpnTitle,
                              @FormParam("Manufacturer") String manufacturer, @FormParam("Description") String description,
                              @FormParam("ResponsibleEngineer") String responsibleEngineer, @Context HttpServletRequest request) {

        JSONObject resp = new JSONObject();
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;

        if (username == null) {
            resp.put("Status", "Failed").put("Message", "User not logged in.");
            return Response.status(Response.Status.UNAUTHORIZED).entity(resp.toString()).build();
        }

        if (supertype == null || type == null || mpnTitle == null || manufacturer == null || description == null ||
            supertype.trim().isEmpty() || type.trim().isEmpty() || mpnTitle.trim().isEmpty() ||
            manufacturer.trim().isEmpty() || description.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "Missing required fields.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
        String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password)) {

            String manufacturerId = getManufacturerId(conn, manufacturer);
            if (manufacturerId == null) {
                resp.put("Status", "Failed").put("Message", "Manufacturer not found: " + manufacturer);
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }

            String mpn = (mpnTitle.trim() + "_" + manufacturer.trim()).toUpperCase();

            String name = generateMPNName(conn);
            SecureRandom random = new SecureRandom();
            StringBuilder objectIdBuilder = new StringBuilder();
            for (int i = 0; i < 4; i++) {
                objectIdBuilder.append(String.format("%04X", random.nextInt(0x10000)));
                if (i < 3) objectIdBuilder.append(".");
            }
            String objectId = objectIdBuilder.toString() + ".MPN";
            
            String firstState = "InWork";
            try (PreparedStatement psState = conn.prepareStatement(
                    "SELECT rulevalue FROM amxschemarules WHERE rulename = 'PartStates'")) {
                ResultSet rsState = psState.executeQuery();
                if (rsState.next()) {
                    String states = rsState.getString("rulevalue");
                    if (states != null && !states.isEmpty()) {
                        firstState = states.split("\\|")[0];
                    }
                }
            }

            String createdDate = sf.format(new java.util.Date());

            String insertSQL = "INSERT INTO amxcorempndetails " +
                    "(objectid, mpn, name, title, type, supertype, manufacturer, description, " +
                    "createddate, owner, email, connectionid, currentstate, manufacturerid) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement insertPS = conn.prepareStatement(insertSQL)) {
                insertPS.setString(1, objectId);
                insertPS.setString(2, mpn);
                insertPS.setString(3, name);
                insertPS.setString(4, mpnTitle.trim());
                insertPS.setString(5, type.trim());
                insertPS.setString(6, supertype.trim());
                insertPS.setString(7, manufacturer.trim());
                insertPS.setString(8, description.trim());
                insertPS.setTimestamp(9, Timestamp.valueOf(createdDate));
                insertPS.setString(10, username);
                insertPS.setString(11, username + "@mpn.com");
                insertPS.setString(12, "");
                insertPS.setString(13, firstState);
                insertPS.setString(14, manufacturerId);
                insertPS.executeUpdate();
            }
            

            String historyMsg = "Created by " + username + " at " + createdDate;
            try (PreparedStatement hIns = conn.prepareStatement(
                    "INSERT INTO mpnhistory (objectid, history) VALUES (?, ?)")) {
                hIns.setString(1, objectId);
                hIns.setString(2, historyMsg);
                hIns.executeUpdate();
            }

            resp.put("Status", "Success")
                .put("ObjectId", objectId)
                .put("MPN", mpn)
                .put("Name", name)
                .put("Title", mpnTitle.trim())
                .put("Manufacturer", manufacturer.trim())
                .put("ManufacturerId", manufacturerId)
                .put("CreatedDate", createdDate)
                .put("Owner", username)
                .put("CurrentState", firstState);

            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();
            
        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
    
    
    
    private String generateMPNName(Connection conn) throws SQLException {
        String sql = "SELECT name FROM amxcorempndetails WHERE name LIKE 'MPN_%' ORDER BY name DESC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int maxNum = 0;
            if (rs.next()) {
                String lastName = rs.getString("name"); 
                try {
                    maxNum = Integer.parseInt(lastName.replace("MPN_", ""));
                } catch (NumberFormatException ignored) {}
            }
            return String.format("MPN_%06d", maxNum + 1);
        }
    }
    
    
    private String getManufacturerId(Connection conn, String manufacturerName) throws SQLException {
        String sql = "SELECT objectid FROM amxsuppliercompanies WHERE LOWER(name) = LOWER(?) LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, manufacturerName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("objectId");
                }
            }
        }
        return null; 
    }
    
    
    
    /**
     * Fetches all columns for a given object ID from amxcorepartdata.
     * @param id the object ID to look up
     * @return JSON response containing all the data fields of the object or an error message if not found
     */
    // Get all part info
    @GET 
    @Path("/getMPN") 
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllInfo(@QueryParam("objectId") String id, @Context HttpServletRequest request) {
    	
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
    	
        String sql = "SELECT * FROM amxcorempndetails WHERE objectid = ?";
        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    JSONObject obj = new JSONObject();
                    ResultSetMetaData md = rs.getMetaData();
                    for (int i = 1; i <= md.getColumnCount(); i++) {
                        obj.put(md.getColumnName(i), rs.getString(i));
                    }
                    return Response.ok(obj.toString()).build();
                }
                return Response.status(Status.NOT_FOUND).entity("{\"error\":\"Object not found\"}").build();
            }
        } catch (SQLException e) {
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }
    
    
    @GET
    @Path("/getLinkedMPNs")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getLinkedMPNs(@QueryParam("objectid") String objectid, @Context HttpServletRequest request) {
    	
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
    	
        if (objectid == null || objectid.trim().isEmpty()) {
            return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
        }

        String sql = "select * from amxcorempndetails where connectionid=(select connectionid from amxcorepartdata where objectid= ? and connectionid != '')";
        
        List<Map<String, String>> results = new ArrayList<>();
        
        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, objectid.trim());

            try (ResultSet rs = pstmt.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                int colCount = metaData.getColumnCount();

                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    for (int i = 1; i <= colCount; i++) {
                        row.put(metaData.getColumnName(i), rs.getString(i));
                    }
                    results.add(row);
                }
            }
            
           
            if (results.isEmpty()) {
                return Response.ok("{\"message\":\"No MPN equivalents found.\"}").build();
            }

            return Response.ok(results).build();

        } catch (SQLException e) {
            e.printStackTrace();
            return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }
    
    
    @POST
    @Path("linkMPNs/{objectid}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response linkMPNs(@PathParam("objectid") String objectid, List<Map<String, Object>> selectedMPNs,@Context HttpServletRequest request) {
        try {
            String appName = request.getContextPath().replace("/", "");  // ← ADD THIS
            DBConfig.setAppName(appName);  
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);

            for (Map<String, Object> mpn : selectedMPNs) {
                String mpnId = (String) mpn.get("objectid");
                String mpnName = (String) mpn.get("name");
                
                if (isMPNAlreadyLinked(conn, mpnId)) {
                    Map<String, String> error = new HashMap<>();
                    error.put("Status", "Error");
                    error.put("Message", "MPN " + mpnName + " is already linked to a different part.");
                    return Response.status(Response.Status.CONFLICT).entity(error).build();
                }

                String existingConnectionId = getConnectionIdFromPart(objectid);
                String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                        ? existingConnectionId
                        : generateHexId("CONN");

                String sql = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, connectionIdToUse);
                    ps.setString(2, "ManufacturerPart");
                    ps.setString(3, mpnName);
                    ps.setString(4, mpnId);  
                    ps.setString(5, objectid);       
                    ps.setString(6, "ManufacturerPart");
                    ps.setString(7, "part");
                    ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                    ps.executeUpdate();
                }
            
            
            String updateMPNDataSQL = "UPDATE amxcorempndetails SET connectionid = ? WHERE objectid = ?";
            try (PreparedStatement ps3 = conn.prepareStatement(updateMPNDataSQL)) {
                ps3.setString(1, connectionIdToUse);
                ps3.setString(2, mpnId);
                ps3.executeUpdate();
            }
            
            String updatePartDataSQL = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
            try (PreparedStatement ps3 = conn.prepareStatement(updatePartDataSQL)) {
                ps3.setString(1, connectionIdToUse);
                ps3.setString(2, objectid);
                ps3.executeUpdate();
            }
            
            
            }

            conn.close();

            Map<String, String> result = new HashMap<>();
            result.put("Status", "Success");
            return Response.ok(result).build();

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("Status", "Error");
            error.put("Message", e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error).build();
        }
    }
    
    public String getConnectionIdFromPart(String objectId) {
        String sql = "SELECT connectionid FROM amxcorepartdata WHERE objectid = ?";
        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, objectId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("connectionid");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    

 
    private boolean isMPNAlreadyLinked(Connection conn, String mpnObjectId) throws Exception {
        String sql = "SELECT connectionid FROM amxcorempndetails " +
                     "WHERE objectid = ? AND connectionid IS NOT NULL and connectionid !=''";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, mpnObjectId);
            ResultSet rs = ps.executeQuery();
            boolean exists = rs.next();
            rs.close();
            return exists;
        }
    }
    

    
    public String generateHexId(String suffix) {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < 4; i++) {
            String segment = Integer.toHexString(random.nextInt(0x10000)).toUpperCase();
            while (segment.length() < 4) {
                segment = "0" + segment;
            }
            sb.append(segment);
            if (i < 3) sb.append(".");
        }

        sb.append(".").append(suffix.toUpperCase());
        return sb.toString();
    }
    
    
    @GET
    @Path("/getLinkedAPNs")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getLinkedAPNs(@QueryParam("objectid") String objectid, @Context HttpServletRequest request) {
    	
    	
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
    	
        if (objectid == null || objectid.trim().isEmpty()) {
            return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
        }

        String sql = "select * from amxcorepartdata where connectionid=(select connectionid from amxcorempndetails where objectid=? and connectionid != '')";

        List<Map<String, String>> results = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, objectid.trim());

            try (ResultSet rs = pstmt.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                int colCount = metaData.getColumnCount();

                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    for (int i = 1; i <= colCount; i++) {
                        row.put(metaData.getColumnName(i), rs.getString(i));
                    }
                    results.add(row);
                }
            }

            if (results.isEmpty()) {
                return Response.ok("{\"message\":\"No APN equivalents found.\"}").build();
            }

            return Response.ok(results).build();

        } catch (SQLException e) {
            e.printStackTrace();
            return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }
    
    
    @POST
    @Path("linkAPN/{objectid}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response linkAPNToMPN(@PathParam("objectid") String objectid,List<Map<String, Object>> selectedAPNs,@Context HttpServletRequest request) {
        try {
        	String appName = request.getContextPath().replace("/", "");
        	DBConfig.setAppName(appName);
        	
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);

            for (Map<String, Object> apn : selectedAPNs) {
                String apnId = (String) apn.get("objectid");
                String apnName = (String) apn.get("name");
                String apnType = (String) apn.get("type");

                if (isMPNAlreadyLinked(conn, objectid)) {
                    Map<String, String> error = new HashMap<>();
                    error.put("Status", "Error");
                    error.put("Message", "Selected MPN " + " is already linked to a part.");
                    return Response.status(Response.Status.CONFLICT).entity(error).build();
                }
                
                String existingConnectionId = getConnectionIdFromPart(apnId);
                String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                        ? existingConnectionId
                        : generateHexId("CONN");

                String sql = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, connectionIdToUse);
                    ps.setString(2, apnType);
                    ps.setString(3, apnName);
                    ps.setString(4, apnId);  
                    ps.setString(5, objectid);       
                    ps.setString(6, "Part");
                    ps.setString(7, "ManufacturerPart");
                    ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                    ps.executeUpdate();
                }
            
            
                String updateMPNDataSQL = "UPDATE amxcorempndetails SET connectionid = ? WHERE objectid = ?";
                try (PreparedStatement ps3 = conn.prepareStatement(updateMPNDataSQL)) {
                    ps3.setString(1, connectionIdToUse);
                    ps3.setString(2, objectid);
                    ps3.executeUpdate();
                }
                
            String updatePartDataSQL = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
            try (PreparedStatement ps3 = conn.prepareStatement(updatePartDataSQL)) {
                ps3.setString(1, connectionIdToUse);
                ps3.setString(2, apnId);
                ps3.executeUpdate();
            }
            }

            conn.close();

            Map<String, String> result = new HashMap<>();
            result.put("Status", "Success");
            return Response.ok(result).build();

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("Status", "Error");
            error.put("Message", e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error).build();
        }
    }
    
    
    // MPN Lifecycle - PUT (update state)
    @PUT
    @Path("/updatempnstate/{objectId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateMPNToSpecificState(@PathParam("objectId") String objectId, String jsonBody, @Context HttpServletRequest request) {
    	
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
    	
        if (objectId == null || objectId.trim().isEmpty()) {
            return Response.ok("{\"error\": \"objectId must be provided\"}").build();
        }

        if (!objectId.endsWith(".MPN")) {
            return Response.ok("{\"error\": \"Invalid objectId suffix. Expected .MPN\"}").build();
        }

        String dataTable    = "amxcorempndetails";
        String ruleName     = "MPNStates";
        String historyTable = "mpnhistory";

        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password)) {
            JSONObject input = new JSONObject(jsonBody);
            String newState = input.optString("state", "").trim();

            if (newState.isEmpty()) {
                return Response.ok("{\"error\": \"State must be provided\"}").build();
            }

            String currentState = getCurrentState(conn, dataTable, objectId);
            if (currentState == null) {
                return Response.ok("{\"error\": \"MPN not found " + "\"}").build();
            }

            List<String> validStates = getStateSequence(conn, ruleName);
            if (!validStates.contains(newState)) {
                return Response.ok("{\"error\": \"Invalid state: " + newState + "\"}").build();
            }

            int currentIndex = validStates.indexOf(currentState);
            int newIndex     = validStates.indexOf(newState);
            String finalState  = validStates.get(validStates.size() - 1);
            String finalState2 = validStates.get(validStates.size() - 2);

            if (currentState.equals(finalState)) {
                return Response.ok("{\"error\": \"State can't be changed as it reaches its final stage: " + currentState + "\"}").build();
            } else if (currentState.equals(finalState2) && newIndex == validStates.size() - 3) {
                return Response.ok("{\"error\": \"State can't be changed back as it reaches its " + currentState + " stage\"}").build();
            }

            String direction;
            if (newIndex == currentIndex + 1) {
                direction = "Promoted";
            } else if (newIndex == currentIndex - 1) {
                direction = "Demoted";
            } else {
                return Response.ok("{\"error\": \"Invalid state transition. Only one-step transitions are allowed.\"}").build();
            }

            String timestamp      = java.time.LocalDateTime.now().toString();
            String historyMessage = direction + " to state: " + newState + " at " + timestamp;

            updatePartState(conn, dataTable, objectId, newState);
            insertHistory(conn, historyTable, objectId, historyMessage);

            return Response.ok("{\"message\": \"State updated successfully\", \"oldState\": \"" + currentState + "\", \"newState\": \"" + newState + "\"}")
                    .build();

        } catch (Exception e) {
            return Response.ok("{\"error\": \"Internal error: " + e.getMessage() + "\"}").build();
        }
    }


    // MPN Lifecycle - GET (current state)
    @GET
    @Path("/updatempnstate/{objectId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getMPNCurrentStateAPI(@PathParam("objectId") String objectId, @Context HttpServletRequest request) {
    	
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
        if (objectId == null || objectId.trim().isEmpty()) {
            return Response.ok("{\"error\": \"objectId must be provided\"}").build();
        }

        if (!objectId.endsWith(".MPN")) {
            return Response.ok("{\"error\": \"Invalid objectId suffix. Expected .MPN\"}").build();
        }

        String dataTable = "amxcorempndetails";

        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password)) {
            String currentState = getCurrentState(conn, dataTable, objectId);
            if (currentState == null) {
                return Response.ok("{\"error\": \"MPN not found " + "\"}").build();
            }
            return Response.ok("{\"currentState\": \"" + currentState + "\"}").build();
        } catch (SQLException e) {
            return Response.ok("{\"error\": \"Database error: " + e.getMessage() + "\"}").build();
        }
    }
    
    
    public String getCurrentState(Connection conn, String tableName, String objectId) throws SQLException {
        String query = "SELECT currentstate FROM " + tableName + " WHERE objectid = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, objectId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("currentstate");
                }
            }
        }
        return null;
    }
    
    
    public List<String> getStateSequence(Connection conn, String ruleName) throws SQLException {
        String query = "SELECT rulevalue FROM amxschemarules WHERE rulename = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, ruleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String ruleValue = rs.getString("rulevalue");
                    return Arrays.asList(ruleValue.split("\\|"));
                }
            }
        }
        return new ArrayList<>();
    }
    
    
    public void updatePartState(Connection conn, String tableName, String objectId, String newState) throws SQLException {
        String query = "UPDATE " + tableName + " SET currentstate=? WHERE objectid=?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, newState);
            ps.setString(2, objectId);
            ps.executeUpdate();
        }
    }
    
    
    public void insertHistory(Connection conn, String historyTable, String objectId, String historyMessage) throws SQLException {
        String query = "INSERT INTO " + historyTable + " (objectid, history) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, objectId);
            ps.setString(2, historyMessage);
            ps.executeUpdate();
        }
    }
    
    
    
    //BUG-1067 started fixing by koushik
    /**
     * @args objectId (String)
     * @return JSON containing successfull update of the state or error message
     * @usage updates state of a partspecification by objectId
     */
    // Part Specification Lifecycle - PUT (update state)
    @PUT
    @Path("/updatepartspecificationstate/{objectId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updatePartSpecificationToSpecificState(@PathParam("objectId") String objectId, String jsonBody, @Context HttpServletRequest request) {
    	try {
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
    	HttpSession session = request.getSession(false);

    	String username = "Unknown";

    	if (session != null && session.getAttribute("username") != null) {
    	    username = (String) session.getAttribute("username");
    	}
    	
        if (objectId == null || objectId.trim().isEmpty()) {
            return Response.ok("{\"error\": \"objectId must be provided\"}").build();
        }

        if (!objectId.endsWith(".PASP")) {
            return Response.ok("{\"error\": \"Invalid objectId suffix. Expected .PASP\"}").build();
        }

        String dataTable    = "amxpartspecificationdata";
        String ruleName     = "PartSpecStates";
        String historyTable = "partspecificationhistory";

        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password)) {
            JSONObject input = new JSONObject(jsonBody);
            String newState = input.optString("state", "").trim();

            if (newState.isEmpty()) {
                return Response.ok("{\"error\": \"State must be provided\"}").build();
            }

            String currentState = getCurrentState(conn, dataTable, objectId);
            if (currentState == null) {
                return Response.ok("{\"error\": \"Part specification not found " + "\"}").build();
            }

            List<String> validStates = getStateSequence(conn, ruleName);
            if (!validStates.contains(newState)) {
                return Response.ok("{\"error\": \"Invalid state: " + newState + "\"}").build();
            }
            int currentIndex = validStates.indexOf(currentState);
            int newIndex     = validStates.indexOf(newState);

            String direction;
            if (newIndex == currentIndex + 1) {
                direction = "Promoted";
            } else if (newIndex == currentIndex - 1) {
                direction = "Demoted";
            } else {
                return Response.ok("{\"error\": \"Invalid state transition. Only one-step transitions are allowed.\"}").build();
            }
			String timestamp      = java.time.LocalDateTime.now().toString();
			 String historyMessage =direction + " to state: " + newState +" by " + username +" at " + timestamp;
            updatePartState(conn, dataTable, objectId, newState);
            insertHistory(conn, historyTable, objectId, historyMessage);

            return Response.ok("{\"message\": \"State updated successfully\", \"oldState\": \"" + currentState + "\", \"newState\": \"" + newState + "\"}")
                    .build();

        } catch (Exception e) {
            return Response.ok("{\"error\": \"Internal error: " + e.getMessage() + "\"}").build();
        }
    	}catch(Exception e) {
    		return Response.ok("{\"error\": \"Internal error: " + e.getMessage() + "\"}").build();
    	}
    }
    
   // PartSpecification Lifecycle - GET (current state)
    /**
     * @args objectId (String)
     * @return JSON containing current state  or error message
     * @usage retrives current state of a partspecification by objectId
     */
    @GET
    @Path("/updatepartspecificationstate/{objectId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPartSpecificationCurrentStateAPI(@PathParam("objectId") String objectId, @Context HttpServletRequest request) {
    	try {
    	String appName =request.getContextPath().replace("/", "");
    	DBConfig.setAppName(appName);
        if (objectId == null || objectId.trim().isEmpty()) {
            return Response.ok("{\"error\": \"objectId must be provided\"}").build();
        }

        if (!objectId.endsWith(".PASP")) {
            return Response.ok("{\"error\": \"Invalid objectId suffix. Expected .PASP\"}").build();
        }

        String dataTable = "amxpartspecificationdata";

        try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password)) {
            String currentState = getCurrentState(conn, dataTable, objectId);
            if (currentState == null) {
                return Response.ok("{\"error\": \"Part specification not found " + "\"}").build();
            }
            return Response.ok("{\"currentState\": \"" + currentState + "\"}").build();
        } catch (SQLException e) {
            return Response.ok("{\"error\": \"Database error: " + e.getMessage() + "\"}").build();
        }
    	}catch(Exception e) {
    		return Response.ok("{\"error\": \"Internal error: " + e.getMessage() + "\"}").build();
    	}
    }
    
    //BUG-1067 fixing ended by koushik.
    
    /**
     * @args objectId (String)
     * @return JSON containing history entries or error message
     * @usage Retrieves history of a part by objectId
     */
    			
        //history
        @GET
           @Path("/getMPNHistory")
           @Produces(MediaType.APPLICATION_JSON)
           public Response getMPNHistory(@QueryParam("objectId") String objectId, @Context HttpServletRequest request) {
        	
        	String appName =request.getContextPath().replace("/", "");
        	DBConfig.setAppName(appName);
               String sql = "SELECT history FROM mpnhistory WHERE objectid = ?";
               try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);
            		   PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, objectId);
                   try (ResultSet rs = ps.executeQuery()) {
                       List<String> histories = new ArrayList<>();
                       while (rs.next()) {
                           histories.add(rs.getString("history"));
                       }
                       if (histories.isEmpty()) {
                           return Response.ok("{\"error\":\"No history found"+ "\"}").build();
                       }
                       JSONObject json = new JSONObject();
                       json.put("objectId", objectId);
                       json.put("history", histories);
                       return Response.ok(json.toString()).build();
                   }
               } catch (SQLException e) {
                   return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
               }
           }
        @GET
        @Path("/getUserAccess")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getUserAccess(@Context HttpServletRequest request) {

            JSONObject resp = new JSONObject();

            HttpSession session = request.getSession(false);
            String username = (session != null) ? (String) session.getAttribute("username") : null;

            if (username == null) {
                resp.put("Status", "Failed");
                resp.put("Message", "User not logged in.");
                return Response.status(Response.Status.UNAUTHORIZED).entity(resp.toString()).build();
            }
//BUG-1038 Started
            String sql = "SELECT access FROM amxcorepersondata WHERE LOWER(username)=LOWER(?)";

            try (Connection conn = DriverManager.getConnection(DBConfig.getUrl(), user, db_password);
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, username);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    resp.put("Status", "Success");
                    resp.put("Access", rs.getString("access"));
                } else {
                    resp.put("Status", "Failed");
                    resp.put("Message", "User not found.");
                }

                return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

            } catch (SQLException e) {
                e.printStackTrace();
                resp.put("Status", "Failed");
                resp.put("Message", e.getMessage());
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
            }
        }
    //BUG-1038 End
    
}
												