# Payroll System - CSV Version

## Features
- CSV-based storage (no SQLite needed!)
- Portable - works on any machine with Node.js
- Easy to backup - just copy data/ folder
- Can edit data in Excel/LibreOffice

## Data Files
- data/employees.csv - Employee records
- data/attendance.csv - Attendance records
- data/payroll.csv - Payroll records
- data/users.csv - Login credentials

## SQLite Backups
Your original SQLite databases are backed up in:
- database-backup/payroll.db.backup
- database-backup/auth.db.backup

## Running the System
npm run dev

## Login
Username: admin
Password: admin123

## For Your Friend
Just copy the entire project folder and run:
cd backend
npm install
npm run dev
