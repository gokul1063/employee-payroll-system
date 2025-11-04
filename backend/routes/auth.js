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
