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
