@echo off
cd /d C:\Users\ISSA\Desktop\coursflutter\projet_flutter\functions

echo 1️⃣ Installation des dépendances...
call npm install

echo.
echo 2️⃣ Lancement des tests...
node test-notifications.js

echo.
echo 3️⃣ Tests terminés!
pause
