console.log('✓ app.js loaded');

async function loadDashboard() {
    console.log('Loading dashboard...');
    
    try {
        // Get employee stats
        const statsRes = await fetch(API_URL + '/employees/stats/dashboard');
        const stats = await statsRes.json();
        console.log('Employee stats:', stats);
        
        document.getElementById('totalEmployees').textContent = stats.total || 0;
        document.getElementById('departments').textContent = stats.departments?.length || 0;
        
        if (stats.recent && stats.recent.length > 0) {
            const tbody = document.querySelector('#recentEmployees tbody');
            tbody.innerHTML = stats.recent.map(emp => 
                '<tr><td>' + emp.employee_id + '</td><td>' + emp.first_name + ' ' + emp.last_name + 
                '</td><td>' + (emp.department || 'N/A') + '</td><td>' + (emp.position || 'N/A') + 
                '</td><td><span class="status-' + emp.status + '">' + emp.status + '</span></td></tr>'
            ).join('');
        }
        
        // Get today's attendance
        const today = new Date().toISOString().split('T')[0];
        console.log('Today:', today);
        
        const attRes = await fetch(API_URL + '/attendance');
        const attData = await attRes.json();
        console.log('All attendance:', attData);
        
        const todayAtt = (attData.attendance || []).filter(a => a.date === today);
        console.log('Today attendance count:', todayAtt.length);
        
        document.getElementById('todayAttendance').textContent = todayAtt.length;
        
        // Get current month payroll
        const currentMonth = String(new Date().getMonth() + 1).padStart(2, '0');
        const currentYear = String(new Date().getFullYear());
        console.log('Current month/year:', currentMonth, currentYear);
        
        const payrollRes = await fetch(API_URL + '/payroll/summary/' + currentMonth + '/' + currentYear);
        const payrollData = await payrollRes.json();
        console.log('Payroll summary:', payrollData);
        
        const totalPayout = payrollData.summary?.total_payout || 0;
        document.getElementById('monthlyPayroll').textContent = '$' + totalPayout.toFixed(2);
        
        console.log('✓ Dashboard loaded');
        
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

if (window.location.pathname.endsWith('index.html') || window.location.pathname === '/') {
    document.addEventListener('DOMContentLoaded', loadDashboard);
}
