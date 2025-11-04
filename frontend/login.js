const API_URL = 'http://localhost:3000/api'\;

document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const errorDiv = document.getElementById('errorMessage');
    
    errorDiv.style.display = 'none';
    
    try {
        const response = await fetch(API_URL + '/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            // Save token and user info
            localStorage.setItem('authToken', data.token);
            localStorage.setItem('userName', data.user.fullName);
            localStorage.setItem('userRole', data.user.role);
            
            // Redirect to dashboard
            window.location.href = '/index.html';
        } else {
            errorDiv.textContent = data.error || 'Login failed';
            errorDiv.style.display = 'block';
        }
    } catch (error) {
        errorDiv.textContent = 'Network error. Please try again.';
        errorDiv.style.display = 'block';
        console.error('Login error:', error);
    }
});

// Check if already logged in
if (localStorage.getItem('authToken')) {
    window.location.href = '/index.html';
}
