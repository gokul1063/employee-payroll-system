console.log('✓ attendance.js loaded');

async function loadAttendance() {
    try {
        const response = await fetch(API_URL + '/attendance');
        const data = await response.json();
        displayAttendance(data.attendance || []);
    } catch (error) {
        console.error('Error:', error);
    }
}

function displayAttendance(records) {
    const tbody = document.querySelector('#attendanceTable tbody');
    if (records.length > 0) {
        tbody.innerHTML = records.map(att => 
            '<tr><td>' + att.date + '</td><td>' + att.employee_id + '</td><td>' + att.first_name + ' ' + att.last_name + 
            '</td><td>' + (att.check_in || 'N/A') + '</td><td>' + (att.check_out || 'N/A') + '</td><td>' + 
            (att.hours_worked ? parseFloat(att.hours_worked).toFixed(2) : '0') + '</td><td>' + att.status + '</td></tr>'
        ).join('');
    } else {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:20px;">No records</td></tr>';
    }
}

async function loadEmployeesDropdown() {
    const response = await fetch(API_URL + '/employees');
    const data = await response.json();
    const options = (data.employees || []).filter(e => e.status === 'active')
        .map(e => '<option value="' + e.employee_id + '">' + e.employee_id + ' - ' + e.first_name + ' ' + e.last_name + '</option>').join('');
    document.getElementById('att_employee_id').innerHTML = '<option value="">Select</option>' + options;
    document.getElementById('filterEmployee').innerHTML = '<option value="">All</option>' + options;
}

function openAttendanceModal() {
    document.getElementById('attendanceForm').reset();
    document.getElementById('att_date').value = new Date().toISOString().split('T')[0];
    document.getElementById('attendanceModal').style.display = 'block';
}

function closeAttendanceModal() {
    document.getElementById('attendanceModal').style.display = 'none';
}

async function filterAttendance() {
    const date = document.getElementById('filterDate').value;
    const empId = document.getElementById('filterEmployee').value;
    const response = await fetch(API_URL + '/attendance');
    const data = await response.json();
    let filtered = data.attendance || [];
    if (date) filtered = filtered.filter(a => a.date === date);
    if (empId) filtered = filtered.filter(a => a.employee_id === empId);
    displayAttendance(filtered);
}

window.openAttendanceModal = openAttendanceModal;
window.closeAttendanceModal = closeAttendanceModal;
window.filterAttendance = filterAttendance;

document.addEventListener('DOMContentLoaded', function() {
    loadAttendance();
    loadEmployeesDropdown();
    const form = document.getElementById('attendanceForm');
    if (form) {
        form.onsubmit = async function(e) {
            e.preventDefault();
            const data = {
                employee_id: document.getElementById('att_employee_id').value,
                date: document.getElementById('att_date').value,
                check_in: document.getElementById('check_in').value,
                check_out: document.getElementById('check_out').value,
                status: document.getElementById('att_status').value
            };
            const response = await fetch(API_URL + '/attendance', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(data)
            });
            if (response.ok) {
                alert('Saved!');
                closeAttendanceModal();
                loadAttendance();
            }
        };
    }
});
