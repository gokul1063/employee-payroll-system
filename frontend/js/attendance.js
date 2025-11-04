console.log('✓ attendance.js loaded');

async function loadAttendance() {
    console.log('Loading attendance...');
    try {
        const response = await fetch(API_URL + '/attendance');
        const data = await response.json();
        displayAttendance(data.attendance || []);
    } catch (error) {
        console.error('Error loading attendance:', error);
    }
}

function displayAttendance(records) {
    const tbody = document.querySelector('#attendanceTable tbody');
    if (records.length > 0) {
        tbody.innerHTML = records.map(att => 
            '<tr><td>' + att.date + '</td><td>' + att.employee_id + '</td><td>' + att.first_name + ' ' + att.last_name + 
            '</td><td>' + (att.check_in || 'N/A') + '</td><td>' + (att.check_out || 'N/A') + '</td><td>' + 
            (att.hours_worked ? parseFloat(att.hours_worked).toFixed(2) : '0') + '</td><td><span class="status-' + 
            att.status + '">' + att.status + '</span></td></tr>'
        ).join('');
        console.log('✓ Displayed ' + records.length + ' attendance records');
    } else {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:20px;">No attendance records found.</td></tr>';
    }
}

async function loadEmployeesDropdown() {
    console.log('Loading employees dropdown...');
    try {
        const response = await fetch(API_URL + '/employees');
        const data = await response.json();
        const employees = data.employees || [];
        const activeEmployees = employees.filter(e => e.status === 'active');
        
        const options = activeEmployees.map(e => 
            '<option value="' + e.employee_id + '">' + e.employee_id + ' - ' + e.first_name + ' ' + e.last_name + '</option>'
        ).join('');
        
        document.getElementById('att_employee_id').innerHTML = '<option value="">Select Employee</option>' + options;
        document.getElementById('filterEmployee').innerHTML = '<option value="">All Employees</option>' + options;
        
        console.log('✓ Loaded ' + activeEmployees.length + ' active employees');
    } catch (error) {
        console.error('Error loading employees:', error);
    }
}

function openAttendanceModal() {
    console.log('Opening attendance modal');
    document.getElementById('attendanceForm').reset();
    document.getElementById('att_date').value = new Date().toISOString().split('T')[0];
    document.getElementById('attendanceModal').style.display = 'block';
}

function closeAttendanceModal() {
    console.log('Closing attendance modal');
    document.getElementById('attendanceModal').style.display = 'none';
}

async function filterAttendance() {
    const date = document.getElementById('filterDate').value;
    const empId = document.getElementById('filterEmployee').value;
    
    try {
        const response = await fetch(API_URL + '/attendance');
        const data = await response.json();
        let filtered = data.attendance || [];
        
        if (date) filtered = filtered.filter(a => a.date === date);
        if (empId) filtered = filtered.filter(a => a.employee_id === empId);
        
        displayAttendance(filtered);
    } catch (error) {
        console.error('Error filtering:', error);
    }
}

async function handleAttendanceSubmit(e) {
    e.preventDefault();
    console.log('Submitting attendance...');
    
    const formData = {
        employee_id: document.getElementById('att_employee_id').value,
        date: document.getElementById('att_date').value,
        check_in: document.getElementById('check_in').value,
        check_out: document.getElementById('check_out').value,
        status: document.getElementById('att_status').value
    };
    
    console.log('Form data:', formData);
    
    try {
        const response = await fetch(API_URL + '/attendance', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(formData)
        });
        
        const result = await response.json();
        console.log('Result:', result);
        
        if (response.ok) {
            alert('Attendance marked successfully!');
            closeAttendanceModal();
            loadAttendance();
        } else {
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed: ' + error.message);
    }
}

window.openAttendanceModal = openAttendanceModal;
window.closeAttendanceModal = closeAttendanceModal;
window.filterAttendance = filterAttendance;

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing attendance page');
    
    loadAttendance();
    loadEmployeesDropdown();
    
    const addBtn = document.getElementById('addAttendanceBtn');
    if (addBtn) {
        addBtn.onclick = openAttendanceModal;
        console.log('✓ Mark Attendance button attached');
    } else {
        console.error('✗ Mark Attendance button not found!');
    }
    
    const closeBtn = document.getElementById('closeAttendanceModalBtn');
    if (closeBtn) closeBtn.onclick = closeAttendanceModal;
    
    const cancelBtn = document.getElementById('cancelAttendanceBtn');
    if (cancelBtn) cancelBtn.onclick = closeAttendanceModal;
    
    const form = document.getElementById('attendanceForm');
    if (form) {
        form.onsubmit = handleAttendanceSubmit;
        console.log('✓ Form handler attached');
    } else {
        console.error('✗ Form not found!');
    }
    
    console.log('Attendance page ready');
});
