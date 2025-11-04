const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const dataDir = path.resolve(__dirname, '../data');

function readCSV(filename) {
    return new Promise((resolve, reject) => {
        const results = [];
        const filePath = path.join(dataDir, filename);
        
        if (!fs.existsSync(filePath)) {
            resolve([]);
            return;
        }
        
        fs.createReadStream(filePath)
            .pipe(csv())
            .on('data', (data) => results.push(data))
            .on('end', () => resolve(results))
            .on('error', (error) => reject(error));
    });
}

function writeCSV(filename, data, headers) {
    const filePath = path.join(dataDir, filename);
    const csvWriter = createCsvWriter({
        path: filePath,
        header: headers
    });
    return csvWriter.writeRecords(data);
}

const employeeHeaders = [
    {id: 'employee_id', title: 'employee_id'},
    {id: 'first_name', title: 'first_name'},
    {id: 'last_name', title: 'last_name'},
    {id: 'email', title: 'email'},
    {id: 'phone', title: 'phone'},
    {id: 'department', title: 'department'},
    {id: 'position', title: 'position'},
    {id: 'join_date', title: 'join_date'},
    {id: 'salary', title: 'salary'},
    {id: 'status', title: 'status'},
    {id: 'created_at', title: 'created_at'}
];

const attendanceHeaders = [
    {id: 'id', title: 'id'},
    {id: 'employee_id', title: 'employee_id'},
    {id: 'date', title: 'date'},
    {id: 'check_in', title: 'check_in'},
    {id: 'check_out', title: 'check_out'},
    {id: 'hours_worked', title: 'hours_worked'},
    {id: 'status', title: 'status'},
    {id: 'created_at', title: 'created_at'}
];

const payrollHeaders = [
    {id: 'id', title: 'id'},
    {id: 'employee_id', title: 'employee_id'},
    {id: 'month', title: 'month'},
    {id: 'year', title: 'year'},
    {id: 'basic_salary', title: 'basic_salary'},
    {id: 'allowances', title: 'allowances'},
    {id: 'deductions', title: 'deductions'},
    {id: 'overtime_hours', title: 'overtime_hours'},
    {id: 'overtime_pay', title: 'overtime_pay'},
    {id: 'net_salary', title: 'net_salary'},
    {id: 'payment_date', title: 'payment_date'},
    {id: 'status', title: 'status'},
    {id: 'created_at', title: 'created_at'}
];

module.exports = {
    async getAllEmployees() {
        return await readCSV('employees.csv');
    },
    
    async getEmployeeById(id) {
        const employees = await readCSV('employees.csv');
        return employees.find(emp => emp.employee_id === id);
    },
    
    async addEmployee(employee) {
        const employees = await readCSV('employees.csv');
        employee.created_at = new Date().toISOString();
        employees.push(employee);
        await writeCSV('employees.csv', employees, employeeHeaders);
        return employee;
    },
    
    async updateEmployee(id, updatedData) {
        const employees = await readCSV('employees.csv');
        const index = employees.findIndex(emp => emp.employee_id === id);
        if (index !== -1) {
            employees[index] = { ...employees[index], ...updatedData };
            await writeCSV('employees.csv', employees, employeeHeaders);
            return true;
        }
        return false;
    },
    
    async deleteEmployee(id) {
        const employees = await readCSV('employees.csv');
        const filtered = employees.filter(emp => emp.employee_id !== id);
        await writeCSV('employees.csv', filtered, employeeHeaders);
        return true;
    },
    
    async getAllAttendance() {
        const attendance = await readCSV('attendance.csv');
        const employees = await readCSV('employees.csv');
        return attendance.map(att => {
            const emp = employees.find(e => e.employee_id === att.employee_id);
            return {
                ...att,
                first_name: emp ? emp.first_name : '',
                last_name: emp ? emp.last_name : ''
            };
        });
    },
    
    async addAttendance(attendance) {
        const records = await readCSV('attendance.csv');
        attendance.id = String(records.length + 1);
        attendance.created_at = new Date().toISOString();
        records.push(attendance);
        await writeCSV('attendance.csv', records, attendanceHeaders);
        return attendance;
    },
    
    async getAllPayroll() {
        const payroll = await readCSV('payroll.csv');
        const employees = await readCSV('employees.csv');
        return payroll.map(pay => {
            const emp = employees.find(e => e.employee_id === pay.employee_id);
            return {
                ...pay,
                first_name: emp ? emp.first_name : '',
                last_name: emp ? emp.last_name : '',
                department: emp ? emp.department : ''
            };
        });
    },
    
    async generatePayroll(month, year) {
        const employees = await readCSV('employees.csv');
        const payroll = await readCSV('payroll.csv');
        const activeEmployees = employees.filter(emp => emp.status === 'active');
        
        for (const emp of activeEmployees) {
            const basic_salary = parseFloat(emp.salary);
            const allowances = basic_salary * 0.2;
            const deductions = basic_salary * 0.1;
            const net_salary = basic_salary + allowances - deductions;
            
            payroll.push({
                id: String(payroll.length + 1),
                employee_id: emp.employee_id,
                month: month,
                year: String(year),
                basic_salary: String(basic_salary),
                allowances: String(allowances),
                deductions: String(deductions),
                overtime_hours: '0',
                overtime_pay: '0',
                net_salary: String(net_salary),
                payment_date: '',
                status: 'pending',
                created_at: new Date().toISOString()
            });
        }
        
        await writeCSV('payroll.csv', payroll, payrollHeaders);
        return true;
    },
    
    async updatePayrollStatus(id, status, payment_date) {
        const payroll = await readCSV('payroll.csv');
        const index = payroll.findIndex(p => p.id === id);
        if (index !== -1) {
            payroll[index].status = status;
            payroll[index].payment_date = payment_date;
            await writeCSV('payroll.csv', payroll, payrollHeaders);
            return true;
        }
        return false;
    },
    
    async getPayrollSummary(month, year) {
        const payroll = await readCSV('payroll.csv');
        const filtered = payroll.filter(p => p.month === month && p.year === year);
        return {
            total_employees: filtered.length,
            total_basic: filtered.reduce((sum, p) => sum + parseFloat(p.basic_salary || 0), 0),
            total_allowances: filtered.reduce((sum, p) => sum + parseFloat(p.allowances || 0), 0),
            total_deductions: filtered.reduce((sum, p) => sum + parseFloat(p.deductions || 0), 0),
            total_overtime: filtered.reduce((sum, p) => sum + parseFloat(p.overtime_pay || 0), 0),
            total_payout: filtered.reduce((sum, p) => sum + parseFloat(p.net_salary || 0), 0)
        };
    },
    
    async authenticateUser(username, password) {
        const users = await readCSV('users.csv');
        return users.find(u => u.username === username && u.password === password);
    }
};
