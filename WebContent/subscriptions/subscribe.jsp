<%@ page contentType="text/html; charset=UTF-8" %>
<%
  if (session.getAttribute("member_id") == null) {
    response.sendRedirect("start.jsp");
    return;
  }
%>
<%@ include file="../shared/header.jsp" %>
<%@ include file="../shared/navigation.jsp" %>
<div class="container">
  <h2>Choose Your Subscription</h2>
  <p>Price: 2000 tk per month</p>
  <form method="post" action="subscribeProcess.jsp" id="subForm">
    <div class="form-group">
      <label for="months">Months</label>
      <input type="number" id="months" name="months" min="1" value="1" required>
    </div>
    <div class="form-group">
      <label>Total Amount (tk)</label>
      <input type="number" id="amount" name="amount" readonly>
    </div>
    <button type="submit" class="btn btn-primary">Pay & Subscribe</button>
  </form>
</div>
<script>
  const pricePerMonth = 2000;
  const monthsEl = document.getElementById('months');
  const amountEl = document.getElementById('amount');
  function recalc(){ amountEl.value = monthsEl.value * pricePerMonth; }
  monthsEl.addEventListener('input', recalc);
  recalc();
  // Prevent negative or zero
  monthsEl.addEventListener('change', () => { if(monthsEl.value < 1){ monthsEl.value = 1; recalc(); } });
  // Basic client-side guard; server still validates
</script>
<%@ include file="../shared/footer.jsp" %>
