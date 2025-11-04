console.log('✓ payroll.js loaded');

async function loadPayroll() {
    try {
        const response = await fetch(API_URL + '/payroll');
        const data = await response.json();
        const tbody = document.querySelector('#payrollTable tbody');
        if (data.payroll && data.payroll.length > 0) {
            tbody.innerHTML = data.payroll.map(p => 
                '<tr><td>' + p.employee_id + '</td><td>' + p.first_name + ' ' + p.last_name + '</td><td>' + 
                p.month + '/' + p.year + '</td><td>$' + parseFloat(p.basic_salary || 0).toFixed(2) + '</td><td>$' + 
                parseFloat(p.allowances || 0).toFixed(2) + '</td><td>$' + parseFloat(p.deductions || 0).toFixed(2) + 
                '</td><td>$' + parseFloat(p.overtime_pay || 0).toFixed(2) + '</td><td>$' + parseFloat(p.net_salary || 0).toFixed(2) + 
                '</td><td>' + p.status + '</td><td>' + (p.status === 'pending' ? 
                '<button class="btn btn-sm btn-success" onclick="markPaid(' + p.id + ')">Pay</button>' : 'Paid') + '</td></tr>'
            ).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;">No payroll records. Generate payroll first.</td></tr>';
        }
        loadPayrollSummary();
    } catch (error) {
        console.error('Error:', error);
    }
}

async function loadPayrollSummary() {
    const month = String(new Date().getMonth() + 1).padStart(2, '0');
    const year = new Date().getFullYear();
    try {
        const response = await fetch(API_URL + '/payroll/summary/' + month + '/' + year);
        const data = await response.json();
        const s = data.summary || {};
        document.getElementById('payrollSummary').innerHTML = 
            '<h3>Summary ' + month + '/' + year + '</h3><div class="summary-grid">' +
            '<div class="summary-item"><h4>' + (s.total_employees || 0) + '</h4><p>Employees</p></div>' +
            '<div class="summary-item"><h4>$' + (s.total_basic || 0).toFixed(2) + '</h4><p>Basic</p></div>' +
            '<div class="summary-item"><h4>$' + (s.total_allowances || 0).toFixed(2) + '</h4><p>Allowances</p></div>' +
            '<div class="summary-item"><h4>$' + (s.total_deductions || 0).toFixed(2) + '</h4><p>Deductions</p></div>' +
            '<div class="summary-item"><h4>$' + (s.total_payout || 0).toFixed(2) + '</h4><p>Total Payout</p></div></div>';
    } catch (error) {
        console.error('Error loading summary:', error);
    }
}

function openGenerateModal() {
    console.log('Opening generate modal');
    document.getElementById('gen_month').value = String(new Date().getMonth() + 1).padStart(2, '0');
    document.getElementById('gen_year').value = new Date().getFullYear();
    document.getElementById('generateModal').style.display = 'block';
}

function closeGenerateModal() {
    document.getElementById('generateModal').style.display = 'none';
}

async function markPaid(id) {
    if (!confirm('Mark as paid?')) return;
    try {
        const response = await fetch(API_URL + '/payroll/' + id + '/status', {
            method: 'PUT',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({status: 'paid', payment_date: new Date().toISOString().split('T')[0]})
        });
        if (response.ok) {
            alert('Marked as paid!');
            loadPayroll();
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

async function handleGenerateSubmit(e) {
    e.preventDefault();
    console.log('Generating payroll...');
    
    try {
        const response = await fetch(API_URL + '/payroll/generate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                month: document.getElementById('gen_month').value,
                year: parseInt(document.getElementById('gen_year').value)
            })
        });
        
        const result = await response.json();
        console.log('Generate result:', result);
        
        if (response.ok) {
            alert('Payroll generated successfully!');
            closeGenerateModal();
            setTimeout(loadPayroll, 2000);
        } else {
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to generate payroll: ' + error.message);
    }
}

window.openGenerateModal = openGenerateModal;
window.closeGenerateModal = closeGenerateModal;
window.markPaid = markPaid;

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing payroll page');
    loadPayroll();
    
    const generateBtn = document.getElementById('generatePayrollBtn');
    if (generateBtn) {
        generateBtn.onclick = openGenerateModal;
        console.log('✓ Generate button attached');
    }
    
    const closeBtn = document.getElementById('closeGenerateModalBtn');
    if (closeBtn) closeBtn.onclick = closeGenerateModal;
    
    const cancelBtn = document.getElementById('cancelGenerateBtn');
    if (cancelBtn) cancelBtn.onclick = closeGenerateModal;
    
    const form = document.getElementById('generateForm');
    if (form) {
        form.onsubmit = handleGenerateSubmit;
        console.log('✓ Form handler attached');
    }
    
    console.log('Payroll page ready');
});
