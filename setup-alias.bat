@echo off
echo Setting up Flutter alias...
doskey flutter="%~dp0flutter.bat" $*
echo.
echo Done! Now you can use "flutter run" and it will auto-start the backend.
echo.
echo Note: This alias only works in this terminal session.
echo To make it permanent, add this to your profile or use run.bat instead.
echo.
