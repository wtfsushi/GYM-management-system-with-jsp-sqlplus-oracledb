<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Invalidate the session
    session.invalidate();
    
    // Redirect to the home page
    response.sendRedirect(request.getContextPath() + "/index.jsp");
%>