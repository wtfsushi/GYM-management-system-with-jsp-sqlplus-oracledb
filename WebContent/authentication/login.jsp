<%@ include file="../shared/header.jsp" %>

<div class="auth-container">
  <div class="auth-box">
    <div class="auth-header">
      <h2>Welcome Back</h2>
    </div>
    <div class="auth-body">
      <div style="margin-bottom:1rem">
        <a class="link-back" href="<%= request.getContextPath() %>/index.jsp"><i class="fas fa-arrow-left"></i> Go back</a>
      </div>
      <form method="post" action="loginProcess.jsp">
        <div class="form-group">
          <label for="username">Username</label>
          <input type="text" id="username" name="username" required>
        </div>
        <div class="form-group">
          <label for="password">Password</label>
          <input type="password" id="password" name="password" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Sign In</button>
      </form>
    </div>
    <div class="auth-footer">
      Don't have an account? <a href="register.jsp">Create one now</a>
    </div>
  </div>
</div>

<%@ include file="../shared/footer.jsp" %>
