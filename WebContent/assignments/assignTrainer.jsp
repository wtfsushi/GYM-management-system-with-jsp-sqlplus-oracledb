<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String _r = (String)session.getAttribute("role");
  if (_r == null || !_r.equalsIgnoreCase("admin")) {
    response.sendRedirect(request.getContextPath() + "/authentication/login.jsp");
    return;
  }
%>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>
<div class="container">
  <h2>Assign Trainer</h2>
  <form method="post" action="assignTrainerProcess.jsp">
    <label>Member ID</label>
    <input type="number" name="member_id" required>
    <label>Trainer ID</label>
    <input type="number" name="trainer_id" required>
    <div style="margin-top:1rem"><button type="submit">Assign</button></div>
  </form>
</div>
<%@ include file="../shared/footer.jsp" %>
