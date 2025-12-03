# Focus Session Installer - Deployment Guide

Ready to share your package? Here's how to get it on GitHub or distribute it!

---

## Option 1: GitHub Repository

### Step 1: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. Repository name: `focus-session-installer`
3. Description: `A lightweight macOS automation tool that manages 25-minute focus sessions with automatic alerts and screen lock`
4. Make it **Public** (so others can discover and use it)
5. Initialize with:
   - ✅ Add a README file (we have one)
   - ✅ Add .gitignore (we have one)
   - ✅ Choose a license → MIT (we have one)
6. Click "Create repository"

### Step 2: Push Code to GitHub

```bash
cd ~/focus-session-installer

# Initialize git if not already done
git init
git add .
git commit -m "Initial commit: Focus Session Watcher v1.0.0"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/focus-session-installer.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Create GitHub Release

```bash
# Create an annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tags to GitHub
git push origin v1.0.0
```

Then on GitHub:
1. Go to **Releases** tab
2. Click "Draft a new release"
3. Select tag `v1.0.0`
4. Title: "Focus Session Watcher v1.0.0"
5. Description:
   ```
   Initial release of Focus Session Watcher!
   
   **Features:**
   - 🎯 Automatic 25-minute focus sessions
   - 🔔 Smart notifications via Shortcuts
   - 🔒 Auto-lock after session completion
   - 📊 Daily CSV analytics
   - ⚡ Minimal resource usage
   
   **Installation:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/focus-session-installer.git
   cd focus-session-installer
   bash install.sh
   ```
   
   See README.md for full documentation.
   ```
6. Click "Publish release"

---

## Option 2: Create Distribution ZIP

### Step 1: Create ZIP File

```bash
cd ~
zip -r focus-session-installer.zip focus-session-installer/ \
  -x "focus-session-installer/.git/*" \
  "focus-session-installer/.DS_Store" \
  "focus-session-installer/*/.DS_Store"
```

### Step 2: Verify ZIP Contents

```bash
unzip -l focus-session-installer.zip | head -20
```

### Step 3: Upload to Distribution Site

**Option A: GitHub Releases**
- Create a GitHub release (see above)
- Upload ZIP as an asset
- Users can download directly

**Option B: DropBox / Google Drive**
```bash
# Share the ZIP file
# Get shareable link and provide to users
```

**Option C: Personal Website**
```bash
# Upload to your website's download section
# Share the direct link
```

---

## Option 3: Homebrew Formula (Advanced)

For experienced developers who want to add Homebrew support:

### Step 1: Create Homebrew Tap (Optional)

```bash
# Create a new repository for your Homebrew formula
# https://github.com/YOUR_USERNAME/homebrew-focus-session
```

### Step 2: Create Formula File

Create `Formula/focus-session-installer.rb`:

```ruby
class FocusSessionInstaller < Formula
  desc "A lightweight macOS focus session tracker with Pomodoro timer"
  homepage "https://github.com/YOUR_USERNAME/focus-session-installer"
  url "https://github.com/YOUR_USERNAME/focus-session-installer/releases/download/v1.0.0/focus-session-installer.zip"
  sha256 "COMPUTE_THIS_SHA256"
  version "1.0.0"
  
  def install
    # Install to Application Support
    app_support = "#{ENV["HOME"]}/Library/Application Support/focus-session/installer"
    
    # Copy files
    mkdir_p app_support
    system "cp -R * #{app_support}/"
    system "chmod +x #{app_support}/*.sh"
    system "chmod +x #{app_support}/bin/*.sh"
    
    # Run installer
    system "bash #{app_support}/install.sh"
  end
  
  def uninstall
    app_support = "#{ENV["HOME"]}/Library/Application Support/focus-session"
    system "rm -rf #{app_support}"
    system "launchctl unload #{ENV["HOME"]}/Library/LaunchAgents/com.user.watch_inactivity_simple.plist"
  end
  
  test do
    assert_predicate "#{ENV["HOME"]}/focus-session-status.txt", :exist?
  end
end
```

### Step 3: Compute SHA256

```bash
sha256sum focus-session-installer.zip
```

Replace `COMPUTE_THIS_SHA256` with the output.

### Step 4: Install via Homebrew

```bash
brew tap YOUR_USERNAME/focus-session
brew install focus-session-installer
```

---

## Sharing Your Package

### Direct Link (ZIP)

```
Simply share the focus-session-installer.zip file or URL:
https://yoursite.com/focus-session-installer.zip
```

**Install instructions for users:**
```bash
unzip focus-session-installer.zip
cd focus-session-installer
bash install.sh
```

### GitHub Repository

```
Share the GitHub URL:
https://github.com/YOUR_USERNAME/focus-session-installer

Users can:
git clone https://github.com/YOUR_USERNAME/focus-session-installer.git
cd focus-session-installer
bash install.sh
```

### Homebrew (if set up)

```
For Homebrew users:
brew tap YOUR_USERNAME/focus-session
brew install focus-session-installer
```

### Gist / Pastebin

For quick sharing:
```bash
# (Not recommended - use GitHub instead)
```

---

## Pre-Distribution Checklist

- [ ] All files present and executable (`bash verify-package.sh`)
- [ ] Installation script tested on clean system
- [ ] README is clear and complete
- [ ] USAGE.md has helpful examples
- [ ] TROUBLESHOOTING.md covers common issues
- [ ] No personal data in files
- [ ] LICENSE file included
- [ ] .gitignore configured
- [ ] Scripts have no hardcoded usernames
- [ ] All documentation is up-to-date

---

## Post-Distribution

### Monitor Issues

- Check GitHub Issues regularly
- Respond to bug reports
- Help with troubleshooting
- Track feature requests

### Release Updates

When making changes:

```bash
# Make your changes
git add .
git commit -m "Fix: [description]"
git push origin main

# Create new release
git tag -a v1.1.0 -m "Version 1.1.0"
git push origin v1.1.0

# Update GitHub release with notes
```

### Update Documentation

- Keep README.md current
- Update CHANGELOG.md with new features
- Add troubleshooting sections for reported issues
- Improve examples based on user feedback

---

## Example README Update

Update your README.md after release:

```markdown
# Focus Session Watcher

A lightweight, minimalist macOS automation tool...

## Installation

### Quick Start (GitHub)
```bash
git clone https://github.com/YOUR_USERNAME/focus-session-installer.git
cd focus-session-installer
bash install.sh
```

### ZIP Download
1. Download: [focus-session-installer.zip](https://github.com/YOUR_USERNAME/focus-session-installer/releases)
2. Unzip and run: `bash install.sh`

### Homebrew
```bash
brew tap YOUR_USERNAME/focus-session
brew install focus-session-installer
```

## Features

- 🎯 25-minute Pomodoro sessions
- 🔔 Smart Shortcuts integration
- 🔒 Auto-lock screen
- 📊 CSV analytics
- ⚡ Minimal resource usage

[...rest of documentation...]
```

---

## Tips for Success

1. **Keep it Simple**: Easy installation = more users
2. **Good Documentation**: People use tools that are well documented
3. **Responsive Support**: Answer questions and fix bugs
4. **Clear Examples**: Show real-world usage
5. **Regular Updates**: Keep the tool maintained
6. **Gather Feedback**: Ask users what they want
7. **Version Clearly**: Use semantic versioning (v1.0.0, v1.1.0)
8. **Test Thoroughly**: Before each release, test on a fresh install

---

## Marketing Your Package

### Where to Share

- **Reddit**: r/macapps, r/productivity, r/automatetheboringsuff
- **Hacker News**: If it's particularly interesting
- **Product Hunt**: For product launches
- **Twitter/X**: Tag #macapps #productivity #automation
- **Dev Communities**: Slack groups, Discord servers
- **Personal Blog**: Write a post about why you built it
- **GitHub Awesome Lists**: Add to relevant awesome lists

### Sample Announcement

```
I just released Focus Session Watcher! 🎯

A lightweight macOS tool that:
✅ Tracks 25-minute focus sessions
✅ Sends Shortcuts alerts
✅ Auto-locks your screen
✅ Exports daily analytics
✅ Uses virtually no resources

GitHub: https://github.com/YOUR_USERNAME/focus-session-installer
Install: bash install.sh

Let me know what you think!
```

---

## License Compliance

You're using MIT License - great choice! Remember:

- Keep LICENSE file in all distributions
- Users can use, modify, and distribute
- No warranty or liability on your part
- Attribution appreciated but not required

---

**Ready to share? Good luck! 🚀**

For questions, check GitHub Issues or contact the community.
