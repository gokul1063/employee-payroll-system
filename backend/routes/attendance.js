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
