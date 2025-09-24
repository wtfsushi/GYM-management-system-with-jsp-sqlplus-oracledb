<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
String fullname = request.getParameter("fullname");
String email = request.getParameter("email");

Connection con = DBConnection.getConnection();
PreparedStatement ps = con.prepareStatement(
	"INSERT INTO users (username, password, full_name, email, role) VALUES (?,?,?,?, 'member')"
);
ps.setString(1, username);
ps.setString(2, password);
ps.setString(3, fullname);
ps.setString(4, email);
ps.executeUpdate();

out.println("<p style='color:green;'>Registration successful! <a href='login.jsp'>Login here</a></p>");
%>
