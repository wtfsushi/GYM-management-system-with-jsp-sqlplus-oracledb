<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>
<div class="container">
    <%
        String role = (String)session.getAttribute("role");
        if (role == null || !"member".equalsIgnoreCase(role)) {
            out.println("<p style='color:red;'>Unauthorized. Members only. <a href='../authentication/login.jsp'>Login</a></p>");
        } else {
    %>
    <h2>Member Dashboard</h2>
    <p>Welcome <%= session.getAttribute("fullname") %></p>
    <%
        String status = (String)session.getAttribute("status");
        java.sql.Date endDate = (java.sql.Date)session.getAttribute("subscription_end");
  
        if(status==null || endDate==null || endDate.before(new java.util.Date())){
    %>
        <p style="color:red;">Subscription expired. <a href="../payments/memberPayment.jsp">Renew Now</a></p>
    <%
    } else {
    %>
        <p style="color:green;">Active until <%= endDate %></p>
    <%
    }
    %>
    <%
        }
    %>
</div>
<%@ include file="../shared/footer.jsp" %>
