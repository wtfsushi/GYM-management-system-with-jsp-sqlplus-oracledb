package com.gymapp.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Oracle DB connection details
    private static final String URL = "jdbc:oracle:thin:@//localhost:1521/XEPDB1";
    private static final String USER = "fitnessdb";         // your Oracle username
    private static final String PASS = "nirvana123"; // your Oracle password

    public static Connection getConnection() throws SQLException {
        try {
            // Load Oracle JDBC Driver
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Oracle JDBC Driver not found. Make sure ojdbc jar is in WEB-INF/lib", e);
        }

        // Return the connection
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
