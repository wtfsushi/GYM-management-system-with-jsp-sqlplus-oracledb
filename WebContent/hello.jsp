<%@ page language="java" contentType="text/html; charset=UTF-8"
    import="java.sql.*, com.gymapp.util.DBConnection" %>
<%
    // Change this to your actual table name.
    // Note: USER is a reserved word in Oracle; if your table is named USER, use "\"USER\"" (with quotes).
    // Examples:
    // String table = "FITNESSDB.USERS";           // schema-qualified
    // String table = "\"USER\"";                  // if the table is literally named USER
    String table = "USERS";                        // default guess; adjust as needed

    String sql = "SELECT * FROM " + table + " ORDER BY 1";
    String error = null;
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>User List</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ccc; padding: 8px; }
    th { background: #f4f4f4; text-align: left; }
    caption { text-align: left; margin-bottom: 8px; font-weight: bold; }
    .error { color: #b00020; }
    .meta { color: #666; font-size: 12px; }
  </style>
</head>
<body>
<h1>Users</h1>

<%
try (Connection con = DBConnection.getConnection();
     Statement st = con.createStatement();
     ResultSet rs = st.executeQuery(sql)) {

    ResultSetMetaData md = rs.getMetaData();
    int cols = md.getColumnCount();
%>
  

  <table>
    <thead>
      <tr>
        <%
          for (int i = 1; i <= cols; i++) {
        %>
          <th><%= md.getColumnLabel(i) %></th>
        <%
          }
        %>
      </tr>
    </thead>
    <tbody>
      <%
        while (rs.next()) {
      %>
        <tr>
          <%
            for (int i = 1; i <= cols; i++) {
              Object val = rs.getObject(i);
          %>
            <td><%= (val != null ? val.toString() : "") %></td>
          <%
            }
          %>
        </tr>
      <%
        }
      %>
    </tbody>
  </table>
<%
} catch (SQLException e) {
%>
  <p class="error">Database error: <%= e.getMessage() %></p>
  <p class="meta">Tip: If your table is named USER, set table = "\"USER\"" or use a synonym.</p>
<%
}
%>
</body>
</html>
