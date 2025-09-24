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
  <h2>Change User Role</h2>
  <form method="post" action="changeRoleProcess.jsp">
    <label for="userId">User ID</label>
    <input id="userId" name="user_id" type="number" required>

    <label for="newRole">New Role</label>
    <select id="newRole" name="role" required onchange="toggleSpecialty()">
      <option value="member">member</option>
      <option value="trainer">trainer</option>
      <option value="admin">admin</option>
    </select>

    <div id="trainerSpecialty" style="display:none;margin-top:0.5rem;">
      <label for="specialty">Trainer Specialty</label>
      <input id="specialty" name="specialty" type="text" placeholder="e.g., Weight Training, Cardio, Yoga">
      <small class="muted">Only required when setting role to trainer.</small>
    </div>

    <div style="margin-top:1rem">
      <button type="submit">Update Role</button>
    </div>
  </form>
</div>
<script>
  function toggleSpecialty(){
    var role = document.getElementById('newRole').value;
    var box = document.getElementById('trainerSpecialty');
    box.style.display = role === 'trainer' ? 'block' : 'none';
  }
  // Initialize on load in case of browser back
  document.addEventListener('DOMContentLoaded', toggleSpecialty);
</script>
<%@ include file="../shared/footer.jsp" %>
