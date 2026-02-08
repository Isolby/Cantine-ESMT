#!/bin/bash

echo "🧪 Test des notifications Firebase"
echo "===================================="
echo ""

cd functions

echo "1️⃣ Vérification des dépendances..."
if [ ! -d "node_modules" ]; then
  echo "📦 Installation des packages..."
  npm install
fi

echo ""
echo "2️⃣ Lancement des tests..."
node test-notifications.js

echo ""
echo "3️⃣ Tests terminés!"
