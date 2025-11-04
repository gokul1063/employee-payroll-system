#!/bin/bash
echo "Creating startup files..."

# Windows batch file
echo '@echo off' > start.bat
echo 'echo ==========================================' >> start.bat
echo 'echo   Starting Payroll System' >> start.bat
echo 'echo ==========================================' >> start.bat
echo 'echo.' >> start.bat
echo 'cd backend' >> start.bat
echo 'call npm install' >> start.bat
echo 'call npm run dev' >> start.bat
echo 'pause' >> start.bat

# Linux/Mac shell script
echo '#!/bin/bash' > start.sh
echo 'echo "=========================================="' >> start.sh
echo 'echo "  Starting Payroll System"' >> start.sh
echo 'echo "=========================================="' >> start.sh
echo 'echo ""' >> start.sh
echo 'cd backend' >> start.sh
echo 'npm install' >> start.sh
echo 'npm run dev' >> start.sh

chmod +x start.sh

echo "✓ Created start.bat for Windows"
echo "✓ Created start.sh for Linux/Mac"
