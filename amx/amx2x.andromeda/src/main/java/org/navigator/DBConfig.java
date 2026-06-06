package org.navigator;

import java.io.InputStream;
import java.util.Properties;

public class DBConfig {

    private static String appName;

    private static final Properties props = new Properties();

    static {
        try (InputStream input =DBConfig.class.getClassLoader().getResourceAsStream("config.properties")) {

            props.load(input);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void setAppName(String name) {
        appName = name;
    }

    public static String getDbName() {
    	
    	return props.getProperty(appName+".db");
    }

    public static String getUrl() {

        String dbName = getDbName();

        return "jdbc:postgresql://localhost:5432/" + dbName;
    }
}