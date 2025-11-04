#!/bin/bash

echo "=========================================="
echo "  Payroll System - Portable Setup"
echo "=========================================="
echo ""

PROJECT_ROOT=$(pwd)
echo "✓ Project root: $PROJECT_ROOT"
echo ""

# ============================================
# PART 1: Fix Current SQLite Version
# ============================================
echo "=== PART 1: Fixing Current Version ==="
echo ""

echo "Step 1: Fixing employees.js..."
cat > frontend/js/employees.js << 'EMPJS'
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
        console.log('Employees loaded');
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
    console.log('Opening add modal');
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
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            alert(editingEmployeeId ? 'Employee updated!' : 'Employee added!');
            closeModal();
            loadEmployees();
        } else {
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Failed: ' + error.message);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing employees page');
    
    loadEmployees();
    
    const addBtn = document.getElementById('addEmployeeBtn');
    if (addBtn) {
        addBtn.addEventListener('click', openAddModal);
        console.log('Add button ready');
    }
    
    const closeBtn = document.getElementById('closeModalBtn');
    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    
    const cancelBtn = document.getElementById('cancelBtn');
    if (cancelBtn) cancelBtn.addEventListener('click', closeModal);
    
    const form = document.getElementById('employeeForm');
    if (form) {
        form.addEventListener('submit', handleEmployeeSubmit);
        console.log('Form ready');
    }
    
    window.onclick = function(event) {
        const modal = document.getElementById('employeeModal');
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    };
});
EMPJS

node -c frontend/js/employees.js && echo "✓ employees.js fixed" || echo "✗ employees.js has errors"
echo ""

# ============================================
# PART 2: Create CSV-Based Portable Version
# ============================================
echo "=== PART 2: Creating Portable CSV Version ==="
echo ""

# Create CSV directory
mkdir -p backend-csv
mkdir -p data-csv

echo "Step 2: Creating CSV data files..."

# Create CSV files
cat > data-csv/employees.csv << 'EMPCSV'
employee_id,first_name,last_name,email,phone,department,position,join_date,salary,status,created_at
EMPCSV

cat > data-csv/attendance.csv << 'ATTCSV'
id,employee_id,date,check_in,check_out,hours_worked,status,created_at
ATTCSV

cat > data-csv/payroll.csv << 'PAYCSV'
id,employee_id,month,year,basic_salary,allowances,deductions,overtime_hours,overtime_pay,net_salary,payment_date,status,created_at
PAYCSV

cat > data-csv/users.csv << 'USERCSV'
id,username,password,full_name,role,created_at
1,admin,admin123,Administrator,admin,2024-01-01
2,user,user123,Test User,user,2024-01-01
USERCSV

echo "✓ CSV files created"
echo ""

echo "Step 3: Installing CSV parser..."
cd backend
npm install csv-parser csv-writer --save 2>&1 | grep -E "added|up to date"
cd ..
echo "✓ CSV packages installed"
echo ""

echo "Step 4: Creating CSV database module..."
cat > backend-csv/csv-database.js << 'CSVDB'
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const dataDir = path.resolve(__dirname, '../data-csv');

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

module.exports = {
    readCSV,
    writeCSV,
    
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
        
        await writeCSV('employees.csv', employees, [
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
        ]);
        
        return employee;
    },
    
    async updateEmployee(id, updatedData) {
        const employees = await readCSV('employees.csv');
        const index = employees.findIndex(emp => emp.employee_id === id);
        
        if (index !== -1) {
            employees[index] = { ...employees[index], ...updatedData };
            await writeCSV('employees.csv', employees, [
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
            ]);
            return true;
        }
        return false;
    },
    
    async deleteEmployee(id) {
        const employees = await readCSV('employees.csv');
        const filtered = employees.filter(emp => emp.employee_id !== id);
        
        await writeCSV('employees.csv', filtered, [
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
        ]);
        
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
        
        await writeCSV('attendance.csv', records, [
            {id: 'id', title: 'id'},
            {id: 'employee_id', title: 'employee_id'},
            {id: 'date', title: 'date'},
            {id: 'check_in', title: 'check_in'},
            {id: 'check_out', title: 'check_out'},
            {id: 'hours_worked', title: 'hours_worked'},
            {id: 'status', title: 'status'},
            {id: 'created_at', title: 'created_at'}
        ]);
        
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
        
        await writeCSV('payroll.csv', payroll, [
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
        ]);
        
        return true;
    },
    
    async updatePayrollStatus(id, status, payment_date) {
        const payroll = await readCSV('payroll.csv');
        const index = payroll.findIndex(p => p.id === id);
        
        if (index !== -1) {
            payroll[index].status = status;
            payroll[index].payment_date = payment_date;
            
            await writeCSV('payroll.csv', payroll, [
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
            ]);
            
            return true;
        }
        return false;
    },
    
    async authenticateUser(username, password) {
        const users = await readCSV('users.csv');
        return users.find(u => u.username === username && u.password === password);
    }
};
CSVDB

echo "✓ CSV database module created"
echo ""

echo "Step 5: Creating CSV-based server..."
cat > backend-csv/server-csv.js << 'CSVSERVER'
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const csvDb = require('./csv-database');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../frontend')));

const sessions = new Map();

function generateToken() {
    return Math.random().toString(36).substring(2) + Date.now().toString(36);
}

// Auth routes
app.post('/api/auth/login', async (req, res) => {
    const { username, password } = req.body;
    
    const user = await csvDb.authenticateUser(username, password);
    
    if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
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

app.post('/api/auth/logout', (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (token) sessions.delete(token);
    res.json({ success: true });
});

app.get('/api/auth/verify', (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const session = sessions.get(token);
    
    if (!session) {
        return res.status(401).json({ error: 'Invalid token' });
    }
    
    res.json({ valid: true, user: session });
});

// Employee routes
app.get('/api/employees', async (req, res) => {
    try {
        const employees = await csvDb.getAllEmployees();
        res.json({ employees });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/employees/:id', async (req, res) => {
    try {
        const employee = await csvDb.getEmployeeById(req.params.id);
        res.json({ employee });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/employees', async (req, res) => {
    try {
        const employee = await csvDb.addEmployee(req.body);
        res.json({ message: 'Employee added', employee });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/employees/:id', async (req, res) => {
    try {
        await csvDb.updateEmployee(req.params.id, req.body);
        res.json({ message: 'Employee updated' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/employees/:id', async (req, res) => {
    try {
        await csvDb.deleteEmployee(req.params.id);
        res.json({ message: 'Employee deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/employees/stats/dashboard', async (req, res) => {
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

// Attendance routes
app.get('/api/attendance', async (req, res) => {
    try {
        const attendance = await csvDb.getAllAttendance();
        res.json({ attendance });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/attendance', async (req, res) => {
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
        
        res.json({ message: 'Attendance marked', attendance });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Payroll routes
app.get('/api/payroll', async (req, res) => {
    try {
        const payroll = await csvDb.getAllPayroll();
        res.json({ payroll });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/payroll/generate', async (req, res) => {
    try {
        const { month, year } = req.body;
        await csvDb.generatePayroll(month, year);
        res.json({ message: 'Payroll generated' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/payroll/:id/status', async (req, res) => {
    try {
        const { status, payment_date } = req.body;
        await csvDb.updatePayrollStatus(req.params.id, status, payment_date);
        res.json({ message: 'Payroll updated' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/payroll/summary/:month/:year', async (req, res) => {
    try {
        const payroll = await csvDb.getAllPayroll();
        const filtered = payroll.filter(p => p.month === req.params.month && p.year === req.params.year);
        
        const summary = {
            total_employees: filtered.length,
            total_basic: filtered.reduce((sum, p) => sum + parseFloat(p.basic_salary || 0), 0),
            total_allowances: filtered.reduce((sum, p) => sum + parseFloat(p.allowances || 0), 0),
            total_deductions: filtered.reduce((sum, p) => sum + parseFloat(p.deductions || 0), 0),
            total_overtime: filtered.reduce((sum, p) => sum + parseFloat(p.overtime_pay || 0), 0),
            total_payout: filtered.reduce((sum, p) => sum + parseFloat(p.net_salary || 0), 0)
        };
        
        res.json({ summary });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/login.html'));
});

app.listen(PORT, () => {
    console.log('==========================================');
    console.log('  Payroll System - CSV Version');
    console.log('==========================================');
    console.log('  Server: http://localhost:' + PORT);
    console.log('  Data: CSV files in data-csv/');
    console.log('  Status: Running');
    console.log('==========================================');
});
CSVSERVER

echo "✓ CSV server created"
echo ""

echo "Step 6: Creating package.json for CSV version..."
cat > backend-csv/package.json << 'PKGJSON'
{
  "name": "payroll-csv",
  "version": "1.0.0",
  "description": "Payroll System with CSV storage",
  "main": "server-csv.js",
  "scripts": {
    "start": "node server-csv.js",
    "dev": "nodemon server-csv.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2",
    "csv-parser": "^3.0.0",
    "csv-writer": "^1.6.0"
  }
}
PKGJSON

echo "✓ package.json created"
echo ""

echo "Step 7: Installing CSV dependencies..."
cd backend-csv
npm install 2>&1 | grep -E "added|up to date"
cd ..
echo "✓ Dependencies installed"
echo ""

echo "Step 8: Creating startup scripts..."

cat > start-sqlite.sh << 'STARTSQLITE'
#!/bin/bash
echo "Starting SQLite version..."
cd backend
npm run dev
STARTSQLITE
chmod +x start-sqlite.sh

cat > start-csv.sh << 'STARTCSV'
#!/bin/bash
echo "Starting CSV version (Portable)..."
cd backend-csv
npm start
STARTCSV
chmod +x start-csv.sh

cat > start-csv-dev.sh << 'STARTCSVDEV'
#!/bin/bash
echo "Starting CSV version (Development)..."
cd backend-csv
npm run dev
STARTCSVDEV
chmod +x start-csv-dev.sh

echo "✓ Startup scripts created"
echo ""

echo "Step 9: Creating README..."
cat > README-VERSIONS.md << 'README'
# Payroll System - Two Versions

## SQLite Version (Original)
- Uses SQLite databases
- Data stored in: database/payroll.db and database/auth.db
- Port: 3000
- Start: ./start-sqlite.sh

## CSV Version (Portable)
- Uses CSV files (no SQLite needed)
- Data stored in: data-csv/*.csv
- Port: 3001
- Start: ./start-csv.sh
- Portable - Can run on any machine with Node.js

## Usage

### Run SQLite Version:
```bash
./start-sqlite.sh
# Visit: http://localhost:3000
