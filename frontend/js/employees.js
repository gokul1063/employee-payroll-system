const API_URL = 'http://localhost:3000/api';
let editingEmployeeId = null;

console.log('employees.js loaded successfully');

async function loadEmployees() {
    console.log('Loading employees...');
    try {
        const response = await fetch(API_URL + '/employees');
        const data = await response.json();
        
        const tbody = document.querySelector('#employeesTable tbody');
        
        if (data.employees && data.employees.length > 0) {
            tbody.innerHTML = data.employees.map(emp => {
                return `
                    <tr>
                        <td>${emp.employee_id}</td>
                        <td>${emp.first_name} ${emp.last_name}</td>
                        <td>${emp.email}</td>
                        <td>${emp.department || 'N/A'}</td>
                        <td>${emp.position || 'N/A'}</td>
                        <td>$${parseFloat(emp.salary).toFixed(2)}</td>
                        <td><span class="status-${emp.status}">${emp.status}</span></td>
                        <td>
                            <button class="btn btn-sm btn-warning" onclick="editEmployee('${emp.employee_id}')">Edit</button>
                            <button class="btn btn-sm btn-danger" onclick="deleteEmployee('${emp.employee_id}')">Delete</button>
                        </td>
                    </tr>
                `;
            }).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;">No employees found. Click "+ Add Employee" to add one.</td></tr>';
        }
        console.log('Employees loaded successfully');
    } catch (error) {
        console.error('Error loading employees:', error);
        alert('Failed to load employees: ' + error.message);
    }
}

function openAddModal() {
    console.log('openAddModal called');
    editingEmployeeId = null;
    document.getElementById('modalTitle').textContent = 'Add Employee';
    document.getElementById('employeeForm').reset();
    document.getElementById('employee_id').disabled = false;
    document.getElementById('employeeModal').style.display = 'block';
}

async function editEmployee(id) {
    console.log('Editing employee:', id);
    try {
        const response = await fetch(API_URL + '/employees/' + id);
        const data = await response.json();
        const emp = data.employee;
        
        if (!emp) {
            alert('Employee not found');
            return;
        }
        
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
        console.error('Error loading employee:', error);
        alert('Failed to load employee details: ' + error.message);
    }
}

async function deleteEmployee(id) {
    if (!confirm('Are you sure you want to delete this employee?')) return;
    
    console.log('Deleting employee:', id);
    try {
        const response = await fetch(API_URL + '/employees/' + id, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            alert('Employee deleted successfully');
            loadEmployees();
        } else {
            const error = await response.json();
            alert('Failed to delete employee: ' + (error.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error deleting employee:', error);
        alert('Failed to delete employee: ' + error.message);
    }
}

function closeModal() {
    console.log('Closing modal');
    document.getElementById('employeeModal').style.display = 'none';
}

async function handleEmployeeSubmit(e) {
    e.preventDefault();
    
    console.log('Form submitted');
    
    const formData = {
        employee_id: document.getElementById('employee_id').value,
        first_name: document.getElementById('first_name').value,
        last_name: document.getElementById('last_name').value,
        email: document.getElementById('email').value,
        phone: document.getElementById('phone').value,
        department: document.getElementById('department').value,
        position: document.getElementById('position').value,
        join_date: document.getElementById('join_date').value,
        salary: parseFloat(document.getElementById('salary').value),
        status: document.getElementById('status').value
    };
    
    console.log('Sending data:', formData);
    
    try {
        const url = editingEmployeeId 
            ? API_URL + '/employees/' + editingEmployeeId
            : API_URL + '/employees';
        
        console.log('Sending to:', url);
        
        const response = await fetch(url, {
            method: editingEmployeeId ? 'PUT' : 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });
        
        const result = await response.json();
        console.log('Server response:', result);
        
        if (response.ok) {
            alert(editingEmployeeId ? 'Employee updated successfully!' : 'Employee added successfully!');
            closeModal();
            loadEmployees();
        } else {
            alert('Error: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error saving employee:', error);
        alert('Failed to save employee: ' + error.message);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    console.log('DOMContentLoaded - Initializing employees page');
    
    loadEmployees();
    
    const form = document.getElementById('employeeForm');
    if (form) {
        form.addEventListener('submit', handleEmployeeSubmit);
        console.log('Form handler attached');
    } else {
        console.error('Form not found!');
    }
    
    window.onclick = function(event) {
        const modal = document.getElementById('employeeModal');
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    }
    
    console.log('Initialization complete');
});

window.openAddModal = openAddModal;
window.editEmployee = editEmployee;
window.deleteEmployee = deleteEmployee;
window.closeModal = closeModal;

console.log('employees.js fully loaded - all functions ready');
