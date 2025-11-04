const express = require('express');
const router = express.Router();
const db = require('../database');

// Get all employees
router.get('/', (req, res) => {
    const sql = 'SELECT * FROM employees ORDER BY created_at DESC';
    db.all(sql, [], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ employees: rows });
    });
});

// Get single employee
router.get('/:id', (req, res) => {
    const sql = 'SELECT * FROM employees WHERE employee_id = ?';
    db.get(sql, [req.params.id], (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ employee: row });
    });
});

// Create employee
router.post('/', (req, res) => {
    const {
        employee_id, first_name, last_name, email, phone,
        department, position, join_date, salary
    } = req.body;

    const sql = `INSERT INTO employees 
        (employee_id, first_name, last_name, email, phone, department, position, join_date, salary)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    db.run(sql, [employee_id, first_name, last_name, email, phone, department, position, join_date, salary],
        function(err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({ id: this.lastID, message: 'Employee created successfully' });
        }
    );
});

// Update employee
router.put('/:id', (req, res) => {
    const {
        first_name, last_name, email, phone,
        department, position, salary, status
    } = req.body;

    const sql = `UPDATE employees SET 
        first_name = ?, last_name = ?, email = ?, phone = ?,
        department = ?, position = ?, salary = ?, status = ?
        WHERE employee_id = ?`;

    db.run(sql, [first_name, last_name, email, phone, department, position, salary, status, req.params.id],
        function(err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({ message: 'Employee updated successfully', changes: this.changes });
        }
    );
});

// Delete employee
router.delete('/:id', (req, res) => {
    const sql = 'DELETE FROM employees WHERE employee_id = ?';
    db.run(sql, [req.params.id], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ message: 'Employee deleted successfully', changes: this.changes });
    });
});

// Get employee statistics
router.get('/stats/dashboard', (req, res) => {
    const queries = {
        total: 'SELECT COUNT(*) as count FROM employees WHERE status = "active"',
        departments: 'SELECT department, COUNT(*) as count FROM employees WHERE status = "active" GROUP BY department',
        recent: 'SELECT * FROM employees ORDER BY created_at DESC LIMIT 5'
    };

    const stats = {};

    db.get(queries.total, [], (err, row) => {
        stats.total = row ? row.count : 0;

        db.all(queries.departments, [], (err, rows) => {
            stats.departments = rows || [];

            db.all(queries.recent, [], (err, rows) => {
                stats.recent = rows || [];
                res.json(stats);
            });
        });
    });
});

module.exports = router;
