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
