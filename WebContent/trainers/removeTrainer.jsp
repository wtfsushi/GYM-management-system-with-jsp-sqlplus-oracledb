<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
  String role = (String)session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("trainers.jsp?err=" + java.net.URLEncoder.encode("Unauthorized.", "UTF-8"));
    return;
  }

  String userIdStr = request.getParameter("user_id");
  if (userIdStr == null || userIdStr.isEmpty()) {
    response.sendRedirect("trainers.jsp?err=" + java.net.URLEncoder.encode("Missing user id.", "UTF-8"));
    return;
  }
  int userId = Integer.parseInt(userIdStr);

  Connection con = null;
  PreparedStatement ps1 = null;
  PreparedStatement ps2 = null;
  try {
    con = DBConnection.getConnection();
    con.setAutoCommit(false);

    // Demote user to member (or keep as is if you prefer deletion)
    ps1 = con.prepareStatement("UPDATE users SET role='member' WHERE user_id=?");
    ps1.setInt(1, userId);
    ps1.executeUpdate();

    // Remove from trainers
    ps2 = con.prepareStatement("DELETE FROM trainers WHERE user_id=?");
    ps2.setInt(1, userId);
    ps2.executeUpdate();

    con.commit();
    response.sendRedirect("trainers.jsp?msg=" + java.net.URLEncoder.encode("Trainer removed (demoted to member).", "UTF-8"));
  } catch (Exception e) {
    if (con != null) try { con.rollback(); } catch (SQLException ignore) {}
    e.printStackTrace();
    response.sendRedirect("trainers.jsp?err=" + java.net.URLEncoder.encode("Error removing trainer.", "UTF-8"));
  } finally {
    if (ps2 != null) try { ps2.close(); } catch (SQLException ignore) {}
    if (ps1 != null) try { ps1.close(); } catch (SQLException ignore) {}
    if (con != null) try { con.close(); } catch (SQLException ignore) {}
  }
%>