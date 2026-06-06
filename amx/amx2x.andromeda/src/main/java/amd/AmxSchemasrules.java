package amd;

import java.sql.*;
import java.util.*;

import org.navigator.DBConfig;

/*
*@usage This class will retrive AMX rule data
*/
public class AmxSchemasrules {

    // Database connection 
    public static final String url = DBConfig.getUrl();
    public static final String user = "postgres";
    public static final String db_password = "admin@1234";
    public static final String table = "amxschemarules";

    static {
        String createTable = """
            CREATE TABLE IF NOT EXISTS amxschemarules (rulename VARCHAR(100),rulevalue TEXT);""";
        try {
            Class.forName("org.postgresql.Driver");  
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(createTable);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
	 /**
	 *@args String,String
	 *@return Map
	 *@usage this method will get amx Rules  
	 */
    public static Map<String, List<String>> getRules(String ruleName, String mapKey) {
        Map<String, List<String>> resultMap = new HashMap<>();
        List<String> values = new ArrayList<>();
        String sql = "SELECT rulevalue FROM amxschemarules WHERE rulename = ?";

        try (
            Connection conn = DriverManager.getConnection(url, user, db_password);
            PreparedStatement stmt = conn.prepareStatement(sql)
        ) {
            stmt.setString(1, ruleName); 

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String value = rs.getString("rulevalue");
                    if (value != null && !value.isEmpty()) {
                        for (String part : value.split("\\|")) {
                            values.add(part.trim());
                        }
                    }
                }
            }

            if (!values.isEmpty()) {
                resultMap.put(mapKey, values);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return resultMap;
    }
		 /**
	 *@args None
	 *@return Map
	 *@usage the below methods will retrive the basic data
	 */
    public static Map<String, List<String>> PersonAccess() {
        return getRules("PersonAccess", "Person Access");
    }

    public Map<String, List<String>> partAccess() {
        return getRules("PartAccess", "Part Access");
    }

    public Map<String, List<String>> partControl() {
        return getRules("PartControl", "Part Control");
    }

    public Map<String, List<String>> partStates() {
        return getRules("PartStates", "Part States");
    }

    public Map<String, List<String>> partControlStates() {
        return getRules("PartControlStates", "Part Control States");
    }
}
