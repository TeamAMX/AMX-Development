package org.navigator;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * @class DataBaseConnection
 * @usage This class is used to establish a connection to the PostgreSQL database.
 *        It provides a static method to get a database connection using JDBC.
 */
public class DataBaseConnection {
    public static final String url = "jdbc:postgresql://localhost:5432/amx2xdev.Andromeda";
    public static final String user = "postgres";
    public static final String db_password= "admin@1234";

    public static Connection getConnection() throws Exception {
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(url, user, db_password);
        
    }
}

