<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
String fullname = request.getParameter("fullname");
String email = request.getParameter("email");
String next = request.getParameter("next");

Integer newUserId = null;

try (Connection con = DBConnection.getConnection()) {
	// Create user with base role 'user'
	try (PreparedStatement ps = con.prepareStatement(
			"INSERT INTO users (username, password, full_name, email, role) VALUES (?,?,?,?, 'user')")) {
		ps.setString(1, username);
		ps.setString(2, password);
		ps.setString(3, fullname);
		ps.setString(4, email);
		ps.executeUpdate();
	}

	// Fetch the user_id back
	try (PreparedStatement ps2 = con.prepareStatement(
			"SELECT user_id FROM users WHERE username=?")) {
		ps2.setString(1, username);
		try (ResultSet rs = ps2.executeQuery()) {
			if (rs.next()) newUserId = rs.getInt(1);
		}
	}
} catch (SQLException e) {
	out.println("<p style='color:red;'>Registration failed: " + e.getMessage() + "</p>");
	out.println("<p><a href='register.jsp'>Back</a></p>");
	return;
}

if (newUserId != null) {
	// Auto-login and continue to next step if given
	session.setAttribute("member_id", newUserId);
	session.setAttribute("role", "user");
	session.setAttribute("fullname", fullname);
	session.setAttribute("username", username);

		if (next != null && next.trim().length() > 0) {
			response.sendRedirect(next);
			return;
		} else {
			// Default: send freshly registered basic users to their dashboard
			response.sendRedirect("../dashboard/userDashboard.jsp");
			return;
		}
} else {
	out.println("<p style='color:red;'>Registration failed (couldn't retrieve new user id).</p>");
	out.println("<p><a href='register.jsp'>Back</a></p>");
}
%>
