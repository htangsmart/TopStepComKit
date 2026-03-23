---
sidebar_position: 2
title: Quick Start
---

# Quick Start

5 steps to get from installation to reading heart rate data.

## Step 1: Install the SDK

Add to your `Podfile`:

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'TopStepComKit'
  pod 'TopStepFitKit'   # Choose based on your device platform
end
```

Run:

```bash
pod install
```

Add Bluetooth permission to `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth access is required to connect to smart wearable devices.</string>
```

## Step 2: Initialize the SDK

In `AppDelegate.m`:

```objectivec
#import <TopStepComKit/TopStepComKit.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    TSKitConfigOptions *options = [TSKitConfigOptions configOptionWithSDKType:eTSSDKTypeFIT
                                                                      license:@"YOUR_32_CHAR_LICENSE"];
    options.isDevelopModel = YES; // Enable during development, disable in production

    id<TSComKitInterface> comKit = [objc_getClass("TSComKit") sharedInstance];
    [comKit initSDKWithConfigOptions:options completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"SDK initialized successfully");
        }
    }];

    return YES;
}
```

## Step 3: Scan for Devices

```objectivec
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

[bleConnect startSearchPeripheral:30
               discoverPeripheral:^(TSPeripheral *peripheral) {
    TSLog(@"Found device: %@", peripheral.systemInfo.bleName);
    [self.deviceList addObject:peripheral];
    [self.tableView reloadData];
} completion:^(TSScanCompletionReason reason, NSError *error) {
    TSLog(@"Scan completed, found %lu devices", (unsigned long)self.deviceList.count);
}];
```

## Step 4: Connect to a Device

```objectivec
// Stop scanning and connect when user selects a device
[bleConnect stopSearchPeripheral];

TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:@"YOUR_USER_ID"];
param.authCode = @"qr_code_scanned_from_device"; // Required for first-time binding

[bleConnect connectWithPeripheral:selectedDevice
                            param:param
                       completion:^(TSBleConnectionState state, NSError *error) {
    if (state == eTSBleStateConnected) {
        TSLog(@"Device connected successfully!");
        [self onDeviceConnected];
    } else if (error) {
        TSLog(@"Connection failed: %@", error.localizedDescription);
    }
}];
```

## Step 5: Read Health Data

```objectivec
id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

// Check device capability first
if (![heartRate isSupport]) return;

// Start real-time heart rate measurement
[heartRate startMeasureWithParam:nil
                    startHandler:^(BOOL isSuccess, NSError *error) {
    TSLog(@"Measurement started: %@", isSuccess ? @"OK" : error.localizedDescription);
} dataHandler:^(TSHRValueItem *data, NSError *error) {
    TSLog(@"Heart rate: %ld bpm", (long)data.value);
} endHandler:^(BOOL isSuccess, NSError *error) {
    TSLog(@"Measurement ended");
}];
```

---

## Next Steps

- [Installation](./guide/installation) — Detailed CocoaPods setup and permissions
- [SDK Initialization](./guide/initialization) — All configuration options
- [BLE Connect Flow](./guide/ble-connect-flow) — Complete connection state machine
- [BLE Connect API](./api/ble-connect) — API reference
- [Heart Rate API](./api/health/heart-rate) — Health data interfaces
