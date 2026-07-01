package org.navigator;

import java.io.ByteArrayInputStream;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.Date;
import org.json.JSONObject;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.http.*;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import jakarta.ws.rs.core.Response.Status;
import amd.Person;
import amd.AmxControlTriggers;
import amd.AmxQueryFromDB;
import amd.AmxSchemasrules;
import amd.AmxSpecificationDocument;

/**
 * DataFetchService provides REST endpoints to fetch part data from the database.
 * It connects to a PostgreSQL database to retrieve specific fields or complete records
 * from the amxcorepartdata table based on an object ID.
 * Connection details:
 *   - URL: jdbc:postgresql://localhost:5432/Andromeda
 *   - User: postgres
 *   - Password: amxadmin123
 * The service uses standard JDBC connections and returns JSON responses.
 */
@Path("/datafetchservice")
public class DataFetchService {
    public static final String url = "jdbc:postgresql://localhost:5432/amx2xdev.Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "admin@1234";
    public static final SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
         
        }
    }
	
	/**
     * Establishes a new database connection using configured JDBC parameters.
     * @return a valid JDBC Connection object
     * @throws SQLException if connection fails
     */
	 
    public Connection getConn() throws SQLException {
        return DriverManager.getConnection(url, user, db_password);
    }
	/**
     * Fetches the value of a specific field from amxcorepartdata for a given object ID.
     * @param id the object ID to look up
     * @param field the database column name to retrieve
     * @return JSON response containing the field value or an error message if not found
     */
	 
    // getinfo()
    @GET
    @Path("/info") 
    @Produces(MediaType.APPLICATION_JSON)
    public Response getInfo(@QueryParam("objectId") String id, @QueryParam("field") String field) {
        String sql = "SELECT " + field + " FROM amxcorepartdata WHERE objectid = ?";
        try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Response.ok(new JSONObject().put("value", rs.getString(1)).toString()).build();
                }
                return Response.status(Status.NOT_FOUND).entity("{\"error\":\"Field not found\"}").build();
            }
        } catch (SQLException e) {
            return Response.status(Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

	/**
     * Fetches all columns for a given object ID from amxcorepartdata.
     * @param id the object ID to look up
     * @return JSON response containing all the data fields of the object or an error message if not found
     */
    // Get all part info
    @GET 
    @Path("/infos") 
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllInfo(@QueryParam("objectId") String id) {
        String sql = "SELECT * FROM amxcorepartdata WHERE objectid = ?";
        try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
	/**
 * @args  String supertype - the supertype/category of the part control type - the specific type of the part control description - description text for the part control assignee - the user assigned to the part control request - HttpServletRequest object to get session info (user authentication)
 * @return Response - JSON response indicating success or failure of the creation operation
 * @usage This method creates a new Part Control entry in the database.
 *        It performs the following steps:
 *          - Validates user session to ensure user is logged in.
 *          - Validates mandatory input fields (supertype, type, description, assignee).
 */

    //createPart
    @POST
    @Path("/createpartcontrol")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createPartControl(@FormParam("SuperType") String supertype, @FormParam("Type") String type,
          @FormParam("Description") String description,@FormParam("Assignee") String assignee,@Context HttpServletRequest request) {
        JSONObject resp = new JSONObject();
        HttpSession session = request.getSession(true);
        if (session == null
                || session.getAttribute("username") == null
                || session.getAttribute("emailId") == null) {
            resp.put("Status", "Failed").put("Message", "User not logged in.");
            return Response.status(Response.Status.UNAUTHORIZED).entity(resp.toString()).build();
        }
        String username = (String) session.getAttribute("username");
        String emailId = (String) session.getAttribute("emailId");

        if (supertype == null || supertype.trim().isEmpty()
                || type == null || type.trim().isEmpty()
                || description == null || description.trim().isEmpty()
                || assignee == null || assignee.trim().isEmpty()) {

            resp.put("Status", "Failed").put("Message", "Missing required fields.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {

            // Generate objectId
            SecureRandom random = new SecureRandom();
            byte[] bytes = new byte[8];
            random.nextBytes(bytes);
            StringBuilder objectIdBuilder = new StringBuilder();
            for (int i = 0; i < bytes.length; i += 2) {
                int part = ((bytes[i] & 0xFF) << 8) | (bytes[i + 1] & 0xFF);
                objectIdBuilder.append(String.format("%04X", part));
                if (i < bytes.length - 2) objectIdBuilder.append(".");
            }
            String objectId = objectIdBuilder.toString() + ".PACO";
            String prefix = "PC-";
            int maxNum = 0;
            String selectMaxNum = "SELECT name FROM amxpartcontroldata WHERE name LIKE ?";
            try (PreparedStatement ps = conn.prepareStatement(selectMaxNum)) {
                ps.setString(1, prefix + "%");
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String existingName = rs.getString("name");
                        if (existingName.startsWith(prefix)) {
                            String numPart = existingName.substring(prefix.length());
                            try {
                                int num = Integer.parseInt(numPart);
                                if (num > maxNum) {
                                    maxNum = num;
                                }
                            } catch (NumberFormatException ignored) {}
                        }
                    }
                }
            }
            int nextNum = maxNum + 1;
            String name = String.format("%s%06d", prefix, nextNum);
            String createdDate = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            String fetchStateRule = "SELECT rulevalue FROM amxschemarules WHERE rulename = 'PartControlStates'";
            String initialState = "InWork"; 

            try (PreparedStatement stateStmt = conn.prepareStatement(fetchStateRule);
                 ResultSet stateRs = stateStmt.executeQuery()) {
                if (stateRs.next()) {
                    String ruleValue = stateRs.getString("rulevalue");
                    if (ruleValue != null && !ruleValue.trim().isEmpty()) {
                        String[] states = ruleValue.split("\\|");
                        if (states.length > 0) {
                            initialState = states[0].trim();
                        }
                    }
                }
            }
            // Insert into amxpartcontroldata
            String insertSQL = "INSERT INTO amxpartcontroldata " +
                    "(objectid, name, supertype, type, description, createddate, owner, email, assignee, connectionid, linkedobjectid, currentstate) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement insertPS = conn.prepareStatement(insertSQL)) {
                insertPS.setString(1, objectId);
                insertPS.setString(2, name);
                insertPS.setString(3, supertype);
                insertPS.setString(4, type);
                insertPS.setString(5, description);
                insertPS.setTimestamp(6, Timestamp.valueOf(createdDate));
                insertPS.setString(7, username);
                insertPS.setString(8, emailId != null ? emailId : "");
                insertPS.setString(9, assignee);
                insertPS.setString(10, "");
                insertPS.setString(11, "");
                insertPS.setString(12, initialState);
                insertPS.executeUpdate();
            }

            // Insert or update partcontrolhistory
            String historyMsg = "Created by " + username + " at " + createdDate;
            String hSelect = "SELECT history FROM partcontrolhistory WHERE objectid = ?";
            try (PreparedStatement hSel = conn.prepareStatement(hSelect)) {
                hSel.setString(1, objectId);
                try (ResultSet hrs = hSel.executeQuery()) {
                    if (hrs.next()) {
                        String hist = hrs.getString("history");
                        String combined = hist + " | " + historyMsg;
                        String hUpdate = "UPDATE partcontrolhistory SET history = ? WHERE objectid = ?";
                        try (PreparedStatement hUpd = conn.prepareStatement(hUpdate)) {
                            hUpd.setString(1, combined);
                            hUpd.setString(2, objectId);
                            hUpd.executeUpdate();
                        }
                    } else {
                        String hInsert = "INSERT INTO partcontrolhistory (objectid, history) VALUES (?, ?)";
                        try (PreparedStatement hIns = conn.prepareStatement(hInsert)) {
                            hIns.setString(1, objectId);
                            hIns.setString(2, historyMsg);
                            hIns.executeUpdate();
                        }
                    }
                }
            }
            // Success response
            JSONObject success = new JSONObject();
            success.put("Status", "Success");
            success.put("Message", "Object created successfully");
            success.put("partcontrolId", objectId);
            success.put("Name", name);
            success.put("InitialState", initialState);
            return Response.ok(success.toString(), MediaType.APPLICATION_JSON).build();
            
        } catch (SQLException ex) {
            ex.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Internal server error: " + ex.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
	/**
	* @args objectId (String), body (JSON String)
	* @return Response
	* @usage Updates the description of a part and logs the update in history
	*/
    
    //updatepart
    @PUT
    @Path("/updatepart/{objectid}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response update(@PathParam("objectid") String objectId, String body) {
        JSONObject resp = new JSONObject();
        SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            JSONObject json = new JSONObject(body);
            String description = json.optString("description", "").trim();

            // Validate input
            if (objectId == null || objectId.trim().isEmpty() || description.isEmpty()) {
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
                // History handling
                String historyMsg = "Updated description at " + updatedDate;
                try (PreparedStatement psSel = conn.prepareStatement("SELECT history FROM parthistory WHERE objectid = ?")) {
                    psSel.setString(1, objectId);
                    try (ResultSet rs = psSel.executeQuery()) {
                        if (rs.next()) {
                            String existing = rs.getString("history");
                            String updated = existing + " | " + historyMsg;
                            try (PreparedStatement psUpd = conn.prepareStatement("UPDATE parthistory SET history = ? WHERE objectid = ?")) {
                                psUpd.setString(1, updated);
                                psUpd.setString(2, objectId);
                                psUpd.executeUpdate();
                            }
                        } else {
                            try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO parthistory (objectid, history) VALUES (?, ?)")) {
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

        } catch (Exception ex) {
            ex.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Invalid input: " + ex.getMessage());
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
    }
	/*
 * @args objectId (String)
 * @return Response
 * @usage Deletes a part by objectId and logs the deletion in history
 */

    // Delete part
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
	* @args none
	* @return List of latest parts in JSON
	* @usage Retrieves the 10 most recent parts ordered by created date
	*/
    // Latest parts
    @GET 
    @Path("/latestparts")
    @Produces(MediaType.APPLICATION_JSON)
    public Response latestParts() {
        String sql = "SELECT * FROM amxcorepartdata ORDER BY createddate DESC LIMIT 10";
        try (Connection conn = getConn(); 
        	PreparedStatement ps = conn.prepareStatement(sql); 
        	ResultSet rs = ps.executeQuery()) {
            List<Map<String, String>> list = new ArrayList<>();
            ResultSetMetaData md = rs.getMetaData();
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                for (int i = 1; i <= md.getColumnCount(); i++) {
                    row.put(md.getColumnName(i), rs.getString(i));
                }
                list.add(row);
            }
            return Response.ok(list).build();
        } catch (SQLException e) {
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }
		/**
 * @args objectId (String)
 * @return JSON containing history entries or error message
 * @usage Retrieves history of a part by objectId
 */
		//BUG-1046 Started By Nageswari
    @GET
    @Path("/mycreatedparts")
    @Produces(MediaType.APPLICATION_JSON)
    public Response myCreatedParts(@Context HttpServletRequest request) {

        return getMyCreatedObjects(request, "amxcorepartdata");
    }
    @GET
    @Path("/mypartcontrols")
    @Produces(MediaType.APPLICATION_JSON)
    public Response myPartControls(@Context HttpServletRequest request) {

        return getMyCreatedObjects(request, "amxpartcontroldata");
    }
    @GET
    @Path("/mympns")
    @Produces(MediaType.APPLICATION_JSON)
    public Response myMpns(@Context HttpServletRequest request) {

        return getMyCreatedObjects(request, "amxcorempndetails");
    }
    //BUG-1046 Ended by Nageswari
    
    //Bug-1054 fixing started by Koushik
    @GET
    @Path("/mypartspecs")
    @Produces(MediaType.APPLICATION_JSON)
    public Response myPartSpecs(@Context HttpServletRequest request) {
    	Response response;
    	try {
    		response = getMyCreatedObjects(request,"amxpartspecificationdata");
    	}catch(Exception e) {
    		e.printStackTrace();
    		return Response.ok("{\"error\":\""+e.getMessage()+"\"}").build();
    	}
    	
    	return response;
    }
    //Bug-1054 fixing ended by Koushik

    
    
    //history
    @GET
       @Path("/history")
       @Produces(MediaType.APPLICATION_JSON)
       public Response getHistory(@QueryParam("objectId") String objectId) {
           String sql = "SELECT history FROM parthistory WHERE objectid = ?";
           try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
               ps.setString(1, objectId);
               try (ResultSet rs = ps.executeQuery()) {
                   List<String> histories = new ArrayList<>();
                   while (rs.next()) {
                       histories.add(rs.getString("history"));
                   }
                   if (histories.isEmpty()) {
                       return Response.ok("{\"error\":\"No history found for Part object:"+ "\"}").build();
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
	   
	   /**
 * @args none
 * @return List of persons in JSON
 * @usage Retrieves all persons from the database
 */

    // Persons list
    @GET
    @Path("/persons")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPersons() {
        String query = "SELECT * FROM amxcorepersondata";        
        List<Map<String, String>> filteredPersons = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, String> person = new LinkedHashMap<>();
                person.put("Username", rs.getString("username"));
                person.put("Firstname", rs.getString("firstname"));
                person.put("Lastname", rs.getString("lastname"));
                person.put("Country", rs.getString("country"));
                person.put("Email", rs.getString("email"));
                person.put("Access", rs.getString("access"));
                person.put("ObjectId", rs.getString("objectid"));
                filteredPersons.add(person);
            }
            return Response.ok(filteredPersons).build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"Failed to load persons.\"}").build();
        }
    }
			/**
 * @args objectid (String)
 * @return Person info as JSON or error message
 * @usage Retrieves detailed information about a person by objectid
 */
    // Person infos
    @GET
    @Path("/getpersoninfos")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPersonInfos(@QueryParam("objectid") String objectid) {
        try {
            if (objectid == null || objectid.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Missing or invalid objectId parameter\"}").build();
            }
            Person person = new Person(objectid);
            Map<String, String> data = person.getInfos();

            if (data == null || data.isEmpty()) {
                return Response.status(Response.Status.OK)
                        .entity("{\"error\":\" Person'"+ "' not found\"}").build();
            }

            return Response.ok(data).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Internal server error. Please try again later.\"}").build();
        }
    }

	/**
 * @args objectId (String), updateData (Map<String, String>)
 * @return JSON Response
 * @usage Updates part information based on objectId and provided data
 */
	//update 
    @PUT
    @Path("/update/{objectId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updatePart(@PathParam("objectId") String objectId, Map<String, String> updateData) {
        try {
            if (objectId == null || objectId.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\": \"objectId must be provided\"}").build();
            }
            Person person = new Person(objectId);
            person.updatePersonInDatabase(updateData);

            return Response.ok("{\"message\": \"Part updated successfully\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\": \"Error updating part: " + e.getMessage() + "\"}").build();
        }
    }
	 
	 /**
 * @args none
 * @return JSON list of person access options
 * @usage Retrieves available access options for persons
 */
  //updatePersonAccess
    @GET
    @Path("/personaccess")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPersonAccessOptions() {
        try {
            Map<String, List<String>> accessMap = AmxSchemasrules.PersonAccess();
            List<String> accessOptions = accessMap.get("Person Access");
            
            if (accessOptions == null || accessOptions.isEmpty()) {
                throw new RuntimeException("No access options found in database.");
            }
            return Response.ok(accessOptions).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }
/**
 * @args objectId (String), updateData (Map<String, String>)
 * @return JSON Response
 * @usage Updates person details based on objectId and provided data
 */
    
 // updateperson
    @PUT
    @Path("/updatePerson/{objectId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updatePerson(@PathParam("objectId") String objectId, Map<String, String> updateData, @Context HttpServletRequest request) {
    	
    	HttpSession session = request.getSession(false);
        if (session == null) {
            return Response.status(Response.Status.UNAUTHORIZED)
                    .entity("{\"error\": \"Session expired\"}").build();
        }
        String access = (String) session.getAttribute("userAccess");
        if (access == null || !access.trim().equalsIgnoreCase("Admin")) {
            return Response.status(Response.Status.FORBIDDEN)
                    .entity("{\"error\": \"Access denied. Please relogin and try\"}").build();
        }
    	
        try {
            Person person = new Person(objectId);
            person.updatePersonInDatabase(updateData);

            return Response.ok("{\"message\": \"Person updated successfully\"}").build();
        } catch (RuntimeException e) {
            return Response.status(Response.Status.NOT_FOUND).entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\": \"Error updating person: " + e.getMessage() + "\"}").build();
        }
    }
    
    
	/**
 * @args objectId (String)
 * @return JSON Response with access level
 * @usage Gets the access level of a person by objectId
 */
	

    @GET
    @Path("/{objectId}/access")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAccess(@PathParam("objectId") String objectId) {
        try {
            Person person = new Person(objectId);
            String access = person.getAccess();
            return Response.ok("{\"access\": \"" + access + "\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        }
    }
	/**
 * @args objectId (String), access (String)
 * @return JSON Response
 * @usage Sets the access level of a person by objectId
 */

    @POST
    @Path("/{objectId}/access")
    @Produces(MediaType.APPLICATION_JSON)
    public Response setAccess(@PathParam("objectId") String objectId, @QueryParam("access") String access) {
        if (access == null || access.isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Missing access parameter\"}").build();
        }

        try {
            Person person = new Person(objectId);
            person.setAccess(access);
            return Response.ok("{\"message\": \"Access updated successfully.\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        }
    }
	
	/**
 * @args seed (String)
 * @return String generated object ID
 * @usage Generates a unique object ID based on a seed string or random if error occurs
 */

    // ID generator
    public String generateObjectId(String seed) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] h = md.digest(seed.getBytes());
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 8; i += 2) {
                sb.append(String.format("%04X", ((h[i] & 0xFF) << 8) | (h[i + 1] & 0xFF)));
                if (i < 6) sb.append(".");
            }
            return sb.toString();
        } catch (Exception e) {
            SecureRandom r = new SecureRandom();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 4; i++) {
                sb.append(String.format("%04X", r.nextInt(0x10000)));
                if (i < 3) sb.append(".");
            }
            return sb.toString();
        }
    }
	
	/**
 * @args Map<String, Object> inputData - JSON data containing partcontrol info
 * @return Response - JSON response with created partcontrol details or error message
 * @usage Creates a new PartControl with connection info and updates related data in the database
 */
    
    //createwith connection
    @SuppressWarnings("unchecked")
    @POST
    @Path("/createWithConnection")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createPartControlWithConnection(Map<String, Object> inputData, @Context HttpServletRequest request) {
        try {
            if (inputData == null || !inputData.containsKey("partcontrol")) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Missing required 'partcontrol' data"))
                    .build();
            }
            Object partObj = inputData.get("partcontrol");
            if (!(partObj instanceof Map)) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "'partcontrol' must be a JSON object"))
                    .build();
            }

            Map<String, Object> rawPartControl = (Map<String, Object>) partObj;
            Map<String, String> partControlMap = new HashMap<>();
            for (Map.Entry<String, Object> entry : rawPartControl.entrySet()) {
                partControlMap.put(entry.getKey().toLowerCase(), entry.getValue() == null ? "" : entry.getValue().toString());
            }

            String sourceObjectId = partControlMap.get("sourceobjectid");
            if (sourceObjectId == null || sourceObjectId.isEmpty()) {
                sourceObjectId = partControlMap.get("objectid");
            }

            if (sourceObjectId == null || sourceObjectId.isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Missing 'sourceobjectid' or 'objectid' in partcontrol data"))
                    .build();
            }

            if (isPartControlLinkedToSource(sourceObjectId)) {
                return Response.status(Response.Status.CONFLICT)
                    .entity(Map.of(
                        "error", "A PartControl linked to this Part '"+"' already exists."
                    ))
                    .build();
            }

            String generatedName = getNextPartControlName();
            String generatedPartId = generateHexId("PACO");
            String existingConnectionId = getConnectionIdForObject(sourceObjectId);
            String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                    ? existingConnectionId
                    : generateHexId("CONN");

            // Fetch initial state from amxschemarules table
            String initialState;
            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
                initialState = getInitialState(conn);

                String insertPartControlSQL = "INSERT INTO amxpartcontroldata " +
                        "(objectid, name, supertype, type, description, createddate, owner, email, assignee, connectionid, linkedobjectid, currentstate) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(insertPartControlSQL)) {
                    ps.setString(1, generatedPartId);
                    ps.setString(2, generatedName);
                    ps.setString(3, rawPartControl.getOrDefault("supertype", "").toString());
                    ps.setString(4, rawPartControl.getOrDefault("type", "").toString());
                    ps.setString(5, rawPartControl.getOrDefault("description", "").toString());
                    ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
                    ps.setString(7, rawPartControl.getOrDefault("owner", "").toString());
                    ps.setString(8, rawPartControl.getOrDefault("email", "").toString());
                    ps.setString(9, rawPartControl.getOrDefault("assignee", "").toString());
                    ps.setString(10, connectionIdToUse);
                    ps.setString(11, sourceObjectId);
                    ps.setString(12, initialState);
                    ps.executeUpdate();
                }

                String insertConnectionDataSQL = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertConnectionDataSQL)) {
                    ps.setString(1, connectionIdToUse);
                    ps.setString(2, rawPartControl.getOrDefault("type", "").toString());
                    ps.setString(3, generatedName);
                    ps.setString(4, generatedPartId);
                    ps.setString(5, sourceObjectId);
                    ps.setString(6, "partcontrol");
                    ps.setString(7, "part");
                    ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                    ps.executeUpdate();
                }

                String updatePartDataSQL = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                try (PreparedStatement ps = conn.prepareStatement(updatePartDataSQL)) {
                    ps.setString(1, connectionIdToUse);
                    ps.setString(2, sourceObjectId);
                    ps.executeUpdate();
                }

                HttpSession session = request.getSession(true);
                String username = (String) session.getAttribute("username");
                String createdDate = LocalDateTime.now()
                                  .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                String historyMsg = "Created by " + username + " at " + createdDate;
                
//                String historyMsg = "Created by system at " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                String insertHistorySQL = "INSERT INTO partcontrolhistory (objectid, history) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertHistorySQL)) {
                    ps.setString(1, generatedPartId);
                    ps.setString(2, historyMsg);
                    ps.executeUpdate();
                }
            }

            return Response.ok(Map.of(
                "objectid", generatedPartId,
                "connectionid", connectionIdToUse,
                "name", generatedName
            )).build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(Map.of("error", "Failed to create partcontrol: " + e.getMessage()))
                .build();
        }
    }
	/**
 * @args Connection conn
 * @return String - initial state from amxschemarules table
 * @throws SQLException
 * @usage Retrieves the initial PartControl state from schema rules table
 */
    public String getInitialState(Connection conn) throws SQLException {
        String fetchStateRule = "SELECT rulevalue FROM amxschemarules WHERE rulename = 'PartControlStates'";
        String initialState = "InWork";
        try (PreparedStatement stateStmt = conn.prepareStatement(fetchStateRule);
             ResultSet stateRs = stateStmt.executeQuery()) {
            if (stateRs.next()) {
                String ruleValue = stateRs.getString("rulevalue");
                if (ruleValue != null && !ruleValue.trim().isEmpty()) {
                    String[] states = ruleValue.split("\\|");
                    if (states.length > 0) {
                        initialState = states[0].trim();
                    }
                }
            }
        }
        return initialState;
    }
	/**
 * @args String sourceObjectId
 * @return boolean - true if a PartControl linked to sourceObjectId exists
 * @usage Checks if a PartControl already exists linked to the given sourceObjectId
 */
        public boolean isPartControlLinkedToSource(String sourceObjectId) {
            String sql = "SELECT COUNT(*) FROM amxpartcontroldata WHERE linkedobjectid = ?";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, sourceObjectId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1) > 0;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return false;
        }

		/**
 * @args none
 * @return String - next available PartControl name (e.g., PC-000001)
 * @throws SQLException
 * @usage Generates the next PartControl name based on existing names in the database
 */
        public String getNextPartControlName() throws SQLException {
            String prefix = "PC-";
            String query = "SELECT name FROM amxpartcontroldata WHERE name LIKE ? ORDER BY name DESC LIMIT 1";
            String lastName = null;

            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, prefix + "%");
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        lastName = rs.getString("name");
                    }
                }
            }

            int nextNumber = 1;
            if (lastName != null && lastName.startsWith(prefix)) {
                String numberPart = lastName.substring(prefix.length());
                try {
                    nextNumber = Integer.parseInt(numberPart) + 1;
                } catch (NumberFormatException e) {
                    nextNumber = 1;
                }
            }

            return String.format("%s%06d", prefix, nextNumber);
        }
/**
 * @args String suffix - suffix to append in the generated ID
 * @return String - generated hex ID string with suffix
 * @usage Generates a random hex-based ID string with a suffix (e.g., XXXX.XXXX.XXXX.XXXX.SUFFIX)
 */
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
		
		/**
 * @args String objectId
 * @return String - connection ID related to the given objectId, or null if none found
 * @usage Retrieves the connection ID for a given objectId from the database
 */
        public String getConnectionIdForObject(String objectId) {
            String sql = "SELECT connectionid FROM amxpartcontroldata WHERE objectid = ?";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
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
/**
 * @return Response - JSON with current object ID or error message
 * @usage Retrieves the current temporary object ID if set
 */
    @GET
    @Path("/objectid")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getObjectId() {
        try {
            String objectId = getId();
            if (objectId == null || objectId.isEmpty()) {
                return Response.status(Response.Status.NOT_FOUND)
                    .entity(Map.of("error", "Object ID not found"))
                    .build();
            }
            return Response.ok(Map.of("objectid", objectId)).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(Map.of("error", "Failed to retrieve object ID"))
                .build();
        }
    }
	/**
 * @param sConnectionId - connection ID to update
 * @return Response - success or error JSON response
 * @usage Updates the connection identified by connectionId
 */
    
    // update connection
    @PUT
    @Path("/connection/{connectionid}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateConnection(@PathParam("connectionid") String sConnectionId) {
        try {
            if (sConnectionId == null || sConnectionId.isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Connection ID must not be empty"))
                    .build();
            }
            updateConnection(sConnectionId);
            return Response.ok(Map.of("message", "Connection updated successfully")).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(Map.of("error", "Failed to update connection"))
                .build();
        }
    }
    /**
 * @return String - current temporary object ID or empty string
 * @throws Exception
 * @usage Getter for temporary object ID stored in sNewTempObjectId
 */
        public String sNewTempObjectId; 
        public String getId() throws Exception {
            String sObjectId = "";
            try {
                if (sNewTempObjectId != null && !sNewTempObjectId.isEmpty()) {
                    sObjectId = sNewTempObjectId;
                }
            } catch (Exception e) {
               
            }
            return sObjectId;
        }
        /**
 * @param objectId - the object ID to search connections for (required)
 * @param connectionId - optional specific connection ID filter
 * @return Response - JSON containing objectId, connectionIds, and related objects or error message
 * @usage Fetches connection IDs and related amxpartcontroldata records linked to the specified objectId,
 *        optionally filtered by connectionId
 */
        //for partcontrol
        @GET
        @Path("/getconnectionids")
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        public Response getConnectionsForObject(
            @QueryParam("objectId") String objectId,
            @QueryParam("connectionId") String connectionId) {

            if (objectId == null || objectId.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Missing required query parameter 'objectId'"))
                    .build();
            }

            Map<String, Object> responseMap = new HashMap<>();
            List<String> connectionIds = new ArrayList<>();
            List<Map<String, Object>> relatedObjects = new ArrayList<>();

            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {

                if (connectionId != null && !connectionId.trim().isEmpty()) {
                  
                    String checkConnSql = "SELECT 1 FROM amxpartcontroldata WHERE connectionid = ? LIMIT 1";
                    try (PreparedStatement psCheck = conn.prepareStatement(checkConnSql)) {
                        psCheck.setString(1, connectionId);
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (!rs.next()) {
                                return Response.status(Response.Status.NOT_FOUND)
                                    .entity(Map.of("error", "ConnectionId not found in amxpartcontroldata"))
                                    .build();
                            }
                        }
                    }

                    connectionIds.add(connectionId);

                    String fetchSql = "SELECT * FROM amxpartcontroldata WHERE connectionid = ?";
                    try (PreparedStatement psFetch = conn.prepareStatement(fetchSql)) {
                        psFetch.setString(1, connectionId);
                        try (ResultSet rs = psFetch.executeQuery()) {
                            ResultSetMetaData meta = rs.getMetaData();
                            int colCount = meta.getColumnCount();

                            while (rs.next()) {
                                Map<String, Object> row = new HashMap<>();
                                for (int i = 1; i <= colCount; i++) {
                                    row.put(meta.getColumnName(i), rs.getObject(i));
                                }
                                relatedObjects.add(row);
                            }
                        }
                    }

                } else {
                    String getConnsSql = "SELECT DISTINCT connectionid FROM amxpartcontroldata WHERE objectid = ?";
                    try (PreparedStatement psConns = conn.prepareStatement(getConnsSql)) {
                        psConns.setString(1, objectId);
                        try (ResultSet rs = psConns.executeQuery()) {
                            while (rs.next()) {
                                connectionIds.add(rs.getString("connectionid"));
                            }
                        }
                    }
                    String fetchSql = "SELECT * FROM amxpartcontroldata WHERE connectionid = ?";

                    for (String connId : connectionIds) {
                        try (PreparedStatement psFetch = conn.prepareStatement(fetchSql)) {
                            psFetch.setString(1, connId);
                            try (ResultSet rs = psFetch.executeQuery()) {
                                ResultSetMetaData meta = rs.getMetaData();
                                int colCount = meta.getColumnCount();

                                while (rs.next()) {
                                    Map<String, Object> row = new HashMap<>();
                                    for (int i = 1; i <= colCount; i++) {
                                        row.put(meta.getColumnName(i), rs.getObject(i));
                                    }
                                    relatedObjects.add(row);
                                }
                            }
                        }
                    }
                }

                responseMap.put("objectId", objectId);
                responseMap.put("connectionIds", connectionIds);
                responseMap.put("relatedObjects", relatedObjects);

                return Response.ok(responseMap).build();

            } catch (SQLException e) {
                e.printStackTrace();
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", "Database error: " + e.getMessage()))
                    .build();
            }
        }
        /*
 * @args none
 * @return Response
 * @usage This method retrieves the 10 latest PartControl records ordered by creation date descending.
 */
        //latestpartcontrol
        @GET
        @Path("/getallpartcontrol")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getAllLatestPartControl() {
            String sql = "SELECT * FROM amxpartcontroldata ORDER BY createddate DESC LIMIT 10";
            List<Map<String, String>> getLatestParts = new ArrayList<>();
            try (Connection conn = getConn(); 
                 PreparedStatement pstmt = conn.prepareStatement(sql); 
                 ResultSet rs = pstmt.executeQuery()) {
                
                ResultSetMetaData data = rs.getMetaData();
                while (rs.next()) {
                    Map<String, String> datamp = new LinkedHashMap<>();
                    int count = data.getColumnCount();
                    for (int i = 1; i <= count; i++) {
                        String columnname = data.getColumnName(i);
                        String val = rs.getString(i);
                        datamp.put(columnname, val);
                    }
                    getLatestParts.add(datamp);
                }
                return Response.ok(getLatestParts).build();

            } catch (SQLException e) {
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
            }
        }
        /**
 * @args String id - objectId of the PartControl or Route
 * @return Response
 * @usage This method retrieves detailed information of a PartControl or Route by objectId.
 */
        //getinfos of PC
        @GET
        @Path("/getinfospc")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getInfoPC(@QueryParam("objectId") String id) {
            String sqlPart = "SELECT * FROM amxpartcontroldata WHERE objectid = ?";
            String sqlRoute = "SELECT * FROM amxroute WHERE objectid = ?";
            
            try (Connection conn = getConn()) {
                try (PreparedStatement ps = conn.prepareStatement(sqlPart)) {
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
                    }
                }
                try (PreparedStatement ps2 = conn.prepareStatement(sqlRoute)) {
                    ps2.setString(1, id);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        if (rs2.next()) {
                            JSONObject obj = new JSONObject();
                            ResultSetMetaData md = rs2.getMetaData();
                            for (int i = 1; i <= md.getColumnCount(); i++) {
                                obj.put(md.getColumnName(i), rs2.getString(i));
                            }
                            return Response.ok(obj.toString()).build();
                        }
                    }
                }
                return Response.status(Status.NOT_FOUND)
                    .entity("{\"error\":\"Object not found in parts or routes\"}")
                    .build();
            } catch (SQLException e) {
                return Response.status(Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
            }
        }
        
        /**
         * @args String objectId
         * @return JSON containing Part Specification details
         * @usage Retrieves Part Specification details by ObjectId
         */
        //BUG-1055 Started by Nageswari
        @GET
        @Path("/getinfops")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getInfoPS(@QueryParam("objectId") String objectId) {

            if (objectId == null || objectId.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"Message\":\"ObjectId is required\"}")
                        .build();
            }

            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {

                String sql = "SELECT * FROM amxpartspecificationdata WHERE objectid = ?";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {

                    ps.setString(1, objectId);

                    try (ResultSet rs = ps.executeQuery()) {

                        if (!rs.next()) {
                            return Response.status(Response.Status.NOT_FOUND)
                                    .entity("{\"Message\":\"Part Specification not found\"}")
                                    .build();
                        }

                        JSONObject obj = new JSONObject();

                        ResultSetMetaData meta = rs.getMetaData();

                        for (int i = 1; i <= meta.getColumnCount(); i++) {

                            String column = meta.getColumnName(i);
                            obj.put(column, rs.getString(i));

                        }

                        return Response.ok(obj.toString(), MediaType.APPLICATION_JSON).build();
                    }
                }

            } catch (Exception e) {

                e.printStackTrace();

                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                        .entity("{\"Message\":\"" + e.getMessage() + "\"}")
                        .build();
            }
        }
        //BUG-1055 Ended by Nageswari
/**
 * @args String objectId - objectId to fetch history for
 * @return Response
 * @usage This method retrieves history records for a PartControl identified by objectId.
 */
        //getpartcontrolhistory
        @GET
        @Path("/partcontrolhistory")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getPartControlHistory(@QueryParam("objectId") String objectId) {
            if (objectId == null || objectId.isEmpty()) {
                return Response.ok("{\"error\":\"ObjectId parameter is required\"}").build();
            }
            String sql = "SELECT history FROM partcontrolhistory WHERE objectid = ?";
            try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, objectId);
                try (ResultSet rs = ps.executeQuery()) {
                    List<String> histories = new ArrayList<>();
                    while (rs.next()) {
                        histories.add(rs.getString("history"));
                    }
                    if (histories.isEmpty()) {
                        return Response.ok("{\"error\":\"No history found for Part Control:"+ "\"}").build();
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
        /**
 * @args String objectid - linked object ID to fetch related PartControl records
 * @return Response - JSON list of PartControl records or error message
 * @usage This method retrieves all PartControl records linked to the given object ID, ordered by creation date descending.
 */
   //getCreatedpartControl
        @GET
        @Path("/getcreatedpartcontrol")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getPartControlByObjectId(@QueryParam("objectid") String objectid) {
            if (objectid == null || objectid.trim().isEmpty()) {
                return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
            }
            String sql = "SELECT * FROM amxpartcontroldata WHERE linkedobjectid = ? ORDER BY createddate DESC";
            List<Map<String, String>> results = new ArrayList<>();
            try (Connection conn = getConn();
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
                    return Response.ok("{\"message\":\"No PartControl data found.\"}").build();
                }
                return Response.ok(results).build();
            } catch (SQLException e) {
                e.printStackTrace();
                return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
            }
        }
/**
 * @args String objectid - PartControl object ID
 *       String body - JSON string containing updated description
 * @return Response - JSON status message indicating success or failure
 * @usage This method updates the description of a PartControl record identified by objectId and logs the update in history.
 */
        //update partcontrol
        @PUT
        @Path("/updatepartcontrol/{objectid}")
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        public Response updatePartContol(@PathParam("objectid") String objectId, String body) {
            JSONObject resp = new JSONObject();

            SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

            try {
                JSONObject json = new JSONObject(body);
                String description = json.optString("description", "").trim();

                // Validate input
                if (objectId == null || objectId.trim().isEmpty() || description.isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "objectid and description are required.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }

      
                String updatedDate = sf.format(new Date());

                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(
                         "UPDATE amxpartcontroldata SET description = ?, createddate = ? WHERE objectid = ?")) {

                    ps.setString(1, description);
                    ps.setTimestamp(2, Timestamp.valueOf(updatedDate));
                    ps.setString(3, objectId);

                    int count = ps.executeUpdate();

                    if (count == 0) {
                        resp.put("Status", "Failed").put("Message", "objectid not found.");
                        return Response.status(Response.Status.NOT_FOUND).entity(resp.toString()).build();
                    }
                    // History handling
//                    String historyMsg = "Updated description at " + updatedDate;
//                    try (PreparedStatement psSel = conn.prepareStatement("SELECT history FROM partcontrolhistory WHERE objectid = ?")) {
//                        psSel.setString(1, objectId);
//                        try (ResultSet rs = psSel.executeQuery()) {
//                            if (rs.next()) {
//                                String existing = rs.getString("history");
//                                String updated = existing + " | " + historyMsg;
//                                try (PreparedStatement psUpd = conn.prepareStatement("UPDATE partcontrolhistory SET history = ? WHERE objectid = ?")) {
//                                    psUpd.setString(1, updated);
//                                    psUpd.setString(2, objectId);
//                                    psUpd.executeUpdate();
//                                }
//                            } 
////                            else {
////                                try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO partcontrolhistory (objectid, history) VALUES (?, ?)")) {
////                                    psIns.setString(1, objectId);
////                                    psIns.setString(2, historyMsg);
////                                    psIns.executeUpdate();
////                                }
////                            }
//                        }
//                    }

                    resp.put("Status", "Success").put("Message", "Part Control updated.");
                    return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

                } catch (SQLException e) {
                    e.printStackTrace();
                    resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
                    return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
                }

            } catch (Exception ex) {
                ex.printStackTrace();
                resp.put("Status", "Failed").put("Message", "Invalid input: " + ex.getMessage());
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }
        }
        
        //BUG-1055 started by Nageswari
      //update Part Specification
        @PUT
        @Path("/updatepartspecification/{objectid}")
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        public Response updatePartSpecification(@PathParam("objectid") String objectId, String body) {

            JSONObject resp = new JSONObject();

            SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

            try {

                JSONObject json = new JSONObject(body);
                String description = json.optString("description", "").trim();

                // Validate input
                if (objectId == null || objectId.trim().isEmpty() || description.isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "objectid and description are required.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }

                String modifiedDate = sf.format(new Date());

                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(
                             "UPDATE amxpartspecificationdata SET description = ?, modifiedtime = ? WHERE objectid = ?")) {

                    ps.setString(1, description);
                    ps.setTimestamp(2, Timestamp.valueOf(modifiedDate));
                    ps.setString(3, objectId);

                    int count = ps.executeUpdate();

                    if (count == 0) {
                        resp.put("Status", "Failed").put("Message", "objectid not found.");
                        return Response.status(Response.Status.NOT_FOUND).entity(resp.toString()).build();
                    }

                    // History handling
                    String historyMsg = "Updated description at " + modifiedDate;

                    try (PreparedStatement psSel = conn.prepareStatement(
                            "SELECT history FROM partspecificationhistory WHERE objectid = ?")) {

                        psSel.setString(1, objectId);

                        try (ResultSet rs = psSel.executeQuery()) {

                            if (rs.next()) {

                                String existing = rs.getString("history");
                                String updated = existing + " | " + historyMsg;

                                try (PreparedStatement psUpd = conn.prepareStatement(
                                        "UPDATE partspecificationhistory SET history = ? WHERE objectid = ?")) {

                                    psUpd.setString(1, updated);
                                    psUpd.setString(2, objectId);
                                    psUpd.executeUpdate();
                                }

                            } else {

                                try (PreparedStatement psIns = conn.prepareStatement(
                                        "INSERT INTO partspecificationhistory (objectid, history) VALUES (?, ?)")) {

                                    psIns.setString(1, objectId);
                                    psIns.setString(2, historyMsg);
                                    psIns.executeUpdate();
                                }
                            }
                        }
                    }

                    resp.put("Status", "Success");
                    resp.put("Message", "Part Specification updated.");

                    return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

                } catch (SQLException e) {

                    e.printStackTrace();

                    resp.put("Status", "Failed");
                    resp.put("Message", "Database error: " + e.getMessage());

                    return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                            .entity(resp.toString()).build();
                }

            } catch (Exception ex) {

                ex.printStackTrace();

                resp.put("Status", "Failed");
                resp.put("Message", "Invalid input: " + ex.getMessage());

                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(resp.toString()).build();
            }
        }
        //BUG-1055 ended by Nageswari
        /**
 * @args String supertype - SuperType of the part specification
 *       String type - Type of the part specification
 *       String description - Description of the part specification
 *       String responsibleEngineer - Engineer responsible for the part
 *       HttpServletRequest request - HTTP request to validate session and get user info
 * @return Response - JSON response indicating success or failure of creation
 * @usage This method creates a new Part Specification entry in the database with generated object ID and name,
 *        validates the user session, and logs creation in the part specification history.
 */
        //amxpartspecificationdata
        @POST
        @Path("/createpartspecification")
        @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
        @Produces(MediaType.APPLICATION_JSON)
        public Response createPartSpecification(@FormParam("SuperType") String supertype,@FormParam("Type") String type,
                @FormParam("Description") String description,@FormParam("ResponsibleEngineer") String responsibleEngineer,
                @Context HttpServletRequest request) {

            JSONObject resp = new JSONObject();
            HttpSession session = request.getSession(false);
            if (session == null
                    || session.getAttribute("username") == null
                    || session.getAttribute("emailId") == null) {
                resp.put("Status", "Failed").put("Message", "User not logged in.");
                return Response.status(Response.Status.UNAUTHORIZED).entity(resp.toString()).build();
            }
            String username = (String) session.getAttribute("username");
            String emailId = (String) session.getAttribute("emailId");

            if (supertype == null || supertype.trim().isEmpty()
                    || type == null || type.trim().isEmpty()
                    || description == null || description.trim().isEmpty()
                    || responsibleEngineer == null || responsibleEngineer.trim().isEmpty()) {
                resp.put("Status", "Failed").put("Message", "Missing required fields.");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }

            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
				//Added by Ajay BUG-1057 New Feature stated
                String firstState = "Draft"; 
                try (PreparedStatement psState = conn.prepareStatement("SELECT rulevalue FROM amxschemarules WHERE rulename = 'PartSpecStates'")) {
                    ResultSet rsState = psState.executeQuery();
                    if (rsState.next()) {
                        String states = rsState.getString("rulevalue");
                        if (states != null && !states.isEmpty()) {
                            firstState = states.split("\\|")[0]; 
                        }
                    }
                    rsState.close();
                }
				//Added by Ajay BUG-1057 New Feature Ended
                SecureRandom random = new SecureRandom();	
                
                byte[] bytes = new byte[8];
                random.nextBytes(bytes);
                StringBuilder objectIdBuilder = new StringBuilder();
                for (int i = 0; i < bytes.length; i += 2) {
                    int part = ((bytes[i] & 0xFF) << 8) | (bytes[i + 1] & 0xFF);
                    objectIdBuilder.append(String.format("%04X", part));
                    if (i < bytes.length - 2) objectIdBuilder.append(".");
                }
                String objectId = objectIdBuilder.toString() + ".PASP";
                String prefix = "PASP-";
                int maxNum = 0;
                String selectMaxNum = "SELECT name FROM amxpartspecificationdata WHERE name LIKE ?";
                try (PreparedStatement ps = conn.prepareStatement(selectMaxNum)) {
                    ps.setString(1, prefix + "%");
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String existingName = rs.getString("name");
                            if (existingName.startsWith(prefix)) {
                                String numPart = existingName.substring(prefix.length());
                                try {
                                    int num = Integer.parseInt(numPart);
                                    if (num > maxNum) {
                                        maxNum = num;
                                    }
                                } catch (NumberFormatException ignored) {
                                }
                            }
                        }
                    }
                }
                int nextNum = maxNum + 1;
                String name = String.format("%s%06d", prefix, nextNum);
                LocalDateTime now = LocalDateTime.now();
                Timestamp timestampNow = Timestamp.valueOf(now);
                String createdDateStr = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                String insertSQL = "INSERT INTO amxpartspecificationdata " +
                        "(objectid, name, supertype, type, description, createdtime, modifiedtime, owner, email, connectionid, currentstate) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"; //Added by Ajay BUG-1057 New Feature

                try (PreparedStatement insertPS = conn.prepareStatement(insertSQL)) {
                    insertPS.setString(1, objectId);
                    insertPS.setString(2, name);
                    insertPS.setString(3, supertype);
                    insertPS.setString(4, type);
                    insertPS.setString(5, description);
                    insertPS.setTimestamp(6, timestampNow);
                    insertPS.setTimestamp(7, timestampNow); 
                    insertPS.setString(8, responsibleEngineer);
                    insertPS.setString(9, emailId != null ? emailId : "");
                    insertPS.setString(10, "");
                    insertPS.setString(11, firstState); //Added by Ajay BUG-1057 New Feature
                    insertPS.executeUpdate();
                }
                String historyMsg = "Created by " + username + " at " + createdDateStr;

                String hSelect = "SELECT history FROM partspecificationhistory WHERE objectid = ?";
                try (PreparedStatement hSel = conn.prepareStatement(hSelect)) {
                    hSel.setString(1, objectId);
                    try (ResultSet hrs = hSel.executeQuery()) {
                        if (hrs.next()) {
                            String hist = hrs.getString("history");
                            String combined = hist + " | " + historyMsg;
                            String hUpdate = "UPDATE partspecificationhistory SET history = ? WHERE objectid = ?";
                            try (PreparedStatement hUpd = conn.prepareStatement(hUpdate)) {
                                hUpd.setString(1, combined);
                                hUpd.setString(2, objectId);
                                hUpd.executeUpdate();
                            }
                        } else {
                            String hInsert = "INSERT INTO partspecificationhistory (objectid, history) VALUES (?, ?)";
                            try (PreparedStatement hIns = conn.prepareStatement(hInsert)) {
                                hIns.setString(1, objectId);
                                hIns.setString(2, historyMsg);
                                hIns.executeUpdate();
                            }
                        }
                    }
                }
                JSONObject success = new JSONObject();
                success.put("Status", "Success");
                success.put("Message", "Object created successfully");
                success.put("ObjectId", objectId);
                success.put("Name", name);
                success.put("CurrentState", firstState);//Added by Ajay BUG-1057 New Feature

                return Response.ok(success.toString(), MediaType.APPLICATION_JSON).build();

            } catch (SQLException ex) {
                ex.printStackTrace();
                resp.put("Status", "Failed").put("Message", "Internal server error: " + ex.getMessage());
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
            }
        }
		
		
		/*
 * @args String objectId - The ID of the part object whose state is to be updated
 *       String jsonBody - JSON string containing the new state value
 * @return Response - JSON response indicating success or error in updating state
 * @usage This method updates the lifecycle state of a part or part control object identified by objectId.
 *        It validates the state transition, checks if promotion conditions are met, updates state and logs history.
 */
        
        //PartLifecycle
        @PUT
        @Path("/updatestate/{objectId}")
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        //Bug-1024 added By Nageswari Start 
        public Response updateToSpecificState(@PathParam("objectId") String objectId, String jsonBody,@Context HttpServletRequest request) {
        	HttpSession session = request.getSession(false);

        	String username = "Unknown";

        	if (session != null && session.getAttribute("username") != null) {
        	    username = (String) session.getAttribute("username");
        	}
        	//Bug-1024 added By Nageswari End
        	if (objectId == null || objectId.trim().isEmpty()) {
                return Response.ok("{\"error\": \"objectId must be provided\"}").build();
            }
            String dataTable;
            String ruleName;
            String historyTable;
            if (objectId.endsWith(".APN")) {
                dataTable = "amxcorepartdata";
                ruleName = "PartStates";
                historyTable = "parthistory";
            } else if (objectId.endsWith(".PACO")) {
                dataTable = "amxpartcontroldata";
                ruleName = "PartControlStates";
                historyTable = "partcontrolhistory";
            } else {
                return Response.ok("{\"error\": \"Invalid objectId suffix\"}").build();
            }
            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
                JSONObject input = new JSONObject(jsonBody);
                String newState = input.optString("state", "").trim();
                if (newState.isEmpty()) {
                    return Response.ok("{\"error\": \"State must be provided\"}").build();
                }
                String currentState = getCurrentState(conn, dataTable, objectId);
                if (currentState == null) {
                    return Response.ok("{\"error\": \"Part not found " + "\"}").build();
                }
                List<String> validStates = getStateSequence(conn, ruleName);
                if (!validStates.contains(newState)) {
                    return Response.ok("{\"error\": \"Invalid state: " + newState + "\"}").build();
                }
                int currentIndex = validStates.indexOf(currentState);
                int newIndex = validStates.indexOf(newState);
                String finalState = validStates.get(validStates.size() - 1);
                String finalState2=validStates.get(validStates.size()-2);
                if (currentState.equals(finalState)) {
                    return Response.ok("{\"error\":\"State can't be changed as it reaches its final stage: " + currentState + "\"}").build();
                }
                else if(currentState.equals(finalState2) && newIndex==validStates.size()-3) {
                	return Response.ok("{\"error\":\"State can't be changed back as it reaches its " + currentState + " stage: \"}").build();
                }

                if (objectId.endsWith(".PACO") && "InApproval".equals(currentState) && "InWork".equals(newState)) {
                	return Response.ok("{\"error\":\"State can't be changed back as it reaches its " + currentState + " stage: \"}").build();
                }
                
                if (objectId.endsWith(".PACO") && "InApproval".equals(currentState) && "Completed".equals(newState)) {
                	return Response.ok("{\"error\":\"State change from " + currentState + " to "+ newState+" is restricted: \"}").build();
                }
                
                if (objectId.endsWith(".PACO") && "Completed".equals(currentState) && "Cancelled".equals(newState)) {
                	return Response.ok("{\"error\":\"State can't be changed from " + currentState + " to "+newState+" : \"}").build();
                }
                
                
                String direction;
                if (newIndex == currentIndex + 1) {
                    direction = "Promoted";
                    if ("Frozen".equals(currentState) && "Released".equals(newState)) {
                        if (!hasConnectedPartControl(conn, objectId)) {
                            return Response.ok("{\"error\": \"Part doesnot have any Partcontrol.Please connect some partcontrol and try promote it\"}").build();
                        }
                    }
                } else if (newIndex == currentIndex - 1) {
                    direction = "Demoted";
                } else {
                    return Response.ok("{\"error\": \"Invalid state transition. Only one-step transitions are allowed.\"}").build();
                }
                String timestamp = java.time.LocalDateTime.now().toString();
//Bug-1024 added by Nageswari 
                String historyMessage =direction + " to state: " + newState +" by " + username +" at " + timestamp;
                updatePartState(conn, dataTable, objectId, newState);
                insertHistory(conn, historyTable, objectId, historyMessage);
                
                if ("Released".equalsIgnoreCase(newState)) {

                	String objectSupertype = "";
                	String objectName = "";
                	String objectType = "";
                	String sql =
                	    "SELECT name, type,supertype FROM " + dataTable +
                	    " WHERE objectid = ?";

                	PreparedStatement ps = conn.prepareStatement(sql);
                	ps.setString(1, objectId);
                	ResultSet rs = ps.executeQuery();

                	if (rs.next()) {

                	    objectName = rs.getString("name");
                	    objectType = rs.getString("type");
                	    objectSupertype=rs.getString("supertype");
                	}
                    String releasedBy = "Admin";
                    String releasedDate =java.time.LocalDateTime.now().toString();

                    sendReleaseMail(
                            objectId,
                            objectName,
                            objectType,
                            objectSupertype,
                            releasedBy,
                            releasedDate
                    );
                }
                
                return Response.ok("{\"message\": \"State updated successfully\", \"oldState\": \"" + currentState + "\", \"newState\": \"" + newState + "\"}")
                        .build();
            } catch (Exception e) {
                return Response.ok("{\"error\": \"Internal error: " + e.getMessage() + "\"}").build();
            }
        }

        // Check the linked part is in Frozen state
        private String validatePartIsFrozen(Connection conn, String partId) throws SQLException {
            String partState = getCurrentState(conn, "amxcorepartdata", partId);
            if (partState == null || !partState.equalsIgnoreCase ("Frozen")) {
                return "Part linked to this Part Control'" + "' is not in Frozen state. The linked part must be Frozen before promoting to InApproval.";
            }
            return null;
        }

        //  Check all MPNs linked to the part are in Released state
        private String validateMPNsAreReleased(Connection conn, String partId) throws SQLException {
            String sql = "SELECT objectid FROM amxcorempndetails WHERE connectionid = (select connectionid from amxcorepartdata where objectid=?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, partId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String mpnId = rs.getString("objectid");
                        String mpnState = getCurrentState(conn, "amxcorempndetails", mpnId);
                        if (mpnState == null || !mpnState.equals("Released")) {
                            return "A MPN '" + "' linked to Part '" + "' is not in Released state. All MPNs must be Released before promoting to InApproval.";
                        }
                    }
                }
            }
            return null;
        }
		
		
		/*
 * @args String objectId - The object ID of the part or part control whose current state is requested
 * @return Response - JSON response with the current state or an error message
 * @usage This GET method returns the current lifecycle state of a part or part control object identified by objectId.
 *        It validates the objectId suffix and queries the appropriate table.
 */
        // GET current state API
        @GET
        @Path("/updatestate/{objectId}")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getCurrentStateAPI(@PathParam("objectId") String objectId) {
            if (objectId == null || objectId.trim().isEmpty()) {
                return Response.ok("{\"error\": \"objectId must be provided\"}").build();
            }
            String dataTable;
            if (objectId.endsWith(".APN")) {
                dataTable = "amxcorepartdata";
            } else if (objectId.endsWith(".PACO")) {
                dataTable = "amxpartcontroldata";
            } else {
                return Response.ok("{\"error\": \"Invalid objectId suffix\"}").build();
            }

            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
                String currentState = getCurrentState(conn, dataTable, objectId);
                if (currentState == null) {
                    return Response.ok("{\"error\": \"Part not found "+ "\"}").build();
                }
                return Response.ok("{\"currentState\": \"" + currentState + "\"}").build();
            } catch (SQLException e) {
                return Response.ok("{\"error\": \"Database error: " + e.getMessage() + "\"}").build();
            }
        }
/*
 * @args Connection conn - Database connection
 *       String tableName - Table to query for the current state
 *       String objectId - Object ID to look up
 * @return String - Current state of the part or null if not found
 * @usage Helper method to fetch the current state of an object from the specified table.
 */
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
/*
 * @args Connection conn - Database connection
 *       String ruleName - Rule name to get state sequence for
 * @return List<String> - Ordered list of valid states as defined by the rule
 * @usage Helper method to retrieve the allowed lifecycle state sequence from schema rules.
 */
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
		/**
 * @args Connection conn - Database connection
 *       String tableName - Table where the state should be updated
 *       String objectId - Object ID of the part or part control
 *       String newState - New state to set
 * @return void
 * @usage Helper method to update the current state of a part or part control in the database.
 */

        public void updatePartState(Connection conn, String tableName, String objectId, String newState) throws SQLException {
            String query = "UPDATE " + tableName + " SET currentstate=? WHERE objectid=?";
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, newState);
                ps.setString(2, objectId);
                ps.executeUpdate();
            }
        }
/*
 * @args Connection conn - Database connection
 *       String historyTable - Table to insert history into
 *       String objectId - Object ID of the part or part control
 *       String historyMessage - History message to log
 * @return void
 * @usage Helper method to insert a new history record for a part or part control state change.
 */
        public void insertHistory(Connection conn, String historyTable, String objectId, String historyMessage) throws SQLException {
            String query = "INSERT INTO " + historyTable + " (objectid, history) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, objectId);
                ps.setString(2, historyMessage);
                ps.executeUpdate();
            }
        }
		
	/*
 * @args Connection conn - Database connection
 *       String objectId - Object ID to check for linked part controls
 * @return boolean - True if there are linked part controls, false otherwise
 * @usage Helper method to check if a part has any connected part control entries.
 */
        public boolean hasConnectedPartControl(Connection conn, String objectId) throws SQLException {
            String query = "SELECT COUNT(*) FROM amxpartcontroldata WHERE linkedobjectid = ?";
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, objectId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1) > 0;
                    }
                }
            }
            return false;
        }


/*
 * @args Map<String, Object> inputData - JSON data containing the partSpecification object with details
 * @return Response - JSON response with the created part specification's objectid, connectionid, and name,
 *                    or error messages if validation fails
 * @usage Creates a new part specification linked to a source object, manages connection IDs,
 *        inserts records in part specification and connection tables, and logs history.
 *        Validates if a part specification already exists for the sourceObjectId to prevent duplicates.
 */
//partspecificationwithconnection
        @SuppressWarnings("unchecked")
		@POST
        @Path("/partspecificationwithconnection")
        
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        public Response partSpecificationWithConnection(Map<String, Object> inputData) {
            try {
                if (inputData == null || !inputData.containsKey("partSpecification")) {
                    return Response.ok(Map.of("error", "Missing required 'partspecification' data")).build();
                }
                Object partObj = inputData.get("partSpecification");
                if (!(partObj instanceof Map)) {
                    return Response.ok(Map.of("error", "'partspecification' must be a JSON object")).build();
                }
                Map<String, Object> rawPartSpecification = (Map<String, Object>) partObj;
                Map<String, String> partSpecificationMap = new HashMap<>();
                for (Map.Entry<String, Object> entry : rawPartSpecification.entrySet()) {
                    partSpecificationMap.put(entry.getKey().toLowerCase(), entry.getValue() == null ? "" : entry.getValue().toString());
                }

                String sourceObjectId = partSpecificationMap.get("sourceobjectid");
                if (sourceObjectId == null || sourceObjectId.isEmpty()) {
                    sourceObjectId = partSpecificationMap.get("objectid");
                }

                if (sourceObjectId == null || sourceObjectId.isEmpty()) {
                    return Response.ok(Map.of("error", "Missing 'sourceobjectid' or 'objectid' in partSpecification data")).build();
                }

                if (isPartSpecificationLinkedToSource(sourceObjectId)) {
                    return Response.ok(Map.of("error", "A PartSpecification linked to this Part '"+ "' already exists.")).build();
                }
                String generatedName = getNextPartSpecificationName();
                String generatedPartId = generateHexaId("PASP");
                String existingConnectionId = getConnectionId(sourceObjectId);
                String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                        ? existingConnectionId
                        : generateHexaId("CONN");
                partSpecificationMap.put("name", generatedName);
                partSpecificationMap.put("objectid", generatedPartId);
                partSpecificationMap.put("connectionid", connectionIdToUse);
                partSpecificationMap.put("linkedobjectid", sourceObjectId);
                String insertPartControlSQL = "INSERT INTO amxpartspecificationdata (objectid, name, supertype, type, description, createdtime, owner, email, modifiedtime, connectionid, linkedobjectid) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(insertPartControlSQL)) {
                    ps.setString(1, generatedPartId);
                    ps.setString(2, generatedName);
                    ps.setString(3, rawPartSpecification.getOrDefault("supertype", "").toString());
                    ps.setString(4, rawPartSpecification.getOrDefault("type", "").toString());
                    ps.setString(5, rawPartSpecification.getOrDefault("description", "").toString());
                    ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
                    ps.setString(7, rawPartSpecification.getOrDefault("owner", "").toString());
                    ps.setString(8, rawPartSpecification.getOrDefault("email", "").toString());
                    ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));
                    ps.setString(10, connectionIdToUse);
                    ps.setString(11, sourceObjectId);
                    ps.executeUpdate();
                }

                String insertConnectionDataSQL = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(insertConnectionDataSQL)) {
                    ps.setString(1, connectionIdToUse);
                    ps.setString(2, rawPartSpecification.getOrDefault("type", "").toString());
                    ps.setString(3, generatedName);
                    ps.setString(4, generatedPartId);
                    ps.setString(5, sourceObjectId);
                    ps.setString(6, "partSpecification");
                    ps.setString(7, "part");
                    ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                    ps.executeUpdate();
                }

                String updatePartDataSQL = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(updatePartDataSQL)) {
                    ps.setString(1, connectionIdToUse);  
                    ps.setString(2, sourceObjectId);      
                    ps.executeUpdate();
                }
                String historyMsg = "Created by system at " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                String insertHistorySQL = "INSERT INTO partspecificationhistory (objectid, history) VALUES (?, ?)";
                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(insertHistorySQL)) {
                    ps.setString(1, generatedPartId);
                    ps.setString(2, historyMsg);
                    ps.executeUpdate();
                }
                return Response.ok(Map.of("objectid", generatedPartId,"connectionid", connectionIdToUse,"name", generatedName)).build();

            } catch (Exception e) {
                e.printStackTrace();
                return Response.ok(Map.of("error", "Failed to create partspecification: " + e.getMessage())).build();
            }
        }
		/**
 * @args String sourceObjectId - The source object ID to check linkage for
 * @return boolean - True if a part specification linked to the sourceObjectId already exists, false otherwise
 * @usage Checks database to prevent duplicate part specifications linked to the same source object.
 */
            public boolean isPartSpecificationLinkedToSource(String sourceObjectId) {
                String sql = "SELECT COUNT(*) FROM amxpartspecificationdata WHERE linkedobjectid = ?";
                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, sourceObjectId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return rs.getInt(1) > 0;
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                return false;
            }
			
			/**
 * @return String - Next sequential part specification name in the format "PASP-000001"
 * @throws SQLException if database access error occurs
 * @usage Retrieves the last part specification name and generates the next sequential name with prefix PASP-
 */
            public String getNextPartSpecificationName() throws SQLException {
                String prefix = "PASP-";
                String query = "SELECT name FROM amxpartspecificationdata WHERE name LIKE ? ORDER BY name DESC LIMIT 1";
                String lastName = null;

                try (Connection conn = DriverManager.getConnection(url, user, db_password);
                     PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, prefix + "%");
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            lastName = rs.getString("name");
                        }
                    }
                }

                int nextNumber = 1;
                if (lastName != null && lastName.startsWith(prefix)) {
                    String numberPart = lastName.substring(prefix.length());
                    try {
                        nextNumber = Integer.parseInt(numberPart) + 1;
                    } catch (NumberFormatException e) {
                        nextNumber = 1;
                    }
                }

                return String.format("%s%06d", prefix, nextNumber);
            }

/**
 * @args String suffix - Suffix to append to the generated hex ID (e.g., "PASP", "CONN")
 * @return String - Generated unique hex ID string like "ABCD.EF12.3456.7890.PASP"
 * @usage Generates a secure random hex ID with the specified suffix for unique object identification.
 */
            public String generateHexaId(String suffix) {
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
			
			
			/**
 * @args String objectId - Object ID whose connection ID is to be fetched
 * @return String - Connection ID associated with the given object ID, or null if not found
 * @usage Retrieves the connection ID from the part specification data table for the given object ID.
 */
            public String getConnectionId(String objectId) {
                String sql = "SELECT connectionid FROM amxpartspecificationdata WHERE objectid = ?";
                try (Connection conn = DriverManager.getConnection(url, user, db_password);
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
/**
 * @args String objectid - the linked object ID to fetch part specifications for
 * @return Response - JSON response with part specifications or error message
 * @usage This method retrieves part specifications linked to the given object ID, ordered by creation time descending.
 */
            //getCreatedpartSpecification
            @GET
            @Path("/getcreatedpartspecification")
            @Produces(MediaType.APPLICATION_JSON)
            public Response getPartSpecificationByObjectId(@QueryParam("objectid") String objectid) {
                if (objectid == null || objectid.trim().isEmpty()) {
                    return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
                }
                String sql = "SELECT * FROM amxpartspecificationdata WHERE linkedobjectid = ? ORDER BY createdtime DESC";
                List<Map<String, String>> results = new ArrayList<>();
                try (Connection conn = getConn();
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
                        return Response.ok("{\"message\":\"No partSpecifications found.\"}").build();
                    }
                    return Response.ok(results).build();
                } catch (SQLException e) {
                    e.printStackTrace();
                    return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
                }
            }
			
			/*
 * @args String objectid - the object ID to fetch existing connection data for
 * @return Response - JSON response with connection data or error message
 * @usage This method retrieves existing connections where 'toid' equals the given object ID and fromname is 'PartControl' or 'partSpecification'.
 */
            
            // get addexistngpartspecification
            @GET
            @Path("/getaddexisting")
            @Produces(MediaType.APPLICATION_JSON)
            public Response getAddExistingData(@QueryParam("objectid") String objectid) {
            	if(objectid==null || objectid.trim().isEmpty()) {
            		return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
            	}
                String sql = "SELECT * FROM amxcoreconnectiondata WHERE toid = ? AND (fromname = 'PartControl' OR fromname = 'partSpecification') ORDER BY createddate DESC";
                List<Map<String, String>> result = new ArrayList<>();
                try (Connection conn = getConn();
                     PreparedStatement pstmt = conn.prepareStatement(sql)){
                	pstmt.setString(1,objectid.trim());
                	try(ResultSet rs=pstmt.executeQuery()){
                		ResultSetMetaData resultsetmetadata=rs.getMetaData();
                		int colCount=resultsetmetadata.getColumnCount();
                		while(rs.next()) {
                			Map<String,String> map=new LinkedHashMap<>();
                			for(int i=1;i<=colCount;i++) {
                				map.put(resultsetmetadata.getColumnName(i), rs.getString(i));
                			}
                			result.add(map);
                		}
                	}
                	if(result.isEmpty()) {
                		return Response.ok("{\"Message\":\"No Part Control or PartSpecification data found.\"}").build();
                	}
                    return Response.ok(result).build();
                } catch (SQLException e) {
					e.printStackTrace();
	                return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();            	
				}
            }
            
			
			/*
 * @args String sql - the SQL query string to execute
 * @return Response - plain text response with query result or error message
 * @usage This method executes an arbitrary SQL query received as a query parameter.
 */
        // QueryFromDB
            @GET
            @Path("/executequery")
            @Produces(MediaType.TEXT_PLAIN)
            public Response executeQueryFromDB(@QueryParam("sql") String sql) {
                if (sql == null || sql.trim().isEmpty()) {
                    return Response.ok("Missing or invalid 'sql' query parameter.").build();
                }
                try {
                    AmxQueryFromDB db = new AmxQueryFromDB();
                    String result = db.executeQuery(sql.trim());
                    if (result == null || result.trim().isEmpty()) {
                        return Response.ok("No result returned from the query.").build();
                    }
                    return Response.ok(result).build();
                } catch (Exception e) {
                    e.printStackTrace();
                    return Response.ok("Error executing query: " + e.getMessage()).build();
                   
                }
            }
			
			/*
 * @args String jsonPayload - JSON string containing file upload details (objectid, fileName, fileContentBase64)
 * @return Response - plain text response indicating success or failure
 * @usage This method uploads a file associated with a given object ID.
 */
            
          //fileupload
            @POST
            @Path("/upload")
            @Consumes(MediaType.APPLICATION_JSON)
            @Produces(MediaType.TEXT_PLAIN)
            public Response uploadFile(String jsonPayload) {
                try {
                    javax.json.JsonReader reader = javax.json.Json.createReader(new java.io.StringReader(jsonPayload));
                    javax.json.JsonObject json = reader.readObject();

                    String objectid = json.getString("objectid", null);
                    String fileName = json.getString("fileName", null);
                    String fileContentBase64 = json.getString("fileContentBase64", null);

                    if (objectid == null || fileName == null || fileContentBase64 == null) {
                        return Response.status(Response.Status.BAD_REQUEST)
                                .entity("Missing required fields").build();
                    }

                    byte[] fileBytes = java.util.Base64.getDecoder().decode(fileContentBase64);
                    amd.AmxSpecificationDocument doc = amd.AmxSpecificationDocument.insertFile(objectid, fileBytes, fileName);
                    return Response.ok("File inserted with ID: " + doc.fileid).build();
                } catch (Exception e) {
                    e.printStackTrace();
                    return Response.serverError().entity("Error: " + e.getMessage()).build();
                }
            }
            /**
 * @args String objectid - the object ID to retrieve uploaded files for
 * @return Response - JSON response with list of uploaded files or error message
 * @usage This method fetches metadata of uploaded files linked to the specified object ID.
 */
            //get uploaded files
            @GET
            @Path("/getUploadedFiles")
            @Produces(MediaType.APPLICATION_JSON)
            public Response getUploadedFiles(@QueryParam("objectid") String objectid) {
                try {
                    if (objectid == null || objectid.trim().isEmpty()) {
                        return Response.status(Response.Status.BAD_REQUEST)
                                .entity("Missing objectid").build();
                    }

                    List<amd.AmxSpecificationDocument> documents = amd.AmxSpecificationDocument.getFilesByObjectId(objectid);
                    javax.json.JsonArrayBuilder arrayBuilder = javax.json.Json.createArrayBuilder();

                    for (amd.AmxSpecificationDocument doc : documents) {
                        arrayBuilder.add(javax.json.Json.createObjectBuilder()
                                .add("fileId", doc.fileid)
                                .add("fileName", doc.filename));
                    }

                    return Response.ok(arrayBuilder.build().toString(), MediaType.APPLICATION_JSON).build();

                } catch (Exception e) {
                    e.printStackTrace();
                    return Response.serverError().entity("Error: " + e.getMessage()).build();
                }
            }
	/**
 * @args String objectid - ID of the object to identify the file String fileName - name of the file to download
 * @return Response - file stream or error message
 * @usage This method allows downloading a file based on object ID and file name.
 */
            //filedownload
            @GET
            @Path("/download")
            @Produces(MediaType.APPLICATION_OCTET_STREAM)
            public Response downloadFile(@QueryParam("objectid") String objectid,@QueryParam("fileName") String fileName) {
                try {
                    AmxSpecificationDocument doc = AmxSpecificationDocument.getFileObjectIdAndFileName(objectid, fileName);
                    if (doc == null) {
                        return Response.status(Response.Status.NOT_FOUND).entity("File not found").build();
                    }
                    return Response.ok(new ByteArrayInputStream(doc.filedata))
                            .header("Content-Disposition", "attachment; filename=\"" + fileName + "\"")
                            .build();

                } catch (Exception e) {
                    e.printStackTrace();
                    return Response.serverError().entity("Download error: " + e.getMessage()).build();
                }
            }
	
	/**
 * @args String objectid - the object ID to fetch part specifications for
 * @return Response - JSON list of part specifications or error message
 * @usage Retrieves all part specifications related to the specified object ID ordered by creation time descending.
 */
///created part specification from PS
           @GET
            @Path("/getpartspecification")
            @Produces(MediaType.APPLICATION_JSON)
            public Response getPartSpecification(@QueryParam("objectid") String objectid) {
                if (objectid == null || objectid.trim().isEmpty()) {
                    return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
                }
                String sql = "SELECT * FROM amxpartspecificationdata WHERE name = ? ORDER BY createdtime DESC";
                List<Map<String, String>> results = new ArrayList<>();
                try (Connection conn = getConn();
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
                        return Response.ok("{\"message\":\"No partSpecifications found.\"}").build();
                    }
                    return Response.ok(results).build();
                } catch (SQLException e) {
                    e.printStackTrace();
                    return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
                }
            }
			/**
			* @args None
			* @return Response - JSON list of latest 10 part specifications or error message
			* @usage Fetches the 10 most recent part specifications ordered by creation date descending.
			*/
            //latest partspecification
            @GET 
            @Path("/latestpartspecifications")
            @Produces(MediaType.APPLICATION_JSON)
            public Response latestPartspecification() {
                String sql = "SELECT * FROM amxpartspecificationdata ORDER BY createdtime DESC LIMIT 10";// BUG-1053  Fixed by koushik
                try (Connection conn = getConn(); 
                	PreparedStatement ps = conn.prepareStatement(sql); 
                	ResultSet rs = ps.executeQuery()) {
                    List<Map<String, String>> list = new ArrayList<>();
                    ResultSetMetaData md = rs.getMetaData();
                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        for (int i = 1; i <= md.getColumnCount(); i++) {
                            row.put(md.getColumnName(i), rs.getString(i));
                        }
                        list.add(row);
                    }
                    return Response.ok(list).build();
                } catch (SQLException e) {
                    return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
                }
            }
            
			/**
			* @args String objectid - object ID to fetch created PartControl data for
			* @return Response - JSON list of PartControl data or error message
			* @usage Retrieves PartControl data linked to the specified object ID ordered by creation date descending.
			*/
    // get created partcontrol from partcontrol management
            @GET
            @Path("/getpartcontrolfrompc")
            @Produces(MediaType.APPLICATION_JSON)
            public Response getPartControlByPC(@QueryParam("objectid") String objectid) {
                if (objectid == null || objectid.trim().isEmpty()) {
                    return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
                }
                String sql = "SELECT * FROM amxpartcontroldata WHERE objectid = ? ORDER BY createddate DESC";
                List<Map<String, String>> results = new ArrayList<>();
                try (Connection conn = getConn();
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
                        return Response.ok("{\"message\":\"No  Created PartControl data found.\"}").build();
                    }
                    return Response.ok(results).build();
                } catch (SQLException e) {
                    e.printStackTrace();
                    return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
                }
            }
			
			/**
			* @args String objectId - object ID of the part control to promote/String jsonBody - JSON payload containing selectedState
			* @return Response - JSON with promotion result or error
			* @usage Promotes the part control state and creates a new route and connection in the database.
			*/
           //promoting state
            @POST
            @Path("/promote/{objectId}")
            @Consumes(MediaType.APPLICATION_JSON)
            @Produces(MediaType.APPLICATION_JSON)
            public Response promotePartControl( @PathParam("objectId") String objectId, @Context HttpServletRequest request,
                String jsonBody){
                if (objectId == null || objectId.trim().isEmpty()) {
                    return Response.ok("{\"error\": \"objectId must be provided\"}").build();
                }

                HttpSession session = request.getSession(true);
                String username = null;
                if (session != null) {
                    username = (String) session.getAttribute("username");
                }

                String selectedState = null;
                try {
                    if (jsonBody != null && !jsonBody.trim().isEmpty()) {
                        JSONObject json = new JSONObject(jsonBody);
                        selectedState = json.optString("selectedState", ""); 
                    }
                } catch (Exception e) {
                    return Response.ok("{\"error\": \"Invalid JSON in request body\"}").build();
                }
                try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
                    conn.setAutoCommit(false);
                    String linkedobjectid = null;
                    String checkQuery = "SELECT linkedobjectid FROM amxpartcontroldata WHERE objectid = ?";
                    try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                        checkStmt.setString(1, objectId);
                        ResultSet rs = checkStmt.executeQuery();
                        if (rs.next()) {
                            linkedobjectid = rs.getString("linkedobjectid");
                        }
                    }
                    if (linkedobjectid == null || linkedobjectid.trim().isEmpty()) {
                        return Response.ok("{\"error\": \"Cannot promote. linkedPart not found for PartControl"+ "\"}").build();
                    }

                    String partError = validatePartIsFrozen(conn, linkedobjectid);
                    if (partError != null) {
                        conn.rollback();
                        return Response.ok("{\"error\": \"" + partError + "\"}").build();
                    }

                    String mpnError = validateMPNsAreReleased(conn, linkedobjectid);
                    if (mpnError != null) {
                        conn.rollback();
                        return Response.ok("{\"error\": \"" + mpnError + "\"}").build();
                    }
                    
                    String lastName = null;
                    String nameQuery = "SELECT name FROM amxroute WHERE name LIKE 'RT-%' ORDER BY name DESC LIMIT 1";
                    try (PreparedStatement nameStmt = conn.prepareStatement(nameQuery)) {
                        ResultSet rs = nameStmt.executeQuery();
                        if (rs.next()) {
                            lastName = rs.getString("name");
                        }
                    }
                    int nextNum = (lastName == null) ? 1 : Integer.parseInt(lastName.substring(3)) + 1;
                    String routeName = String.format("RT-%06d", nextNum);
                    String routeId = generateCustomId("ROUT");
                    String connectionId = generateCustomId("CONN");
                    Timestamp now = Timestamp.valueOf(LocalDateTime.now());
                    String insertRoute = "INSERT INTO amxroute (objectid, name, supertype, type, createddate, owner, connectionid) " +
                                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement insertRouteStmt = conn.prepareStatement(insertRoute)) {
                        insertRouteStmt.setString(1, routeId);
                        insertRouteStmt.setString(2, routeName);
                        insertRouteStmt.setString(3, "route");
                        insertRouteStmt.setString(4, "amxroute");
                        insertRouteStmt.setTimestamp(5, now);
                        insertRouteStmt.setString(6, username);
                        insertRouteStmt.setString(7, connectionId);
                        insertRouteStmt.executeUpdate();
                    }
                    String insertConn = "INSERT INTO amxcoreconnectiondata (connectionid, name, type, fromid, toid, fromname, toname, createddate) " +
                                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement insertConnStmt = conn.prepareStatement(insertConn)) {
                        insertConnStmt.setString(1, connectionId);
                        insertConnStmt.setString(2, routeName);
                        insertConnStmt.setString(3, "amxroute");
                        insertConnStmt.setString(4, objectId);
                        insertConnStmt.setString(5, routeId);
                        insertConnStmt.setString(6, "PartControl");
                        insertConnStmt.setString(7, "Route");
                        insertConnStmt.setTimestamp(8, now);
                        insertConnStmt.executeUpdate();
                    }
                    String updatePart = "UPDATE amxpartcontroldata SET connectionid = ? WHERE objectid = ?";
                    try (PreparedStatement updateStmt = conn.prepareStatement(updatePart)) {
                        updateStmt.setString(1, connectionId);
                        updateStmt.setString(2, objectId);
                        updateStmt.executeUpdate();
                    }

                    String updateState = "UPDATE amxpartcontroldata SET currentstate = ? WHERE objectid = ?";
                    try (PreparedStatement updateStateStmt = conn.prepareStatement(updateState)) {
                        updateStateStmt.setString(1, selectedState);
                        updateStateStmt.setString(2, objectId);
                        updateStateStmt.executeUpdate();
                    }
                    String historyMessage = String.format("Promoted by %s to state %s",
                            (username != null ? username : "unknown"),
                            (selectedState != null && !selectedState.isEmpty() ? selectedState : "undefined"));
                    String insertHistory = "INSERT INTO partcontrolhistory (objectid, history) VALUES (?, ?)";
                    try (PreparedStatement insertHistoryStmt = conn.prepareStatement(insertHistory)) {
                    	insertHistoryStmt.setString(1, objectId);
                    	insertHistoryStmt.setString(2, historyMessage);
                    	insertHistoryStmt.executeUpdate();
                    }
                    conn.commit();
                    JSONObject responseJson = new JSONObject();
                    responseJson.put("message", "Route created and Promotion of state is successful");
                    responseJson.put("routeName", routeName);
                    responseJson.put("routeObjectId", routeId);
                    responseJson.put("connectionId", connectionId);

                    return Response.ok(responseJson.toString()).build();

                } catch (Exception e) {
                    e.printStackTrace();
                    return Response.ok("{\"error\": \"Internal error: " + e.getMessage() + "\"}").build();
                }
            }

		/**
			* @args String suffix - suffix to append to the generated ID
			* @return String - generated custom ID string
			* @usage Generates a unique custom ID string with a given suffix.
		*/
            public String generateCustomId(String suffix) {
                SecureRandom random = new SecureRandom();
                byte[] bytes = new byte[8];
                random.nextBytes(bytes);
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < bytes.length; i += 2) {
                    int part = ((bytes[i] & 0xFF) << 8) | (bytes[i + 1] & 0xFF);
                    sb.append(String.format("%04X", part));
                    if (i < bytes.length - 2) sb.append(".");
                }
                sb.append(".").append(suffix);
                return sb.toString();
            }
			/**
			* @args String objectid - the object ID to fetch connected routes for
			* @return Response - JSON list of connected routes or error message
			* @usage Retrieves routes connected to the given object ID.
			*/

// getconnected routes
            @GET
            @Path("/getconnectedroute")
            @Produces(MediaType.APPLICATION_JSON)
            public Response getConnectedRoute(@QueryParam("objectid") String objectid) {
                if (objectid == null || objectid.trim().isEmpty()) {
                    return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
                }
                try {
                	AmxControlTriggers triggers = new AmxControlTriggers(objectid);
                    List<Map<String, String>> result = triggers.getConnectedRoute();

                    if (result == null || result.isEmpty()) {
                        return Response.ok("{\"message\":\"No connected route found.\"}").build();
                    }
                    return Response.ok(result).build();
                } catch (Exception e) {
                    e.printStackTrace();
                    return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
                }
            }
			
			/**
			* @args String objectid - the part control object ID String loginuser - username to check assignment for
			* @return Response - JSON indicating whether user is assignee or error
			* @usage Checks if the specified user is assigned to the given part control object.
			*/
//assigne check
    @GET
    @Path("/checkAssignee")
  @Produces(MediaType.APPLICATION_JSON)
  public Response checkPartControlAssignee(@QueryParam("objectid") String objectid,@QueryParam("loginuser") String loginuser) {
     if (objectid == null || objectid.trim().isEmpty() || 
         loginuser == null || loginuser.trim().isEmpty()) {
         return Response.ok("{\"error\":\"Both objectid and loginuser query parameters are required\"}").build();
    }

     try {
        AmxControlTriggers triggers = new AmxControlTriggers();
        boolean isAssignee = triggers.partControlAssignee(objectid, loginuser);
        String json = "{\"isAssignee\":" + isAssignee + "}";
        return Response.ok(json).build();
  } catch (Exception e) {
      e.printStackTrace();
       return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
             }
           }
           
		   /**
			* @args String name - part control name
			* String assignee - assignee username
			* String approvalState - new approval state to promote to
			* @return Response - JSON with success message or error
			* @usage Updates the approval state of the part control and related part data if applicable.
			*/
 // promote to approval state
    @POST
    @Path("/promoteapprovalstate")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response promoteApprovalState(
            @FormParam("partName") String name,
            @FormParam("assignee") String assignee,
            @FormParam("approvalState") String approvalState) {

        Map<String, String> responseMap = new HashMap<>();

        if (name == null || assignee == null || approvalState == null ||
            name.trim().isEmpty() || assignee.trim().isEmpty() || approvalState.trim().isEmpty()) {

            responseMap.put("error", "Missing required fields.");
            return Response.status(Response.Status.BAD_REQUEST).entity(responseMap).build();
        }

        String state = approvalState.trim();
        String updatePartControlSql = "UPDATE amxpartcontroldata SET currentstate = ? WHERE name = ? AND assignee = ?";
        String selectControlDataSql = "SELECT objectid, linkedobjectid FROM amxpartcontroldata WHERE name = ? AND assignee = ?";
        String updateLinkedPartStateSql = "UPDATE amxcorepartdata SET currentstate = ? WHERE objectid = ?";

        try (Connection conn = getConn()) {
            conn.setAutoCommit(false);
            
            int rowsAffected;
            try (PreparedStatement pstmt = conn.prepareStatement(updatePartControlSql)) {
                pstmt.setString(1, state);
                pstmt.setString(2, name);
                pstmt.setString(3, assignee);
                rowsAffected = pstmt.executeUpdate();
            }

            if (rowsAffected == 0) {
                conn.rollback();
                responseMap.put("error", "No matching record found to update.");
                return Response.status(Response.Status.NOT_FOUND).entity(responseMap).build();
            }
            String linkedObjectId = null;
            String objectId = null;
            if ("Completed".equalsIgnoreCase(state)) {
                

                try (PreparedStatement pstmt = conn.prepareStatement(selectControlDataSql)) {
                    pstmt.setString(1, name);
                    pstmt.setString(2, assignee);

                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            linkedObjectId = rs.getString("linkedobjectid");
                            objectId= rs.getString("objectid");
                        }
                    }
                }

                String timestamp = java.time.LocalDateTime.now().toString();
                String historyTable = "partcontrolhistory";
                String historyMessage = "Promoted to " + "newState" + " at " + timestamp;
                insertHistory(conn, historyTable, objectId, historyMessage);
                

                if (linkedObjectId != null && !linkedObjectId.isEmpty()) {
                    try (PreparedStatement pstmt = conn.prepareStatement(updateLinkedPartStateSql)) {
                        pstmt.setString(1, "Released");
                        pstmt.setString(2, linkedObjectId);
                        pstmt.executeUpdate();
                    }
                }
            }

            conn.commit();

            responseMap.put("message", "Approval state updated successfully.");
            responseMap.put("status", "success");
            return Response.ok(responseMap).build();

        } catch (SQLException e) {
            e.printStackTrace();
            responseMap.put("error", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(responseMap).build();
        } catch (Exception ex) {
            ex.printStackTrace();
            responseMap.put("error", "Unexpected error: " + ex.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(responseMap).build();
        }
    }

    
    
    /**
    * @args String objectid - linked object ID to fetch related Part records
    * @return Response - JSON list of Part records or error message
    * @usage This method retrieves all Part records linked to the given object ID, ordered by creation date descending.
    */
      //getCreatedpart
           @GET
           @Path("/getcreatedebom")
           @Produces(MediaType.APPLICATION_JSON)
           public Response getPartByObjectId(@QueryParam("objectid") String objectid) {
               if (objectid == null || objectid.trim().isEmpty()) {
                   return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
               }
               String sql = "SELECT * FROM amxcorepartdata WHERE objectid = ? ORDER BY createddate DESC";
               List<Map<String, String>> results = new ArrayList<>();
               try (Connection conn = getConn();
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
                       return Response.ok("{\"message\":\"No Part data found.\"}").build();
                   }
                   return Response.ok(results).build();
               } catch (SQLException e) {
                   e.printStackTrace();
                   return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
               }
           }
    

           
           
           @POST
           @Path("/createpartwithconnection")
           @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
           @Produces(MediaType.APPLICATION_JSON)
           public Response createChildPartWithConnection(@FormParam("ObjectId") String sourceObjectId,@FormParam("SuperType") String supertype,@FormParam("Type") String type,@FormParam("APN") String apn,
                   @FormParam("Description") String description,@FormParam("FastenerSubPart") String fastenerSubPart,
                   @FormParam("Variant") String variant,@Context HttpServletRequest request) {

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
              
//              if (isPartLinkedToSource(sourceObjectId)) {
//                  return Response.status(Response.Status.CONFLICT)
//                      .entity(Map.of(
//                          "error", "A Part linked to the sourceObjectId '" + sourceObjectId + "' already exists."
//                      ))
//                      .build();
//              }
       
              try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
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
       
                  
                  String existingConnectionId = getConnectionIdFromPart(sourceObjectId);
                  String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                          ? existingConnectionId
                          : generateHexId("CONN");
       
                  
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
       
                  String insertSQL = "INSERT INTO amxcorepartdata(objectid, apn, name, type, supertype, description, createddate, owner, email, fastenersubpart, variant, connectionid, currentstate) "
                          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
       
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
                      insertPS.setString(12, connectionIdToUse);
                      insertPS.setString(13, firstState);
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
                 

                       String insertConnectionDataSQL = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                               + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                       try (PreparedStatement ps2 = conn.prepareStatement(insertConnectionDataSQL)) {
                           ps2.setString(1, connectionIdToUse);
                           ps2.setString(2, type);
                           ps2.setString(3, name);
                           ps2.setString(4, objectId);
                           ps2.setString(5, sourceObjectId);
                           ps2.setString(6, "part");
                           ps2.setString(7, "part");
                           ps2.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                           ps2.executeUpdate();
                       }

                       String updatePartDataSQL = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                       try (PreparedStatement ps3 = conn.prepareStatement(updatePartDataSQL)) {
                           ps3.setString(1, connectionIdToUse);
                           ps3.setString(2, sourceObjectId);
                           ps3.executeUpdate();
                       }

                       String historyMsg1 = "Created by system at " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                       String insertHistorySQL = "INSERT INTO parthistory (objectid, history) VALUES (?, ?)";
                       try (PreparedStatement ps4 = conn.prepareStatement(insertHistorySQL)) {
                           ps4.setString(1, objectId);
                           ps4.setString(2, historyMsg1);
                           ps4.executeUpdate();
                       }
                       
                       return Response.ok(Map.of(
                               "objectid", objectId,
                               "connectionid", connectionIdToUse,
                               "name", name
                           )).build();
                   }catch (Exception e) {
                       e.printStackTrace();
                       return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                           .entity(Map.of("error", "Failed to create part: " + e.getMessage()))
                           .build();
                   }

                   

               } 
           

           
           public String getConnectionIdFromPart(String objectId) {
               String sql = "SELECT connectionid FROM amxcorepartdata WHERE objectid = ?";
               try (Connection conn = DriverManager.getConnection(url, user, db_password);
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
           
           
           
           public boolean isPartLinkedToSource(String fromId) {
               String sql = "SELECT COUNT(*) FROM amxcoreconnectiondata WHERE toid = ?";
               try (Connection conn = DriverManager.getConnection(url, user, db_password);
                    PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, fromId);
                   try (ResultSet rs = ps.executeQuery()) {
                       if (rs.next()) {
                           return rs.getInt(1) > 0;
                       }
                   }
               } catch (SQLException e) {
                   e.printStackTrace();
               }
               return false;
           }
           
           
           @GET
           @Path("/getcreatedchildpart")
           @Produces(MediaType.APPLICATION_JSON)
           public Response getChildPartByObjectId(@QueryParam("objectid") String objectid) {
               if (objectid == null || objectid.trim().isEmpty()) {
                   return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
               }
            
               String sql = "select * from amxcorepartdata where objectid IN (select fromid from amxcoreconnectiondata where toid=?);";            
               List<Map<String, String>> results = new ArrayList<>();
            
               try (Connection conn = getConn();
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
                       return Response.ok("{\"message\":\"No Child Part data found.\"}").build();
                   }
            
                   return Response.ok(results).build();
            
               } catch (SQLException e) {
                   e.printStackTrace();
                   return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
               }
           }
           
           
           @GET
           @Path("/getlinkedpart")
           @Produces(MediaType.APPLICATION_JSON)
           public Response getPartByLinkedObjectId(@QueryParam("objectid") String objectid) {
               if (objectid == null || objectid.trim().isEmpty()) {
                   return Response.ok("{\"error\":\"objectid query parameter is required\"}").build();
               }
               String sql = "SELECT * FROM amxcorepartdata WHERE objectid = (SELECT linkedobjectid FROM amxpartcontroldata WHERE objectid = ?);";
               List<Map<String, String>> results = new ArrayList<>();
               try (Connection conn = getConn();
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
                       return Response.ok("{\"message\":\"No Part data found.\"}").build();
                   }
                   return Response.ok(results).build();
               } catch (SQLException e) {
                   e.printStackTrace();
                   return Response.ok("{\"error\":\"" + e.getMessage() + "\"}").build();
               }
           }
   
           
           @POST
           @Path("/createpartforcontrolwithconnection")
           @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
           @Produces(MediaType.APPLICATION_JSON)
           public Response createPartForControlWithConnection(@FormParam("ObjectId") String sourceObjectId,@FormParam("SuperType") String supertype,@FormParam("Type") String type,@FormParam("APN") String apn,
                   @FormParam("Description") String description,@FormParam("FastenerSubPart") String fastenerSubPart,
                   @FormParam("Variant") String variant,@Context HttpServletRequest request) {

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
              
              if (isPartLinkedToControl(sourceObjectId)) {
                  return Response.status(Response.Status.CONFLICT)
                      .entity(Map.of(
                          "error", "A Part linked to this Part Control '"+"' already exists."
                      ))
                      .build();
              }
       
              try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
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
       
                  
                  String existingConnectionId = getConnectionIdForObject(sourceObjectId);
                  String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                          ? existingConnectionId
                          : generateHexId("CONN");
       
                  
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
       
                  String insertSQL = "INSERT INTO amxcorepartdata(objectid, apn, name, type, supertype, description, createddate, owner, email, fastenersubpart, variant, connectionid, currentstate) "
                          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
       
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
                      insertPS.setString(12, connectionIdToUse);
                      insertPS.setString(13, firstState);
                      insertPS.executeUpdate();
                  }
       //Bug-1024 added by Nageswari 
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
                 

                       String insertConnectionDataSQL = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                               + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                       try (PreparedStatement ps2 = conn.prepareStatement(insertConnectionDataSQL)) {
                           ps2.setString(1, connectionIdToUse);
                           ps2.setString(2, type);
                           ps2.setString(3, name);
                           ps2.setString(4, objectId);
                           ps2.setString(5, sourceObjectId);
                           ps2.setString(6, "part");
                           ps2.setString(7, "partcontrol");
                           ps2.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                           ps2.executeUpdate();
                       }

                       String updatePartDataSQL = "UPDATE amxpartcontroldata SET connectionid = ?, linkedobjectid = ? WHERE objectid = ?";
                       try (PreparedStatement ps3 = conn.prepareStatement(updatePartDataSQL)) {
                           ps3.setString(1, connectionIdToUse);
                           ps3.setString(2, objectId);
                           ps3.setString(3, sourceObjectId);
                           ps3.executeUpdate();
                       }

                       String historyMsg1 = "Created by system at " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                       String insertHistorySQL = "INSERT INTO parthistory (objectid, history) VALUES (?, ?)";
                       try (PreparedStatement ps4 = conn.prepareStatement(insertHistorySQL)) {
                           ps4.setString(1, objectId);
                           ps4.setString(2, historyMsg1);
                           ps4.executeUpdate();
                       }
                       
                       return Response.ok(Map.of(
                               "objectid", objectId,
                               "connectionid", connectionIdToUse,
                               "name", name
                           )).build();
                   }catch (Exception e) {
                       e.printStackTrace();
                       return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                           .entity(Map.of("error", "Failed to new create part: " + e.getMessage()))
                           .build();
                   }

               }
           
           
           public boolean isPartLinkedToControl(String fromId) {
               String sql = "SELECT COUNT(*) FROM amxpartcontroldata WHERE objectid = ? and linkedobjectid is not null and linkedobjectid !=''";
               try (Connection conn = DriverManager.getConnection(url, user, db_password);
                    PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, fromId);
                   try (ResultSet rs = ps.executeQuery()) {
                       if (rs.next()) {
                           return rs.getInt(1) > 0;
                       }
                   }
               } catch (SQLException e) {
                   e.printStackTrace();
               }
               return false;
           }
           
// @Email
//method for sending released mail
           public static void sendReleaseMail(
        	        String objectId,
        	        String objectName,
        	        String objectType,
        	        String objectSupertype,
        	        String releasedBy,
        	        String releaseDate) {

        	    final String from = "andromeda.lifecycle@gmail.com";
        	    final String password = "cmnl gfrx niti soiq";
        	    String to = "teamamx248@gmail.com";

        	    Properties props = new Properties();

        	    props.put("mail.smtp.auth", "true");
        	    props.put("mail.smtp.starttls.enable", "true");
        	    props.put("mail.smtp.host", "smtp.gmail.com");
        	    props.put("mail.smtp.port", "587");

        	    Session session = Session.getInstance(props, new Authenticator() {
        	                protected PasswordAuthentication getPasswordAuthentication() {
        	                    return new PasswordAuthentication(from, password);
        	                }
        	    	});

        	    try {

        	        Message message = new MimeMessage(session);
        	        message.setFrom(new InternetAddress(from));
        	        message.setRecipients(Message.RecipientType.TO,InternetAddress.parse(to));
        	        message.setSubject("Part Release Notification - " + objectName);

        	        String htmlBody =
        	                "<html>" +
        	                "<body style='font-family:Arial;padding:15px'>" +

        	                "<h2 style='color:green'>" +
        	                "Part Successfully Released" +
        	                "</h2>" +

        	                "<p>" +
        	                "This is an automated notification from " +
        	                "Andromeda PLM System." +
        	                "</p>" +

        	                "<table border='1' cellpadding='8' " +
        	                "cellspacing='0' style='border-collapse:collapse'>" +

        	                "<tr>" +
        	                "<td><b>Object ID</b></td>" +
        	                "<td>" + objectId + "</td>" +
        	                "</tr>" +

        	                "<tr>" +
        	                "<td><b>Object Name</b></td>" +
        	                "<td>" + objectName + "</td>" +
        	                "</tr>" +

        	                "<tr>" +
        	                "<td><b>Object Type</b></td>" +
        	                "<td>" + objectType + "</td>" +
        	                "</tr>" +

        	                "<tr>" +
        	                "<td><b>Object Supertype</b></td>" +
        	                "<td>" + objectSupertype + "</td>" +
        	                "</tr>" +

        	                "<tr>" +
        	                "<td><b>Previous State</b></td>" +
        	                "<td>Frozen</td>" +
        	                "</tr>" +

        	                "<tr>" +
        	                "<td><b>Current State</b></td>" +
        	                "<td style='color:green;font-weight:bold'>" +
        	                "RELEASED" +
        	                "</td>" +
        	                "</tr>" +

        	                "<tr>" +
        	                "<td><b>Released By</b></td>" +
        	                "<td>" + releasedBy + "</td>" +
        	                "</tr>" +

        	                "<tr>" +
        	                "<td><b>Released Date</b></td>" +
        	                "<td>" + releaseDate + "</td>" +
        	                "</tr>" +

        	                "</table>" +

        	                "<br>" +

        	                "<p>" +
        	                "The object has successfully completed " +
        	                "its lifecycle approval process and is now " +
        	                "available for downstream operations." +
        	                "</p>" +

        	                "<ul>" +
        	                "<li>Engineering BOM Usage</li>" +
        	                "<li>Manufacturing Process</li>" +
        	                "<li>Reference & Documentation</li>" +
        	                "<li>Production Release</li>" +
        	                "</ul>" +

        	                "<br>" +

        	                "<p style='color:gray;font-size:12px'>" +
        	                "This is an auto-generated email. " +
        	                "Please do not reply." +
        	                "</p>" +

        	                "<p>" +
        	                "<b>Andromeda PLM System</b>" +
        	                "</p>" +

        	                "</body>" +
        	                "</html>";

        	        message.setContent(htmlBody, "text/html");
        	        Transport.send(message);

        	    } catch (Exception e) {
        	        e.printStackTrace();
        	    }
        	}
    
           
           
           @DELETE
           @Path("/deleteFile")
           @Produces(MediaType.APPLICATION_JSON)
           public Response deleteFile( @QueryParam("objectid") String objectid, @QueryParam("fileName") String fileName) {

        	   try {
                   if (objectid == null || objectid.trim().isEmpty()) {
                       return Response.status(Response.Status.BAD_REQUEST).entity("{\"error\":\"objectid is required\"}").build();
                   }

                   if (fileName == null || fileName.trim().isEmpty()) {
                       return Response.status(Response.Status.BAD_REQUEST).entity("{\"error\":\"fileName is required\"}").build();
                   }

                   boolean deleted = AmxSpecificationDocument.deleteFile(objectid, fileName);

                   if (!deleted) {
                       return Response.status(Response.Status.NOT_FOUND).entity("{\"error\":\"File not found\"}").build();
                   }

                   return Response.ok("{\"message\":\"File deleted successfully\"}").build();

               } catch (Exception e) {
                   e.printStackTrace();
                   return Response.serverError().entity("{\"error\":\"Delete failed: "+ e.getMessage() + "\"}").build();
               }
           }
           
           
           
       	/**
       	* @args none
       	* @return List of latest MPNs in JSON
       	* @usage Retrieves the 10 most recent MPNs ordered by created date
       	*/
           // Latest MPNs
           @GET 
           @Path("/latestmpns")
           @Produces(MediaType.APPLICATION_JSON)
           public Response getLatestMPNs() {
               String sql = "SELECT * FROM amxcorempndetails ORDER BY createddate DESC LIMIT 10";
               try (Connection conn = getConn(); 
               	PreparedStatement ps = conn.prepareStatement(sql); 
               	ResultSet rs = ps.executeQuery()) {
                   List<Map<String, String>> list = new ArrayList<>();
                   ResultSetMetaData md = rs.getMetaData();
                   while (rs.next()) {
                       Map<String, String> row = new LinkedHashMap<>();
                       for (int i = 1; i <= md.getColumnCount(); i++) {
                           row.put(md.getColumnName(i), rs.getString(i));
                       }
                       list.add(row);
                   }
                   return Response.ok(list).build();
               } catch (SQLException e) {
                   return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
               }
           }

           
           @POST
           @Path("/linkebomparts/{parentObjectId}")
           @Consumes(MediaType.APPLICATION_JSON)
           @Produces(MediaType.APPLICATION_JSON)
           public Response linkEBOMParts(@PathParam("parentObjectId") String parentObjectId,List<Map<String, Object>> selectedParts) {
               try {
                   Class.forName("org.postgresql.Driver");
                   Connection conn = DriverManager.getConnection(url, user, db_password);

                   for (Map<String, Object> part : selectedParts) {
                       String childObjectId = (String) part.get("objectid");
                       String childName     = (String) part.get("name");
                       String childType     = (String) part.get("type");
                       String supertype     = (String) part.get("supertype");

                       if (supertype == null || !supertype.equalsIgnoreCase("part")) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Invalid selection. Please select only Part objects.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }

                       if (childObjectId.equalsIgnoreCase(parentObjectId)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Cannot link a part to itself.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }

                       if (isEBOMAlreadyLinked(conn, parentObjectId, childObjectId)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Part '" + childName + "' is already linked to another parent '"+"'.");
                           return Response.status(Response.Status.CONFLICT).entity(error).build();
                       }

                       String existingConnectionId = getConnectionIdFromPart(childObjectId);
                       String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                               ? existingConnectionId
                               : generateHexId("CONN");

                       String insertSql = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                       try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, childType);
                           ps.setString(3, childName);
                           ps.setString(4, childObjectId);
                           ps.setString(5, parentObjectId);
                           ps.setString(6, "Part");
                           ps.setString(7, "Part");
                           ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                           ps.executeUpdate();
                       }

                       String updateChildSql = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updateChildSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, childObjectId);
                           ps.executeUpdate();
                       }

                       String updateParentSql = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updateParentSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, parentObjectId);
                           ps.executeUpdate();
                       }
                   }

                   conn.close();

                   Map<String, String> result = new HashMap<>();
                   result.put("Status", "Success");
                   result.put("Message", selectedParts.size() + " part(s) linked successfully.");
                   return Response.ok(result).build();

               } catch (Exception e) {
                   e.printStackTrace();
                   Map<String, String> error = new HashMap<>();
                   error.put("Status", "Error");
                   error.put("Message", e.getMessage());
                   return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error).build();
               }
           }

           private boolean isEBOMAlreadyLinked(Connection conn, String parentObjectId, String childObjectId) throws SQLException {
               String sql = "SELECT COUNT(*) FROM amxcoreconnectiondata WHERE fromid = ? ";
               try (PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, childObjectId);
            //       ps.setString(2, childObjectId);
                   try (ResultSet rs = ps.executeQuery()) {
                       return rs.next() && rs.getInt(1) > 0;
                   }
               }
           }

           
           
           @POST
           @Path("/linkpartcontrol/{objectid}")
           @Consumes(MediaType.APPLICATION_JSON)
           @Produces(MediaType.APPLICATION_JSON)
           public Response linkPartControl(@PathParam("objectid") String objectid,List<Map<String, Object>> selectedParts) {
               try {
                   Class.forName("org.postgresql.Driver");
                   Connection conn = DriverManager.getConnection(url, user, db_password);

                   for (Map<String, Object> part : selectedParts) {
                       String partId   = (String) part.get("objectid");
                       String partName = (String) part.get("name");
                       String partType = (String) part.get("type");
                       String supertype = (String) part.get("supertype");

                       if (supertype == null || !supertype.equalsIgnoreCase("AmxControl")) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Invalid selection. Please select only Part Control objects.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }

                       if (partId.equalsIgnoreCase(objectid)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Cannot link a part to itself.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }
                       if (isPartControlLinkedToSource(objectid)) {
                    	   Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "A PartControl linked to the this Part already exists.");
                           return Response.status(Response.Status.CONFLICT).entity(error).build();
                       }

                       if (isPartControlAlreadyLinked(conn, objectid, partId)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "PartControl '" + partName + "' is already linked to another Part.");
                           return Response.status(Response.Status.CONFLICT).entity(error).build();
                       }
                       
                       String existingConnectionId = getConnectionIdFromPart(objectid);
                       String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                               ? existingConnectionId
                               : generateHexId("CONN");

                       String insertSql = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                       try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, partType);
                           ps.setString(3, partName);
                           ps.setString(4, partId);
                           ps.setString(5, objectid);
                           ps.setString(6, "PartControl");
                           ps.setString(7, "Part");
                           ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                           ps.executeUpdate();
                       }

                       String updatePartSql = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updatePartSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, objectid);
                           ps.executeUpdate();
                       }

                       String updateControlSql = "UPDATE amxpartcontroldata SET connectionid = ?, linkedobjectid=? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updateControlSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, objectid);
                           ps.setString(3, partId);
                           ps.executeUpdate();
                       }
                   }

                   conn.close();

                   Map<String, String> result = new HashMap<>();
                   result.put("Status", "Success");
                   result.put("Message", selectedParts.size() + " partControl(s) linked successfully.");
                   return Response.ok(result).build();

               } catch (Exception e) {
                   e.printStackTrace();
                   Map<String, String> error = new HashMap<>();
                   error.put("Status", "Error");
                   error.put("Message", e.getMessage());
                   return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error).build();
               }
           }

           private boolean isPartControlAlreadyLinked(Connection conn, String objectid, String partId) throws SQLException {
               String sql = "SELECT COUNT(*) FROM amxcoreconnectiondata WHERE fromid = ? AND toname = 'Part'";
               try (PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, partId);
//                   ps.setString(2, partId);
                   try (ResultSet rs = ps.executeQuery()) {
                       return rs.next() && rs.getInt(1) > 0;
                   }
               }
           }
           
           
           @POST
           @Path("/linkpartspecification/{objectid}")
           @Consumes(MediaType.APPLICATION_JSON)
           @Produces(MediaType.APPLICATION_JSON)
           public Response linkPartSpecification(@PathParam("objectid") String objectid,List<Map<String, Object>> selectedParts) {
               try {
                   Class.forName("org.postgresql.Driver");
                   Connection conn = DriverManager.getConnection(url, user, db_password);

                   for (Map<String, Object> part : selectedParts) {
                       String partId    = (String) part.get("objectid");
                       String partName  = (String) part.get("name");
                       String partType  = (String) part.get("type");
                       String supertype = (String) part.get("supertype");

                       if (supertype == null || !supertype.equalsIgnoreCase("Document")) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Selected object '" + partName + "' is not a Part Specification.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }

                       if (partId.equalsIgnoreCase(objectid)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Cannot link a part to itself.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }
                       if (isPartSpecificationLinkedToSource(objectid)) {
                           return Response.ok(Map.of("error", "A PartSpecification linked to the this Part '" + "' already exists.")).build();
                       }

                       if (isPartSpecificationAlreadyLinked(conn, objectid, partId)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Part Specification '" + partName + "' is already linked to another Part.");
                           return Response.status(Response.Status.CONFLICT).entity(error).build();
                       }

                       String existingConnectionId = getConnectionIdFromPart(objectid);
                       String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                               ? existingConnectionId
                               : generateHexId("CONN");

                       String insertSql = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                       try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, partType);
                           ps.setString(3, partName);
                           ps.setString(4, partId);
                           ps.setString(5, objectid);
                           ps.setString(6, "PartSpecification");
                           ps.setString(7, "Part");
                           ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                           ps.executeUpdate();
                       }

                       String updatePartSql = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updatePartSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, objectid);
                           ps.executeUpdate();
                       }

                       String updateSpecSql = "UPDATE amxpartspecificationdata SET connectionid = ?, linkedobjectid = ? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updateSpecSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, objectid);
                           ps.setString(3, partId);
                           ps.executeUpdate();
                       }
                   }

                   conn.close();

                   Map<String, String> result = new HashMap<>();
                   result.put("Status", "Success");
                   result.put("Message", selectedParts.size() + " partSpecification(s) linked successfully.");
                   return Response.ok(result).build();

               } catch (Exception e) {
                   e.printStackTrace();
                   Map<String, String> error = new HashMap<>();
                   error.put("Status", "Error");
                   error.put("Message", e.getMessage());
                   return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error).build();
               }
           }

           private boolean isPartSpecificationAlreadyLinked(Connection conn, String objectid, String partId) throws SQLException {
               String sql = "SELECT COUNT(*) FROM amxcoreconnectiondata WHERE fromid = ? AND toname = 'Part'";
               try (PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, partId);
                   try (ResultSet rs = ps.executeQuery()) {
                       return rs.next() && rs.getInt(1) > 0;
                   }
               }
           }
           
           
           @POST
           @Path("/linkparttocontrol/{objectid}")
           @Consumes(MediaType.APPLICATION_JSON)
           @Produces(MediaType.APPLICATION_JSON)
           public Response linkPartToControl(@PathParam("objectid") String objectid,List<Map<String, Object>> selectedParts) {
               try {
                   Class.forName("org.postgresql.Driver");
                   Connection conn = DriverManager.getConnection(url, user, db_password);

                   for (Map<String, Object> part : selectedParts) {
                       String partId    = (String) part.get("objectid");
                       String partName  = (String) part.get("name");
                       String partType  = (String) part.get("type");
                       String supertype = (String) part.get("supertype");

                       if (supertype == null || !supertype.equalsIgnoreCase("Part")) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Selected object '" + partName + "' is not a Part.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }

                       if (partId.equalsIgnoreCase(objectid)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Cannot link a part to itself.");
                           return Response.status(Response.Status.BAD_REQUEST).entity(error).build();
                       }

                       if (isPartAlreadyLinkedToControl(conn, objectid)) {
                           return Response.status(Response.Status.CONFLICT)
                               .entity(Map.of(
                                   "Status", "Error",
                                   "Message", "A Part is already linked to this PartControl '" + "'."
                               ))
                               .build();
                       }

                       if (isPartAlreadyLinkedElsewhere(conn, partId)) {
                           Map<String, String> error = new HashMap<>();
                           error.put("Status", "Error");
                           error.put("Message", "Part '" + partName + "' is already linked to another PartControl.");
                           return Response.status(Response.Status.CONFLICT).entity(error).build();
                       }

                       String existingConnectionId = getConnectionIdFromPartControl(objectid);
                       String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                               ? existingConnectionId
                               : generateHexId("CONN");

                       String insertSql = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                       try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, partType);
                           ps.setString(3, partName);
                           ps.setString(4, partId);
                           ps.setString(5, objectid);
                           ps.setString(6, "Part");
                           ps.setString(7, "PartControl");
                           ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                           ps.executeUpdate();
                       }

                       String updateControlSql = "UPDATE amxpartcontroldata SET connectionid = ?, linkedobjectid = ? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updateControlSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, partId);
                           ps.setString(3, objectid);
                           ps.executeUpdate();
                       }

                       String updatePartSql = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                       try (PreparedStatement ps = conn.prepareStatement(updatePartSql)) {
                           ps.setString(1, connectionIdToUse);
                           ps.setString(2, partId);
                           ps.executeUpdate();
                       }
                   }

                   conn.close();

                   Map<String, String> result = new HashMap<>();
                   result.put("Status", "Success");
                   result.put("Message", selectedParts.size() + " part(s) linked to PartControl successfully.");
                   return Response.ok(result).build();

               } catch (Exception e) {
                   e.printStackTrace();
                   Map<String, String> error = new HashMap<>();
                   error.put("Status", "Error");
                   error.put("Message", e.getMessage());
                   return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error).build();
               }
           }

           private boolean isPartAlreadyLinkedToControl(Connection conn, String objectid) throws SQLException {
               String sql = "SELECT COUNT(*) FROM amxcoreconnectiondata " +
      	             "WHERE (fromid = ? AND toname = 'part') " +
      	             "OR (toid = ? AND fromname = 'part')";
               try (PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, objectid);
                   ps.setString(2, objectid);
                   try (ResultSet rs = ps.executeQuery()) {
                       return rs.next() && rs.getInt(1) > 0;
                   }
               }
           }

           private boolean isPartAlreadyLinkedElsewhere(Connection conn, String partId) throws SQLException {
        	   String sql = "SELECT COUNT(*)\r\n"
        	   		+ "FROM amxcoreconnectiondata\r\n"
        	   		+ "WHERE (fromid = ? AND (toname = 'PartControl' OR toname = 'partcontrol'))\r\n"
        	   		+ "   OR (toid = ? AND (fromname = 'PartControl' OR fromname = 'partcontrol'))";
               try (PreparedStatement ps = conn.prepareStatement(sql)) {
                   ps.setString(1, partId);
                   ps.setString(2, partId);                  
                   try (ResultSet rs = ps.executeQuery()) {
                       return rs.next() && rs.getInt(1) > 0;
                   }
               }
           }

           private String getConnectionIdFromPartControl(String objectid) {
               try {
                   Class.forName("org.postgresql.Driver");
                   Connection conn = DriverManager.getConnection(url, user, db_password);
                   String sql = "SELECT connectionid FROM amxpartcontroldata WHERE objectid = ?";
                   try (PreparedStatement ps = conn.prepareStatement(sql)) {
                       ps.setString(1, objectid);
                       try (ResultSet rs = ps.executeQuery()) {
                           if (rs.next()) return rs.getString("connectionid");
                       }
                   }
                   conn.close();
               } catch (Exception e) {
                   e.printStackTrace();
               }
               return null;
           }
           //BUG-11046 Strated By Nageswari
           private Response getMyCreatedObjects(HttpServletRequest request, String tableName) {

        	    HttpSession session = request.getSession(false);

        	    if (session == null || session.getAttribute("username") == null) {
        	        return Response.status(Response.Status.UNAUTHORIZED)
        	                .entity("{\"error\":\"User not logged in.\"}")
        	                .build();
        	    }

        	    String username = (String) session.getAttribute("username");
        	    //BUG-1054 Fixing started by koushik
        	    String sql;
        	    if(tableName == "amxpartspecificationdata") {
        	    	sql = "SELECT * FROM " + tableName + " WHERE owner=? ORDER BY createdtime DESC";
        	    }
        	    else {
        	    	sql = "SELECT * FROM " + tableName + " WHERE owner=? ORDER BY createddate DESC";
        	    }
        	    //BUG-1054 Fixing ended by koushik
        	    try (Connection conn = getConn();
        	         PreparedStatement ps = conn.prepareStatement(sql)) {

        	        ps.setString(1, username);

        	        ResultSet rs = ps.executeQuery();

        	        List<Map<String, String>> list = new ArrayList<>();
        	        ResultSetMetaData md = rs.getMetaData();

        	        while (rs.next()) {

        	            Map<String, String> row = new LinkedHashMap<>();

        	            for (int i = 1; i <= md.getColumnCount(); i++) {
        	                row.put(md.getColumnName(i), rs.getString(i));
        	            }

        	            list.add(row);
        	        }

        	        return Response.ok(list).build();

        	    } catch (SQLException e) {

        	        e.printStackTrace();

        	        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
        	                .entity("{\"error\":\"" + e.getMessage() + "\"}")
        	                .build();
        	    }
        	}
           //BUG-1046 Ended By Nageswari
  }


