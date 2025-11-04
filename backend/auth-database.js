const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Auth database path
const authDbPath = path.resolve(__dirname, '../database/auth.db');

// Create connection
const authDb = new sqlite3.Database(authDbPath, (err) => {
    if (err) {
        console.error('Error opening auth database:', err.message);
    } else {
        console.log('Connected to Auth database');
    }
});

module.exports = authDb;
