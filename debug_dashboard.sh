#!/bin/bash

echo "=========================================="
echo "  Debugging Dashboard Values"
echo "=========================================="
echo ""

# ============================================
# STEP 1: Check actual data
# ============================================
echo "=== STEP 1: Checking actual data in CSV files ==="

echo "Employees in data/employees.csv:"
cat data/employees.csv
echo ""

echo "Attendance in data/attendance.csv:"
cat data/attendance.csv
echo ""

echo "Payroll in data/payroll.csv:"
cat data/payroll.csv
echo ""

# ============================================
# STEP 2: Get current date info
# ============================================
echo "=== STEP 2: Current date information ==="

echo "Today's date: $(date +%Y-%m-%d)"
echo "Current month: $(date +%m)"
echo "Current year: $(date +%Y)"
echo ""

# ============================================
# STEP 3: Test API endpoints
# ============================================
echo "=== STEP 3: Testing API endpoints ==="

echo "Testing /api/attendance:"
curl -s http://localhost:3000/api/attendance | python3 -m json.tool 2>/dev/null || curl -s http://localhost:3000/api/attendance
echo ""

echo "Testing /api/payroll:"
curl -s http://localhost:3000/api/payroll | python3 -m json.tool 2>/dev/null || curl -s http://localhost:3000/api/payroll
echo ""

MONTH=$(date +%m)
YEAR=$(date +%Y)
echo "Testing /api/payroll/summary/$MONTH/$YEAR:"
curl -s "http://localhost:3000/api/payroll/summary/$MONTH/$YEAR" | python3 -m json.tool 2>/dev/null || curl -s "http://localhost:3000/api/payroll/summary/$MONTH/$YEAR"
echo ""

# ============================================
# STEP 4: Fix the issues
# ============================================
echo "=========================================="
echo "Creating fixes..."
echo "=========================================="
echo ""

