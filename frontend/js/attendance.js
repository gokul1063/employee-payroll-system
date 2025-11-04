const API_URL = 'http://localhost:3000/api';

// Load attendance records
async function loadAttendance() {
    try {
        const response = await fetch(`${API_URL}/attendance`);
        const data = await response.json();
        
        displayAttendance(data.attendance || []);
    } catch (error) {
        console.error('Error loading attendance:', error);
        alert('Failed to load attendance: ' + error.message);
    }
}

// Display attendance
function displayAttendance(records) {
    const tbody = document.querySelector('#attendanceTable tbody');
    
    if (records.length > 0) {
        tbody.innerHTML = records.map(att => `
            <tr>
                <td>${att.date}</td>
                <td>${att.employee_id}</td>
                <td>${att.first_name} ${att.last_name}</td>
                <td>${att.check_in || 'N/A'}</td>
                <td>${att.check_out || 'N/A'}</td>
                <td>${att.hours_worked ? att.hours_worked.toFixed(2) : '0'}</td>
                <td><span class="status-${att.status}">${att.status}</span></td>
                <td>
                    <button class="btn btn-sm btn-warning" onclick="editAttendance(${att.id})">Edit</button>
                </td>
            </tr>
        `).join('');
    } else {
        tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;">No attendance records found.</td></tr>';
    }
}

// Load employees for dropdown
async function loadEmployeesDropdown() {
    try {
        const response = await fetch(`${API_URL}/employees`);
        const data = await response.json();
        
        const select = document.getElementById('att_employee_id');
        const filterSelect = document.getElementById('filterEmployee');
        
        const options = (data.employees || [])
            .filter(emp => emp.status === 'active')
            .map(emp => `<option value="${emp.employee_id}">${emp.employee_id} - ${emp.first_name} ${emp.last_name}</option>`)
            .join('');
        
        select.innerHTML = '<option value="">Select Employee</option>' + options;
        filterSelect.innerHTML = '<option value="">All Employees</option>' + options;
    } catch (error) {
        console.error('Error loading employees:', error);
    }
}

// Open attendance modal
function openAttendanceModal() {
    document.getElementById('attendanceForm').reset();
    document.getElementById('att_date').value = new Date().toISOString().split('T')[0];
    document.getElementById('attendanceModal').style.display = 'block';
}

// Close attendance modal
function closeAttendanceModal() {
    document.getElementById('attendanceModal').style.display = 'none';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('attendanceModal');
    if (event.target == modal) {
        modal.style.display = 'none';
    }
}

// Filter attendance
async function filterAttendance() {
    const date = document.getElementById('filterDate').value;
    const employeeId = document.getElementById('filterEmployee').value;
    
    try {
        const response = await fetch(`${API_URL}/attendance`);
        const data = await response.json();
        
        let filtered = data.attendance || [];
        
        if (date) {
            filtered = filtered.filter(att => att.date === date);
        }
        
        if (employeeId) {
            filtered = filtered.filter(att => att.employee_id === employeeId);
        }
        
        displayAttendance(filtered);
    } catch (error) {
        console.error('Error filtering attendance:', error);
    }
}

// Load on page load
document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('attendanceForm');
    
    if (form) {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const formData = {
                employee_id: document.getElementById('att_employee_id').value,
                date: document.getElementById('att_date').value,
                check_in: document.getElementById('check_in').value,
                check_out: document.getElementById('check_out').value,
                status: document.getElementById('att_status').value
            };
            
            try {
                const response = await fetch(`${API_URL}/attendance`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(formData)
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    alert('Attendance marked successfully');
                    closeAttendanceModal();
                    loadAttendance();
                } else {
                    alert('Failed to mark attendance: ' + (result.error || 'Unknown error'));
                }
            } catch (error) {
                console.error('Error marking attendance:', error);
                alert('Failed to mark attendance: ' + error.message);
            }
        });
    }
    
    loadAttendance();
    loadEmployeesDropdown();
});
