#!/bin/bash

echo "=========================================="
echo "  Network Error Debug"
echo "=========================================="
echo ""

# ============================================
# STEP 1: Check if server is running
# ============================================
echo "=== STEP 1: Checking if server is running ==="

if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✓ Server is responding on port 3000"
else
    echo "✗ Server is NOT responding on port 3000"
    echo ""
    echo "Checking if something else is using port 3000..."
    lsof -i :3000 2>/dev/null || echo "Nothing is using port 3000"
    echo ""
    echo "You need to start the server!"
    echo "In a separate terminal, run:"
    echo "  cd backend"
    echo "  npm run dev"
    exit 1
fi
echo ""

# ============================================
# STEP 2: Test login API endpoint
# ============================================
echo "=== STEP 2: Testing login API endpoint ==="

echo "Testing POST /api/auth/login..."
response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

echo "HTTP Status: $http_code"
echo "Response: $body"

if [ "$http_code" = "200" ]; then
    echo "✓ Login API works!"
else
    echo "✗ Login API failed!"
fi
echo ""

# ============================================
# STEP 3: Check users.csv
# ============================================
echo "=== STEP 3: Checking users.csv ==="

if [ -f "data/users.csv" ]; then
    echo "✓ users.csv exists"
    echo "Content:"
    cat data/users.csv
else
    echo "✗ users.csv missing!"
    echo "Creating it now..."
    cat > data/users.csv << 'EOF'
id,username,password,full_name,role,created_at
1,admin,admin123,Administrator,admin,2024-01-01
2,user,user123,Test User,user,2024-01-01
EOF
    echo "✓ Created users.csv"
fi
echo ""

# ============================================
# STEP 4: Check backend routes
# ============================================
echo "=== STEP 4: Testing all API endpoints ==="

echo "GET /api/employees:"
curl -s http://localhost:3000/api/employees | head -50
echo ""

echo "GET /api/attendance:"
curl -s http://localhost:3000/api/attendance | head -50
echo ""

echo "GET /api/payroll:"
curl -s http://localhost:3000/api/payroll | head -50
echo ""

# ============================================
# STEP 5: Check config.js
# ============================================
echo "=== STEP 5: Checking frontend config ==="

if [ -f "frontend/js/config.js" ]; then
    echo "✓ config.js exists"
    cat frontend/js/config.js
else
    echo "✗ config.js missing!"
fi
echo ""

# ============================================
# STEP 6: Create simple test page
# ============================================
echo "=== STEP 6: Creating direct test page ==="

cat > frontend/direct-test.html << 'TESTHTML'
<!DOCTYPE html>
<html>
<head>
    <title>Direct Test</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        button { padding: 10px; margin: 5px; }
        pre { background: #f0f0f0; padding: 10px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>Direct API Test</h1>
    
    <h2>Test 1: Check API_URL</h2>
    <button onclick="test1()">Check Config</button>
    <pre id="result1"></pre>
    
    <h2>Test 2: Test Login API</h2>
    <button onclick="test2()">Test Login</button>
    <pre id="result2"></pre>
    
    <h2>Test 3: Manual Login</h2>
    <input type="text" id="user" placeholder="username" value="admin">
    <input type="password" id="pass" placeholder="password" value="admin123">
    <button onclick="test3()">Login</button>
    <pre id="result3"></pre>
    
    <script>
        function test1() {
            const result = document.getElementById('result1');
            result.textContent = 'API_URL = ' + (typeof API_URL !== 'undefined' ? API_URL : 'UNDEFINED!');
            result.className = typeof API_URL !== 'undefined' ? 'success' : 'error';
        }
        
        async function test2() {
            const result = document.getElementById('result2');
            result.textContent = 'Testing...';
            try {
                const response = await fetch('http://localhost:3000/api/auth/login', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({username: 'admin', password: 'admin123'})
                });
                const data = await response.json();
                result.className = response.ok ? 'success' : 'error';
                result.textContent = 'Status: ' + response.status + '\n' + JSON.stringify(data, null, 2);
            } catch (error) {
                result.className = 'error';
                result.textContent = 'ERROR: ' + error.message;
            }
        }
        
        async function test3() {
            const result = document.getElementById('result3');
            const username = document.getElementById('user').value;
            const password = document.getElementById('pass').value;
            result.textContent = 'Logging in as: ' + username;
            try {
                const response = await fetch('http://localhost:3000/api/auth/login', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({username, password})
                });
                const data = await response.json();
                result.className = response.ok ? 'success' : 'error';
                result.textContent = 'Status: ' + response.status + '\n' + JSON.stringify(data, null, 2);
                if (response.ok) {
                    result.textContent += '\n\nSUCCESS! Token: ' + data.token;
                }
            } catch (error) {
                result.className = 'error';
                result.textContent = 'ERROR: ' + error.message;
            }
        }
    </script>
    <script src="js/config.js"></script>
</body>
</html>
TESTHTML

echo "✓ Created direct-test.html"
echo ""

echo "=========================================="
echo "  Debug Complete"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Check if server is running above"
echo "   If NOT, start it:"
echo "   cd backend && npm run dev"
echo ""
echo "2. Open test page:"
echo "   http://localhost:3000/direct-test.html"
echo ""
echo "3. Click all test buttons and share results"
echo ""
echo "4. Check server terminal for errors"
echo "=========================================="

