<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, com.gymapp.util.DBConnection" %>
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
    // Recent activity variables (newest member + their payment)
    String newestMemberName = null;
    java.util.Date newestMemberDate = null;
    Double newestPaymentAmount = null;
    Integer newestPaymentMonths = null;
    java.util.Date newestPaymentDate = null;
    boolean hasLatestActivity = false;
    Integer newestUserId = null;
        
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

            // Recent Activity: newest member and their payment (use latest audit row)
            try {
                // Step 1: get latest audit_id for subscription insert
                Integer latestAuditId = null;
                PreparedStatement psMax = con.prepareStatement(
                    "SELECT MAX(audit_id) AS max_id FROM subscribi_auditlog WHERE UPPER(TRIM(action)) = 'INSERT'"
                );
                ResultSet rsMax = psMax.executeQuery();
                if (rsMax.next() && rsMax.getObject("max_id") != null) {
                    latestAuditId = rsMax.getInt("max_id");
                }
                rsMax.close();
                psMax.close();

                if (latestAuditId != null) {
                    // Step 2: fetch that audit row with user display name
                    PreparedStatement psRow = con.prepareStatement(
                        "SELECT sa.subscription_id, sa.user_id, sa.months, sa.amount, sa.action_date, " +
                        "       NVL(u.full_name, u.username) AS display_name " +
                        "FROM subscribi_auditlog sa " +
                        "LEFT JOIN users u ON u.user_id = sa.user_id " +
                        "WHERE sa.audit_id = ?"
                    );
                    psRow.setInt(1, latestAuditId);
                    ResultSet rsRow = psRow.executeQuery();
                    if (rsRow.next()) {
                        hasLatestActivity = true;
                        newestUserId = rsRow.getInt("user_id");
                        newestMemberName = rsRow.getString("display_name");
                        java.sql.Timestamp ad = rsRow.getTimestamp("action_date");
                        newestMemberDate = ad != null ? new java.util.Date(ad.getTime()) : null;
                        newestPaymentDate = newestMemberDate;
                        newestPaymentAmount = rsRow.getObject("amount") != null ? rsRow.getDouble("amount") : null;
                        newestPaymentMonths = rsRow.getObject("months") != null ? rsRow.getInt("months") : null;
                    }
                    rsRow.close();
                    psRow.close();
                }
            } catch (SQLException e) {
                // No audit table or rows, or SQL not supported
                e.printStackTrace();
            }

            // Fallback: if no audit activity was found, use newest subscription directly
            if (!hasLatestActivity) {
                try {
                    PreparedStatement psLatestSub = con.prepareStatement(
                        "SELECT * FROM (" +
                        "  SELECT s.subscription_id, s.user_id, s.months, s.amount, s.start_date, " +
                        "         NVL(u.full_name, u.username) AS display_name " +
                        "  FROM subscriptions s " +
                        "  LEFT JOIN users u ON u.user_id = s.user_id " +
                        "  ORDER BY s.start_date DESC NULLS LAST, s.subscription_id DESC" +
                        ") WHERE ROWNUM = 1"
                    );
                    ResultSet rsLatestSub = psLatestSub.executeQuery();
                    if (rsLatestSub.next()) {
                        hasLatestActivity = true;
                        newestUserId = rsLatestSub.getInt("user_id");
                        newestMemberName = rsLatestSub.getString("display_name");
                        java.sql.Date sd = rsLatestSub.getDate("start_date");
                        newestMemberDate = sd != null ? new java.util.Date(sd.getTime()) : null;
                        newestPaymentDate = newestMemberDate;
                        newestPaymentAmount = rsLatestSub.getObject("amount") != null ? rsLatestSub.getDouble("amount") : null;
                        newestPaymentMonths = rsLatestSub.getObject("months") != null ? rsLatestSub.getInt("months") : null;
                    }
                    rsLatestSub.close();
                    psLatestSub.close();
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
                    // Row 1: Newest Member
                    if (hasLatestActivity) {
                %>
                    <tr>
                        <td><%= newestMemberDate != null ? df.format(newestMemberDate) : "" %></td>
                        <td>New Member</td>
                        <td><%= (newestMemberName != null && !newestMemberName.isEmpty()) ? newestMemberName : ("User #" + (newestUserId != null ? newestUserId : 0)) %></td>
                        <td>Registered new account</td>
                    </tr>
                <%
                    }
                    // Row 2: Payment for newest member
                    if (hasLatestActivity && newestPaymentAmount != null) {
                %>
                    <tr>
                        <td><%= newestPaymentDate != null ? df.format(newestPaymentDate) : (newestMemberDate != null ? df.format(newestMemberDate) : "") %></td>
                        <td>Payment</td>
                        <td><%= (newestMemberName != null && !newestMemberName.isEmpty()) ? newestMemberName : ("User #" + (newestUserId != null ? newestUserId : 0)) %></td>
                        <td>৳<%= String.format("%.2f", newestPaymentAmount) %><%= (newestPaymentMonths != null ? (" for " + newestPaymentMonths + " month" + (newestPaymentMonths > 1 ? "s" : "")) : "") %></td>
                    </tr>
                <%
                    }
                    if (!hasLatestActivity) {
                %>
                    <tr>
                        <td colspan="4" style="text-align:center;color:#999">No recent activity yet.</td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<% } %>
<%@ include file="../shared/footer.jsp" %>
