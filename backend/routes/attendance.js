const express = require('express');
const router = express.Router();
const db = require('../database');

// Get all attendance records
router.get('/', (req, res) => {
    const sql = `SELECT a.*, e.first_name, e.last_name 
                 FROM attendance a 
                 JOIN employees e ON a.employee_id = e.employee_id 
                 ORDER BY a.date DESC`;
    
    db.all(sql, [], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ attendance: rows });
    });
});

// Get attendance by employee
router.get('/employee/:id', (req, res) => {
    const sql = 'SELECT * FROM attendance WHERE employee_id = ? ORDER BY date DESC';
    db.all(sql, [req.params.id], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ attendance: rows });
    });
});

// Mark attendance
router.post('/', (req, res) => {
    const { employee_id, date, check_in, check_out, status } = req.body;
    
    // Calculate hours worked
    let hours_worked = 0;
    if (check_in && check_out) {
        const inTime = new Date(`2000-01-01 ${check_in}`);
        const outTime = new Date(`2000-01-01 ${check_out}`);
        hours_worked = (outTime - inTime) / (1000 * 60 * 60);
    }

    const sql = `INSERT INTO attendance 
        (employee_id, date, check_in, check_out, hours_worked, status)
        VALUES (?, ?, ?, ?, ?, ?)`;

    db.run(sql, [employee_id, date, check_in, check_out, hours_worked, status],
        function(err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({ id: this.lastID, message: 'Attendance marked successfully' });
        }
    );
});

// Update attendance
router.put('/:id', (req, res) => {
    const { check_in, check_out, status } = req.body;
    
    let hours_worked = 0;
    if (check_in && check_out) {
        const inTime = new Date(`2000-01-01 ${check_in}`);
        const outTime = new Date(`2000-01-01 ${check_out}`);
        hours_worked = (outTime - inTime) / (1000 * 60 * 60);
    }

    const sql = `UPDATE attendance SET 
        check_in = ?, check_out = ?, hours_worked = ?, status = ?
        WHERE id = ?`;

    db.run(sql, [check_in, check_out, hours_worked, status, req.params.id],
        function(err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({ message: 'Attendance updated successfully' });
        }
    );
});

// Get monthly attendance summary
router.get('/summary/:month/:year', (req, res) => {
    const { month, year } = req.params;
    
    const sql = `SELECT 
        e.employee_id, e.first_name, e.last_name,
        COUNT(a.id) as days_present,
        SUM(a.hours_worked) as total_hours
        FROM employees e
        LEFT JOIN attendance a ON e.employee_id = a.employee_id
        AND strftime('%m', a.date) = ?
        AND strftime('%Y', a.date) = ?
        WHERE e.status = 'active'
        GROUP BY e.employee_id`;

    db.all(sql, [month.padStart(2, '0'), year], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ summary: rows });
    });
});

module.exports = router;
