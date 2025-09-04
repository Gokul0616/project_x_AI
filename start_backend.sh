#!/bin/bash

echo "🚀 Starting Twitter Clone Backend..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

# Navigate to backend directory
cd backend

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Create uploads directory if it doesn't exist
if [ ! -d "uploads" ]; then
    echo "📁 Creating uploads directory..."
    mkdir uploads
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Please copy .env.example to .env and configure it."
    cp .env.example .env
    echo "📝 Created .env file from .env.example. Please update the MONGODB_URI."
fi

# Start the server
echo "🟢 Starting server on port 5000..."
echo "📊 Environment: development"
echo "🔗 Server will be available at: http://localhost:5000"
echo "🔗 API Health check: http://localhost:5000/api/health"
echo ""
echo "⚠️  Make sure MongoDB is running and the MONGODB_URI in .env is correct!"
echo ""

npm run dev