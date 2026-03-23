---
sidebar_position: 3
title: BLE Connection Flow
---

# BLE Connection Flow

This guide covers the complete flow from device discovery to a successful connection, along with lifecycle management (disconnect, unbind).

## Connection State Machine

The SDK models the connection process as 5 sequential states. The device is only usable once it reaches the final state:

```
eTSBleStateDisconnected
         │
         │  connectWithPeripheral: called
         ▼
eTSBleStateConnecting        ← Physical BLE link establishing
         │
         │  Physical link established
         ▼
eTSBleStateAuthenticating    ← Binding / login authentication
         │
         │  Authentication passed
         ▼
eTSBleStatePreparingData     ← Fetching device base info
         │
         │  Info sync complete
         ▼
eTSBleStateConnected         ← Device ready for all operations
```

Only after reaching `eTSBleStateConnected` can you call health data, settings, or other feature APIs.

## Step-by-Step Code

### Step 1: Scan for Devices

```objectivec
// Start scanning (30-second timeout)
[bleConnect startSearchPeripheral:30
               discoverPeripheral:^(TSPeripheral *peripheral) {
    // Called once for each device found
    TSLog(@"Found: %@ | MAC: %@",
          peripheral.systemInfo.bleName,
          peripheral.systemInfo.macAddress);

    [self.peripheralList addObject:peripheral];
    [self.tableView reloadData];

} completion:^(TSScanCompletionReason reason, NSError *error) {
    switch (reason) {
        case eTSScanCompleteReasonTimeout:
            TSLog(@"Scan timed out — found %lu device(s)", (unsigned long)self.peripheralList.count);
            break;
        case eTSScanCompleteReasonUserStopped:
            TSLog(@"Scan stopped by user");
            break;
        case eTSScanCompleteReasonPermissionDenied:
            TSLog(@"Bluetooth permission denied");
            [self showBluetoothPermissionAlert];
            break;
        default:
            if (error) TSLog(@"Scan error: %@", error.localizedDescription);
            break;
    }
}];
```

### Step 2: Stop Scanning When User Selects a Device

```objectivec
- (void)didSelectPeripheral:(TSPeripheral *)peripheral {
    // Stop scanning immediately to save battery
    [bleConnect stopSearchPeripheral];
    [self connectToPeripheral:peripheral];
}
```

### Step 3: First-Time Connection (Binding)

First-time connection requires an `authCode` obtained by scanning the QR code on the device:

```objectivec
- (void)connectToPeripheral:(TSPeripheral *)peripheral {
    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:self.userId];

    // Required for first-time binding (scanned from device QR code)
    param.authCode = self.scannedAuthCode;

    // Phone info (displayed on the device)
    param.brand         = @"Apple";
    param.model         = [UIDevice currentDevice].model;
    param.systemVersion = [UIDevice currentDevice].systemVersion;

    // User info (for device personalization)
    TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
    userInfo.age    = 28;
    userInfo.gender = 1;   // 1 = male, 0 = female
    userInfo.height = 175;
    userInfo.weight = 70;
    param.userInfo = userInfo;

    [bleConnect connectWithPeripheral:peripheral
                                param:param
                           completion:^(TSBleConnectionState state, NSError *error) {
        if (error) {
            TSLog(@"Connection failed: %@", error.localizedDescription);
            [self showConnectFailedAlert:error];
            return;
        }

        switch (state) {
            case eTSBleStateConnecting:
                [self showLoadingWith:@"Connecting..."];
                break;
            case eTSBleStateAuthenticating:
                [self showLoadingWith:@"Authenticating..."];
                break;
            case eTSBleStatePreparingData:
                [self showLoadingWith:@"Preparing..."];
                break;
            case eTSBleStateConnected:
                TSLog(@"Device connected!");
                [self hideLoading];
                [self onDeviceConnected:peripheral];
                break;
            case eTSBleStateDisconnected:
                [self hideLoading];
                break;
        }
    }];
}
```

### Step 4: Reconnecting (Already-Bound Device)

On subsequent app launches, use `reconnectWithPeripheral:` — no QR code needed:

```objectivec
- (void)reconnectSavedDevice {
    TSPeripheral *savedDevice = [self loadSavedPeripheral];
    if (!savedDevice) return;

    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:self.userId];

    [bleConnect reconnectWithPeripheral:savedDevice
                                  param:param
                             completion:^(TSBleConnectionState state, NSError *error) {
        if (state == eTSBleStateConnected) {
            TSLog(@"Reconnected successfully");
        } else if (error) {
            TSLog(@"Reconnect failed: %@", error.localizedDescription);
            // Typically need to re-scan and bind
        }
    }];
}
```

## Monitoring Connection State Changes

Listen for disconnection events throughout the app lifecycle:

```objectivec
// Set in AppDelegate or a global manager
[bleConnect setKitDelegate:self];

// Implement the delegate method (see TSBleConnectInterface protocol)
- (void)bleConnectStateDidChanged:(TSBleConnectionState)state {
    if (state == eTSBleStateDisconnected) {
        TSLog(@"Device disconnected");
        [self handleDeviceDisconnected];
    } else if (state == eTSBleStateConnected) {
        TSLog(@"Device reconnected");
        [self handleDeviceConnected];
    }
}
```

## Disconnecting

```objectivec
// Disconnect while keeping binding info (can reconnect later)
[bleConnect disconnectCompletion:^(BOOL isSuccess, NSError *error) {
    TSLog(@"Disconnect: %@", isSuccess ? @"success" : error.localizedDescription);
}];
```

## Unbinding

```objectivec
// Full unbind — requires QR scan to rebind next time
[bleConnect unbindPeripheralCompletion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"Unbound — clearing saved device info");
        [self clearSavedDevice];
        [self navigateToDeviceList];
    }
}];
```

## Best Practices

1. **First connection**: Use `connectWithPeripheral:param:completion:` with the scanned `authCode`
2. **Subsequent launches**: Use `reconnectWithPeripheral:param:completion:` — no `authCode` required
3. **Enable auto-reconnect**: Set `autoConnectWhenAppLaunch = YES` in `TSKitConfigOptions` — the SDK will automatically reconnect to the last device on app launch
4. **State check**: Call `[bleConnect isConnected]` before invoking any feature API
5. **Feature support check**: Not all devices support every feature — call `[featureKit isSupport]` before use

## Important Notes

1. Scanning and connecting only works on a real device — iOS Simulator does not support BLE
2. The `completion` block in `connectWithPeripheral:` is called multiple times (once per state transition)
3. Other feature modules can only be used after `eTSBleStateConnected` is reached
4. The BLE connection persists when the app goes to background, but some operations (e.g., data sync) may be restricted by the system
5. An app can only be connected to one device at a time
