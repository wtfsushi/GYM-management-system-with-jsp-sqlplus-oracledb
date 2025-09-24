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
	// Populate subscription_end if available
	java.sql.Date endDate = null;
	try {
		PreparedStatement ps2 = con.prepareStatement("SELECT MAX(end_date) FROM subscriptions WHERE user_id=?");
		ps2.setInt(1, rs.getInt("member_id"));
		ResultSet rs2 = ps2.executeQuery();
		if (rs2.next()) endDate = rs2.getDate(1);
		rs2.close(); ps2.close();
	} catch (SQLException ignore) {}
	session.setAttribute("subscription_end", endDate);
	session.setAttribute("status", endDate == null ? null : (endDate.after(new java.util.Date()) ? "active" : "expired"));

	String role = rs.getString("role");
	if("admin".equalsIgnoreCase(role))
		response.sendRedirect("../dashboard/adminDashboard.jsp");
	else if("trainer".equalsIgnoreCase(role))
		response.sendRedirect("../dashboard/trainerDashboard.jsp");
	else if("member".equalsIgnoreCase(role))
		response.sendRedirect("../dashboard/memberDashboard.jsp");
	else
		response.sendRedirect("../dashboard/userDashboard.jsp");
} else {
	out.println("<p style='color:red;'>Invalid login</p>");
	out.println("<a href='login.jsp'>Try again</a>");
}
%>
