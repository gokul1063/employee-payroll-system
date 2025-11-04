const express = require('express');
const router = express.Router();
const authDb = require('../auth-database');

// Simple session storage (in production, use Redis or proper session management)
const sessions = new Map();

// Generate simple session token
function generateToken() {
    return Math.random().toString(36).substring(2) + Date.now().toString(36);
}

// Login
router.post('/login', (req, res) => {
    const { username, password } = req.body;
    
    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password required' });
    }
    
    const sql = 'SELECT * FROM users WHERE username = ? AND password = ?';
    
    authDb.get(sql, [username, password], (err, user) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        
        if (!user) {
            return res.status(401).json({ error: 'Invalid username or password' });
        }
        
        // Create session
        const token = generateToken();
        sessions.set(token, {
            userId: user.id,
            username: user.username,
            fullName: user.full_name,
            role: user.role,
            loginTime: new Date()
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
});

// Logout
router.post('/logout', (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (token) {
        sessions.delete(token);
    }
    
    res.json({ success: true, message: 'Logged out successfully' });
});

// Verify token
router.get('/verify', (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
        return res.status(401).json({ error: 'No token provided' });
    }
    
    const session = sessions.get(token);
    
    if (!session) {
        return res.status(401).json({ error: 'Invalid or expired token' });
    }
    
    res.json({
        valid: true,
        user: {
            username: session.username,
            fullName: session.fullName,
            role: session.role
        }
    });
});

// Middleware to check authentication
function requireAuth(req, res, next) {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
        return res.status(401).json({ error: 'Authentication required' });
    }
    
    const session = sessions.get(token);
    
    if (!session) {
        return res.status(401).json({ error: 'Invalid or expired session' });
    }
    
    req.user = session;
    next();
}

module.exports = router;
module.exports.requireAuth = requireAuth;
