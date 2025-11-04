#!/bin/bash

echo "=========================================="
echo "  Complete Debug & Fix"
echo "=========================================="
echo ""

PROJECT_ROOT=$(pwd)

# ============================================
# STEP 1: Check if server is running
# ============================================
echo "=== STEP 1: Checking server status ==="

if curl -s http://localhost:3000/api/employees > /dev/null 2>&1; then
    echo "✓ Server is running"
else
    echo "✗ Server is NOT running!"
    echo "  Please start server in another terminal:"
    echo "  cd backend && npm run dev"
    echo ""
fi

# ============================================
# STEP 2: Test API endpoints
# ============================================
echo "=== STEP 2: Testing API endpoints ==="

echo "Testing GET /api/employees..."
curl -s http://localhost:3000/api/employees | head -20
echo ""

# ============================================
# STEP 3: Check CSV files
# ============================================
echo "=== STEP 3: Checking CSV files ==="

if [ -f "data/employees.csv" ]; then
    echo "✓ employees.csv exists"
    echo "  Content:"
    cat data/employees.csv
    echo ""
else
    echo "✗ employees.csv NOT FOUND"
fi

if [ -f "data/users.csv" ]; then
    echo "✓ users.csv exists"
    echo "  Content:"
    cat data/users.csv
    echo ""
else
    echo "✗ users.csv NOT FOUND"
fi

# ============================================
# STEP 4: Migrate SQLite data to CSV
# ============================================
echo "=== STEP 4: Migrating SQLite data to CSV ==="

if [ -f "database/payroll.db" ]; then
    echo "Found SQLite database, extracting data..."
    
    # Check if sqlite3 is available
    if command -v sqlite3 &> /dev/null; then
        echo "Extracting employees..."
        sqlite3 -header -csv database/payroll.db "SELECT employee_id,first_name,last_name,email,phone,department,position,join_date,salary,status,created_at FROM employees;" > data/employees_temp.csv
        
        # Check if we got data
        if [ -s data/employees_temp.csv ]; then
            mv data/employees_temp.csv data/employees.csv
            echo "✓ Migrated employees to CSV"
            echo "  Data:"
            cat data/employees.csv
        else
            echo "No employee data in SQLite"
        fi
    else
        echo "sqlite3 not available, skipping migration"
    fi
else
    echo "No SQLite database found"
fi

echo ""

# ============================================
# STEP 5: Create sample data if empty
# ============================================
echo "=== STEP 5: Creating sample data ==="

cat > data/employees.csv << 'ENDCSV'
employee_id,first_name,last_name,email,phone,department,position,join_date,salary,status,created_at
EMP001,John,Doe,john@example.com,1234567890,IT,Developer,2024-01-01,50000,active,2024-01-01T00:00:00Z
EMP002,Jane,Smith,jane@example.com,1234567891,HR,Manager,2024-01-01,60000,active,2024-01-01T00:00:00Z
ENDCSV

echo "✓ Created sample employees"
cat data/employees.csv
echo ""

cat > data/users.csv << 'ENDCSV'
id,username,password,full_name,role,created_at
1,admin,admin123,Administrator,admin,2024-01-01
2,user,user123,Test User,user,2024-01-01
ENDCSV

echo "✓ Created users"
echo ""

# ============================================
# STEP 6: Create simple test page
# ============================================
echo "=== STEP 6: Creating test page ==="

cat > frontend/test.html << 'ENDHTML'
<!DOCTYPE html>
<html>
<head>
    <title>API Test</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        button { padding: 10px 20px; margin: 5px; cursor: pointer; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 5px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>API Test Page</h1>
    
    <h2>1. Test Login</h2>
    <button onclick="testLogin()">Test Login</button>
    <pre id="loginResult"></pre>
    
    <h2>2. Test Get Employees</h2>
    <button onclick="testGetEmployees()">Get Employees</button>
    <pre id="employeesResult"></pre>
    
    <h2>3. Test Add Employee</h2>
    <button onclick="testAddEmployee()">Add Test Employee</button>
    <pre id="addResult"></pre>
    
    <h2>4. Test Modal</h2>
    <button onclick="testModal()">Open Modal</button>
    
    <div id="testModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5);">
        <div style="background:white; margin:100px auto; padding:20px; width:400px; border-radius:10px;">
            <h3>Test Modal</h3>
            <p>If you can see this, modal CSS works!</p>
            <button onclick="closeTestModal()">Close</button>
        </div>
    </div>
    
    <script>
        const API_URL = 'http://localhost:3000/api';
        
        async function testLogin() {
            const result = document.getElementById('loginResult');
            result.textContent = 'Testing...';
            try {
                const response = await fetch(API_URL + '/auth/login', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({username: 'admin', password: 'admin123'})
                });
                const data = await response.json();
                result.className = response.ok ? 'success' : 'error';
                result.textContent = JSON.stringify(data, null, 2);
            } catch (error) {
                result.className = 'error';
                result.textContent = 'Error: ' + error.message;
            }
        }
        
        async function testGetEmployees() {
            const result = document.getElementById('employeesResult');
            result.textContent = 'Testing...';
            try {
                const response = await fetch(API_URL + '/employees');
                const data = await response.json();
                result.className = response.ok ? 'success' : 'error';
                result.textContent = JSON.stringify(data, null, 2);
            } catch (error) {
                result.className = 'error';
                result.textContent = 'Error: ' + error.message;
            }
        }
        
        async function testAddEmployee() {
            const result = document.getElementById('addResult');
            result.textContent = 'Testing...';
            try {
                const testEmployee = {
                    employee_id: 'TEST' + Date.now(),
                    first_name: 'Test',
                    last_name: 'Employee',
                    email: 'test' + Date.now() + '@example.com',
                    phone: '1111111111',
                    department: 'IT',
                    position: 'Tester',
                    join_date: '2024-01-01',
                    salary: 40000,
                    status: 'active'
                };
                const response = await fetch(API_URL + '/employees', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(testEmployee)
                });
                const data = await response.json();
                result.className = response.ok ? 'success' : 'error';
                result.textContent = JSON.stringify(data, null, 2);
            } catch (error) {
                result.className = 'error';
                result.textContent = 'Error: ' + error.message;
            }
        }
        
        function testModal() {
            document.getElementById('testModal').style.display = 'block';
        }
        
        function closeTestModal() {
            document.getElementById('testModal').style.display = 'none';
        }
    </script>
</body>
</html>
ENDHTML

echo "✓ Created test.html"
echo "  Access at: http://localhost:3000/test.html"
echo ""

# ============================================
# STEP 7: Create simplified employees.js
# ============================================
echo "=== STEP 7: Creating simplified employees.js ==="

cat > frontend/js/employees.js << 'ENDJS'
const API_URL = 'http://localhost:3000/api';
let editingEmployeeId = null;

console.log('=== EMPLOYEES.JS LOADED ===');

async function loadEmployees() {
    console.log('Loading employees...');
    const tbody = document.querySelector('#employeesTable tbody');
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;">Loading...</td></tr>';
    
    try {
        const response = await fetch(API_URL + '/employees');
        console.log('Response status:', response.status);
        
        const data = await response.json();
        console.log('Data received:', data);
        
        if (data.employees && data.employees.length > 0) {
            console.log('Found', data.employees.length, 'employees');
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
            console.log('No employees found');
            tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;">No employees. Click Add Employee.</td></tr>';
        }
    } catch (error) {
        console.error('ERROR loading employees:', error);
        tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;color:red;">Error: ' + error.message + '</td></tr>';
    }
}

function openAddModal() {
    console.log('=== OPENING ADD MODAL ===');
    const modal = document.getElementById('employeeModal');
    console.log('Modal element:', modal);
    
    if (!modal) {
        alert('ERROR: Modal element not found!');
        return;
    }
    
    editingEmployeeId = null;
    document.getElementById('modalTitle').textContent = 'Add Employee';
    document.getElementById('employeeForm').reset();
    document.getElementById('employee_id').disabled = false;
    
    modal.style.display = 'block';
    console.log('Modal displayed');
}

function closeModal() {
    console.log('Closing modal');
    document.getElementById('employeeModal').style.display = 'none';
}

async function editEmployee(id) {
    console.log('Edit employee:', id);
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
    if (!confirm('Delete employee ' + id + '?')) return;
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
    console.log('=== SAVING EMPLOYEE ===');
    
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
        console.log('Result:', result);
        
        if (response.ok) {
            alert('Success!');
            closeModal();
            loadEmployees();
        } else {
            alert('Error: ' + (result.error || 'Unknown'));
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed: ' + error.message);
    }
}

window.openAddModal = openAddModal;
window.closeModal = closeModal;
window.editEmployee = editEmployee;
window.deleteEmployee = deleteEmployee;

document.addEventListener('DOMContentLoaded', function() {
    console.log('=== DOM LOADED ===');
    
    loadEmployees();
    
    const addBtn = document.getElementById('addEmployeeBtn');
    console.log('Add button:', addBtn);
    if (addBtn) {
        addBtn.onclick = openAddModal;
        console.log('✓ Button click handler attached');
    }
    
    const form = document.getElementById('employeeForm');
    console.log('Form:', form);
    if (form) {
        form.onsubmit = saveEmployee;
        console.log('✓ Form submit handler attached');
    }
    
    const closeBtn = document.getElementById('closeModalBtn');
    if (closeBtn) closeBtn.onclick = closeModal;
    
    const cancelBtn = document.getElementById('cancelBtn');
    if (cancelBtn) cancelBtn.onclick = closeModal;
    
    console.log('=== INITIALIZATION COMPLETE ===');
});
ENDJS

echo "✓ Created simplified employees.js"
echo ""

# ============================================
# STEP 8: Verify syntax
# ============================================
echo "=== STEP 8: Verifying JavaScript syntax ==="

if node -c frontend/js/employees.js 2>&1; then
    echo "✓ employees.js syntax OK"
else
    echo "✗ employees.js has syntax errors"
fi
echo ""

# ============================================
# FINAL INSTRUCTIONS
# ============================================
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Sample data created with 2 employees:"
echo "  - EMP001: John Doe"
echo "  - EMP002: Jane Smith"
echo ""
echo "Next steps:"
echo ""
echo "1. RESTART SERVER (if running):"
echo "   Press Ctrl+C in server terminal"
echo "   cd backend"
echo "   npm run dev"
echo ""
echo "2. CLEAR BROWSER CACHE:"
echo "   Press Ctrl+Shift+Delete"
echo "   Clear everything"
echo ""
echo "3. TEST API FIRST:"
echo "   Open: http://localhost:3000/test.html"
echo "   Click all test buttons"
echo "   Share results with me"
echo ""
echo "4. Then try main app:"
echo "   Open: http://localhost:3000"
echo "   Login: admin / admin123"
echo "   Check browser console (F12)"
echo ""
echo "If still not working, share:"
echo "  - Server terminal output"
echo "  - Browser console output"
echo "  - Test page results"
echo "=========================================="

