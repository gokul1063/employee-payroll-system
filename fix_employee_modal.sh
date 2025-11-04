#!/bin/bash

echo "=========================================="
echo "  Fixing Employee Add Modal Issue"
echo "=========================================="
echo ""

PROJECT_ROOT=$(pwd)
echo "Working directory: $PROJECT_ROOT"
echo ""

# ============================================
# STEP 1: Fix employees.html
# ============================================
echo "=== STEP 1: Fixing employees.html ==="

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
                <li><a href="#" onclick="logout()" style="color: #ff6b6b;">🚪 Logout</a></li>
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

    <script src="../js/auth-check.js"></script>
    <script src="../js/employees.js"></script>
</body>
</html>
ENDHTML

echo "✓ employees.html created"
echo ""

# ============================================
# STEP 2: Fix employees.js
# ============================================
echo "=== STEP 2: Fixing employees.js ==="

cat > frontend/js/employees.js << 'ENDJS'
const API_URL = 'http://localhost:3000/api';
let editingEmployeeId = null;

console.log('employees.js loaded');

async function loadEmployees() {
    console.log('Loading employees...');
    try {
        const response = await fetch(API_URL + '/employees');
        const data = await response.json();
        const tbody = document.querySelector('#employeesTable tbody');
        
        if (data.employees && data.employees.length > 0) {
            tbody.innerHTML = '';
            data.employees.forEach(function(emp) {
                const row = document.createElement('tr');
                row.innerHTML = 
                    '<td>' + emp.employee_id + '</td>' +
                    '<td>' + emp.first_name + ' ' + emp.last_name + '</td>' +
                    '<td>' + emp.email + '</td>' +
                    '<td>' + (emp.department || 'N/A') + '</td>' +
                    '<td>' + (emp.position || 'N/A') + '</td>' +
                    '<td>$' + parseFloat(emp.salary).toFixed(2) + '</td>' +
                    '<td><span class="status-' + emp.status + '">' + emp.status + '</span></td>' +
                    '<td>' +
                        '<button class="btn btn-sm btn-warning edit-btn" data-id="' + emp.employee_id + '">Edit</button> ' +
                        '<button class="btn btn-sm btn-danger delete-btn" data-id="' + emp.employee_id + '">Delete</button>' +
                    '</td>';
                tbody.appendChild(row);
            });
            attachActionButtons();
            console.log('✓ Loaded ' + data.employees.length + ' employees');
        } else {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;">No employees found. Click "+ Add Employee" to add one.</td></tr>';
            console.log('No employees found');
        }
    } catch (error) {
        console.error('Error loading employees:', error);
        alert('Failed to load employees: ' + error.message);
    }
}

function attachActionButtons() {
    document.querySelectorAll('.edit-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            editEmployee(this.getAttribute('data-id'));
        });
    });
    document.querySelectorAll('.delete-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            deleteEmployee(this.getAttribute('data-id'));
        });
    });
}

function openAddModal() {
    console.log('openAddModal() called');
    const modal = document.getElementById('employeeModal');
    console.log('Modal element:', modal);
    
    editingEmployeeId = null;
    document.getElementById('modalTitle').textContent = 'Add Employee';
    document.getElementById('employeeForm').reset();
    document.getElementById('employee_id').disabled = false;
    modal.style.display = 'block';
    
    console.log('Modal display set to:', modal.style.display);
}

async function editEmployee(id) {
    console.log('Editing employee:', id);
    try {
        const response = await fetch(API_URL + '/employees/' + id);
        const data = await response.json();
        const emp = data.employee;
        
        if (!emp) {
            alert('Employee not found');
            return;
        }
        
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
        console.error('Error loading employee:', error);
        alert('Failed to load employee: ' + error.message);
    }
}

async function deleteEmployee(id) {
    if (!confirm('Are you sure you want to delete this employee?')) return;
    
    console.log('Deleting employee:', id);
    try {
        const response = await fetch(API_URL + '/employees/' + id, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            alert('Employee deleted successfully');
            loadEmployees();
        } else {
            alert('Failed to delete employee');
        }
    } catch (error) {
        console.error('Error deleting employee:', error);
        alert('Failed to delete employee: ' + error.message);
    }
}

function closeModal() {
    console.log('closeModal() called');
    document.getElementById('employeeModal').style.display = 'none';
}

async function handleEmployeeSubmit(e) {
    e.preventDefault();
    console.log('Form submitted');
    
    const formData = {
        employee_id: document.getElementById('employee_id').value,
        first_name: document.getElementById('first_name').value,
        last_name: document.getElementById('last_name').value,
        email: document.getElementById('email').value,
        phone: document.getElementById('phone').value,
        department: document.getElementById('department').value,
        position: document.getElementById('position').value,
        join_date: document.getElementById('join_date').value,
        salary: parseFloat(document.getElementById('salary').value),
        status: document.getElementById('status').value
    };
    
    console.log('Form data:', formData);
    
    try {
        const url = editingEmployeeId 
            ? API_URL + '/employees/' + editingEmployeeId
            : API_URL + '/employees';
        
        console.log('Posting to:', url);
        
        const response = await fetch(url, {
            method: editingEmployeeId ? 'PUT' : 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(formData)
        });
        
        const result = await response.json();
        console.log('Response:', result);
        
        if (response.ok) {
            alert(editingEmployeeId ? 'Employee updated successfully!' : 'Employee added successfully!');
            closeModal();
            loadEmployees();
        } else {
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error saving employee:', error);
        alert('Failed to save employee: ' + error.message);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded - Initializing employees page');
    
    loadEmployees();
    
    const addBtn = document.getElementById('addEmployeeBtn');
    console.log('Add button element:', addBtn);
    if (addBtn) {
        addBtn.addEventListener('click', function() {
            console.log('Add button clicked!');
            openAddModal();
        });
        console.log('✓ Add button listener attached');
    } else {
        console.error('✗ Add button not found!');
    }
    
    const closeBtn = document.getElementById('closeModalBtn');
    if (closeBtn) {
        closeBtn.addEventListener('click', closeModal);
        console.log('✓ Close button listener attached');
    }
    
    const cancelBtn = document.getElementById('cancelBtn');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', closeModal);
        console.log('✓ Cancel button listener attached');
    }
    
    const form = document.getElementById('employeeForm');
    console.log('Form element:', form);
    if (form) {
        form.addEventListener('submit', handleEmployeeSubmit);
        console.log('✓ Form submit listener attached');
    } else {
        console.error('✗ Form not found!');
    }
    
    window.onclick = function(event) {
        const modal = document.getElementById('employeeModal');
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };
    
    console.log('✓ Initialization complete');
});
ENDJS

node -c frontend/js/employees.js && echo "✓ employees.js - No syntax errors" || echo "✗ employees.js - Has syntax errors"
echo ""

# ============================================
# STEP 3: Verify Modal CSS
# ============================================
echo "=== STEP 3: Checking modal CSS ==="

if grep -q ".modal {" frontend/css/style.css; then
    echo "✓ Modal CSS exists"
else
    echo "✗ Modal CSS missing - Adding it"
    cat >> frontend/css/style.css << 'ENDCSS'

/* Modal styles */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background-color: rgba(0,0,0,0.4);
}

.modal-content {
    background-color: #fefefe;
    margin: 5% auto;
    padding: 20px;
    border: 1px solid #888;
    border-radius: 10px;
    width: 90%;
    max-width: 600px;
    max-height: 85vh;
    overflow-y: auto;
}

.close {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
}

.close:hover,
.close:focus {
    color: black;
    text-decoration: none;
    cursor: pointer;
}
ENDCSS
    echo "✓ Added modal CSS"
fi
echo ""

# ============================================
# STEP 4: Update attendance.html
# ============================================
echo "=== STEP 4: Updating attendance.html ==="

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
                <li><a href="#" onclick="logout()" style="color: #ff6b6b;">🚪 Logout</a></li>
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

    <script src="../js/auth-check.js"></script>
    <script src="../js/attendance.js"></script>
</body>
</html>
ENDATTHTML

echo "✓ attendance.html updated"
echo ""

# ============================================
# STEP 5: Update attendance.js
# ============================================
echo "=== STEP 5: Updating attendance.js ==="

cat > frontend/js/attendance.js << 'ENDATTJS'
const API_URL = 'http://localhost:3000/api';

console.log('attendance.js loaded');

async function loadAttendance() {
    try {
        const response = await fetch(API_URL + '/attendance');
        const data = await response.json();
        displayAttendance(data.attendance || []);
    } catch (error) {
        console.error('Error loading attendance:', error);
    }
}

function displayAttendance(records) {
    const tbody = document.querySelector('#attendanceTable tbody');
    if (records.length > 0) {
        tbody.innerHTML = '';
        records.forEach(function(att) {
            const row = document.createElement('tr');
            row.innerHTML = 
                '<td>' + att.date + '</td>' +
                '<td>' + att.employee_id + '</td>' +
                '<td>' + att.first_name + ' ' + att.last_name + '</td>' +
                '<td>' + (att.check_in || 'N/A') + '</td>' +
                '<td>' + (att.check_out || 'N/A') + '</td>' +
                '<td>' + (att.hours_worked ? parseFloat(att.hours_worked).toFixed(2) : '0') + '</td>' +
                '<td><span class="status-' + att.status + '">' + att.status + '</span></td>';
            tbody.appendChild(row);
        });
    } else {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:20px;">No attendance records found.</td></tr>';
    }
}

async function loadEmployeesDropdown() {
    try {
        const response = await fetch(API_URL + '/employees');
        const data = await response.json();
        const select = document.getElementById('att_employee_id');
        const filterSelect = document.getElementById('filterEmployee');
        const options = (data.employees || [])
            .filter(function(emp) { return emp.status === 'active'; })
            .map(function(emp) {
                return '<option value="' + emp.employee_id + '">' + emp.employee_id + ' - ' + emp.first_name + ' ' + emp.last_name + '</option>';
            }).join('');
        select.innerHTML = '<option value="">Select Employee</option>' + options;
        filterSelect.innerHTML = '<option value="">All Employees</option>' + options;
    } catch (error) {
        console.error('Error loading employees:', error);
    }
}

function openAttendanceModal() {
    console.log('Opening attendance modal');
    document.getElementById('attendanceForm').reset();
    document.getElementById('att_date').value = new Date().toISOString().split('T')[0];
    document.getElementById('attendanceModal').style.display = 'block';
}

function closeAttendanceModal() {
    document.getElementById('attendanceModal').style.display = 'none';
}

async function filterAttendance() {
    const date = document.getElementById('filterDate').value;
    const employeeId = document.getElementById('filterEmployee').value;
    try {
        const response = await fetch(API_URL + '/attendance');
        const data = await response.json();
        let filtered = data.attendance || [];
        if (date) {
            filtered = filtered.filter(function(att) { return att.date === date; });
        }
        if (employeeId) {
            filtered = filtered.filter(function(att) { return att.employee_id === employeeId; });
        }
        displayAttendance(filtered);
    } catch (error) {
        console.error('Error filtering attendance:', error);
    }
}

async function handleAttendanceSubmit(e) {
    e.preventDefault();
    const formData = {
        employee_id: document.getElementById('att_employee_id').value,
        date: document.getElementById('att_date').value,
        check_in: document.getElementById('check_in').value,
        check_out: document.getElementById('check_out').value,
        status: document.getElementById('att_status').value
    };
    try {
        const response = await fetch(API_URL + '/attendance', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        });
        if (response.ok) {
            alert('Attendance marked successfully');
            closeAttendanceModal();
            loadAttendance();
        } else {
            const result = await response.json();
            alert('Failed: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to mark attendance');
    }
}

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing attendance page');
    loadAttendance();
    loadEmployeesDropdown();
    const addBtn = document.getElementById('addAttendanceBtn');
    if (addBtn) {
        addBtn.addEventListener('click', openAttendanceModal);
    }
    const closeBtn = document.getElementById('closeAttendanceModalBtn');
    if (closeBtn) {
        closeBtn.addEventListener('click', closeAttendanceModal);
    }
    const cancelBtn = document.getElementById('cancelAttendanceBtn');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', closeAttendanceModal);
    }
    const form = document.getElementById('attendanceForm');
    if (form) {
        form.addEventListener('submit', handleAttendanceSubmit);
    }
    window.onclick = function(event) {
        const modal = document.getElementById('attendanceModal');
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };
});
ENDATTJS

node -c frontend/js/attendance.js && echo "✓ attendance.js - No syntax errors" || echo "✗ attendance.js - Has syntax errors"
echo ""

# ============================================
# STEP 6: Verify all files
# ============================================
echo "=== STEP 6: Verifying all JavaScript files ==="

cd frontend/js
for file in app.js login.js auth-check.js employees.js attendance.js payroll.js; do
    if [ -f "$file" ]; then
        if node -c "$file" 2>/dev/null; then
            echo "  ✓ $file"
        else
            echo "  ✗ $file - has errors"
        fi
    else
        echo "  ✗ $file - missing"
    fi
done
cd ../..
echo ""

echo "=========================================="
echo "  Fix Complete!"
echo "=========================================="
echo ""
echo "What was fixed:"
echo "  ✓ employees.html - Button with ID"
echo "  ✓ employees.js - Event listeners"
echo "  ✓ Modal CSS verified"
echo "  ✓ attendance.html & js updated"
echo "  ✓ All syntax checked"
echo ""
echo "Next steps:"
echo "  1. Restart server: cd backend && npm run dev"
echo "  2. Clear browser cache (Ctrl+Shift+Delete)"
echo "  3. Go to: http://localhost:3000"
echo "  4. Login: admin / admin123"
echo "  5. Go to Employees page"
echo "  6. Click '+ Add Employee'"
echo ""
echo "Check browser console (F12) for debug logs!"
echo "=========================================="

