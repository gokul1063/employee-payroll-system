console.log('✓ auth-check.js loaded');

if (window.location.pathname.includes('login.html')) {
    console.log('On login page');
} else {
    checkAuth();
}

async function checkAuth() {
    const token = localStorage.getItem('authToken');
    if (!token) {
        window.location.href = '/login.html';
        return false;
    }
    try {
        const response = await fetch(API_URL + '/auth/verify', {
            headers: {'Authorization': 'Bearer ' + token}
        });
        if (!response.ok) {
            localStorage.clear();
            window.location.href = '/login.html';
            return false;
        }
        updateUserInfo();
        return true;
    } catch (error) {
        localStorage.clear();
        window.location.href = '/login.html';
        return false;
    }
}

function logout() {
    const token = localStorage.getItem('authToken');
    if (token) {
        fetch(API_URL + '/auth/logout', {
            method: 'POST',
            headers: {'Authorization': 'Bearer ' + token}
        }).catch(err => console.error(err));
    }
    localStorage.clear();
    window.location.href = '/login.html';
}

function updateUserInfo() {
    const userName = localStorage.getItem('userName') || 'User';
    document.querySelectorAll('.user-info span').forEach(el => {
        el.textContent = userName;
    });
}
