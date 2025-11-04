#!/bin/bash

echo "=========================================="
echo "  Data Cleanup Script"
echo "=========================================="
echo ""

# Backup current data
echo "Creating backups..."
mkdir -p data-backups/$(date +%Y%m%d_%H%M%S)
cp data/*.csv data-backups/$(date +%Y%m%d_%H%M%S)/
echo "✓ Backed up to: data-backups/$(date +%Y%m%d_%H%M%S)/"
echo ""

# Show current data counts
echo "Current data:"
echo "  Employees: $(tail -n +2 data/employees.csv | wc -l)"
echo "  Attendance: $(tail -n +2 data/attendance.csv | wc -l)"
echo "  Payroll: $(tail -n +2 data/payroll.csv | wc -l)"
echo ""

# Ask for confirmation
echo "This will:"
echo "  ✓ KEEP all employees"
echo "  ✗ DELETE all attendance records"
echo "  ✗ DELETE all payroll records"
echo ""
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Clearing data..."

# Clear attendance (keep header only)
head -1 data/attendance.csv > data/attendance_temp.csv
mv data/attendance_temp.csv data/attendance.csv
echo "✓ Cleared attendance records"

# Clear payroll (keep header only)
head -1 data/payroll.csv > data/payroll_temp.csv
mv data/payroll_temp.csv data/payroll.csv
echo "✓ Cleared payroll records"

# Keep employees as is
echo "✓ Kept all employee records"

echo ""
echo "Final data:"
echo "  Employees: $(tail -n +2 data/employees.csv | wc -l)"
echo "  Attendance: $(tail -n +2 data/attendance.csv | wc -l)"
echo "  Payroll: $(tail -n +2 data/payroll.csv | wc -l)"
echo ""
echo "=========================================="
echo "  Data Cleanup Complete!"
echo "=========================================="
echo ""
echo "Backups saved in: data-backups/"
echo ""
echo "To restore from backup:"
echo "  cp data-backups/YYYYMMDD_HHMMSS/*.csv data/"
echo "=========================================="

