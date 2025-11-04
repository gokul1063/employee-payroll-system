#!/bin/bash

echo "=========================================="
echo "  Fixing Final 3 Issues"
echo "=========================================="
echo ""

# ============================================
# ISSUE 1: Fix attendance.js - Mark button
# ============================================
echo "=== ISSUE 1: Fixing Mark Attendance button ==="

cat > frontend/js/attendance.js << 'ENDATTJS'
console.log('✓ attendance.js loaded');

async function loadAttendance() {
    console.log('Loading attendance...');
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
        tbody.innerHTML = records.map(att => 
            '<tr><td>' + att.date + '</td><td>' + att.employee_id + '</td><td>' + att.first_name + ' ' + att.last_name + 
            '</td><td>' + (att.check_in || 'N/A') + '</td><td>' + (att.check_out || 'N/A') + '</td><td>' + 
            (att.hours_worked ? parseFloat(att.hours_worked).toFixed(2) : '0') + '</td><td><span class="status-' + 
            att.status + '">' + att.status + '</span></td></tr>'
        ).join('');
        console.log('✓ Displayed ' + records.length + ' attendance records');
    } else {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:20px;">No attendance records found.</td></tr>';
    }
}

async function loadEmployeesDropdown() {
    console.log('Loading employees dropdown...');
    try {
        const response = await fetch(API_URL + '/employees');
        const data = await response.json();
        const employees = data.employees || [];
        const activeEmployees = employees.filter(e => e.status === 'active');
        
        const options = activeEmployees.map(e => 
            '<option value="' + e.employee_id + '">' + e.employee_id + ' - ' + e.first_name + ' ' + e.last_name + '</option>'
        ).join('');
        
        document.getElementById('att_employee_id').innerHTML = '<option value="">Select Employee</option>' + options;
        document.getElementById('filterEmployee').innerHTML = '<option value="">All Employees</option>' + options;
        
        console.log('✓ Loaded ' + activeEmployees.length + ' active employees');
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
    console.log('Closing attendance modal');
    document.getElementById('attendanceModal').style.display = 'none';
}

async function filterAttendance() {
    const date = document.getElementById('filterDate').value;
    const empId = document.getElementById('filterEmployee').value;
    
    try {
        const response = await fetch(API_URL + '/attendance');
        const data = await response.json();
        let filtered = data.attendance || [];
        
        if (date) filtered = filtered.filter(a => a.date === date);
        if (empId) filtered = filtered.filter(a => a.employee_id === empId);
        
        displayAttendance(filtered);
    } catch (error) {
        console.error('Error filtering:', error);
    }
}

async function handleAttendanceSubmit(e) {
    e.preventDefault();
    console.log('Submitting attendance...');
    
    const formData = {
        employee_id: document.getElementById('att_employee_id').value,
        date: document.getElementById('att_date').value,
        check_in: document.getElementById('check_in').value,
        check_out: document.getElementById('check_out').value,
        status: document.getElementById('att_status').value
    };
    
    console.log('Form data:', formData);
    
    try {
        const response = await fetch(API_URL + '/attendance', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(formData)
        });
        
        const result = await response.json();
        console.log('Result:', result);
        
        if (response.ok) {
            alert('Attendance marked successfully!');
            closeAttendanceModal();
            loadAttendance();
        } else {
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed: ' + error.message);
    }
}

window.openAttendanceModal = openAttendanceModal;
window.closeAttendanceModal = closeAttendanceModal;
window.filterAttendance = filterAttendance;

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing attendance page');
    
    loadAttendance();
    loadEmployeesDropdown();
    
    const addBtn = document.getElementById('addAttendanceBtn');
    if (addBtn) {
        addBtn.onclick = openAttendanceModal;
        console.log('✓ Mark Attendance button attached');
    } else {
        console.error('✗ Mark Attendance button not found!');
    }
    
    const closeBtn = document.getElementById('closeAttendanceModalBtn');
    if (closeBtn) closeBtn.onclick = closeAttendanceModal;
    
    const cancelBtn = document.getElementById('cancelAttendanceBtn');
    if (cancelBtn) cancelBtn.onclick = closeAttendanceModal;
    
    const form = document.getElementById('attendanceForm');
    if (form) {
        form.onsubmit = handleAttendanceSubmit;
        console.log('✓ Form handler attached');
    } else {
        console.error('✗ Form not found!');
    }
    
    console.log('Attendance page ready');
});
ENDATTJS

echo "✓ Fixed attendance.js"
echo ""

# ============================================
# ISSUE 2: Fix payroll summary calculation
# ============================================
echo "=== ISSUE 2: Fixing payroll summary ==="

cat > backend/routes/payroll.js << 'ENDPAYROUTE'
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
        console.log('Generating payroll for:', month, year);
        await csvDb.generatePayroll(month, year);
        res.json({ message: 'Payroll generated successfully' });
    } catch (error) {
        console.error('Error generating payroll:', error);
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
        const { month, year } = req.params;
        console.log('Getting summary for:', month, year);
        
        const allPayroll = await csvDb.getAllPayroll();
        console.log('Total payroll records:', allPayroll.length);
        
        // Filter for the specific month and year
        const filtered = allPayroll.filter(p => {
            const matches = p.month === month && p.year === year;
            if (matches) {
                console.log('Matched payroll:', p);
            }
            return matches;
        });
        
        console.log('Filtered records:', filtered.length);
        
        const summary = {
            total_employees: filtered.length,
            total_basic: filtered.reduce((sum, p) => sum + parseFloat(p.basic_salary || 0), 0),
            total_allowances: filtered.reduce((sum, p) => sum + parseFloat(p.allowances || 0), 0),
            total_deductions: filtered.reduce((sum, p) => sum + parseFloat(p.deductions || 0), 0),
            total_overtime: filtered.reduce((sum, p) => sum + parseFloat(p.overtime_pay || 0), 0),
            total_payout: filtered.reduce((sum, p) => sum + parseFloat(p.net_salary || 0), 0)
        };
        
        console.log('Summary:', summary);
        res.json({ summary });
    } catch (error) {
        console.error('Error getting summary:', error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
ENDPAYROUTE

echo "✓ Fixed payroll route with better logging"
echo ""

# ============================================
# ISSUE 3: Fix dashboard stats
# ============================================
echo "=== ISSUE 3: Fixing dashboard statistics ==="

cat > frontend/js/app.js << 'ENDAPPJS'
console.log('✓ app.js loaded');

async function loadDashboard() {
    console.log('Loading dashboard...');
    
    try {
        // Get employee stats
        const statsRes = await fetch(API_URL + '/employees/stats/dashboard');
        const stats = await statsRes.json();
        console.log('Employee stats:', stats);
        
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
        
        // Get today's attendance
        const today = new Date().toISOString().split('T')[0];
        console.log('Today:', today);
        
        const attRes = await fetch(API_URL + '/attendance');
        const attData = await attRes.json();
        console.log('All attendance:', attData);
        
        const todayAtt = (attData.attendance || []).filter(a => a.date === today);
        console.log('Today attendance count:', todayAtt.length);
        
        document.getElementById('todayAttendance').textContent = todayAtt.length;
        
        // Get current month payroll
        const currentMonth = String(new Date().getMonth() + 1).padStart(2, '0');
        const currentYear = String(new Date().getFullYear());
        console.log('Current month/year:', currentMonth, currentYear);
        
        const payrollRes = await fetch(API_URL + '/payroll/summary/' + currentMonth + '/' + currentYear);
        const payrollData = await payrollRes.json();
        console.log('Payroll summary:', payrollData);
        
        const totalPayout = payrollData.summary?.total_payout || 0;
        document.getElementById('monthlyPayroll').textContent = '$' + totalPayout.toFixed(2);
        
        console.log('✓ Dashboard loaded');
        
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

if (window.location.pathname.endsWith('index.html') || window.location.pathname === '/') {
    document.addEventListener('DOMContentLoaded', loadDashboard);
}
ENDAPPJS

echo "✓ Fixed app.js with better logging"
echo ""

# ============================================
# Check and display sample data
# ============================================
echo "=== Checking data files ==="

echo "Employees:"
head -3 data/employees.csv
echo ""

echo "Attendance:"
head -3 data/attendance.csv
echo ""

echo "Payroll:"
head -3 data/payroll.csv
echo ""

echo "Users:"
head -3 data/users.csv
echo ""

# ============================================
# Verify all files
# ============================================
echo "=== Verifying JavaScript files ==="

for file in config.js app.js auth-check.js employees.js attendance.js payroll.js; do
    if node -c frontend/js/$file 2>/dev/null; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file - error"
    fi
done
echo ""

echo "=========================================="
echo "  Final Fixes Complete!"
echo "=========================================="
echo ""
echo "What was fixed:"
echo "  ✓ Mark Attendance button now works"
echo "  ✓ Payroll summary calculation fixed"
echo "  ✓ Dashboard statistics fixed"
echo "  ✓ Added extensive console logging"
echo ""
echo "Next steps:"
echo ""
echo "1. Restart server:"
echo "   cd backend"
echo "   Press Ctrl+C to stop"
echo "   npm run dev"
echo ""
echo "2. Clear browser cache (Ctrl+Shift+Delete)"
echo ""
echo "3. Open browser with console (F12)"
echo ""
echo "4. Login and test:"
echo "   a) Dashboard - check console logs"
echo "   b) Attendance - click Mark Attendance"
echo "   c) Payroll - generate for current month"
echo "   d) Check server terminal for logs"
echo ""
echo "5. To see summary values:"
echo "   - Go to Payroll"
echo "   - Click Generate Payroll"
echo "   - Select current month/year"
echo "   - Click Generate"
echo "   - Summary should show values"
echo "   - Refresh Dashboard to see updated stats"
echo ""
echo "All components now have console.log debugging!"
echo "Check browser console and server terminal for details."
echo "=========================================="

