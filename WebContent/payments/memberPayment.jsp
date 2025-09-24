<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
String msg="";
if("POST".equalsIgnoreCase(request.getMethod())){
    int memberId = (int)session.getAttribute("member_id");
    double amount = Double.parseDouble(request.getParameter("amount"));
    int months = Integer.parseInt(request.getParameter("months"));

    Connection con = DBConnection.getConnection();
    PreparedStatement ps = con.prepareStatement(
      "INSERT INTO payments VALUES (payment_seq.NEXTVAL, ?, ?, SYSDATE, ?)"
    );
    ps.setInt(1, memberId);
    ps.setDouble(2, amount);
    ps.setInt(3, months);
    ps.executeUpdate();

    msg="Payment successful! Your subscription has been renewed.";
}
%>
<h2>Renew Subscription</h2>
<form method="post">
  Amount: <input type="text" name="amount" required><br>
  Months: <input type="number" name="months" value="1"><br>
  <button type="submit">Pay</button>
</form>
<p style="color:green;"><%= msg %></p>
