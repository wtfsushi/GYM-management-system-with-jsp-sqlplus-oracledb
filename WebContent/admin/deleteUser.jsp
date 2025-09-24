<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
  String role = (String)session.getAttribute("role");
  if (role == null || !role.equalsIgnoreCase("admin")) {
    response.sendRedirect(request.getContextPath() + "/authentication/login.jsp");
    return;
  }

  String idStr = request.getParameter("user_id");
  if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("users.jsp?err=" + java.net.URLEncoder.encode("Missing user id.", "UTF-8"));
    return;
  }

  int userId = Integer.parseInt(idStr);
  Connection con = null;
  try {
    con = DBConnection.getConnection();
    con.setAutoCommit(false);

    // Delete dependents first to avoid FK issues
    String[] deletes = new String[]{
      "DELETE FROM trainers WHERE user_id=?",
      "DELETE FROM subscriptions WHERE user_id=?",
      "DELETE FROM subscribi_auditlog WHERE user_id=?",
      // Payments may use USER_ID or MEMBER_ID depending on schema revisions; try both
      "DELETE FROM payments WHERE user_id=?",
      "DELETE FROM payments WHERE member_id=?",
      // In case these log tables have FKs to USERS, clear existing rows first
      "DELETE FROM created_trainer_log WHERE user_id=?",
      "DELETE FROM audit_log WHERE user_id=?"
    };
    for (String sql : deletes) {
      try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, userId);
        try { ps.executeUpdate(); } catch (SQLException ignore) { /* table may not exist */ }
      }
    }

    // Finally delete user
    int affected;
    try (PreparedStatement ps = con.prepareStatement("DELETE FROM users WHERE user_id=?")) {
      ps.setInt(1, userId);
      affected = ps.executeUpdate();
    }

    con.commit();
    String msg = affected>0 ? "User removed." : "User not found.";
    response.sendRedirect("users.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
  } catch (SQLException e) {
    if (con != null) try { con.rollback(); } catch (SQLException ex) {}
    response.sendRedirect("users.jsp?err=" + java.net.URLEncoder.encode("Error removing user: "+e.getMessage(), "UTF-8"));
  } finally {
    if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException ex) {}
  }
%>
