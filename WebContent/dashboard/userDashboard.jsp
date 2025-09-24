<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>
<div class="container">
<%
  String role = (String)session.getAttribute("role");
  if (role == null) {
    response.sendRedirect("../authentication/login.jsp");
    return;
  }
  if ("member".equalsIgnoreCase(role)) {
    response.sendRedirect("memberDashboard.jsp");
    return;
  }
  if ("trainer".equalsIgnoreCase(role)) {
    response.sendRedirect("trainerDashboard.jsp");
    return;
  }
%>
  <h2>User Dashboard</h2>
  <p>Welcome <%= session.getAttribute("fullname") %></p>
  <p>Your account is active as a basic user. To access member features, please subscribe.</p>
  <a href="../subscriptions/start.jsp" class="btn btn-primary">Subscribe Now</a>
</div>
<%@ include file="../shared/footer.jsp" %>
