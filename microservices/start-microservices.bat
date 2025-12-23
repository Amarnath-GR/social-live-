@echo off
echo Starting Social Live Microservices...

REM Build and start all services
docker-compose up --build -d

echo Services starting...
echo API Gateway: http://localhost:8080
echo Auth Service: http://localhost:3001
echo Social Service: http://localhost:3002
echo Wallet Service: http://localhost:3003
echo Streaming Service: http://localhost:3004
echo Commerce Service: http://localhost:3005

REM Wait for services to be ready
echo Waiting for services to be ready...
timeout /t 30 /nobreak

REM Check service health
echo Checking service health...
curl -f http://localhost:3001/health && echo ✅ Auth Service
curl -f http://localhost:3002/health && echo ✅ Social Service
curl -f http://localhost:3003/health && echo ✅ Wallet Service
curl -f http://localhost:3004/health && echo ✅ Streaming Service
curl -f http://localhost:3005/health && echo ✅ Commerce Service

echo Microservices are ready!
pause