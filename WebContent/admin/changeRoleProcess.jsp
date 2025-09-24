<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
String _r = (String)session.getAttribute("role");
if (_r == null || !_r.equalsIgnoreCase("admin")) {
  response.sendRedirect(request.getContextPath() + "/authentication/login.jsp");
  return;
}

request.setCharacterEncoding("UTF-8");
int userId = Integer.parseInt(request.getParameter("user_id"));
String role = request.getParameter("role");
String specialty = request.getParameter("specialty");

try (Connection con = DBConnection.getConnection();
     CallableStatement cs = con.prepareCall("{ call set_user_role(?, ?, ?) }");) {

    cs.setInt(1, userId);
    cs.setString(2, role);
    cs.setString(3, specialty);
    cs.execute();

    out.println("<p style='color:green;'>Role updated successfully.</p>");
    out.println("<p><a href='changeRole.jsp'>Back</a> | <a href='../dashboard/adminDashboard.jsp'>Dashboard</a></p>");
} catch (SQLException e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    out.println("<p><a href='changeRole.jsp'>Back</a></p>");
}
%>
