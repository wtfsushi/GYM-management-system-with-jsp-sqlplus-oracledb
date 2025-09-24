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
        
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            
            // Count total members
            PreparedStatement psMem = con.prepareStatement("SELECT COUNT(*) as count FROM users WHERE role='member'");
            ResultSet rsMem = psMem.executeQuery();
            if(rsMem.next()) {
                totalMembers = rsMem.getInt("count");
            }
            
            // Count total trainers
            PreparedStatement psTr = con.prepareStatement("SELECT COUNT(*) as count FROM users WHERE role='trainer'");
            ResultSet rsTr = psTr.executeQuery();
            if(rsTr.next()) {
                totalTrainers = rsTr.getInt("count");
            }
            
            // Get total revenue - assuming we have a payments table
            try {
                PreparedStatement psRev = con.prepareStatement("SELECT SUM(amount) as total FROM payments");
                ResultSet rsRev = psRev.executeQuery();
                if(rsRev.next() && rsRev.getObject("total") != null) {
                    totalRevenue = rsRev.getDouble("total");
                }
            } catch (SQLException e) {
                // Payments table might not exist yet
                totalRevenue = 0;
            }
            
            // Count pending payments - assuming status field in payments table
            try {
                PreparedStatement psPend = con.prepareStatement("SELECT COUNT(*) as count FROM payments WHERE status='pending'");
                ResultSet rsPend = psPend.executeQuery();
                if(rsPend.next()) {
                    pendingPayments = rsPend.getInt("count");
                }
            } catch (SQLException e) {
                // Payments table might not exist yet
                pendingPayments = 0;
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
                <span class="stat-value">$<%= String.format("%.2f", totalRevenue) %></span>
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
                    <tr>
                        <td>Sep 24, 2025</td>
                        <td>New Member</td>
                        <td>John Smith</td>
                        <td>Registered new account</td>
                    </tr>
                    <tr>
                        <td>Sep 23, 2025</td>
                        <td>Payment</td>
                        <td>Emily Johnson</td>
                        <td>$50.00 monthly membership</td>
                    </tr>
                    <tr>
                        <td>Sep 22, 2025</td>
                        <td>Role Change</td>
                        <td>Michael Brown</td>
                        <td>Promoted to trainer</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<% } %>
<%@ include file="../shared/footer.jsp" %>
