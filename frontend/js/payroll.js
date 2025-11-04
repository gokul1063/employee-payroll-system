console.log('payroll.js loaded');

let currentViewMonth = null;
let currentViewYear = null;

async function loadPayroll() {
    try {
        const response = await fetch(API_URL + '/payroll');
        const data = await response.json();
        displayPayroll(data.payroll || []);
        loadPayrollSummary();
    } catch (error) {
        console.error('Error:', error);
    }
}

async function loadAllPayroll() {
    console.log('Loading all payroll records');
    currentViewMonth = null;
    currentViewYear = null;
    
    try {
        const response = await fetch(API_URL + '/payroll');
        const data = await response.json();
        displayPayroll(data.payroll || []);
        
        // Show combined summary
        const all = data.payroll || [];
        const summary = {
            total_employees: all.length,
            total_basic: all.reduce((s, p) => s + parseFloat(p.basic_salary || 0), 0),
            total_allowances: all.reduce((s, p) => s + parseFloat(p.allowances || 0), 0),
            total_deductions: all.reduce((s, p) => s + parseFloat(p.deductions || 0), 0),
            total_overtime: all.reduce((s, p) => s + parseFloat(p.overtime_pay || 0), 0),
            total_payout: all.reduce((s, p) => s + parseFloat(p.net_salary || 0), 0)
        };
        
        displaySummary('All Time', summary);
    } catch (error) {
        console.error('Error:', error);
    }
}

async function loadPayrollForMonth() {
    const month = document.getElementById('viewMonth').value;
    const year = document.getElementById('viewYear').value;
    
    console.log('Loading payroll for:', month, year);
    currentViewMonth = month;
    currentViewYear = year;
    
    try {
        const response = await fetch(API_URL + '/payroll');
        const data = await response.json();
        
        const filtered = (data.payroll || []).filter(p => 
            String(p.month) === month && String(p.year) === year
        );
        
        console.log('Filtered records:', filtered.length);
        displayPayroll(filtered);
        
        const summary = {
            total_employees: filtered.length,
            total_basic: filtered.reduce((s, p) => s + parseFloat(p.basic_salary || 0), 0),
            total_allowances: filtered.reduce((s, p) => s + parseFloat(p.allowances || 0), 0),
            total_deductions: filtered.reduce((s, p) => s + parseFloat(p.deductions || 0), 0),
            total_overtime: filtered.reduce((s, p) => s + parseFloat(p.overtime_pay || 0), 0),
            total_payout: filtered.reduce((s, p) => s + parseFloat(p.net_salary || 0), 0)
        };
        
        displaySummary(month + '/' + year, summary);
    } catch (error) {
        console.error('Error:', error);
    }
}

function displayPayroll(payrollRecords) {
    const tbody = document.querySelector('#payrollTable tbody');
    
    if (payrollRecords.length > 0) {
        tbody.innerHTML = payrollRecords.map(p => 
            '<tr><td>' + p.employee_id + '</td><td>' + p.first_name + ' ' + p.last_name + '</td><td>' + 
            p.month + '/' + p.year + '</td><td>$' + parseFloat(p.basic_salary || 0).toFixed(2) + '</td><td>$' + 
            parseFloat(p.allowances || 0).toFixed(2) + '</td><td>$' + parseFloat(p.deductions || 0).toFixed(2) + 
            '</td><td>$' + parseFloat(p.overtime_pay || 0).toFixed(2) + '</td><td>$' + parseFloat(p.net_salary || 0).toFixed(2) + 
            '</td><td><span class="status-' + p.status + '">' + p.status + '</span></td><td>' + 
            (p.status === 'pending' ? '<button class="btn btn-sm btn-success" onclick="markPaid(' + p.id + ')">Pay</button>' : 'Paid') + 
            '</td></tr>'
        ).join('');
        console.log('Displayed', payrollRecords.length, 'records');
    } else {
        tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;padding:20px;">No payroll records found for selected period.</td></tr>';
    }
}

async function loadPayrollSummary() {
    const month = String(new Date().getMonth() + 1).padStart(2, '0');
    const year = String(new Date().getFullYear());
    
    try {
        const response = await fetch(API_URL + '/payroll');
        const data = await response.json();
        
        const filtered = (data.payroll || []).filter(p => 
            String(p.month) === month && String(p.year) === year
        );
        
        const summary = {
            total_employees: filtered.length,
            total_basic: filtered.reduce((s, p) => s + parseFloat(p.basic_salary || 0), 0),
            total_allowances: filtered.reduce((s, p) => s + parseFloat(p.allowances || 0), 0),
            total_deductions: filtered.reduce((s, p) => s + parseFloat(p.deductions || 0), 0),
            total_overtime: filtered.reduce((s, p) => s + parseFloat(p.overtime_pay || 0), 0),
            total_payout: filtered.reduce((s, p) => s + parseFloat(p.net_salary || 0), 0)
        };
        
        displaySummary(month + '/' + year, summary);
    } catch (error) {
        console.error('Error:', error);
    }
}

function displaySummary(period, summary) {
    document.getElementById('payrollSummary').innerHTML = 
        '<h3>Summary for ' + period + '</h3><div class="summary-grid">' +
        '<div class="summary-item"><h4>' + summary.total_employees + '</h4><p>Employees</p></div>' +
        '<div class="summary-item"><h4>$' + summary.total_basic.toFixed(2) + '</h4><p>Basic Salary</p></div>' +
        '<div class="summary-item"><h4>$' + summary.total_allowances.toFixed(2) + '</h4><p>Allowances</p></div>' +
        '<div class="summary-item"><h4>$' + summary.total_deductions.toFixed(2) + '</h4><p>Deductions</p></div>' +
        '<div class="summary-item"><h4>$' + summary.total_overtime.toFixed(2) + '</h4><p>Overtime</p></div>' +
        '<div class="summary-item"><h4>$' + summary.total_payout.toFixed(2) + '</h4><p>Total Payout</p></div></div>';
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
    if (!confirm('Mark this payroll as paid?')) return;
    
    try {
        const response = await fetch(API_URL + '/payroll/' + id + '/status', {
            method: 'PUT',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                status: 'paid',
                payment_date: new Date().toISOString().split('T')[0]
            })
        });
        
        if (response.ok) {
            alert('Marked as paid!');
            
            // Reload based on current view
            if (currentViewMonth && currentViewYear) {
                loadPayrollForMonth();
            } else {
                loadPayroll();
            }
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

async function handleGenerateSubmit(e) {
    e.preventDefault();
    
    const month = document.getElementById('gen_month').value;
    const year = parseInt(document.getElementById('gen_year').value);
    
    try {
        const response = await fetch(API_URL + '/payroll/generate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ month, year })
        });
        
        if (response.ok) {
            alert('Payroll generated successfully!');
            closeGenerateModal();
            
            // Set view to generated month
            document.getElementById('viewMonth').value = month;
            document.getElementById('viewYear').value = year;
            
            setTimeout(() => loadPayrollForMonth(), 1000);
        } else {
            const result = await response.json();
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Failed: ' + error.message);
    }
}

window.loadPayrollForMonth = loadPayrollForMonth;
window.loadAllPayroll = loadAllPayroll;
window.openGenerateModal = openGenerateModal;
window.closeGenerateModal = closeGenerateModal;
window.markPaid = markPaid;

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing payroll page');
    
    // Set current month/year as default
    const now = new Date();
    document.getElementById('viewMonth').value = String(now.getMonth() + 1).padStart(2, '0');
    document.getElementById('viewYear').value = now.getFullYear();
    
    // Load for current month
    loadPayrollForMonth();
    
    const generateBtn = document.getElementById('generatePayrollBtn');
    if (generateBtn) generateBtn.onclick = openGenerateModal;
    
    const closeBtn = document.getElementById('closeGenerateModalBtn');
    if (closeBtn) closeBtn.onclick = closeGenerateModal;
    
    const cancelBtn = document.getElementById('cancelGenerateBtn');
    if (cancelBtn) cancelBtn.onclick = closeGenerateModal;
    
    const form = document.getElementById('generateForm');
    if (form) form.onsubmit = handleGenerateSubmit;
    
    console.log('Payroll page ready');
});
