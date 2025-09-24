<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
String _r = (String)session.getAttribute("role");
if (_r == null || !_r.equalsIgnoreCase("admin")) {
  response.sendRedirect(request.getContextPath() + "/authentication/login.jsp");
  return;
}

int memberId = Integer.parseInt(request.getParameter("member_id"));
int trainerId = Integer.parseInt(request.getParameter("trainer_id"));

try (Connection con = DBConnection.getConnection();
     CallableStatement cs = con.prepareCall("{call assign_trainer_proc(?,?)}")) {
  cs.setInt(1, memberId);
  cs.setInt(2, trainerId);
  cs.execute();
  out.println("<p style='color:green;'>Trainer assigned.</p>");
  out.println("<p><a href='assignTrainer.jsp'>Back</a> | <a href='../dashboard/adminDashboard.jsp'>Dashboard</a></p>");
} catch (SQLException e) {
  out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
  out.println("<p><a href='assignTrainer.jsp'>Back</a></p>");
}
%>
