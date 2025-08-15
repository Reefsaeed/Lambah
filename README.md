# Lambah - AI Dashboard Warning Detection 

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.6+-blue.svg)](https://developer.apple.com/ios/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-purple.svg)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

> **Lambah** is an intelligent iOS app that uses AI-powered computer vision to instantly detect and identify dashboard warning lights, providing expert guidance and solutions for vehicle maintenance.

## Features ✨

- **Real-time Detection**: Instant dashboard warning light identification using CoreML and Vision
- **AI-Powered**: Advanced machine learning model trained on automotive dashboard symbols
- **Clean Interface**: User-friendly camera interface with detection frame guidance
- **Expert Guidance**: Detailed explanations and actionable advice for each warning
- **Service Locator**: Find nearest car service centers with integrated maps
- **Smooth Experience**: Beautiful onboarding and polished UI animations

## Architecture 🏗️

This project follows **Clean MVVM Architecture**:

```
📁 Project Structure
├──  Application/
├──  Models/
├──  ViewModels/
├──  Views/
├──  ViewControllers/
├──  Services/
└──  Extensions/
```

**Benefits:**
- Clean separation of concerns
- Easily testable ViewModels
- Reusable components
- Reactive UI updates with Combine

## Requirements 📋

- iOS 17.6+
- Xcode 16.0+
- Swift 5.0+
- Device with Camera
- CoreML Model: `best.mlmodel`

## Installation 🚀

1. **Clone the repository**
   ```bash
   git clone https://github.com/reefsaeed/lambah.git
   cd lambah
   ```

2. **Open in Xcode**
   ```bash
   open Lambah.xcodeproj
   ```

3. **Add CoreML Model**
   - Add your trained `best.mlmodel` file to the project
   - Ensure it's included in the target bundle

4. **Build and Run**
   - Select your target device/simulator
   - Build and run (⌘+R)

## Configuration 🔧

Add camera permission to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to detect dashboard warning symbols</string>
```

## How It Works 📱

1. **Launch the app** and complete the onboarding
2. **Point your camera** at your dashboard
3. **Position warning lights** within the detection frame
4. **Get instant results** with confidence levels
5. **View detailed information** about detected warnings
6. **Find nearby service** if repairs are needed

## Supported Dashboard Symbols 🛠️

- 🔴 **Critical**: Brake system, engine oil, temperature
- 🟠 **Important**: Check engine, battery, ABS
- 🟡 **General**: Fuel level, tire pressure, seat belt


## Author 👨‍💻
**Reef Saeed**
- GitHub: [@reefsaeed](https://github.com/reefsaeed)
