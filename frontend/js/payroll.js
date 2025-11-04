const API_URL = 'http://localhost:3000/api';

// Load payroll records
async function loadPayroll() {
    try {
        const response = await fetch(`${API_URL}/payroll`);
        const data = await response.json();
        
        const tbody = document.querySelector('#payrollTable tbody');
        
        if (data.payroll && data.payroll.length > 0) {
            tbody.innerHTML = data.payroll.map(pay => `
                <tr>
                    <td>${pay.employee_id}</td>
                    <td>${pay.first_name} ${pay.last_name}</td>
                    <td>${pay.month}/${pay.year}</td>
                    <td>$${parseFloat(pay.basic_salary || 0).toFixed(2)}</td>
                    <td>$${parseFloat(pay.allowances || 0).toFixed(2)}</td>
                    <td>$${parseFloat(pay.deductions || 0).toFixed(2)}</td>
                    <td>$${parseFloat(pay.overtime_pay || 0).toFixed(2)}</td>
                    <td>$${parseFloat(pay.net_salary || 0).toFixed(2)}</td>
                    <td><span class="status-${pay.status}">${pay.status}</span></td>
                    <td>
                        ${pay.status === 'pending' ? 
                            `<button class="btn btn-sm btn-success" onclick="markPaid(${pay.id})">Mark Paid</button>` : 
                            'Paid'}
                    </td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;padding:20px;">No payroll records found. Generate payroll to begin.</td></tr>';
        }
        
        loadPayrollSummary();
    } catch (error) {
        console.error('Error loading payroll:', error);
        alert('Failed to load payroll: ' + error.message);
    }
}

// Load payroll summary
async function loadPayrollSummary() {
    const currentMonth = String(new Date().getMonth() + 1).padStart(2, '0');
    const currentYear = new Date().getFullYear();
    
    try {
        const response = await fetch(`${API_URL}/payroll/summary/${currentMonth}/${currentYear}`);
        const data = await response.json();
        const summary = data.summary || {};
        
        document.getElementById('payrollSummary').innerHTML = `
            <h3>Current Month Summary (${currentMonth}/${currentYear})</h3>
            <div class="summary-grid">
                <div class="summary-item">
                    <h4>${summary.total_employees || 0}</h4>
                    <p>Employees</p>
                </div>
                <div class="summary-item">
                    <h4>$${(summary.total_basic || 0).toFixed(2)}</h4>
                    <p>Total Basic Salary</p>
                </div>
                <div class="summary-item">
                    <h4>$${(summary.total_allowances || 0).toFixed(2)}</h4>
                    <p>Total Allowances</p>
                </div>
                <div class="summary-item">
                    <h4>$${(summary.total_deductions || 0).toFixed(2)}</h4>
                    <p>Total Deductions</p>
                </div>
                <div class="summary-item">
                    <h4>$${(summary.total_overtime || 0).toFixed(2)}</h4>
                    <p>Total Overtime</p>
                </div>
                <div class="summary-item">
                    <h4>$${(summary.total_payout || 0).toFixed(2)}</h4>
                    <p>Total Payout</p>
                </div>
            </div>
        `;
    } catch (error) {
        console.error('Error loading summary:', error);
    }
}

// Open generate modal
function openGenerateModal() {
    const currentMonth = String(new Date().getMonth() + 1).padStart(2, '0');
    const currentYear = new Date().getFullYear();
    
    document.getElementById('gen_month').value = currentMonth;
    document.getElementById('gen_year').value = currentYear;
    document.getElementById('generateModal').style.display = 'block';
}

// Close generate modal
function closeGenerateModal() {
    document.getElementById('generateModal').style.display = 'none';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('generateModal');
    if (event.target == modal) {
        modal.style.display = 'none';
    }
}

// Mark as paid
async function markPaid(id) {
    if (!confirm('Mark this payroll as paid?')) return;
    
    try {
        const response = await fetch(`${API_URL}/payroll/${id}/status`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                status: 'paid',
                payment_date: new Date().toISOString().split('T')[0]
            })
        });
        
        if (response.ok) {
            alert('Payroll marked as paid');
            loadPayroll();
        } else {
            const error = await response.json();
            alert('Failed to update status: ' + (error.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error updating status:', error);
        alert('Failed to update status: ' + error.message);
    }
}

// Load on page load
document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('generateForm');
    
    if (form) {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const formData = {
                month: document.getElementById('gen_month').value,
                year: parseInt(document.getElementById('gen_year').value)
            };
            
            try {
                const response = await fetch(`${API_URL}/payroll/generate`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(formData)
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    alert('Payroll generated successfully! Please wait a moment...');
                    closeGenerateModal();
                    setTimeout(() => loadPayroll(), 2000);
                } else {
                    alert('Failed to generate payroll: ' + (result.error || 'Unknown error'));
                }
            } catch (error) {
                console.error('Error generating payroll:', error);
                alert('Failed to generate payroll: ' + error.message);
            }
        });
    }
    
    loadPayroll();
});
