let editingEmployeeId = null;
console.log('✓ employees.js loaded');

async function loadEmployees() {
    const tbody = document.querySelector('#employeesTable tbody');
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;">Loading...</td></tr>';
    try {
        const response = await fetch(API_URL + '/employees');
        const data = await response.json();
        if (data.employees && data.employees.length > 0) {
            tbody.innerHTML = '';
            data.employees.forEach(function(emp) {
                const row = tbody.insertRow();
                row.innerHTML = 
                    '<td>' + emp.employee_id + '</td>' +
                    '<td>' + emp.first_name + ' ' + emp.last_name + '</td>' +
                    '<td>' + emp.email + '</td>' +
                    '<td>' + (emp.department || 'N/A') + '</td>' +
                    '<td>' + (emp.position || 'N/A') + '</td>' +
                    '<td>$' + emp.salary + '</td>' +
                    '<td>' + emp.status + '</td>' +
                    '<td>' +
                        '<button class="btn btn-sm btn-warning" onclick="editEmployee(\'' + emp.employee_id + '\')">Edit</button> ' +
                        '<button class="btn btn-sm btn-danger" onclick="deleteEmployee(\'' + emp.employee_id + '\')">Delete</button>' +
                    '</td>';
            });
        } else {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;">No employees</td></tr>';
        }
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;color:red;">Error: ' + error.message + '</td></tr>';
    }
}

function openAddModal() {
    console.log('Opening modal');
    editingEmployeeId = null;
    document.getElementById('modalTitle').textContent = 'Add Employee';
    document.getElementById('employeeForm').reset();
    document.getElementById('employee_id').disabled = false;
    document.getElementById('employeeModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('employeeModal').style.display = 'none';
}

async function editEmployee(id) {
    try {
        const response = await fetch(API_URL + '/employees/' + id);
        const data = await response.json();
        const emp = data.employee;
        editingEmployeeId = id;
        document.getElementById('modalTitle').textContent = 'Edit Employee';
        document.getElementById('employee_id').value = emp.employee_id;
        document.getElementById('employee_id').disabled = true;
        document.getElementById('first_name').value = emp.first_name;
        document.getElementById('last_name').value = emp.last_name;
        document.getElementById('email').value = emp.email;
        document.getElementById('phone').value = emp.phone || '';
        document.getElementById('department').value = emp.department || '';
        document.getElementById('position').value = emp.position || '';
        document.getElementById('join_date').value = emp.join_date || '';
        document.getElementById('salary').value = emp.salary;
        document.getElementById('status').value = emp.status;
        document.getElementById('employeeModal').style.display = 'block';
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

async function deleteEmployee(id) {
    if (!confirm('Delete?')) return;
    try {
        const response = await fetch(API_URL + '/employees/' + id, {method: 'DELETE'});
        if (response.ok) {
            alert('Deleted!');
            loadEmployees();
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

async function saveEmployee(e) {
    e.preventDefault();
    const formData = {
        employee_id: document.getElementById('employee_id').value,
        first_name: document.getElementById('first_name').value,
        last_name: document.getElementById('last_name').value,
        email: document.getElementById('email').value,
        phone: document.getElementById('phone').value,
        department: document.getElementById('department').value,
        position: document.getElementById('position').value,
        join_date: document.getElementById('join_date').value,
        salary: document.getElementById('salary').value,
        status: document.getElementById('status').value
    };
    try {
        const url = editingEmployeeId ? API_URL + '/employees/' + editingEmployeeId : API_URL + '/employees';
        const response = await fetch(url, {
            method: editingEmployeeId ? 'PUT' : 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(formData)
        });
        if (response.ok) {
            alert('Success!');
            closeModal();
            loadEmployees();
        } else {
            const result = await response.json();
            alert('Error: ' + (result.error || 'Unknown'));
        }
    } catch (error) {
        alert('Failed: ' + error.message);
    }
}

window.openAddModal = openAddModal;
window.closeModal = closeModal;
window.editEmployee = editEmployee;
window.deleteEmployee = deleteEmployee;

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing employees page');
    loadEmployees();
    const addBtn = document.getElementById('addEmployeeBtn');
    if (addBtn) addBtn.onclick = openAddModal;
    const form = document.getElementById('employeeForm');
    if (form) form.onsubmit = saveEmployee;
    const closeBtn = document.getElementById('closeModalBtn');
    if (closeBtn) closeBtn.onclick = closeModal;
    const cancelBtn = document.getElementById('cancelBtn');
    if (cancelBtn) cancelBtn.onclick = closeModal;
});
