<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.gymapp.util.DBConnection" %>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>

<%
    String role = (String)session.getAttribute("role");
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect("../authentication/login.jsp");
    } else {
        // Get statistics from the database
        int totalMembers = 0;
        int totalTrainers = 0;
        double totalRevenue = 0;
    int pendingPayments = 0;
    // Recent activity: last 5 payments
    List<String> recentNames = new ArrayList<String>();
    List<Integer> recentUserIds = new ArrayList<Integer>();
    List<java.util.Date> recentDates = new ArrayList<java.util.Date>();
    List<Double> recentAmounts = new ArrayList<Double>();
    List<Integer> recentMonths = new ArrayList<Integer>();
        
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            
            // Count total members
            PreparedStatement psMem = con.prepareStatement("SELECT COUNT(*) as count FROM users WHERE role='member'");
            ResultSet rsMem = psMem.executeQuery();
            if(rsMem.next()) {
                totalMembers = rsMem.getInt("count");
            }
            rsMem.close();
            psMem.close();
            
            // Count total trainers
            PreparedStatement psTr = con.prepareStatement("SELECT COUNT(*) as count FROM users WHERE role='trainer'");
            ResultSet rsTr = psTr.executeQuery();
            if(rsTr.next()) {
                totalTrainers = rsTr.getInt("count");
            }
            rsTr.close();
            psTr.close();
            
            // Get total revenue from SUBSCRIBI_AUDITLOG (sum of amounts for inserted subscriptions)
            try {
                PreparedStatement psRev = con.prepareStatement(
                    "SELECT SUM(amount) AS total FROM subscribi_auditlog WHERE UPPER(TRIM(action)) = 'INSERT'"
                );
                ResultSet rsRev = psRev.executeQuery();
                if (rsRev.next() && rsRev.getObject("total") != null) {
                    totalRevenue = rsRev.getDouble("total");
                }
                rsRev.close();
                psRev.close();
            } catch (SQLException e) {
                // audit table might not exist yet
                totalRevenue = 0;
            }
            
            // Count pending payments - assuming status field in payments table
            try {
                PreparedStatement psPend = con.prepareStatement("SELECT COUNT(*) as count FROM payments WHERE status='pending'");
                ResultSet rsPend = psPend.executeQuery();
                if(rsPend.next()) {
                    pendingPayments = rsPend.getInt("count");
                }
                rsPend.close();
                psPend.close();
            } catch (SQLException e) {
                // Payments table might not exist yet
                pendingPayments = 0;
            }

            // Recent Activity: fetch last 5 payments from audit log
            boolean haveAny = false;
            try {
                PreparedStatement psList = con.prepareStatement(
                    "SELECT * FROM (" +
                    "  SELECT sa.user_id, sa.months, sa.amount, sa.action_date, " +
                    "         NVL(u.full_name, u.username) AS display_name " +
                    "  FROM subscribi_auditlog sa " +
                    "  LEFT JOIN users u ON u.user_id = sa.user_id " +
                    "  WHERE UPPER(TRIM(sa.action)) = 'INSERT' " +
                    "  ORDER BY sa.action_date DESC NULLS LAST, sa.audit_id DESC" +
                    ") WHERE ROWNUM <= 5"
                );
                ResultSet rsList = psList.executeQuery();
                while (rsList.next()) {
                    haveAny = true;
                    recentUserIds.add(rsList.getInt("user_id"));
                    java.sql.Timestamp ts = rsList.getTimestamp("action_date");
                    recentDates.add(ts != null ? new java.util.Date(ts.getTime()) : null);
                    recentNames.add(rsList.getString("display_name"));
                    recentAmounts.add(rsList.getObject("amount") != null ? rsList.getDouble("amount") : null);
                    recentMonths.add(rsList.getObject("months") != null ? rsList.getInt("months") : null);
                }
                rsList.close();
                psList.close();
            } catch (SQLException e) {
                // audit table missing or query failed
                e.printStackTrace();
            }

            // Fallback to subscriptions if audit returned nothing
            if (!haveAny) {
                try {
                    PreparedStatement psList2 = con.prepareStatement(
                        "SELECT * FROM (" +
                        "  SELECT s.user_id, s.months, s.amount, s.start_date AS action_date, " +
                        "         NVL(u.full_name, u.username) AS display_name " +
                        "  FROM subscriptions s " +
                        "  LEFT JOIN users u ON u.user_id = s.user_id " +
                        "  ORDER BY s.start_date DESC NULLS LAST, s.subscription_id DESC" +
                        ") WHERE ROWNUM <= 5"
                    );
                    ResultSet rsList2 = psList2.executeQuery();
                    while (rsList2.next()) {
                        haveAny = true;
                        recentUserIds.add(rsList2.getInt("user_id"));
                        java.sql.Timestamp ts = rsList2.getTimestamp("action_date");
                        recentDates.add(ts != null ? new java.util.Date(ts.getTime()) : null);
                        recentNames.add(rsList2.getString("display_name"));
                        recentAmounts.add(rsList2.getObject("amount") != null ? rsList2.getDouble("amount") : null);
                        recentMonths.add(rsList2.getObject("months") != null ? rsList2.getInt("months") : null);
                    }
                    rsList2.close();
                    psList2.close();
                } catch (SQLException ignore) {
                    // subscriptions table missing
                }
            }
        } catch (Exception e) {
            // Handle database errors gracefully
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
%>

<div class="container">
    <div class="dashboard-header">
        <div>
            <h2>Admin Dashboard</h2>
            <p class="dashboard-subtitle">Manage your fitness center operations</p>
        </div>
        <div class="dashboard-actions">
            <a href="../reports/paymentReport.jsp" class="btn btn-outline"><i class="fas fa-chart-bar"></i> View Reports</a>
        </div>
    </div>

    <!-- Stats Overview -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-users"></i></div>
            <div class="stat-details">
                <span class="stat-value"><%= totalMembers %></span>
                <span class="stat-label">Total Members</span>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-person-running"></i></div>
            <div class="stat-details">
                <span class="stat-value"><%= totalTrainers %></span>
                <span class="stat-label">Trainers</span>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-dollar-sign"></i></div>
            <div class="stat-details">
                <span class="stat-value">৳<%= String.format("%.2f", totalRevenue) %></span>
                <span class="stat-label">Total Revenue</span>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-clock"></i></div>
            <div class="stat-details">
                <span class="stat-value"><%= pendingPayments %></span>
                <span class="stat-label">Pending Payments</span>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="dashboard-section">
        <h3><i class="fas fa-bolt"></i> Quick Actions</h3>
        <div class="quick-actions">
            <a href="../admin/changeRole.jsp" class="action-card">
                <div class="action-icon"><i class="fas fa-user-tag"></i></div>
                <div class="action-text">
                    <h4>Change User Role</h4>
                    <p>Promote members to trainers or admins</p>
                </div>
            </a>
            <a href="../trainers/trainers.jsp" class="action-card">
                <div class="action-icon"><i class="fas fa-dumbbell"></i></div>
                <div class="action-text">
                    <h4>Manage Trainers</h4>
                    <p>View and edit trainer profiles</p>
                </div>
            </a>
            <a href="../assignments/assignTrainer.jsp" class="action-card">
                <div class="action-icon"><i class="fas fa-handshake"></i></div>
                <div class="action-text">
                    <h4>Assign Trainers</h4>
                    <p>Match members with appropriate trainers</p>
                </div>
            </a>
            <a href="../payments/payment.jsp" class="action-card">
                <div class="action-icon"><i class="fas fa-credit-card"></i></div>
                <div class="action-text">
                    <h4>Payments</h4>
                    <p>Process and track member payments</p>
                </div>
            </a>
        </div>
    </div>
    
    <!-- Recent Activity -->
    <div class="dashboard-section">
        <div class="section-header">
            <h3><i class="fas fa-history"></i> Recent Activity</h3>
            <a href="#" class="section-link">View All</a>
        </div>
        <div class="card">
            <table class="dashboard-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Activity</th>
                        <th>User</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("MMM dd, yyyy");
                    if (recentDates.size() == 0) {
                %>
                    <tr>
                        <td colspan="4" style="text-align:center;color:#999">No recent activity yet.</td>
                    </tr>
                <%
                    } else {
                        for (int i = 0; i < recentDates.size(); i++) {
                            String name = recentNames.get(i);
                            Integer uid = recentUserIds.get(i);
                            java.util.Date dt = recentDates.get(i);
                            Double amt = recentAmounts.get(i);
                            Integer mon = recentMonths.get(i);
                            String displayName = (name != null && name.length() > 0) ? name : ("User #" + (uid != null ? uid : 0));
                %>
                    <tr>
                        <td><%= dt != null ? df.format(dt) : "" %></td>
                        <td>New Member</td>
                        <td><%= displayName %></td>
                        <td>Registered new account</td>
                    </tr>
                <%
                        if (amt != null) {
                %>
                    <tr>
                        <td><%= dt != null ? df.format(dt) : "" %></td>
                        <td>Payment</td>
                        <td><%= displayName %></td>
                        <td>৳<%= String.format("%.2f", amt) %><%= (mon != null ? (" for " + mon + " month" + (mon > 1 ? "s" : "")) : "") %></td>
                    </tr>
                <%
                        }
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<% } %>
<%@ include file="../shared/footer.jsp" %>
