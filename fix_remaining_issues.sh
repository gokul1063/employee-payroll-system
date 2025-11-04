#!/bin/bash

echo "=========================================="
echo "  Fixing Remaining Issues"
echo "=========================================="
echo ""

# ============================================
# ISSUE 1: Fix employees.html redirect
# ============================================
echo "=== ISSUE 1: Fixing employees.html ==="

cat > frontend/pages/employees.html << 'ENDHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employees - Payroll System</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <nav class="sidebar">
            <div class="logo">
                <h2>💼 Payroll</h2>
            </div>
            <ul class="nav-links">
                <li><a href="../index.html">📊 Dashboard</a></li>
                <li><a href="employees.html" class="active">👥 Employees</a></li>
                <li><a href="attendance.html">📅 Attendance</a></li>
                <li><a href="payroll.html">💰 Payroll</a></li>
                <li><a href="#" onclick="logout()">🚪 Logout</a></li>
            </ul>
        </nav>

        <main class="main-content">
            <header>
                <h1>Employee Management</h1>
                <button class="btn btn-primary" id="addEmployeeBtn">+ Add Employee</button>
            </header>

            <div class="content">
                <table id="employeesTable">
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Position</th>
                            <th>Salary</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td colspan="8" style="text-align:center;padding:20px;">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <div id="employeeModal" class="modal">
        <div class="modal-content">
            <span class="close" id="closeModalBtn">&times;</span>
            <h2 id="modalTitle">Add Employee</h2>
            <form id="employeeForm">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Employee ID:</label>
                        <input type="text" id="employee_id" required>
                    </div>
                    <div class="form-group">
                        <label>First Name:</label>
                        <input type="text" id="first_name" required>
                    </div>
                    <div class="form-group">
                        <label>Last Name:</label>
                        <input type="text" id="last_name" required>
                    </div>
                    <div class="form-group">
                        <label>Email:</label>
                        <input type="email" id="email" required>
                    </div>
                    <div class="form-group">
                        <label>Phone:</label>
                        <input type="tel" id="phone">
                    </div>
                    <div class="form-group">
                        <label>Department:</label>
                        <select id="department" required>
                            <option value="">Select Department</option>
                            <option value="IT">IT</option>
                            <option value="HR">HR</option>
                            <option value="Finance">Finance</option>
                            <option value="Sales">Sales</option>
                            <option value="Marketing">Marketing</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Position:</label>
                        <input type="text" id="position" required>
                    </div>
                    <div class="form-group">
                        <label>Join Date:</label>
                        <input type="date" id="join_date" required>
                    </div>
                    <div class="form-group">
                        <label>Salary:</label>
                        <input type="number" id="salary" step="0.01" required>
                    </div>
                    <div class="form-group">
                        <label>Status:</label>
                        <select id="status">
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <button type="button" class="btn btn-secondary" id="cancelBtn">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script src="../js/config.js"></script>
    <script src="../js/auth-check.js"></script>
    <script src="../js/employees.js"></script>
</body>
</html>
ENDHTML

echo "✓ Fixed employees.html (loads config.js FIRST)"
echo ""

# ============================================
# ISSUE 2: Fix payroll.html
# ============================================
echo "=== ISSUE 2: Fixing payroll.html ==="

cat > frontend/pages/payroll.html << 'ENDPAYHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payroll - Payroll System</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <nav class="sidebar">
            <div class="logo">
                <h2>💼 Payroll</h2>
            </div>
            <ul class="nav-links">
                <li><a href="../index.html">📊 Dashboard</a></li>
                <li><a href="employees.html">👥 Employees</a></li>
                <li><a href="attendance.html">📅 Attendance</a></li>
                <li><a href="payroll.html" class="active">💰 Payroll</a></li>
                <li><a href="#" onclick="logout()">🚪 Logout</a></li>
            </ul>
        </nav>

        <main class="main-content">
            <header>
                <h1>Payroll Management</h1>
                <button class="btn btn-primary" id="generatePayrollBtn">Generate Payroll</button>
            </header>

            <div class="content">
                <div class="payroll-summary" id="payrollSummary">
                    <h3>Loading...</h3>
                </div>

                <table id="payrollTable">
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>Month/Year</th>
                            <th>Basic Salary</th>
                            <th>Allowances</th>
                            <th>Deductions</th>
                            <th>Overtime</th>
                            <th>Net Salary</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td colspan="10" style="text-align:center;padding:20px;">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <div id="generateModal" class="modal">
        <div class="modal-content">
            <span class="close" id="closeGenerateModalBtn">&times;</span>
            <h2>Generate Payroll</h2>
            <form id="generateForm">
                <div class="form-group">
                    <label>Month:</label>
                    <select id="gen_month" required>
                        <option value="01">January</option>
                        <option value="02">February</option>
                        <option value="03">March</option>
                        <option value="04">April</option>
                        <option value="05">May</option>
                        <option value="06">June</option>
                        <option value="07">July</option>
                        <option value="08">August</option>
                        <option value="09">September</option>
                        <option value="10">October</option>
                        <option value="11">November</option>
                        <option value="12">December</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Year:</label>
                    <input type="number" id="gen_year" min="2020" max="2030" required>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Generate</button>
                    <button type="button" class="btn btn-secondary" id="cancelGenerateBtn">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script src="../js/config.js"></script>
    <script src="../js/auth-check.js"></script>
    <script src="../js/payroll.js"></script>
</body>
</html>
ENDPAYHTML

echo "✓ Fixed payroll.html (loads config.js FIRST)"
echo ""

# ============================================
# Fix attendance.html too
# ============================================
echo "=== Fixing attendance.html ==="

cat > frontend/pages/attendance.html << 'ENDATTHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance - Payroll System</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <nav class="sidebar">
            <div class="logo">
                <h2>💼 Payroll</h2>
            </div>
            <ul class="nav-links">
                <li><a href="../index.html">📊 Dashboard</a></li>
                <li><a href="employees.html">👥 Employees</a></li>
                <li><a href="attendance.html" class="active">📅 Attendance</a></li>
                <li><a href="payroll.html">💰 Payroll</a></li>
                <li><a href="#" onclick="logout()">🚪 Logout</a></li>
            </ul>
        </nav>

        <main class="main-content">
            <header>
                <h1>Attendance Management</h1>
                <button class="btn btn-primary" id="addAttendanceBtn">+ Mark Attendance</button>
            </header>

            <div class="content">
                <div class="filter-section">
                    <input type="date" id="filterDate" onchange="filterAttendance()">
                    <select id="filterEmployee" onchange="filterAttendance()">
                        <option value="">All Employees</option>
                    </select>
                </div>

                <table id="attendanceTable">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>Check In</th>
                            <th>Check Out</th>
                            <th>Hours</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td colspan="7" style="text-align:center;padding:20px;">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <div id="attendanceModal" class="modal">
        <div class="modal-content">
            <span class="close" id="closeAttendanceModalBtn">&times;</span>
            <h2>Mark Attendance</h2>
            <form id="attendanceForm">
                <div class="form-group">
                    <label>Employee:</label>
                    <select id="att_employee_id" required>
                        <option value="">Select Employee</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Date:</label>
                    <input type="date" id="att_date" required>
                </div>
                <div class="form-group">
                    <label>Check In:</label>
                    <input type="time" id="check_in" required>
                </div>
                <div class="form-group">
                    <label>Check Out:</label>
                    <input type="time" id="check_out">
                </div>
                <div class="form-group">
                    <label>Status:</label>
                    <select id="att_status" required>
                        <option value="present">Present</option>
                        <option value="absent">Absent</option>
                        <option value="half-day">Half Day</option>
                        <option value="leave">Leave</option>
                    </select>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <button type="button" class="btn btn-secondary" id="cancelAttendanceBtn">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script src="../js/config.js"></script>
    <script src="../js/auth-check.js"></script>
    <script src="../js/attendance.js"></script>
</body>
</html>
ENDATTHTML

echo "✓ Fixed attendance.html (loads config.js FIRST)"
echo ""

# ============================================
# Verify all HTML pages
# ============================================
echo "=== Verifying all HTML pages load config.js ==="

for file in index.html login.html; do
    if [ -f "frontend/$file" ]; then
        if grep -q "config.js" "frontend/$file"; then
            echo "  ✓ $file loads config.js"
        else
            echo "  ✗ $file missing config.js"
        fi
    fi
done

for file in employees.html attendance.html payroll.html; do
    if [ -f "frontend/pages/$file" ]; then
        if grep -q "config.js" "frontend/pages/$file"; then
            echo "  ✓ pages/$file loads config.js"
        else
            echo "  ✗ pages/$file missing config.js"
        fi
    fi
done
echo ""

# ============================================
# Fix payroll.js to use button click
# ============================================
echo "=== Fixing payroll.js event handlers ==="

cat > frontend/js/payroll.js << 'ENDPAYJS'
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
ENDPAYJS

echo "✓ Fixed payroll.js"
echo ""

# ============================================
# Verify JavaScript syntax
# ============================================
echo "=== Verifying JavaScript syntax ==="

for file in config.js auth-check.js employees.js attendance.js payroll.js; do
    if node -c frontend/js/$file 2>/dev/null; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file - syntax error"
    fi
done
echo ""

echo "=========================================="
echo "  Fix Complete!"
echo "=========================================="
echo ""
echo "Fixed issues:"
echo "  ✓ employees.html - now loads config.js first"
echo "  ✓ payroll.html - now loads config.js first"
echo "  ✓ attendance.html - now loads config.js first"
echo "  ✓ payroll.js - fixed API_URL reference"
echo "  ✓ All event handlers properly attached"
echo ""
echo "Next steps:"
echo "  1. Clear browser cache (Ctrl+Shift+Delete)"
echo "  2. Hard refresh (Ctrl+Shift+R)"
echo "  3. Login with admin/admin123"
echo "  4. Try:"
echo "     - Click Employees (should work now)"
echo "     - Click Add Employee (should work)"
echo "     - Click Payroll"
echo "     - Click Generate Payroll (should work now)"
echo ""
echo "All pages now have proper script loading:"
echo "  1. config.js (defines API_URL)"
echo "  2. auth-check.js (checks login)"
echo "  3. page-specific.js (uses API_URL)"
echo "=========================================="

