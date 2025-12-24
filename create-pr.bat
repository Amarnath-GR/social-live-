@echo off
echo ========================================
echo Creating Pull Request for Social Media App
echo ========================================
echo.

echo Step 1: Creating feature branch from initial commit...
git checkout -b feature/social-media-mvp c67e30dd

if %errorlevel% neq 0 (
    echo Error: Failed to create branch. It might already exist.
    echo Switching to existing branch...
    git checkout feature/social-media-mvp
)

echo.
echo Step 2: Pushing feature branch to GitHub...
git push origin feature/social-media-mvp

if %errorlevel% neq 0 (
    echo Error: Failed to push branch.
    echo Please check your GitHub credentials and try again.
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Branch created and pushed.
echo ========================================
echo.
echo Next steps:
echo 1. Go to: https://github.com/Amarnath-GR/social-live-
echo 2. Click "Pull requests" tab
echo 3. Click "New pull request"
echo 4. Set Base: main, Compare: feature/social-media-mvp
echo 5. Copy content from PULL_REQUEST_TEMPLATE.md
echo 6. Click "Create pull request"
echo.
echo Or use GitHub CLI:
echo gh pr create --title "Complete Social Media Application - MVP Implementation" --body-file PULL_REQUEST_TEMPLATE.md --base main --head feature/social-media-mvp
echo.
echo ========================================

pause
