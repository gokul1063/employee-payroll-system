@echo off
echo ==========================================
echo   Starting Payroll System
echo ==========================================
echo.
cd backend
call npm install
call npm run dev
pause
