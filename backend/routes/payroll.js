const express = require('express');
const router = express.Router();
const db = require('../database');

// Get all payroll records
router.get('/', (req, res) => {
    const sql = `SELECT p.*, e.first_name, e.last_name, e.department 
                 FROM payroll p 
                 JOIN employees e ON p.employee_id = e.employee_id 
                 ORDER BY p.year DESC, p.month DESC`;
    
    db.all(sql, [], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ payroll: rows });
    });
});

// Get payroll by employee
router.get('/employee/:id', (req, res) => {
    const sql = 'SELECT * FROM payroll WHERE employee_id = ? ORDER BY year DESC, month DESC';
    db.all(sql, [req.params.id], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ payroll: rows });
    });
});

// Generate payroll for a month
router.post('/generate', (req, res) => {
    const { month, year } = req.body;
    
    // Get all active employees
    db.all('SELECT * FROM employees WHERE status = "active"', [], (err, employees) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }

        employees.forEach(emp => {
            // Calculate attendance for the month
            const attendanceSql = `SELECT SUM(hours_worked) as total_hours 
                                  FROM attendance 
                                  WHERE employee_id = ? 
                                  AND strftime('%m', date) = ? 
                                  AND strftime('%Y', date) = ?`;

            db.get(attendanceSql, [emp.employee_id, month.padStart(2, '0'), year], (err, attendance) => {
                const total_hours = attendance ? attendance.total_hours || 0 : 0;
                const standard_hours = 160; // 8 hours * 20 days
                const overtime_hours = Math.max(0, total_hours - standard_hours);
                const overtime_pay = overtime_hours * (emp.salary / standard_hours) * 1.5;

                const basic_salary = emp.salary;
                const allowances = basic_salary * 0.2; // 20% allowances
                const deductions = basic_salary * 0.1; // 10% deductions (tax, etc.)
                const net_salary = basic_salary + allowances - deductions + overtime_pay;

                const insertSql = `INSERT INTO payroll 
                    (employee_id, month, year, basic_salary, allowances, deductions, 
                     overtime_hours, overtime_pay, net_salary, status)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')`;

                db.run(insertSql, [emp.employee_id, month, year, basic_salary, allowances, 
                                  deductions, overtime_hours, overtime_pay, net_salary]);
            });
        });

        res.json({ message: 'Payroll generated successfully' });
    });
});

// Update payroll status
router.put('/:id/status', (req, res) => {
    const { status, payment_date } = req.body;
    const sql = 'UPDATE payroll SET status = ?, payment_date = ? WHERE id = ?';
    
    db.run(sql, [status, payment_date, req.params.id], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ message: 'Payroll status updated successfully' });
    });
});

// Get payroll summary
router.get('/summary/:month/:year', (req, res) => {
    const { month, year } = req.params;
    
    const sql = `SELECT 
        COUNT(*) as total_employees,
        SUM(basic_salary) as total_basic,
        SUM(allowances) as total_allowances,
        SUM(deductions) as total_deductions,
        SUM(overtime_pay) as total_overtime,
        SUM(net_salary) as total_payout
        FROM payroll 
        WHERE month = ? AND year = ?`;

    db.get(sql, [month, year], (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ summary: row });
    });
});

module.exports = router;
