<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>
<div class="container">
  <%
    String role = (String)session.getAttribute("role");
    if (role == null || !"admin".equalsIgnoreCase(role)) {
      out.println("<div class='card'><p style='color:#ff4d4f'>Unauthorized. Admins only. <a href='../authentication/login.jsp'>Login</a></p></div>");
    } else {
      String q = request.getParameter("q");
      String msg = request.getParameter("msg");
      String err = request.getParameter("err");
  %>

  <% if (msg != null) { %>
    <div class="card" style="border-color:#1f8b4c">
      <p style="color:#22c55e; margin:0"><%= msg %></p>
    </div>
  <% } %>
  <% if (err != null) { %>
    <div class="card" style="border-color:#7a2627">
      <p style="color:#ff4d4f; margin:0"><%= err %></p>
    </div>
  <% } %>

  <div class="dashboard-header">
    <div>
      <h2>Manage Trainers</h2>
      <p class="dashboard-subtitle">Search, update specialties, or remove trainers</p>
    </div>
    <form method="get" class="card" style="display:flex; gap:.5rem; align-items:center; padding:.5rem 0.75rem">
      <input type="text" name="q" value="<%= q != null ? q : "" %>" placeholder="Search by name or email" style="min-width:260px" />
      <button type="submit" class="btn">Search</button>
      <a href="trainers.jsp" class="btn btn-outline">Reset</a>
    </form>
  </div>

  <div class="card">
    <table class="table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Specialty</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <%
          Connection con = null;
          PreparedStatement ps = null;
          ResultSet rs = null;
          try {
            con = DBConnection.getConnection();
            String sql = "SELECT u.user_id, u.full_name, u.email, t.specialty " +
                         "FROM users u JOIN trainers t ON u.user_id = t.user_id " +
                         (q != null && !q.trim().isEmpty() ? "WHERE LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ? " : "") +
                         "ORDER BY u.full_name";
            ps = con.prepareStatement(sql);
            if (q != null && !q.trim().isEmpty()) {
              String like = "%" + q.toLowerCase() + "%";
              ps.setString(1, like);
              ps.setString(2, like);
            }
            rs = ps.executeQuery();
            boolean any = false;
            while (rs.next()) {
              any = true;
              int uid = rs.getInt("user_id");
              String name = rs.getString("full_name");
              String email = rs.getString("email");
              String specialty = rs.getString("specialty");
        %>
        <tr>
          <td><%= uid %></td>
          <td><%= name %></td>
          <td><%= email %></td>
          <td>
            <form method="post" action="updateTrainerSpecialty.jsp" style="display:flex; gap:.5rem; align-items:center">
              <input type="hidden" name="user_id" value="<%= uid %>" />
              <input type="text" name="specialty" value="<%= specialty != null ? specialty : "" %>" placeholder="e.g., Strength, Yoga" />
              <button type="submit" class="btn btn-success">Update</button>
            </form>
          </td>
          <td>
            <form method="post" action="removeTrainer.jsp" onsubmit="return confirm('Are you sure you want to remove this trainer?');" style="display:inline">
              <input type="hidden" name="user_id" value="<%= uid %>" />
              <button type="submit" class="btn btn-danger">Remove</button>
            </form>
          </td>
        </tr>
        <%
            }
            if (!any) {
        %>
        <tr>
          <td colspan="5" class="muted">No trainers found.</td>
        </tr>
        <%
            }
          } catch (Exception e) {
        %>
        <tr>
          <td colspan="5" class="muted">Error loading trainers.</td>
        </tr>
        <%
            e.printStackTrace();
          } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            if (con != null) try { con.close(); } catch (SQLException ignore) {}
          }
        %>
      </tbody>
    </table>
  </div>

  <% } %>
</div>
<%@ include file="../shared/footer.jsp" %>
