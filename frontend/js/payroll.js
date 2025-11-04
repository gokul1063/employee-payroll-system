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
            tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;">No records</td></tr>';
        }
        loadPayrollSummary();
    } catch (error) {
        console.error('Error:', error);
    }
}

async function loadPayrollSummary() {
    const month = String(new Date().getMonth() + 1).padStart(2, '0');
    const year = new Date().getFullYear();
    const response = await fetch(API_URL + '/payroll/summary/' + month + '/' + year);
    const data = await response.json();
    const s = data.summary || {};
    document.getElementById('payrollSummary').innerHTML = 
        '<h3>Summary ' + month + '/' + year + '</h3><div class="summary-grid">' +
        '<div class="summary-item"><h4>' + (s.total_employees || 0) + '</h4><p>Employees</p></div>' +
        '<div class="summary-item"><h4>$' + (s.total_basic || 0).toFixed(2) + '</h4><p>Basic</p></div>' +
        '<div class="summary-item"><h4>$' + (s.total_payout || 0).toFixed(2) + '</h4><p>Total</p></div></div>';
}

function openGenerateModal() {
    document.getElementById('gen_month').value = String(new Date().getMonth() + 1).padStart(2, '0');
    document.getElementById('gen_year').value = new Date().getFullYear();
    document.getElementById('generateModal').style.display = 'block';
}

function closeGenerateModal() {
    document.getElementById('generateModal').style.display = 'none';
}

async function markPaid(id) {
    if (!confirm('Mark as paid?')) return;
    await fetch(API_URL + '/payroll/' + id + '/status', {
        method: 'PUT',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({status: 'paid', payment_date: new Date().toISOString().split('T')[0]})
    });
    loadPayroll();
}

window.openGenerateModal = openGenerateModal;
window.closeGenerateModal = closeGenerateModal;
window.markPaid = markPaid;

document.addEventListener('DOMContentLoaded', function() {
    loadPayroll();
    const form = document.getElementById('generateForm');
    if (form) {
        form.onsubmit = async function(e) {
            e.preventDefault();
            const response = await fetch(API_URL + '/payroll/generate', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    month: document.getElementById('gen_month').value,
                    year: parseInt(document.getElementById('gen_year').value)
                })
            });
            if (response.ok) {
                alert('Generated!');
                closeGenerateModal();
                setTimeout(loadPayroll, 2000);
            }
        };
    }
});
