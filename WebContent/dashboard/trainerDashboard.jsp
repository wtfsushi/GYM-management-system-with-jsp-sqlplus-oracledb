<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>
<div class="container">
    <h2>Trainer Dashboard</h2>
    <%
        Integer userId = (Integer)session.getAttribute("member_id");
        String role = (String)session.getAttribute("role");
        String fullname = (String)session.getAttribute("fullname");
        if (userId == null || role == null || !"trainer".equalsIgnoreCase(role)) {
            out.println("<p style='color:red;'>Not authenticated as trainer. Please <a href='../authentication/login.jsp'>login</a>.</p>");
        } else {
            String specialty = null;
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("SELECT specialty FROM trainers WHERE user_id = ?");
                ps.setInt(1, userId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    specialty = rs.getString(1);
                }
            } catch (SQLException e) {
                out.println("<p style='color:red;'>Error loading trainer profile: " + e.getMessage() + "</p>");
            } finally {
                try { if (rs != null) rs.close(); } catch(Exception ignore) {}
                try { if (ps != null) ps.close(); } catch(Exception ignore) {}
                try { if (con != null) con.close(); } catch(Exception ignore) {}
            }
    %>
        <p>Welcome, <%= (fullname != null && !fullname.isEmpty()) ? fullname : "Trainer" %></p>
        <p><strong>Specialty:</strong> <%= (specialty != null && !specialty.isEmpty()) ? specialty : "Not set yet" %></p>
        <hr>
        <p class="muted">Assigned members list can be added here later.</p>
    <%
        }
    %>
</div>
<%@ include file="../shared/footer.jsp" %>
