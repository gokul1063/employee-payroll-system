const API_URL = 'http://localhost:3000/api'\;

// Check authentication on protected pages
async function checkAuth() {
    const token = localStorage.getItem('authToken');
    
    if (!token) {
        window.location.href = '/login.html';
        return false;
    }
    
    try {
        const response = await fetch(API_URL + '/auth/verify', {
            headers: {
                'Authorization': 'Bearer ' + token
            }
        });
        
        if (!response.ok) {
            localStorage.clear();
            window.location.href = '/login.html';
            return false;
        }
        
        return true;
    } catch (error) {
        console.error('Auth check failed:', error);
        localStorage.clear();
        window.location.href = '/login.html';
        return false;
    }
}

// Logout function
function logout() {
    const token = localStorage.getItem('authToken');
    
    if (token) {
        fetch(API_URL + '/auth/logout', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token
            }
        }).catch(err => console.error('Logout error:', err));
    }
    
    localStorage.clear();
    window.location.href = '/login.html';
}

// Update user info in header
function updateUserInfo() {
    const userName = localStorage.getItem('userName') || 'User';
    const userInfoElements = document.querySelectorAll('.user-info span');
    
    userInfoElements.forEach(el => {
        el.textContent = userName;
    });
}

// Check auth when page loads
if (!window.location.pathname.includes('login.html')) {
    checkAuth();
    updateUserInfo();
}
