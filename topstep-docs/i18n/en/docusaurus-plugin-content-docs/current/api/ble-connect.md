---
sidebar_position: 1
title: BleConnect
---

# BleConnect Module

The BleConnect module provides comprehensive Bluetooth device connection management for TopStepComKit SDK, including device discovery, binding, authentication, and connection lifecycle management. All callbacks execute on the main thread for safe UI updates.

## Prerequisites

- iOS 12.0 or higher
- CoreBluetooth framework imported
- Bluetooth permission granted by user (NSBluetoothPeripheralUsageDescription)
- Valid user ID for device binding and connection

## Data Models

### TSPeripheralConnectParam

Connection parameters for device binding and connection operations.

| Property | Type | Description |
|----------|------|-------------|
| `userId` | `NSString *` | User ID for device connection (required) |
| `userInfo` | `TSUserInfoModel *` | User profile information for personalization |
| `authCode` | `NSString *` | Authentication code from QR code scanning during binding |
| `allowConnectWithBT` | `BOOL` | Flag indicating Bluetooth connection is allowed |
| `brand` | `NSString *` | Phone manufacturer name (e.g., "Apple") |
| `model` | `NSString *` | Phone model identifier (e.g., "iPhone 15 Pro") |
| `systemVersion` | `NSString *` | Phone OS version (e.g., "iOS 17.0") |

### TSPeripheralScanParam

Advanced scan parameters for device discovery with filtering.

| Property | Type | Description |
|----------|------|-------------|
| `userId` | `NSString *` | User ID for filtering (required) |
| `serviceUUIDs` | `NSArray<CBUUID *> *` | Filter by advertised service UUIDs (nil = no filter) |
| `solicitedServiceUUIDs` | `NSArray<CBUUID *> *` | Filter by solicited service UUIDs (nil = no filter) |
| `deviceName` | `NSString *` | Filter by device Bluetooth name (nil = no filter) |
| `macAddress` | `NSString *` | Filter by MAC address (nil = no filter) |
| `onlyUnconnected` | `BOOL` | Return only unconnected devices (default: NO) |
| `allowDuplicates` | `BOOL` | Allow multiple discoveries of same device (default: NO) |
| `scanTimeout` | `NSInteger` | Scan timeout in seconds (0 = infinite) |

### TSPeripheral

Complete device information model containing system, screen, project, capability, and limitation data.

| Property | Type | Description |
|----------|------|-------------|
| `systemInfo` | `TSPeripheralSystem *` | Bluetooth connection and addressing information |
| `screenInfo` | `TSPeripheralScreen *` | Screen size, shape, and preview configurations |
| `projectInfo` | `TSPeripheralProject *` | Project ID, firmware version, serial number |
| `capability` | `TSPeripheralCapability *` | Supported features and fine-grained capabilities |
| `limitation` | `TSPeripheralLimitations *` | Device feature constraints and limits |

### TSPeripheralSystem

System-level information for device communication.

| Property | Type | Description |
|----------|------|-------------|
| `peripheral` | `CBPeripheral *` | Core Bluetooth peripheral object |
| `central` | `CBCentralManager *` | Bluetooth central manager for connections |
| `uuid` | `NSString *` | UUID string from CBPeripheral (readonly) |
| `mac` | `NSString *` | MAC address in colon-separated format (e.g., "DE:82:47:15:28:B0") |
| `bleName` | `NSString *` | Device Bluetooth name |
| `RSSI` | `NSNumber *` | Signal strength indicator |
| `advertisementData` | `NSDictionary *` | Raw advertisement data from device |

### TSPeripheralScreen

Screen and preview image configuration.

| Property | Type | Description |
|----------|------|-------------|
| `shape` | `TSPeriphShape` | Device physical shape (circle, square, rectangle) |
| `screenSize` | `CGSize` | Screen dimensions in pixels |
| `screenBorderRadius` | `CGFloat` | Screen corner radius in pixels |
| `dialPreviewSize` | `CGSize` | Watch face preview thumbnail size in pixels |
| `dialPreviewBorderRadius` | `CGFloat` | Watch face preview corner radius in pixels |
| `videoPreviewSize` | `CGSize` | Camera video stream size in pixels |
| `videoPreviewBorderRadius` | `CGFloat` | Video preview corner radius in pixels |

### TSPeripheralProject

Project and version information.

| Property | Type | Description |
|----------|------|-------------|
| `projectId` | `NSString *` | Unique project identifier |
| `companyId` | `NSString *` | Manufacturer identifier |
| `brand` | `NSString *` | Brand name (max 16 characters) |
| `model` | `NSString *` | Model identifier (max 16 characters) |
| `firmVersion` | `NSString *` | Firmware version string (semantic versioning) |
| `virtualVersion` | `NSString *` | Internal version tracking number |
| `serialNumber` | `NSString *` | Unique device serial number |
| `mainProjNum` | `NSString *` | Main project number (FitCloudKit) |
| `subProjNum` | `NSString *` | Sub project number (FitCloudKit) |

### TSPeripheralCapability

Device capability container composing feature, message, and activity modules.

| Property | Type | Description |
|----------|------|-------------|
| `featureAbility` | `TSFeatureAbility *` | Coarse-grained feature support flags |
| `messageAbility` | `TSMessageAbility *` | Fine-grained message type support (nullable) |
| `dailyActivityAbility` | `TSDailyActivityAbility *` | Fine-grained activity type support (nullable) |

### TSFeatureAbility

Feature module capability flags indicating which major features are supported.

| Property | Type | Description |
|----------|------|-------------|
| `originAbility` | `NSData *` | Raw ability data from device (max 16 bytes) |
| `supportCapabilities` | `TSPeripheralSupportAbility` | Parsed capability flags bitmask |
| `isSupportStepCounting` | `BOOL` | Step counting support |
| `isSupportDistanceCounting` | `BOOL` | Distance counting support |
| `isSupportCalorieCounting` | `BOOL` | Calorie counting support |
| `isSupportHeartRate` | `BOOL` | Heart rate monitoring support |
| `isSupportBloodPressure` | `BOOL` | Blood pressure monitoring support |
| `isSupportBloodOxygen` | `BOOL` | Blood oxygen monitoring support |
| `isSupportStress` | `BOOL` | Stress monitoring support |
| `isSupportSleep` | `BOOL` | Sleep monitoring support |
| `isSupportTemperature` | `BOOL` | Temperature monitoring support |
| `isSupportECG` | `BOOL` | ECG monitoring support |
| `isSupportFemaleHealth` | `BOOL` | Female health features support |
| `isSupportInitiateWorkout` | `BOOL` | Initiate workout support |
| `isSupportWeightManagement` | `BOOL` | Weight management support |
| `isSupportReminders` | `BOOL` | Reminders support |
| `isSupportCallManagement` | `BOOL` | Call management support |
| `isSupportAppNotifications` | `BOOL` | App notifications support |
| `isSupportMusicControl` | `BOOL` | Music control support |
| `isSupportWeatherDisplay` | `BOOL` | Weather display support |
| `isSupportFindMyPhone` | `BOOL` | Find my phone support |
| `isSupportAlarmClock` | `BOOL` | Alarm clock support |
| `isSupportWorldClock` | `BOOL` | World clock support |
| `isSupportMapNavigation` | `BOOL` | Map navigation support |
| `isSupportShakeCamera` | `BOOL` | Shake to take photo support |
| `isSupportCameraPreview` | `BOOL` | Camera video preview support |
| `isSupportEWallet` | `BOOL` | E-wallet support |
| `isSupportBusinessCard` | `BOOL` | Business card support |
| `isSupportPhotoAlbum` | `BOOL` | Photo album support |
| `isSupportEBook` | `BOOL` | E-book support |
| `isSupportVoiceRecording` | `BOOL` | Voice recording support |
| `isSupportAppStore` | `BOOL` | App store support |
| `isSupportMotionGames` | `BOOL` | Motion sensing games support |
| `isSupportSportUpload` | `BOOL` | Sport upload support |
| `isSupportERNIEBot` | `BOOL` | ERNIE Bot support |
| `isSupportChatGPT` | `BOOL` | ChatGPT support |
| `isSupportLoversFeature` | `BOOL` | Lovers feature support |
| `isSupportContacts` | `BOOL` | Contacts support |
| `isSupportEmergencyContacts` | `BOOL` | Emergency contacts support |
| `isSupportMuslimPrayer` | `BOOL` | Muslim prayer reminders support |
| `isSupportQiblaCompass` | `BOOL` | Qibla compass support |
| `isSupportNFCPayment` | `BOOL` | NFC payment support |
| `isSupportVoiceAssistant` | `BOOL` | Voice assistant support |
| `isSupportFacePush` | `BOOL` | Watch face push support |
| `isSupportCustomFace` | `BOOL` | Custom watch face support |
| `isSupportSlideshowFace` | `BOOL` | Slideshow watch face support |
| `isSupportDialComponent` | `BOOL` | Dial component support |
| `isSupportTimeSettings` | `BOOL` | Time settings support |
| `isSupportLanguage` | `BOOL` | Language settings support |
| `isSupportUserInfoSettings` | `BOOL` | User information settings support |
| `isSupportDailyActivity` | `BOOL` | Daily activity support |
| `isSupportFirmwareUpgrade` | `BOOL` | Firmware upgrade support |
| `isSupportUnitSettings` | `BOOL` | Unit settings support |
| `isSupportEarbudsAPIs` | `BOOL` | Earbuds APIs support |
| `isSupportAIChat` | `BOOL` | AI chat support |
| `isSupportAIChatAudioUsingSco` | `BOOL` | AI chat audio using SCO support |
| `isSupportScreenLock` | `BOOL` | Screen lock support |
| `isSupportGameLock` | `BOOL` | Game lock support |

### TSMessageAbility

Fine-grained message type support management.

| Property | Type | Description |
|----------|------|-------------|
| No direct properties | - | Access through methods |

### TSDailyActivityAbility

Fine-grained daily activity type support management.

| Property | Type | Description |
|----------|------|-------------|
| No direct properties | - | Access through methods |

### TSBluetoothSystem

Complete Bluetooth system information (BLE and Classic Bluetooth).

| Property | Type | Description |
|----------|------|-------------|
| `bleInfo` | `TSBluetoothInfo *` | BLE adapter information |
| `btInfo` | `TSBluetoothInfo *` | Classic Bluetooth adapter information |

### TSBluetoothInfo

Bluetooth adapter information.

| Property | Type | Description |
|----------|------|-------------|
| `macAddress` | `NSString *` | MAC address (colon-separated, may be nil on iOS) |
| `name` | `NSString *` | Adapter name |
| `status` | `TSBleStatus` | Adapter connection status |

### TSPeripheralLimitations

Device feature capability constraints.

| Property | Type | Description |
|----------|------|-------------|
| `maxAlarmCount` | `UInt8` | Maximum alarm clocks (0 = not supported) |
| `maxContactCount` | `UInt8` | Maximum contacts (0 = not supported) |
| `maxEmergencyContactCount` | `UInt8` | Maximum emergency contacts (0 = not supported, 255 = unlimited) |
| `maxPushDialCount` | `UInt8` | Maximum custom watch face slots (0 = not supported) |
| `maxInnerDialCount` | `UInt8` | Pre-installed watch faces count |
| `maxWorldClockCount` | `UInt8` | Maximum world clocks (0 = not supported, 255 = unlimited) |
| `maxSedentaryReminderCount` | `UInt8` | Maximum sedentary reminders (0 = not supported, 255 = unlimited) |
| `maxWaterDrinkingReminderCount` | `UInt8` | Maximum water drinking reminders (0 = not supported, 255 = unlimited) |
| `maxMedicationReminderCount` | `UInt8` | Maximum medication reminders (0 = not supported, 255 = unlimited) |
| `maxCustomReminderCount` | `UInt8` | Maximum custom reminders (0 = not supported, 255 = unlimited) |

## Enumerations

### TSBleConnectionState

Bluetooth connection state enumeration defining the complete lifecycle from discovery through full readiness.

| Value | Name | Description |
|-------|------|-------------|
| `0` | `eTSBleStateDisconnected` | Device not connected (initial state or after failure) |
| `1` | `eTSBleStateConnecting` | Establishing BLE physical connection |
| `2` | `eTSBleStateAuthenticating` | Performing bind/login authentication |
| `3` | `eTSBleStatePreparingData` | Fetching device information after authentication |
| `4` | `eTSBleStateConnected` | Fully connected and ready for data operations |

### TSScanCompletionReason

Reasons for scan completion.

| Value | Name | Description |
|-------|------|-------------|
| `1000` | `eTSScanCompleteReasonTimeout` | Scan timeout occurred |
| `1001` | `eTSScanCompleteReasonBleNotReady` | Bluetooth not ready |
| `1002` | `eTSScanCompleteReasonPermissionDenied` | Bluetooth permission denied |
| `1003` | `eTSScanCompleteReasonUserStopped` | User manually stopped scan |
| `1004` | `eTSScanCompleteReasonSystemError` | System error occurred |
| `1005` | `eTSScanCompleteReasonNotSupport` | Bluetooth not supported |

### TSBleStatus

Bluetooth adapter connection status.

| Value | Name | Description |
|-------|------|-------------|
| `0` | `TSBleDisconnected` | Not connected |
| `1` | `TSBleConnected` | Connected (physical connection established) |
| `2` | `TSBleReady` | Ready (connected and notify/SPP opened) |

### TSPeriphShape

Device physical shape enumeration.

| Value | Name | Description |
|-------|------|-------------|
| `0` | `eTSPeriphShapeUnknow` | Unknown shape |
| `1` | `eTSPeriphShapeCircle` | Circular device (round watch) |
| `2` | `eTSPeriphShapeSquare` | Square device (square watch) |
| `3` | `eTSPeriphShapeVerticalRectangle` | Vertical rectangle (portrait orientation) |
| `4` | `eTSPeriphShapeTransverseRectangle` | Horizontal rectangle (landscape orientation) |

### TSPeripheralSupportAbility

Feature support capability flags (64-bit bitmask).

| Bit Range | Features |
|-----------|----------|
| 0-12 | Health: steps, distance, calories, heart rate, blood pressure, oxygen, stress, sleep, temperature, ECG, female health, workouts, daily activity, weight |
| 16-33 | Smart: reminders, calls, notifications, music, weather, find phone, alarm, world clock, maps, shake camera, camera preview, e-wallet, business card, photos, e-book, recording, app store, motion games |
| 34-36 | AI: sport upload, ERNIE Bot, ChatGPT |
| 37-39 | Social: lovers, contacts, emergency contacts |
| 40-41 | Religious: Muslim prayer, Qibla compass |
| 42-46 | Hardware: NFC, voice assistant, watch face, custom face, slideshow face |
| 47-51 | System: time, language, user info, firmware upgrade, units |
| 52-57 | Reserved: earbuds, dial component, AI chat, AI chat SCO, screen lock, game lock |

## Callback Types

### TSScanDiscoveryBlock

Device discovery callback during scan.

```objc
typedef void(^TSScanDiscoveryBlock)(TSPeripheral *_Nonnull peripheral);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `peripheral` | `TSPeripheral *` | Discovered device with name, ID, and signal information |

### TSScanCompletionBlock

Scan completion callback.

```objc
typedef void(^TSScanCompletionBlock)(TSScanCompletionReason reason, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `reason` | `TSScanCompletionReason` | Reason for scan completion |
| `error` | `NSError *` | Error details if applicable (nullable) |

### TSBleConnectionStateCallback

Connection state change callback during connection process.

```objc
typedef void (^TSBleConnectionStateCallback)(TSBleConnectionState connectionState);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `connectionState` | `TSBleConnectionState` | Current connection state |

### TSBleConnectionCompletionBlock

Connection result callback with state and optional error.

```objc
typedef void (^TSBleConnectionCompletionBlock)(TSBleConnectionState connectionState, NSError *_Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `connectionState` | `TSBleConnectionState` | Final or current connection state |
| `error` | `NSError *` | Error details if failure occurred (nullable) |

## API Reference

### Get current connection state

Retrieve the current Bluetooth connection state asynchronously.

```objc
- (void)getConnectState:(TSBleConnectionStateCallback)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSBleConnectionStateCallback` | Callback returning current connection state |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

[bleConnect getConnectState:^(TSBleConnectionState connectionState) {
    switch (connectionState) {
        case eTSBleStateDisconnected:
            TSLog(@"Device disconnected");
            break;
        case eTSBleStateConnecting:
            TSLog(@"Device connecting...");
            break;
        case eTSBleStateAuthenticating:
            TSLog(@"Device authenticating...");
            break;
        case eTSBleStatePreparingData:
            TSLog(@"Device preparing data...");
            break;
        case eTSBleStateConnected:
            TSLog(@"Device connected and ready");
            break;
    }
}];
```

### Start scanning for devices

Begin searching for Bluetooth devices with simple timeout configuration.

```objc
- (void)startSearchPeripheral:(NSTimeInterval)timeout
           discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                   completion:(TSScanCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | `NSTimeInterval` | Scan timeout in seconds (0 = default 30 seconds) |
| `discoverPeripheral` | `TSScanDiscoveryBlock` | Callback triggered when device discovered |
| `completion` | `TSScanCompletionBlock` | Callback when scan completes or times out |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

[bleConnect startSearchPeripheral:30.0  // 30 second timeout
                discoverPeripheral:^(TSPeripheral *peripheral) {
    TSLog(@"Device found: %@, RSSI: %@", peripheral.systemInfo.bleName, peripheral.systemInfo.RSSI);
    
    // Update UI with discovered device
    [self updateDeviceListWithPeripheral:peripheral];
} completion:^(TSScanCompletionReason reason, NSError *error) {
    if (error) {
        TSLog(@"Scan error: %@", error.localizedDescription);
    } else {
        TSLog(@"Scan completed with reason: %ld", (long)reason);
    }
}];
```

### Start scanning with advanced parameters

Begin searching with detailed filter and configuration options.

```objc
- (void)startSearchPeripheralWithParam:(TSPeripheralScanParam *)param
                    discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                            completion:(TSScanCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `param` | `TSPeripheralScanParam *` | Scan parameters with filters and timeout |
| `discoverPeripheral` | `TSScanDiscoveryBlock` | Callback for device discovery |
| `completion` | `TSScanCompletionBlock` | Callback when scan completes |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

TSPeripheralScanParam *param = [[TSPeripheralScanParam alloc] init];
param.userId = @"user123";
param.scanTimeout = 30;  // 30 second timeout
param.allowDuplicates = YES;  // Get RSSI updates
param.deviceName = @"MyDevice";  // Filter by name (optional)
param.onlyUnconnected = YES;

[bleConnect startSearchPeripheralWithParam:param
                       discoverPeripheral:^(TSPeripheral *peripheral) {
    TSLog(@"Found device: %@", peripheral.systemInfo.bleName);
} completion:^(TSScanCompletionReason reason, NSError *error) {
    TSLog(@"Scan completed");
}];
```

### Stop scanning

Halt the current device search operation.

```objc
- (void)stopSearchPeripheral;
```

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

// Stop scanning
[bleConnect stopSearchPeripheral];
TSLog(@"Scan stopped");
```

### Connect to device

Establish initial connection and binding to a new device.

```objc
- (void)connectWithPeripheral:(TSPeripheral *)peripheral
                        param:(TSPeripheralConnectParam *)param
                   completion:(TSBleConnectionCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `peripheral` | `TSPeripheral *` | Device to connect to |
| `param` | `TSPeripheralConnectParam *` | Connection parameters including user ID |
| `completion` | `TSBleConnectionCompletionBlock` | Callback for connection progress and result |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;
TSPeripheral *device = /* ... selected device ... */;

TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:@"user123"];
param.authCode = @"123456";  // From QR code
param.brand = @"Apple";
param.model = @"iPhone 15";
param.systemVersion = @"17.0";

[bleConnect connectWithPeripheral:device param:param completion:^(TSBleConnectionState connectionState, NSError *error) {
    if (error) {
        TSLog(@"Connection failed: %@", error.localizedDescription);
        return;
    }
    
    switch (connectionState) {
        case eTSBleStateConnecting:
            TSLog(@"Connecting...");
            [self updateProgressText:@"Connecting to device..."];
            break;
        case eTSBleStateAuthenticating:
            TSLog(@"Authenticating...");
            [self updateProgressText:@"Authenticating..."];
            break;
        case eTSBleStatePreparingData:
            TSLog(@"Preparing data...");
            [self updateProgressText:@"Preparing data..."];
            break;
        case eTSBleStateConnected:
            TSLog(@"Connected!");
            [self showConnectionSuccessUI];
            break;
        case eTSBleStateDisconnected:
            TSLog(@"Disconnected");
            break;
    }
}];
```

### Reconnect to device

Re-establish connection to a previously bound device.

```objc
- (void)reconnectWithPeripheral:(TSPeripheral *)peripheral
                          param:(TSPeripheralConnectParam *)param
                     completion:(TSBleConnectionCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `peripheral` | `TSPeripheral *` | Previously bound device to reconnect |
| `param` | `TSPeripheralConnectParam *` | Connection parameters with same user ID |
| `completion` | `TSBleConnectionCompletionBlock` | Callback for reconnection progress and result |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;
TSPeripheral *device = /* ... stored device ... */;

TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:@"user123"];
param.brand = @"Apple";
param.model = @"iPhone 15";
param.systemVersion = @"17.0";

[bleConnect reconnectWithPeripheral:device param:param completion:^(TSBleConnectionState connectionState, NSError *error) {
    if (error) {
        TSLog(@"Reconnection failed: %@", error.localizedDescription);
    } else if (connectionState == eTSBleStateConnected) {
        TSLog(@"Reconnected successfully!");
    }
}];
```

### Disconnect device

Safely disconnect from current device while preserving binding information.

```objc
- (void)disconnectCompletion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Callback when disconnection completes |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

[bleConnect disconnectCompletion:^(NSError *error) {
    if (error) {
        TSLog(@"Disconnect error: %@", error.localizedDescription);
    } else {
        TSLog(@"Device disconnected");
    }
}];
```

### Unbind device

Completely remove device binding and clear all pairing information.

```objc
- (void)unbindPeripheralCompletion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Callback when unbinding completes |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

[bleConnect unbindPeripheralCompletion:^(NSError *error) {
    if (error) {
        TSLog(@"Unbind error: %@", error.localizedDescription);
    } else {
        TSLog(@"Device unbound - must rebind to use again");
    }
}];
```

### Check connection status

Quickly verify if device is currently connected.

```objc
- (BOOL)isConnected;
```

**Returns:** `BOOL` — YES if device connected, NO otherwise

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

if ([bleConnect isConnected]) {
    TSLog(@"Device is connected");
    // Enable features that require connection
} else {
    TSLog(@"Device is not connected");
    // Show connection UI
}
```

### Get Bluetooth adapter information

Retrieve complete Bluetooth system information for BLE and Classic Bluetooth.

```objc
- (void)getBluetoothInfo:(void(^)(TSBluetoothSystem * _Nullable bluetoothInfo, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | Block returning `TSBluetoothSystem *` | Callback with Bluetooth system information and optional error |

**Code Example:**

```objc
id<TSBleConnectInterface> bleConnect = /* ... get interface ... */;

[bleConnect getBluetoothInfo:^(TSBluetoothSystem *bluetoothInfo, NSError *error) {
    if (error) {
        TSLog(@"Error getting Bluetooth info: %@", error.localizedDescription);
        return;
    }
    
    if (bluetoothInfo) {
        TSLog(@"BLE Status: %ld", (long)bluetoothInfo.bleInfo.status);
        TSLog(@"BLE Name: %@", bluetoothInfo.bleInfo.name);
        
        if (bluetoothInfo.btInfo) {
            TSLog(@"BT Status: %ld", (long)bluetoothInfo.btInfo.status);
            TSLog(@"BT Name: %@", bluetoothInfo.btInfo.name);
        }
    }
}];
```

## Important Notes

1. **All callbacks execute on the main thread** — Safe for direct UI updates without dispatch_async

2. **Connection state flow on success:**
   - `eTSBleStateDisconnected` → `eTSBleStateConnecting` → `eTSBleStateAuthenticating` → `eTSBleStatePreparingData` → `eTSBleStateConnected`

3. **Connection state flow on failure at any stage:**
   - Any state → `eTSBleStateDisconnected` with error details in completion callback

4. **Multiple callback invocations** — The completion callback is triggered multiple times with different states during connection; use state parameter to track progress

5. **Scan resource management** — Call `stopSearchPeripheral` when not needed to conserve battery and release resources

6. **User ID requirement** — Always provide valid user ID in connection and scan parameters for proper binding

7. **MAC address availability** — MAC addresses may be `nil` on iOS due to privacy restrictions

8. **Thread safety** — Methods can be safely called from any thread; callbacks always return on main thread

9. **Disconnection vs `Unbinding**` — Disconnection preserves binding (use `reconnectWithPeripheral`); unbinding removes all pairing info (use `connectWithPeripheral` to rebind)

10. **Capability modules** — Check `featureAbility` first (coarse-grained); then check `messageAbility` and `dailyActivityAbility` for fine-grained details of supported types

11. **Limitation constraints** — Value of `0` means feature not supported; value of `255` (TSUnLimitNum) means unlimited

12. **Default scan timeout** — Pass `0` to `startSearchPeripheral:` to use default 30-second timeout; use `TSPeripheralScanParam` for custom timeout

13. **Error handling** — Always check error parameter in callbacks; connection failures may occur at any stage

14. **State callback purpose** — Use state callback for progress UI updates; use completion callback for business logic decisions