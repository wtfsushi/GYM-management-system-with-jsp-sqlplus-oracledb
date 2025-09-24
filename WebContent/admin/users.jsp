<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
  String role = (String)session.getAttribute("role");
  if (role == null || !role.equalsIgnoreCase("admin")) {
    response.sendRedirect(request.getContextPath() + "/authentication/login.jsp");
    return;
  }
%>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>
<div class="container">
  <h2>All Users</h2>
  <p style="color: <%= request.getParameter("err")!=null?"red":"green" %>"><%= request.getParameter("err")!=null?request.getParameter("err"):request.getParameter("msg")!=null?request.getParameter("msg"):"" %></p>
  <table class="table">
    <thead>
      <tr>
        <th>ID</th><th>Username</th><th>Full Name</th><th>Email</th><th>Role</th><th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <%
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT user_id, username, full_name, email, role FROM users ORDER BY user_id");
             ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
      %>
      <tr>
        <td><%= rs.getInt("user_id") %></td>
        <td><%= rs.getString("username") %></td>
        <td><%= rs.getString("full_name") %></td>
        <td><%= rs.getString("email") %></td>
        <td><%= rs.getString("role") %></td>
        <td>
          <form method="post" action="deleteUser.jsp" onsubmit="return confirm('Remove this user? This cannot be undone.');" style="display:inline">
            <input type="hidden" name="user_id" value="<%= rs.getInt("user_id") %>">
            <button type="submit" class="btn btn-danger">Remove</button>
          </form>
        </td>
      </tr>
      <%
          }
        } catch (SQLException e) {
          out.println("<tr><td colspan='6' style='color:red'>"+e.getMessage()+"</td></tr>");
        }
      %>
    </tbody>
  </table>
</div>
<%@ include file="../shared/footer.jsp" %>
