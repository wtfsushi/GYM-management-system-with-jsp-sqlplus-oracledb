<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
try (Connection con = DBConnection.getConnection()) {
    out.println(" Connected successfully tooo: " + con.getMetaData().getURL());
} catch(Exception e) {
    out.println("❌ Database error: " + e.getMessage());
}
%>
