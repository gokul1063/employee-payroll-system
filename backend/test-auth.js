const authDb = require('./auth-database');

console.log('Testing auth database...\n');

// Test 1: Check if database is connected
console.log('Test 1: Database connection');
authDb.get('SELECT 1 as test', [], (err, row) => {
    if (err) {
        console.error('✗ Database connection failed:', err.message);
    } else {
        console.log('✓ Database connected');
    }
});

// Test 2: Check if users table exists
console.log('\nTest 2: Users table');
authDb.all('SELECT * FROM users', [], (err, rows) => {
    if (err) {
        console.error('✗ Users table error:', err.message);
    } else {
        console.log('✓ Users table exists');
        console.log('Users found:', rows.length);
        rows.forEach(user => {
            console.log(`  - ${user.username} (${user.full_name})`);
        });
    }
});

// Test 3: Test login query
console.log('\nTest 3: Login query');
const testUsername = 'admin';
const testPassword = 'admin123';
authDb.get('SELECT * FROM users WHERE username = ? AND password = ?', 
    [testUsername, testPassword], 
    (err, user) => {
        if (err) {
            console.error('✗ Login query error:', err.message);
        } else if (user) {
            console.log('✓ Login successful for:', user.username);
            console.log('User data:', user);
        } else {
            console.log('✗ No user found with those credentials');
        }
        
        setTimeout(() => process.exit(0), 100);
    }
);
