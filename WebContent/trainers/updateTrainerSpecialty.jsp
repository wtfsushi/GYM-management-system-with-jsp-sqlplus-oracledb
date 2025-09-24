<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
  String role = (String)session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("trainers.jsp?err=" + java.net.URLEncoder.encode("Unauthorized.", "UTF-8"));
    return;
  }

  String userIdStr = request.getParameter("user_id");
  String specialty = request.getParameter("specialty");

  if (userIdStr == null || userIdStr.isEmpty()) {
    response.sendRedirect("trainers.jsp?err=" + java.net.URLEncoder.encode("Missing user id.", "UTF-8"));
    return;
  }

  int userId = Integer.parseInt(userIdStr);
  Connection con = null;
  PreparedStatement ps = null;
  try {
    con = DBConnection.getConnection();
    ps = con.prepareStatement("UPDATE trainers SET specialty = ? WHERE user_id = ?");
    ps.setString(1, specialty);
    ps.setInt(2, userId);
    int updated = ps.executeUpdate();
    if (updated > 0) {
      response.sendRedirect("trainers.jsp?msg=" + java.net.URLEncoder.encode("Specialty updated.", "UTF-8"));
    } else {
      response.sendRedirect("trainers.jsp?err=" + java.net.URLEncoder.encode("Trainer not found.", "UTF-8"));
    }
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("trainers.jsp?err=" + java.net.URLEncoder.encode("Error updating specialty.", "UTF-8"));
  } finally {
    if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
    if (con != null) try { con.close(); } catch (SQLException ignore) {}
  }
%>