<%@ page contentType="text/html; charset=UTF-8" %>
<nav class="top-nav">
    <ul>
        <li><a href="<%= request.getContextPath() %>/index.jsp"><i class="fas fa-home"></i> Home</a></li>
        
        <% 
        String navRole = (String)session.getAttribute("role");
        String navUsername = (String)session.getAttribute("username");
        String navFullname = (String)session.getAttribute("fullname");
        
        if (navRole != null && navUsername != null) { 
            // User is logged in
            String dashboardLink = "";
            String dashboardIcon = "";
            
            if ("admin".equals(navRole)) {
                dashboardLink = request.getContextPath() + "/dashboard/adminDashboard.jsp";
                dashboardIcon = "fa-user-shield";
            } else if ("trainer".equals(navRole)) {
                dashboardLink = request.getContextPath() + "/dashboard/trainerDashboard.jsp";
                dashboardIcon = "fa-person-running";
            } else {
                dashboardLink = request.getContextPath() + "/dashboard/memberDashboard.jsp";
                dashboardIcon = "fa-user";
            }
        %>
            <li><a href="<%= dashboardLink %>"><i class="fas <%= dashboardIcon %>"></i> <%= navRole.substring(0, 1).toUpperCase() + navRole.substring(1) %> Dashboard</a></li>
            <li class="nav-spacer"></li>
            <li><a href="#" class="nav-user"><i class="fas fa-user-circle"></i> <%= navFullname != null ? navFullname : navUsername %></a></li>
            <li><a href="<%= request.getContextPath() %>/authentication/logout.jsp" class="nav-logout"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        <% } else { 
            // User is not logged in
        %>
            <li class="nav-spacer"></li>
            <li><a href="<%= request.getContextPath() %>/authentication/login.jsp"><i class="fas fa-sign-in-alt"></i> Login</a></li>
            <li><a href="<%= request.getContextPath() %>/authentication/register.jsp"><i class="fas fa-user-plus"></i> Register</a></li>
        <% } %>
    </ul>
</nav>
