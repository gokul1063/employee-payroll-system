#!/bin/bash

echo "=========================================="
echo "  Fixing Login Page"
echo "=========================================="
echo ""

# ============================================
# STEP 1: Fix login.html
# ============================================
echo "=== STEP 1: Creating clean login.html ==="

cat > frontend/login.html << 'ENDHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Payroll System</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .login-container {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .login-box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 400px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h1 {
            color: #667eea;
            margin-bottom: 10px;
        }
        .login-form .form-group {
            margin-bottom: 20px;
        }
        .login-form label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: 500;
        }
        .login-form input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
        }
        .login-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }
        .login-btn:hover {
            opacity: 0.9;
        }
        .error-message {
            background: #fee;
            color: #c33;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            display: none;
        }
        .demo-credentials {
            background: #f8f9ff;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            font-size: 13px;
        }
        .demo-credentials h4 {
            margin-bottom: 10px;
            color: #667eea;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="login-header">
                <h1>💼 Payroll System</h1>
                <p>Please login to continue</p>
            </div>
            
            <div id="errorMessage" class="error-message"></div>
            
            <form class="login-form" id="loginForm">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required autofocus>
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <button type="submit" class="login-btn">Login</button>
            </form>
            
            <div class="demo-credentials">
                <h4>Demo Credentials:</h4>
                <p><strong>Username:</strong> admin</p>
                <p><strong>Password:</strong> admin123</p>
            </div>
        </div>
    </div>
    
    <script src="js/config.js"></script>
    <script>
        console.log('Login page loaded');
        console.log('API_URL:', typeof API_URL !== 'undefined' ? API_URL : 'UNDEFINED');
        
        // Check if already logged in
        if (localStorage.getItem('authToken')) {
            console.log('Already logged in, redirecting...');
            window.location.href = '/index.html';
        }
        
        document.getElementById('loginForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            console.log('Form submitted');
            
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            const errorDiv = document.getElementById('errorMessage');
            
            console.log('Username:', username);
            console.log('Password length:', password.length);
            
            errorDiv.style.display = 'none';
            errorDiv.textContent = '';
            
            try {
                console.log('Fetching:', API_URL + '/auth/login');
                
                const response = await fetch(API_URL + '/auth/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        username: username,
                        password: password
                    })
                });
                
                console.log('Response status:', response.status);
                console.log('Response ok:', response.ok);
                
                const data = await response.json();
                console.log('Response data:', data);
                
                if (response.ok && data.success) {
                    console.log('Login successful!');
                    console.log('Token:', data.token);
                    
                    localStorage.setItem('authToken', data.token);
                    localStorage.setItem('userName', data.user.fullName);
                    localStorage.setItem('userRole', data.user.role);
                    
                    console.log('Saved to localStorage');
                    console.log('Redirecting to dashboard...');
                    
                    window.location.href = '/index.html';
                } else {
                    console.error('Login failed:', data.error);
                    errorDiv.textContent = data.error || 'Login failed';
                    errorDiv.style.display = 'block';
                }
            } catch (error) {
                console.error('Network error:', error);
                console.error('Error name:', error.name);
                console.error('Error message:', error.message);
                errorDiv.textContent = 'Network error: ' + error.message;
                errorDiv.style.display = 'block';
            }
        });
        
        console.log('Login page ready');
    </script>
</body>
</html>
ENDHTML

echo "✓ Created new login.html with inline JavaScript"
echo ""

# ============================================
# STEP 2: Verify config.js
# ============================================
echo "=== STEP 2: Verifying config.js ==="

cat frontend/js/config.js
echo ""

# ============================================
# STEP 3: Test in browser
# ============================================
echo "=========================================="
echo "  Login Page Fixed!"
echo "=========================================="
echo ""
echo "Changes made:"
echo "  ✓ Rewrote login.html with inline JS"
echo "  ✓ Added extensive console logging"
echo "  ✓ Removed dependency on login.js"
echo ""
echo "Next steps:"
echo ""
echo "1. Clear browser cache:"
echo "   Ctrl+Shift+Delete - Clear everything"
echo ""
echo "2. Close ALL browser windows"
echo ""
echo "3. Open NEW browser window"
echo ""
echo "4. Press F12 to open console FIRST"
echo ""
echo "5. Then go to: http://localhost:3000"
echo ""
echo "6. You should see in console:"
echo "   ✓ Config loaded"
echo "   Login page loaded"
echo "   API_URL: http://localhost:3000/api"
echo "   Login page ready"
echo ""
echo "7. Try to login with: admin / admin123"
echo ""
echo "8. Share what you see in console!"
echo "=========================================="

