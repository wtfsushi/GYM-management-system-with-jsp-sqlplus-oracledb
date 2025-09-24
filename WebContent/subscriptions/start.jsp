<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // Entry point for Subscribe button.
  // If not logged in, send to registration with next pointing back here -> subscribe.jsp
  Object uid = session.getAttribute("member_id");
  if (uid == null) {
    String next = request.getContextPath() + "/subscriptions/subscribe.jsp";
    response.sendRedirect(request.getContextPath() + "/authentication/register.jsp?next=" + java.net.URLEncoder.encode(next, "UTF-8"));
  } else {
    response.sendRedirect("subscribe.jsp");
  }
%>
