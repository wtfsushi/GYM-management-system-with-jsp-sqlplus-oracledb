<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
String _r = (String)session.getAttribute("role");
if (_r == null || !_r.equalsIgnoreCase("admin")) {
  response.sendRedirect(request.getContextPath() + "/authentication/login.jsp");
  return;
}

int memberId = Integer.parseInt(request.getParameter("member_id"));
double amount = Double.parseDouble(request.getParameter("amount"));
int months = Integer.parseInt(request.getParameter("months"));

try (Connection con = DBConnection.getConnection();
     PreparedStatement ps = con.prepareStatement(
       "INSERT INTO payments VALUES (payment_seq.NEXTVAL, ?, ?, SYSDATE, ?)"
     )) {
  ps.setInt(1, memberId);
  ps.setDouble(2, amount);
  ps.setInt(3, months);
  ps.executeUpdate();
  out.println("<p style='color:green;'>Payment recorded.</p>");
  out.println("<p><a href='payment.jsp'>Back</a> | <a href='../dashboard/adminDashboard.jsp'>Dashboard</a></p>");
} catch (SQLException e) {
  out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
  out.println("<p><a href='payment.jsp'>Back</a></p>");
}
%>
