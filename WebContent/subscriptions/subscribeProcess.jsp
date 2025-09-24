<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
Integer memberId = (Integer)session.getAttribute("member_id");
if (memberId == null) {
  response.sendRedirect("start.jsp");
  return;
}

int months = Math.max(1, Integer.parseInt(request.getParameter("months")));
double amount = months * 2000.0; // server-side source of truth

Connection con = null;
try {
  con = DBConnection.getConnection();
  con.setAutoCommit(false);

  // Calculate start/end dates in Oracle: start = SYSDATE, end = ADD_MONTHS(SYSDATE, months)
  // 1) Insert into subscriptions table
  PreparedStatement ps1 = con.prepareStatement(
    "INSERT INTO subscriptions (subscription_id, user_id, start_date, end_date, months, amount) " +
    "VALUES (subscriptions_seq.NEXTVAL, ?, SYSDATE, ADD_MONTHS(SYSDATE, ?), ?, ?)"
  );
  ps1.setInt(1, memberId);
  ps1.setInt(2, months);
  ps1.setInt(3, months);
  ps1.setDouble(4, amount);
  ps1.executeUpdate();
  ps1.close();

  // 2) Record a payment (optional but handy for reports)
  try (PreparedStatement ps2 = con.prepareStatement(
      "INSERT INTO payments (payment_id, member_id, amount, payment_date, months) " +
      "VALUES (payment_seq.NEXTVAL, ?, ?, SYSDATE, ?)")) {
    ps2.setInt(1, memberId);
    ps2.setDouble(2, amount);
    ps2.setInt(3, months);
    ps2.executeUpdate();
  } catch (SQLException ignore) {
    // Some projects may not have payments table/seq; ignore if missing.
  }

  // 3) Update role to member if currently user
  try (PreparedStatement ps3 = con.prepareStatement(
      "UPDATE users SET role='member' WHERE user_id=? AND LOWER(role) IN ('user','guest')")) {
    ps3.setInt(1, memberId);
    ps3.executeUpdate();
  }

  // Fetch latest end_date to store in session for dashboard display
  java.sql.Date endDate = null;
  try (PreparedStatement ps4 = con.prepareStatement(
      "SELECT MAX(end_date) FROM subscriptions WHERE user_id=?")) {
    ps4.setInt(1, memberId);
    try (ResultSet rs4 = ps4.executeQuery()) {
      if (rs4.next()) endDate = rs4.getDate(1);
    }
  }

  con.commit();

  // Update session state so dashboard doesn't ask to login again
  session.setAttribute("role", "member");
  if (endDate != null) session.setAttribute("subscription_end", endDate);
  session.setAttribute("status", "active");

  response.sendRedirect(request.getContextPath() + "/dashboard/memberDashboard.jsp");
  return;
} catch (SQLException e) {
  if (con != null) try { con.rollback(); } catch (SQLException ex) {}
  out.println("<p style='color:red;'>Subscription error: " + e.getMessage() + "</p>");
  out.println("<p><a href='subscribe.jsp'>Back</a></p>");
} finally {
  if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException ex) {}
}
%>
