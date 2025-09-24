<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
Connection con = DBConnection.getConnection();
Statement st = con.createStatement();

ResultSet rs = st.executeQuery(
  "SELECT u.full_name, NVL(SUM(p.amount),0) total_paid " +
  "FROM users u LEFT JOIN payments p ON u.user_id = p.member_id " +
  "GROUP BY u.full_name"
);
out.println("<table border='1'><tr><th>Member</th><th>Total Paid</th></tr>");
while(rs.next()){
  out.println("<tr><td>"+rs.getString(1)+"</td><td>"+rs.getDouble(2)+"</td></tr>");
}
out.println("</table>");
%>
