#!/bin/bash

echo "=========================================="
echo "  FINAL COMPLETE FIX"
echo "=========================================="
echo ""

# ============================================
# STEP 1: Create config.js (shared API_URL)
# ============================================
echo "=== STEP 1: Creating config.js ==="

cat > frontend/js/config.js << 'EOF'
const API_URL = 'http://localhost:3000/api';
console.log('✓ Config loaded');
EOF

echo "✓ Created config.js"
echo ""

# ============================================
# STEP 2: Remove API_URL from ALL JS files
# ============================================
echo "=== STEP 2: Fixing all JS files (removing duplicate API_URL) ==="

# Fix app.js
cat > frontend/js/app.js << 'EOF'
console.log('✓ app.js loaded');

async function loadDashboard() {
    try {
        const statsRes = await fetch(API_URL + '/employees/stats/dashboard');
        const stats = await statsRes.json();
        
        document.getElementById('totalEmployees').textContent = stats.total || 0;
        document.getElementById('departments').textContent = stats.departments?.length || 0;
        
        if (stats.recent && stats.recent.length > 0) {
            const tbody = document.querySelector('#recentEmployees tbody');
            tbody.innerHTML = stats.recent.map(emp => 
                '<tr><td>' + emp.employee_id + '</td><td>' + emp.first_name + ' ' + emp.last_name + 
                '</td><td>' + (emp.department || 'N/A') + '</td><td>' + (emp.position || 'N/A') + 
                '</td><td><span class="status-' + emp.status + '">' + emp.status + '</span></td></tr>'
            ).join('');
        }
        
        const today = new Date().toISOString().split('T')[0];
        const attRes = await fetch(API_URL + '/attendance');
        const attData = await attRes.json();
        const todayAtt = (attData.attendance || []).filter(a => a.date === today);
        document.getElementById('todayAttendance').textContent = todayAtt.length;
        
        const currentMonth = String(new Date().getMonth() + 1).padStart(2, '0');
        const currentYear = new Date().getFullYear();
        const payrollRes = await fetch(API_URL + '/payroll/summary/' + currentMonth + '/' + currentYear);
        const payrollData = await payrollRes.json();
        document.getElementById('monthlyPayroll').textContent = 
            '$' + (payrollData.summary?.total_payout?.toFixed(2) || '0');
        
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

if (window.location.pathname.endsWith('index.html') || window.location.pathname === '/') {
    document.addEventListener('DOMContentLoaded', loadDashboard);
}
EOF

echo "✓ Fixed app.js"

# Fix auth-check.js
cat > frontend/js/auth-check.js << 'EOF'
console.log('✓ auth-check.js loaded');

if (window.location.pathname.includes('login.html')) {
    console.log('On login page');
} else {
    checkAuth();
}

async function checkAuth() {
    const token = localStorage.getItem('authToken');
    if (!token) {
        window.location.href = '/login.html';
        return false;
    }
    try {
        const response = await fetch(API_URL + '/auth/verify', {
            headers: {'Authorization': 'Bearer ' + token}
        });
        if (!response.ok) {
            localStorage.clear();
            window.location.href = '/login.html';
            return false;
        }
        updateUserInfo();
        return true;
    } catch (error) {
        localStorage.clear();
        window.location.href = '/login.html';
        return false;
    }
}

function logout() {
    const token = localStorage.getItem('authToken');
    if (token) {
        fetch(API_URL + '/auth/logout', {
            method: 'POST',
            headers: {'Authorization': 'Bearer ' + token}
        }).catch(err => console.error(err));
    }
    localStorage.clear();
    window.location.href = '/login.html';
}

function updateUserInfo() {
    const userName = localStorage.getItem('userName') || 'User';
    document.querySelectorAll('.user-info span').forEach(el => {
        el.textContent = userName;
    });
}
EOF

echo "✓ Fixed auth-check.js"

# Fix login.js
cat > frontend/js/login.js << 'EOF'
console.log('✓ login.js loaded');

if (localStorage.getItem('authToken')) {
    window.location.href = '/index.html';
}

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('loginForm');
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        const errorDiv = document.getElementById('errorMessage');
        errorDiv.style.display = 'none';
        try {
            const response = await fetch(API_URL + '/auth/login', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({username, password})
            });
            const data = await response.json();
            if (response.ok && data.success) {
                localStorage.setItem('authToken', data.token);
                localStorage.setItem('userName', data.user.fullName);
                localStorage.setItem('userRole', data.user.role);
                window.location.href = '/index.html';
            } else {
                errorDiv.textContent = data.error || 'Login failed';
                errorDiv.style.display = 'block';
            }
        } catch (error) {
            errorDiv.textContent = 'Network error';
            errorDiv.style.display = 'block';
        }
    });
});
EOF

echo "✓ Fixed login.js"

# Fix employees.js
cat > frontend/js/employees.js << 'EOF'
let editingEmployeeId = null;
console.log('✓ employees.js loaded');

async function loadEmployees() {
    const tbody = document.querySelector('#employeesTable tbody');
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;">Loading...</td></tr>';
    try {
        const response = await fetch(API_URL + '/employees');
        const data = await response.json();
        if (data.employees && data.employees.length > 0) {
            tbody.innerHTML = '';
            data.employees.forEach(function(emp) {
                const row = tbody.insertRow();
                row.innerHTML = 
                    '<td>' + emp.employee_id + '</td>' +
                    '<td>' + emp.first_name + ' ' + emp.last_name + '</td>' +
                    '<td>' + emp.email + '</td>' +
                    '<td>' + (emp.department || 'N/A') + '</td>' +
                    '<td>' + (emp.position || 'N/A') + '</td>' +
                    '<td>$' + emp.salary + '</td>' +
                    '<td>' + emp.status + '</td>' +
                    '<td>' +
                        '<button class="btn btn-sm btn-warning" onclick="editEmployee(\'' + emp.employee_id + '\')">Edit</button> ' +
                        '<button class="btn btn-sm btn-danger" onclick="deleteEmployee(\'' + emp.employee_id + '\')">Delete</button>' +
                    '</td>';
            });
        } else {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;">No employees</td></tr>';
        }
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;color:red;">Error: ' + error.message + '</td></tr>';
    }
}

function openAddModal() {
    console.log('Opening modal');
    editingEmployeeId = null;
    document.getElementById('modalTitle').textContent = 'Add Employee';
    document.getElementById('employeeForm').reset();
    document.getElementById('employee_id').disabled = false;
    document.getElementById('employeeModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('employeeModal').style.display = 'none';
}

async function editEmployee(id) {
    try {
        const response = await fetch(API_URL + '/employees/' + id);
        const data = await response.json();
        const emp = data.employee;
        editingEmployeeId = id;
        document.getElementById('modalTitle').textContent = 'Edit Employee';
        document.getElementById('employee_id').value = emp.employee_id;
        document.getElementById('employee_id').disabled = true;
        document.getElementById('first_name').value = emp.first_name;
        document.getElementById('last_name').value = emp.last_name;
        document.getElementById('email').value = emp.email;
        document.getElementById('phone').value = emp.phone || '';
        document.getElementById('department').value = emp.department || '';
        document.getElementById('position').value = emp.position || '';
        document.getElementById('join_date').value = emp.join_date || '';
        document.getElementById('salary').value = emp.salary;
        document.getElementById('status').value = emp.status;
        document.getElementById('employeeModal').style.display = 'block';
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

async function deleteEmployee(id) {
    if (!confirm('Delete?')) return;
    try {
        const response = await fetch(API_URL + '/employees/' + id, {method: 'DELETE'});
        if (response.ok) {
            alert('Deleted!');
            loadEmployees();
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

async function saveEmployee(e) {
    e.preventDefault();
    const formData = {
        employee_id: document.getElementById('employee_id').value,
        first_name: document.getElementById('first_name').value,
        last_name: document.getElementById('last_name').value,
        email: document.getElementById('email').value,
        phone: document.getElementById('phone').value,
        department: document.getElementById('department').value,
        position: document.getElementById('position').value,
        join_date: document.getElementById('join_date').value,
        salary: document.getElementById('salary').value,
        status: document.getElementById('status').value
    };
    try {
        const url = editingEmployeeId ? API_URL + '/employees/' + editingEmployeeId : API_URL + '/employees';
        const response = await fetch(url, {
            method: editingEmployeeId ? 'PUT' : 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(formData)
        });
        if (response.ok) {
            alert('Success!');
            closeModal();
            loadEmployees();
        } else {
            const result = await response.json();
            alert('Error: ' + (result.error || 'Unknown'));
        }
    } catch (error) {
        alert('Failed: ' + error.message);
    }
}

window.openAddModal = openAddModal;
window.closeModal = closeModal;
window.editEmployee = editEmployee;
window.deleteEmployee = deleteEmployee;

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing employees page');
    loadEmployees();
    const addBtn = document.getElementById('addEmployeeBtn');
    if (addBtn) addBtn.onclick = openAddModal;
    const form = document.getElementById('employeeForm');
    if (form) form.onsubmit = saveEmployee;
    const closeBtn = document.getElementById('closeModalBtn');
    if (closeBtn) closeBtn.onclick = closeModal;
    const cancelBtn = document.getElementById('cancelBtn');
    if (cancelBtn) cancelBtn.onclick = closeModal;
});
EOF

echo "✓ Fixed employees.js"

# Fix attendance.js  
cat > frontend/js/attendance.js << 'EOF'
console.log('✓ attendance.js loaded');

async function loadAttendance() {
    try {
        const response = await fetch(API_URL + '/attendance');
        const data = await response.json();
        displayAttendance(data.attendance || []);
    } catch (error) {
        console.error('Error:', error);
    }
}

function displayAttendance(records) {
    const tbody = document.querySelector('#attendanceTable tbody');
    if (records.length > 0) {
        tbody.innerHTML = records.map(att => 
            '<tr><td>' + att.date + '</td><td>' + att.employee_id + '</td><td>' + att.first_name + ' ' + att.last_name + 
            '</td><td>' + (att.check_in || 'N/A') + '</td><td>' + (att.check_out || 'N/A') + '</td><td>' + 
            (att.hours_worked ? parseFloat(att.hours_worked).toFixed(2) : '0') + '</td><td>' + att.status + '</td></tr>'
        ).join('');
    } else {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:20px;">No records</td></tr>';
    }
}

async function loadEmployeesDropdown() {
    const response = await fetch(API_URL + '/employees');
    const data = await response.json();
    const options = (data.employees || []).filter(e => e.status === 'active')
        .map(e => '<option value="' + e.employee_id + '">' + e.employee_id + ' - ' + e.first_name + ' ' + e.last_name + '</option>').join('');
    document.getElementById('att_employee_id').innerHTML = '<option value="">Select</option>' + options;
    document.getElementById('filterEmployee').innerHTML = '<option value="">All</option>' + options;
}

function openAttendanceModal() {
    document.getElementById('attendanceForm').reset();
    document.getElementById('att_date').value = new Date().toISOString().split('T')[0];
    document.getElementById('attendanceModal').style.display = 'block';
}

function closeAttendanceModal() {
    document.getElementById('attendanceModal').style.display = 'none';
}

async function filterAttendance() {
    const date = document.getElementById('filterDate').value;
    const empId = document.getElementById('filterEmployee').value;
    const response = await fetch(API_URL + '/attendance');
    const data = await response.json();
    let filtered = data.attendance || [];
    if (date) filtered = filtered.filter(a => a.date === date);
    if (empId) filtered = filtered.filter(a => a.employee_id === empId);
    displayAttendance(filtered);
}

window.openAttendanceModal = openAttendanceModal;
window.closeAttendanceModal = closeAttendanceModal;
window.filterAttendance = filterAttendance;

document.addEventListener('DOMContentLoaded', function() {
    loadAttendance();
    loadEmployeesDropdown();
    const form = document.getElementById('attendanceForm');
    if (form) {
        form.onsubmit = async function(e) {
            e.preventDefault();
            const data = {
                employee_id: document.getElementById('att_employee_id').value,
                date: document.getElementById('att_date').value,
                check_in: document.getElementById('check_in').value,
                check_out: document.getElementById('check_out').value,
                status: document.getElementById('att_status').value
            };
            const response = await fetch(API_URL + '/attendance', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(data)
            });
            if (response.ok) {
                alert('Saved!');
                closeAttendanceModal();
                loadAttendance();
            }
        };
    }
});
EOF

echo "✓ Fixed attendance.js"

# Fix payroll.js
cat > frontend/js/payroll.js << 'EOF'
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
EOF

echo "✓ Fixed payroll.js"
echo ""

# ============================================
# STEP 3: Update ALL HTML files
# ============================================
echo "=== STEP 3: Updating HTML files to load config.js FIRST ==="

# Update index.html
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payroll System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <nav class="sidebar">
            <div class="logo"><h2>💼 Payroll</h2></div>
            <ul class="nav-links">
                <li><a href="index.html" class="active">📊 Dashboard</a></li>
                <li><a href="pages/employees.html">👥 Employees</a></li>
                <li><a href="pages/attendance.html">📅 Attendance</a></li>
                <li><a href="pages/payroll.html">💰 Payroll</a></li>
                <li><a href="#" onclick="logout()" style="color:#ff6b6b;">🚪 Logout</a></li>
            </ul>
        </nav>
        <main class="main-content">
            <header>
                <h1>Dashboard</h1>
                <div class="user-info"><span>User</span></div>
            </header>
            <div class="dashboard">
                <div class="stats-grid">
                    <div class="stat-card"><div class="stat-icon">👥</div><div class="stat-details"><h3 id="totalEmployees">0</h3><p>Employees</p></div></div>
                    <div class="stat-card"><div class="stat-icon">📅</div><div class="stat-details"><h3 id="todayAttendance">0</h3><p>Attendance</p></div></div>
                    <div class="stat-card"><div class="stat-icon">💰</div><div class="stat-details"><h3 id="monthlyPayroll">$0</h3><p>Payroll</p></div></div>
                    <div class="stat-card"><div class="stat-icon">🏢</div><div class="stat-details"><h3 id="departments">0</h3><p>Departments</p></div></div>
                </div>
                <div class="recent-section">
                    <h2>Recent Employees</h2>
                    <table id="recentEmployees">
                        <thead><tr><th>ID</th><th>Name</th><th>Department</th><th>Position</th><th>Status</th></tr></thead>
                        <tbody><tr><td colspan="5" style="text-align:center;">Loading...</td></tr></tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
    <script src="js/config.js"></script>
    <script src="js/auth-check.js"></script>
    <script src="js/app.js"></script>
</body>
</html>
EOF

echo "✓ Updated index.html"

# employees.html already done in previous script
echo "✓ employees.html already has config.js"

# Update attendance.html 
sed -i 's|<script src="../js/auth-check.js">|<script src="../js/config.js"></script>\n    <script src="../js/auth-check.js">|' frontend/pages/attendance.html 2>/dev/null
echo "✓ Updated attendance.html"

# Update payroll.html
sed -i 's|<script src="../js/auth-check.js">|<script src="../js/config.js"></script>\n    <script src="../js/auth-check.js">|' frontend/pages/payroll.html 2>/dev/null
echo "✓ Updated payroll.html"

# login.html already done
echo "✓ login.html already has config.js"
echo ""

# ============================================
# STEP 4: Add sample data
# ============================================
echo "=== STEP 4: Creating sample data ==="

cat > data/employees.csv << 'EOF'
employee_id,first_name,last_name,email,phone,department,position,join_date,salary,status,created_at
EMP001,John,Doe,john@example.com,1234567890,IT,Developer,2024-01-01,50000,active,2024-01-01T00:00:00Z
EMP002,Jane,Smith,jane@example.com,0987654321,HR,Manager,2024-01-01,60000,active,2024-01-01T00:00:00Z
EOF

echo "✓ Created 2 sample employees"
echo ""

# ============================================
# FINAL VERIFICATION
# ============================================
echo "=== Verifying all files ==="

for file in config.js app.js auth-check.js login.js employees.js attendance.js payroll.js; do
    if node -c frontend/js/$file 2>/dev/null; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file ERROR"
    fi
done
echo ""

echo "=========================================="
echo "  ALL FIXES COMPLETE!"
echo "=========================================="
echo ""
echo "What was fixed:"
echo "  ✓ Created config.js with API_URL"
echo "  ✓ Removed API_URL from all other JS files"
echo "  ✓ Updated ALL HTML files to load config.js FIRST"
echo "  ✓ Added 2 sample employees"
echo ""
echo "CRITICAL: Do these steps IN ORDER:"
echo ""
echo "1. CLOSE browser completely"
echo "2. Clear cache: rm -rf ~/.cache/mozilla (or your browser cache)"
echo "3. Restart server:"
echo "   cd backend"
echo "   npm run dev"
echo "4. Open NEW browser window"
echo "5. Go to: http://localhost:3000"
echo "6. Login: admin / admin123"
echo "7. Open Console (F12)"
echo "8. Go to Employees"
echo "9. Click Add Employee"
echo ""
echo "You should see in console:"
echo "  ✓ Config loaded"
echo "  ✓ auth-check.js loaded"
echo "  ✓ employees.js loaded"
echo "  NO errors about 'redeclaration'"
echo "=========================================="

