# Gym Management System (JSP + Oracle)

A starter JSP/Servlet web app scaffolded for a university project with Oracle DB. It includes placeholder pages, shared layout, and a simple Oracle `DBConnection` utility.

## Requirements
- Java 8+ (11+ recommended)
- Apache Tomcat 9/10 (or any Servlet 3.1+ container)
- Oracle Database (XE is fine)
- Oracle JDBC driver (ojdbc8.jar)

## Setup
1. Place `ojdbc8.jar` into `WebContent/WEB-INF/lib/` or your Tomcat `lib` directory.
2. Adjust connection defaults in `src/com/gymapp/util/DBConnection.java` or set environment variables:
   - `ORACLE_URL` (e.g., `jdbc:oracle:thin:@//localhost:1521/XEPDB1`)
   - `ORACLE_USER`
   - `ORACLE_PASSWORD`
3. Deploy to Tomcat:
   - Create a Dynamic Web Project or configure your server to point to `GymProject` context.
   - Ensure `WebContent` is the web root.
4. Open in browser: `/authentication/login.jsp`

## Next Steps
- Add Servlets for login/registration and dashboard routing.
- Create Oracle schema and PL/SQL (triggers, procedures, cursor demo) in `sql/`.
- Implement role-based session filter.

## Structure
```
GymProject/
  src/com/gymapp/util/DBConnection.java
  WebContent/
    authentication/...
    dashboard/...
    payments/...
    assignments/...
    reports/...
    shared/...
    css/style.css
    WEB-INF/web.xml
```

## Notes
- This scaffold is intentionally minimal; wire it to real data using JDBC + Servlets.