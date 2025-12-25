@echo off
echo Starting ML Recommendation Service...

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Python is required but not installed.
    exit /b 1
)

REM Navigate to ML service directory
cd ml-service

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

REM Create necessary directories
if not exist "models" mkdir models
if not exist "data" mkdir data

REM Start the service
echo Starting ML service on port 8001...
python -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload