# Flutter SDK Installation Instructions

## Current Status
Flutter SDK is not installed on your system. Due to directory restrictions in Claude Code, manual installation is required.

## Option 1: Manual Download (Recommended)

### Step 1: Download Flutter SDK
1. Open your web browser
2. Go to: https://docs.flutter.dev/get-started/install/macos
3. Download **Flutter SDK 3.32.5** for macOS (ARM64)
   - Direct link: https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.32.5-stable.zip

### Step 2: Find and Extract the Downloaded File

First, let's find where the Flutter zip file was downloaded:

```bash
# Check Downloads folder
ls -la ~/Downloads/ | grep -i flutter

# If not in Downloads, check Desktop
ls -la ~/Desktop/ | grep -i flutter

# Or search your system
find ~ -name "*flutter*.zip" 2>/dev/null
```

### Step 3: Extract and Setup

Once you find the Flutter zip file, extract it:

```bash
# Create development directory
mkdir -p ~/development
cd ~/development

# Extract the downloaded zip file (replace PATH_TO_FILE with actual path)
# Example: if file is in Downloads:
unzip ~/Downloads/flutter_macos_arm64_3.32.5-stable.zip

# OR if file is in Desktop:
# unzip ~/Desktop/flutter_macos_arm64_3.32.5-stable.zip

# OR if file has a different name, use the actual filename you found

# Add Flutter to PATH permanently
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Alternative: Download via Terminal

If the file wasn't downloaded properly, download it directly:

```bash
mkdir -p ~/development
cd ~/development
curl -L -o flutter_macos_arm64.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.32.5-stable.zip
unzip flutter_macos_arm64.zip
```

### Step 3: Verify Installation
```bash
flutter --version
flutter doctor
```

## Option 2: Using Homebrew (Alternative)
```bash
# This may take 5-10 minutes
brew install --cask flutter

# Verify installation
flutter --version
flutter doctor
```

## After Installation
Once Flutter is installed, return to Claude Code and we can proceed with:
1. Installing project dependencies (`flutter pub get`)
2. Running code generation (`dart run build_runner build`)
3. Launching the demo app (`flutter run`)

## Expected Flutter Doctor Output
After installation, `flutter doctor` should show:
- ✓ Flutter (Channel stable, 3.32.5)
- ✓ Android toolchain (if Android development desired)
- ✓ Xcode (if iOS development desired)
- ✓ VS Code or Android Studio

## Next Steps
After completing the Flutter installation, let me know and I'll continue with SETUP-002 (project dependencies) and SETUP-003 (launching the demo app).