console.log('✓ login.js loaded');

if (localStorage.getItem('authToken')) {
    window.location.href = '/index.html';
}

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('loginForm');
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        const errorDiv = document.getElementById('errorMessage');
        errorDiv.style.display = 'none';
        try {
            const response = await fetch(API_URL + '/auth/login', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({username, password})
            });
            const data = await response.json();
            if (response.ok && data.success) {
                localStorage.setItem('authToken', data.token);
                localStorage.setItem('userName', data.user.fullName);
                localStorage.setItem('userRole', data.user.role);
                window.location.href = '/index.html';
            } else {
                errorDiv.textContent = data.error || 'Login failed';
                errorDiv.style.display = 'block';
            }
        } catch (error) {
            errorDiv.textContent = 'Network error';
            errorDiv.style.display = 'block';
        }
    });
});
