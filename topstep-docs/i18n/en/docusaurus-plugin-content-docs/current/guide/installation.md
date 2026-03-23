---
sidebar_position: 1
title: Installation
---

# Installation

This guide explains how to integrate TopStepComKit SDK into your iOS project using CocoaPods.

## Requirements

| Environment | Minimum Version |
|-------------|----------------|
| iOS | 12.0 |
| Xcode | 13.0 |
| CocoaPods | 1.10.0 |

## Step 1: Install CocoaPods

If not already installed:

```bash
sudo gem install cocoapods
```

## Step 2: Initialize Podfile

In your project root:

```bash
cd YourProjectFolder
pod init
```

## Step 3: Add Dependencies

Open the `Podfile` and add the appropriate pod for your device platform.

### Choose Your Platform Pod

| Device Platform | Pod Name | SDK Type Constant |
|----------------|----------|------------------|
| Realtek (FIT) | `TopStepFitKit` | `eTSSDKTypeFIT` |
| BES (FW) | `TopStepNewPlatformKit` | `eTSSDKTypeFW` |
| SJ | `TopStepSJWatchKit` | `eTSSDKTypeSJ` |
| CRP | `TopStepCRPKit` | `eTSSDKTypeCRP` |
| UTE | `TopStepUTEKit` | `eTSSDKTypeUTE` |
| TPB | `TopStepTPBKit` | `eTSSDKTypeTPB` |

**Single platform example:**

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'TopStepComKit'   # Core (required)
  pod 'TopStepFitKit'   # Realtek devices
end
```

**Multi-platform example:**

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'TopStepComKit'
  pod 'TopStepFitKit'
  pod 'TopStepNewPlatformKit'
  pod 'TopStepSJWatchKit'
  pod 'TopStepCRPKit'
end
```

## Step 4: Install

```bash
pod install
```

After installation, open the project using `.xcworkspace` (not `.xcodeproj`).

## Step 5: Configure Bluetooth Permissions

Add the following to `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth access is required to connect to smart wearable devices.</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>Bluetooth access is required to connect to smart wearable devices.</string>
```

:::tip iOS 13+
`NSBluetoothAlwaysUsageDescription` is required on iOS 13 and later. Without it, Bluetooth will not function.
:::

## Step 6: Import the SDK

In files that use the SDK:

```objectivec
#import <TopStepComKit/TopStepComKit.h>
```

Or add to `Prefix.pch` for project-wide access:

```objectivec
#ifdef __OBJC__
  #import <Foundation/Foundation.h>
  #import <UIKit/UIKit.h>
  #import <TopStepComKit/TopStepComKit.h>
#endif
```

## Troubleshooting

**"Unable to find a specification for TopStepComKit"**

Check that your Podfile includes the correct source for the TopStep private spec repo:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://your-topstep-spec-repo.git'  # Replace with actual URL
```

**"Undefined symbol: _OBJC_CLASS_$_TSComKit"**

Make sure you also added the device-specific platform pod (e.g. `TopStepFitKit`) to your Podfile, and ran `pod install`.

**Bluetooth permission dialog never appears**

Confirm the `Info.plist` permission keys are correctly set. Note that BLE is not supported in the iOS Simulator — test on a real device.
