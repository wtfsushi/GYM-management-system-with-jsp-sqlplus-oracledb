<%@ include file="../shared/header.jsp" %>

<div class="auth-container">
  <div class="auth-box">
    <div class="auth-header">
      <h2>Create Account</h2>
    </div>
    <div class="auth-body">
      <div style="margin-bottom:1rem">
        <a class="link-back" href="<%= request.getContextPath() %>/index.jsp"><i class="fas fa-arrow-left"></i> Go back</a>
      </div>
      <form method="post" action="registerProcess.jsp">
        <input type="hidden" name="next" value="<%= request.getParameter("next") == null ? "" : request.getParameter("next") %>">
        <div class="form-group">
          <label for="username">Username</label>
          <input type="text" id="username" name="username" required>
        </div>
        <div class="form-group">
          <label for="password">Password</label>
          <input type="password" id="password" name="password" required>
        </div>
        <div class="form-group">
          <label for="fullname">Full Name</label>
          <input type="text" id="fullname" name="fullname" required>
        </div>
        <div class="form-group">
          <label for="email">Email</label>
          <input type="email" id="email" name="email" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Create Account</button>
      </form>
    </div>
    <div class="auth-footer">
      Already have an account? <a href="login.jsp">Sign in</a>
    </div>
  </div>
</div>

<%@ include file="../shared/footer.jsp" %>
