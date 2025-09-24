<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");

Connection con = DBConnection.getConnection();
PreparedStatement ps = con.prepareStatement(
	"SELECT user_id AS member_id, role, full_name AS fullname FROM users WHERE username=? AND password=?"
);
ps.setString(1, username);
ps.setString(2, password);
ResultSet rs = ps.executeQuery();

if(rs.next()){
	session.setAttribute("member_id", rs.getInt("member_id"));
	session.setAttribute("role", rs.getString("role"));
	session.setAttribute("fullname", rs.getString("fullname"));
	session.setAttribute("username", username); // Store the username in the session
	// Optional attributes not present in USERS table
	session.setAttribute("subscription_end", null);
	session.setAttribute("status", null);

	String role = rs.getString("role");
	if("admin".equalsIgnoreCase(role))
		response.sendRedirect("../dashboard/adminDashboard.jsp");
	else if("trainer".equalsIgnoreCase(role))
		response.sendRedirect("../dashboard/trainerDashboard.jsp");
	else
		response.sendRedirect("../dashboard/memberDashboard.jsp");
} else {
	out.println("<p style='color:red;'>Invalid login</p>");
	out.println("<a href='login.jsp'>Try again</a>");
}
%>
