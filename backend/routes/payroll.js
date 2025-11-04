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
