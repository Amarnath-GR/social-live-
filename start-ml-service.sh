#!/bin/bash

echo "Starting ML Recommendation Service..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is required but not installed."
    exit 1
fi

# Navigate to ML service directory
cd ml-service

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Create necessary directories
mkdir -p models data

# Start the service
echo "Starting ML service on port 8001..."
python -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload