@echo off
echo Testing Backend Connectivity...
echo.
echo Testing localhost:2307...
curl -s http://localhost:2307/api/v1/health
echo.
echo.
echo Testing 172.29.212.108:2307...
curl -s http://172.29.212.108:2307/api/v1/health
echo.
echo.
echo If you see JSON responses above, backend is working!
echo If not, run 'add-firewall-rule.bat' as administrator.
pause
