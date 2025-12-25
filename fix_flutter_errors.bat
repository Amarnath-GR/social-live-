@echo off
echo Fixing Flutter errors in the project...

cd /d "c:\Users\Amarnath.G.Rathod\social-live-flutter-mvp\social-live-flutter"

echo Fixing withOpacity deprecated method calls...
powershell -Command "(Get-ChildItem -Path . -Filter '*.dart' -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)' | Set-Content $_.FullName }"

echo Fixing print statements...
powershell -Command "(Get-ChildItem -Path . -Filter '*.dart' -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\bprint\(', 'debugPrint(' | Set-Content $_.FullName }"

echo Fixing ButtonBar deprecated widget...
powershell -Command "(Get-ChildItem -Path . -Filter '*.dart' -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'ButtonBar\(', 'OverflowBar(' | Set-Content $_.FullName }"

echo Fixing library prefix naming...
powershell -Command "(Get-ChildItem -Path . -Filter '*.dart' -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'import ''dart:io'' as IO;', 'import ''dart:io'' as io;' | Set-Content $_.FullName }"

echo Fixing deprecated form field value parameter...
powershell -Command "(Get-ChildItem -Path . -Filter '*.dart' -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'value:\s*([^,\n]+),', 'initialValue: $1,' | Set-Content $_.FullName }"

echo Running flutter analyze to check remaining issues...
flutter analyze

echo Done! Check the output above for any remaining issues.
pause