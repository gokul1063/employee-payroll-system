#!/bin/bash

echo "=========================================="
echo "  Converting to CSV-Based System"
echo "=========================================="
echo ""

PROJECT_ROOT=$(pwd)
echo "Project root: $PROJECT_ROOT"
echo ""

# ============================================
# STEP 1: Backup SQLite Databases
# ============================================
echo "=== STEP 1: Backing up SQLite databases ==="

mkdir -p database-backup
if [ -f "database/payroll.db" ]; then
    cp database/payroll.db database-backup/payroll.db.backup
    echo "✓ Backed up payroll.db"
fi

if [ -f "database/auth.db" ]; then
    cp database/auth.db database-backup/auth.db.backup
    echo "✓ Backed up auth.db"
fi

echo "✓ Databases backed up to: database-backup/"
echo ""

# ============================================
# STEP 2: Create CSV Data Directory
# ============================================
echo "=== STEP 2: Creating CSV data structure ==="

mkdir -p data
echo "✓ Created data/ directory"
echo ""

# ============================================
# STEP 3: Create CSV Data Files
# ============================================
echo "=== STEP 3: Creating CSV files ==="

cat > data/employees.csv << 'EOF'
employee_id,first_name,last_name,email,phone,department,position,join_date,salary,status,created_at
EOF
echo "✓ Created employees.csv"

cat > data/attendance.csv << 'EOF'
id,employee_id,date,check_in,check_out,hours_worked,status,created_at
EOF
echo "✓ Created attendance.csv"

cat > data/payroll.csv << 'EOF'
id,employee_id,month,year,basic_salary,allowances,deductions,overtime_hours,overtime_pay,net_salary,payment_date,status,created_at
EOF
echo "✓ Created payroll.csv"

cat > data/users.csv << 'EOF'
id,username,password,full_name,role,created_at
1,admin,admin123,Administrator,admin,2024-01-01 00:00:00
2,user,user123,Test User,user,2024-01-01 00:00:00
EOF
echo "✓ Created users.csv with default users"
echo ""

# ============================================
# STEP 4: Install CSV Dependencies
# ============================================
echo "=== STEP 4: Installing CSV dependencies ==="

cd backend
npm install csv-parser csv-writer --save
echo "✓ Installed csv-parser and csv-writer"
cd ..
echo ""

# ============================================
# STEP 5: Create CSV Database Module
# ============================================
echo "=== STEP 5: Creating CSV database module ==="

cat > backend/csv-db.js << 'ENDCSV'
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const dataDir = path.resolve(__dirname, '../data');

function readCSV(filename) {
    return new Promise((resolve, reject) => {
        const results = [];
        const filePath = path.join(dataDir, filename);
        
        if (!fs.existsSync(filePath)) {
            resolve([]);
            return;
        }
        
        fs.createReadStream(filePath)
            .pipe(csv())
            .on('data', (data) => results.push(data))
            .on('end', () => resolve(results))
            .on('error', (error) => reject(error));
    });
}

function writeCSV(filename, data, headers) {
    const filePath = path.join(dataDir, filename);
    const csvWriter = createCsvWriter({
        path: filePath,
        header: headers
    });
    return csvWriter.writeRecords(data);
}

const employeeHeaders = [
    {id: 'employee_id', title: 'employee_id'},
    {id: 'first_name', title: 'first_name'},
    {id: 'last_name', title: 'last_name'},
    {id: 'email', title: 'email'},
    {id: 'phone', title: 'phone'},
    {id: 'department', title: 'department'},
    {id: 'position', title: 'position'},
    {id: 'join_date', title: 'join_date'},
    {id: 'salary', title: 'salary'},
    {id: 'status', title: 'status'},
    {id: 'created_at', title: 'created_at'}
];

const attendanceHeaders = [
    {id: 'id', title: 'id'},
    {id: 'employee_id', title: 'employee_id'},
    {id: 'date', title: 'date'},
    {id: 'check_in', title: 'check_in'},
    {id: 'check_out', title: 'check_out'},
    {id: 'hours_worked', title: 'hours_worked'},
    {id: 'status', title: 'status'},
    {id: 'created_at', title: 'created_at'}
];

const payrollHeaders = [
    {id: 'id', title: 'id'},
    {id: 'employee_id', title: 'employee_id'},
    {id: 'month', title: 'month'},
    {id: 'year', title: 'year'},
    {id: 'basic_salary', title: 'basic_salary'},
    {id: 'allowances', title: 'allowances'},
    {id: 'deductions', title: 'deductions'},
    {id: 'overtime_hours', title: 'overtime_hours'},
    {id: 'overtime_pay', title: 'overtime_pay'},
    {id: 'net_salary', title: 'net_salary'},
    {id: 'payment_date', title: 'payment_date'},
    {id: 'status', title: 'status'},
    {id: 'created_at', title: 'created_at'}
];

module.exports = {
    async getAllEmployees() {
        return await readCSV('employees.csv');
    },
    
    async getEmployeeById(id) {
        const employees = await readCSV('employees.csv');
        return employees.find(emp => emp.employee_id === id);
    },
    
    async addEmployee(employee) {
        const employees = await readCSV('employees.csv');
        employee.created_at = new Date().toISOString();
        employees.push(employee);
        await writeCSV('employees.csv', employees, employeeHeaders);
        return employee;
    },
    
    async updateEmployee(id, updatedData) {
        const employees = await readCSV('employees.csv');
        const index = employees.findIndex(emp => emp.employee_id === id);
        if (index !== -1) {
            employees[index] = { ...employees[index], ...updatedData };
            await writeCSV('employees.csv', employees, employeeHeaders);
            return true;
        }
        return false;
    },
    
    async deleteEmployee(id) {
        const employees = await readCSV('employees.csv');
        const filtered = employees.filter(emp => emp.employee_id !== id);
        await writeCSV('employees.csv', filtered, employeeHeaders);
        return true;
    },
    
    async getAllAttendance() {
        const attendance = await readCSV('attendance.csv');
        const employees = await readCSV('employees.csv');
        return attendance.map(att => {
            const emp = employees.find(e => e.employee_id === att.employee_id);
            return {
                ...att,
                first_name: emp ? emp.first_name : '',
                last_name: emp ? emp.last_name : ''
            };
        });
    },
    
    async addAttendance(attendance) {
        const records = await readCSV('attendance.csv');
        attendance.id = String(records.length + 1);
        attendance.created_at = new Date().toISOString();
        records.push(attendance);
        await writeCSV('attendance.csv', records, attendanceHeaders);
        return attendance;
    },
    
    async getAllPayroll() {
        const payroll = await readCSV('payroll.csv');
        const employees = await readCSV('employees.csv');
        return payroll.map(pay => {
            const emp = employees.find(e => e.employee_id === pay.employee_id);
            return {
                ...pay,
                first_name: emp ? emp.first_name : '',
                last_name: emp ? emp.last_name : '',
                department: emp ? emp.department : ''
            };
        });
    },
    
    async generatePayroll(month, year) {
        const employees = await readCSV('employees.csv');
        const payroll = await readCSV('payroll.csv');
        const activeEmployees = employees.filter(emp => emp.status === 'active');
        
        for (const emp of activeEmployees) {
            const basic_salary = parseFloat(emp.salary);
            const allowances = basic_salary * 0.2;
            const deductions = basic_salary * 0.1;
            const net_salary = basic_salary + allowances - deductions;
            
            payroll.push({
                id: String(payroll.length + 1),
                employee_id: emp.employee_id,
                month: month,
                year: String(year),
                basic_salary: String(basic_salary),
                allowances: String(allowances),
                deductions: String(deductions),
                overtime_hours: '0',
                overtime_pay: '0',
                net_salary: String(net_salary),
                payment_date: '',
                status: 'pending',
                created_at: new Date().toISOString()
            });
        }
        
        await writeCSV('payroll.csv', payroll, payrollHeaders);
        return true;
    },
    
    async updatePayrollStatus(id, status, payment_date) {
        const payroll = await readCSV('payroll.csv');
        const index = payroll.findIndex(p => p.id === id);
        if (index !== -1) {
            payroll[index].status = status;
            payroll[index].payment_date = payment_date;
            await writeCSV('payroll.csv', payroll, payrollHeaders);
            return true;
        }
        return false;
    },
    
    async getPayrollSummary(month, year) {
        const payroll = await readCSV('payroll.csv');
        const filtered = payroll.filter(p => p.month === month && p.year === year);
        return {
            total_employees: filtered.length,
            total_basic: filtered.reduce((sum, p) => sum + parseFloat(p.basic_salary || 0), 0),
            total_allowances: filtered.reduce((sum, p) => sum + parseFloat(p.allowances || 0), 0),
            total_deductions: filtered.reduce((sum, p) => sum + parseFloat(p.deductions || 0), 0),
            total_overtime: filtered.reduce((sum, p) => sum + parseFloat(p.overtime_pay || 0), 0),
            total_payout: filtered.reduce((sum, p) => sum + parseFloat(p.net_salary || 0), 0)
        };
    },
    
    async authenticateUser(username, password) {
        const users = await readCSV('users.csv');
        return users.find(u => u.username === username && u.password === password);
    }
};
ENDCSV

echo "✓ Created csv-db.js"
echo ""

# ============================================
# STEP 6: Update Routes to Use CSV
# ============================================
echo "=== STEP 6: Updating routes for CSV ==="

cat > backend/routes/employees.js << 'ENDROUTE'
const express = require('express');
const router = express.Router();
const csvDb = require('../csv-db');

router.get('/', async (req, res) => {
    try {
        const employees = await csvDb.getAllEmployees();
        res.json({ employees });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/stats/dashboard', async (req, res) => {
    try {
        const employees = await csvDb.getAllEmployees();
        const active = employees.filter(e => e.status === 'active');
        const departments = {};
        active.forEach(emp => {
            departments[emp.department] = (departments[emp.department] || 0) + 1;
        });
        res.json({
            total: active.length,
            departments: Object.keys(departments).map(d => ({department: d, count: departments[d]})),
            recent: employees.slice(-5).reverse()
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    try {
        const employee = await csvDb.getEmployeeById(req.params.id);
        res.json({ employee });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', async (req, res) => {
    try {
        const employee = await csvDb.addEmployee(req.body);
        res.json({ message: 'Employee created successfully', employee });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.put('/:id', async (req, res) => {
    try {
        await csvDb.updateEmployee(req.params.id, req.body);
        res.json({ message: 'Employee updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        await csvDb.deleteEmployee(req.params.id);
        res.json({ message: 'Employee deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
ENDROUTE

echo "✓ Updated employees.js route"

cat > backend/routes/attendance.js << 'ENDATT'
const express = require('express');
const router = express.Router();
const csvDb = require('../csv-db');

router.get('/', async (req, res) => {
    try {
        const attendance = await csvDb.getAllAttendance();
        res.json({ attendance });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', async (req, res) => {
    try {
        const { employee_id, date, check_in, check_out, status } = req.body;
        let hours_worked = 0;
        if (check_in && check_out) {
            const inTime = new Date('2000-01-01 ' + check_in);
            const outTime = new Date('2000-01-01 ' + check_out);
            hours_worked = (outTime - inTime) / (1000 * 60 * 60);
        }
        const attendance = await csvDb.addAttendance({
            employee_id, date, check_in, check_out,
            hours_worked: String(hours_worked), status
        });
        res.json({ message: 'Attendance marked successfully', attendance });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
ENDATT

echo "✓ Updated attendance.js route"

cat > backend/routes/payroll.js << 'ENDPAY'
const express = require('express');
const router = express.Router();
const csvDb = require('../csv-db');

router.get('/', async (req, res) => {
    try {
        const payroll = await csvDb.getAllPayroll();
        res.json({ payroll });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/generate', async (req, res) => {
    try {
        const { month, year } = req.body;
        await csvDb.generatePayroll(month, year);
        res.json({ message: 'Payroll generated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.put('/:id/status', async (req, res) => {
    try {
        const { status, payment_date } = req.body;
        await csvDb.updatePayrollStatus(req.params.id, status, payment_date);
        res.json({ message: 'Payroll status updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/summary/:month/:year', async (req, res) => {
    try {
        const summary = await csvDb.getPayrollSummary(req.params.month, req.params.year);
        res.json({ summary });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
ENDPAY

echo "✓ Updated payroll.js route"

cat > backend/routes/auth.js << 'ENDAUTH'
const express = require('express');
const router = express.Router();
const csvDb = require('../csv-db');

const sessions = new Map();

function generateToken() {
    return Math.random().toString(36).substring(2) + Date.now().toString(36);
}

router.post('/login', async (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password required' });
    }
    const user = await csvDb.authenticateUser(username, password);
    if (!user) {
        return res.status(401).json({ error: 'Invalid username or password' });
    }
    const token = generateToken();
    sessions.set(token, {
        userId: user.id,
        username: user.username,
        fullName: user.full_name,
        role: user.role
    });
    res.json({
        success: true,
        token: token,
        user: {
            username: user.username,
            fullName: user.full_name,
            role: user.role
        }
    });
});

router.post('/logout', (req, res) => {
    const authHeader = req.headers.authorization;
    const token = authHeader ? authHeader.replace('Bearer ', '') : null;
    if (token) sessions.delete(token);
    res.json({ success: true, message: 'Logged out successfully' });
});

router.get('/verify', (req, res) => {
    const authHeader = req.headers.authorization;
    const token = authHeader ? authHeader.replace('Bearer ', '') : null;
    if (!token) {
        return res.status(401).json({ error: 'No token provided' });
    }
    const session = sessions.get(token);
    if (!session) {
        return res.status(401).json({ error: 'Invalid or expired token' });
    }
    res.json({ valid: true, user: session });
});

module.exports = router;
ENDAUTH

echo "✓ Updated auth.js route"
echo ""

# ============================================
# STEP 7: Update server.js
# ============================================
echo "=== STEP 7: Updating server.js ==="

cat > backend/server.js << 'ENDSERVER'
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const authRoutes = require('./routes/auth');
const employeeRoutes = require('./routes/employees');
const payrollRoutes = require('./routes/payroll');
const attendanceRoutes = require('./routes/attendance');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../frontend')));

app.use('/api/auth', authRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/payroll', payrollRoutes);
app.use('/api/attendance', attendanceRoutes);

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/login.html'));
});

app.listen(PORT, () => {
    console.log('==========================================');
    console.log('  Payroll System - CSV Version');
    console.log('==========================================');
    console.log('  Server: http://localhost:' + PORT);
    console.log('  Database: CSV files in data/');
    console.log('  Status: Running');
    console.log('==========================================');
});
ENDSERVER

echo "✓ Updated server.js"
echo ""

# ============================================
# STEP 8: Fix employees.js frontend
# ============================================
echo "=== STEP 8: Fixing frontend employees.js ==="

cat > frontend/js/employees.js << 'ENDEMP'
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
        } else {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;">No employees found.</td></tr>';
        }
    } catch (error) {
        console.error('Error:', error);
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
    console.log('Opening modal');
    editingEmployeeId = null;
    document.getElementById('modalTitle').textContent = 'Add Employee';
    document.getElementById('employeeForm').reset();
    document.getElementById('employee_id').disabled = false;
    document.getElementById('employeeModal').style.display = 'block';
}

async function editEmployee(id) {
    try {
        const response = await fetch(API_URL + '/employees/' + id);
        const data = await response.json();
        const emp = data.employee;
        if (!emp) return;
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
        console.error('Error:', error);
    }
}

async function deleteEmployee(id) {
    if (!confirm('Delete this employee?')) return;
    try {
        const response = await fetch(API_URL + '/employees/' + id, {
            method: 'DELETE'
        });
        if (response.ok) {
            alert('Employee deleted');
            loadEmployees();
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

function closeModal() {
    document.getElementById('employeeModal').style.display = 'none';
}

async function handleEmployeeSubmit(e) {
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
        salary: parseFloat(document.getElementById('salary').value),
        status: document.getElementById('status').value
    };
    try {
        const url = editingEmployeeId 
            ? API_URL + '/employees/' + editingEmployeeId
            : API_URL + '/employees';
        const response = await fetch(url, {
            method: editingEmployeeId ? 'PUT' : 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(formData)
        });
        const result = await response.json();
        if (response.ok) {
            alert(editingEmployeeId ? 'Updated!' : 'Added!');
            closeModal();
            loadEmployees();
        } else {
            alert('Error: ' + (result.error || 'Unknown'));
        }
    } catch (error) {
        alert('Failed: ' + error.message);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing');
    loadEmployees();
    const addBtn = document.getElementById('addEmployeeBtn');
    if (addBtn) {
        addBtn.addEventListener('click', openAddModal);
        console.log('Button ready');
    }
    const closeBtn = document.getElementById('closeModalBtn');
    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    const cancelBtn = document.getElementById('cancelBtn');
    if (cancelBtn) cancelBtn.addEventListener('click', closeModal);
    const form = document.getElementById('employeeForm');
    if (form) {
        form.addEventListener('submit', handleEmployeeSubmit);
    }
    window.onclick = function(event) {
        const modal = document.getElementById('employeeModal');
        if (event.target == modal) modal.style.display = 'none';
    };
});
ENDEMP

echo "✓ Fixed employees.js"
echo ""

# ============================================
# STEP 9: Create README
# ============================================
echo "=== STEP 9: Creating documentation ==="

cat > README-CSV.md << 'ENDREADME'
# Payroll System - CSV Version

## Features
- CSV-based storage (no SQLite needed!)
- Portable - works on any machine with Node.js
- Easy to backup - just copy data/ folder
- Can edit data in Excel/LibreOffice

## Data Files
- data/employees.csv - Employee records
- data/attendance.csv - Attendance records
- data/payroll.csv - Payroll records
- data/users.csv - Login credentials

## SQLite Backups
Your original SQLite databases are backed up in:
- database-backup/payroll.db.backup
- database-backup/auth.db.backup

## Running the System
npm run dev

## Login
Username: admin
Password: admin123

## For Your Friend
Just copy the entire project folder and run:
cd backend
npm install
npm run dev
ENDREADME

echo "✓ Created README-CSV.md"
echo ""

echo "=========================================="
echo "  Conversion Complete!"
echo "=========================================="
echo ""
echo "✓ SQLite databases backed up to: database-backup/"
echo "✓ System converted to CSV format"
echo "✓ Data files in: data/"
echo ""
echo "To start the server:"
echo "  cd backend"
echo "  npm run dev"
echo ""
echo "Your CSV files:"
echo "  data/employees.csv"
echo "  data/attendance.csv"
echo "  data/payroll.csv"
echo "  data/users.csv"
echo ""
echo "Login: admin / admin123"
echo "=========================================="

