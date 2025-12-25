@echo off
echo Adding Windows Firewall rule for port 2307...
netsh advfirewall firewall add rule name="Flutter Backend 2307" dir=in action=allow protocol=TCP localport=2307
echo.
echo Firewall rule added successfully!
echo You can now access the backend from your physical device.
pause
