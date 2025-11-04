const API_URL = 'http://localhost:3000/api';

// Load dashboard data
async function loadDashboard() {
    try {
        // Get employee stats
        const statsRes = await fetch(`${API_URL}/employees/stats/dashboard`);
        const stats = await statsRes.json();
        
        document.getElementById('totalEmployees').textContent = stats.total || 0;
        document.getElementById('departments').textContent = stats.departments?.length || 0;
        
        // Load recent employees
        if (stats.recent && stats.recent.length > 0) {
            const tbody = document.querySelector('#recentEmployees tbody');
            tbody.innerHTML = stats.recent.map(emp => `
                <tr>
                    <td>${emp.employee_id}</td>
                    <td>${emp.first_name} ${emp.last_name}</td>
                    <td>${emp.department || 'N/A'}</td>
                    <td>${emp.position || 'N/A'}</td>
                    <td><span class="status-${emp.status}">${emp.status}</span></td>
                </tr>
            `).join('');
        }
        
        // Get today's attendance
        const today = new Date().toISOString().split('T')[0];
        const attRes = await fetch(`${API_URL}/attendance`);
        const attData = await attRes.json();
        const todayAtt = attData.attendance?.filter(a => a.date === today) || [];
        document.getElementById('todayAttendance').textContent = todayAtt.length;
        
        // Get current month payroll
        const currentMonth = String(new Date().getMonth() + 1).padStart(2, '0');
        const currentYear = new Date().getFullYear();
        const payrollRes = await fetch(`${API_URL}/payroll/summary/${currentMonth}/${currentYear}`);
        const payrollData = await payrollRes.json();
        document.getElementById('monthlyPayroll').textContent = 
            '$' + (payrollData.summary?.total_payout?.toFixed(2) || '0');
        
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

// Load dashboard on page load
if (window.location.pathname.endsWith('index.html') || window.location.pathname === '/') {
    document.addEventListener('DOMContentLoaded', loadDashboard);
}
