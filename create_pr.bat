@echo off
echo Creating Pull Request for Profile Stats, Sample Reels, and Cart Fixes
echo.

echo Step 1: Check current branch
git branch
echo.

echo Step 2: Create new feature branch
git checkout -b fix/profile-stats-reels-cart
echo.

echo Step 3: Add all changes
git add lib/screens/profile_screen.dart
git add lib/models/post_model.dart
git add lib/services/real_video_service.dart
git add lib/services/marketplace_service.dart
git add lib/screens/product_detail_screen.dart
git add lib/screens/simple_marketplace_screen.dart
git add PR_CHANGES.md
echo.

echo Step 4: Commit changes
git commit -m "fix: Profile stats, sample reels, and cart improvements

- Add real counts to profile (followers, following, likes)
- Add 5 sample reels to home feed
- Fix shopping cart to start empty
- Remove hardcoded cart items
- Add proper cart state management

Fixes #[issue-number]"
echo.

echo Step 5: Push to remote
git push origin fix/profile-stats-reels-cart
echo.

echo Done! Now go to GitHub and create a Pull Request from 'fix/profile-stats-reels-cart' to 'main'
echo.
pause
