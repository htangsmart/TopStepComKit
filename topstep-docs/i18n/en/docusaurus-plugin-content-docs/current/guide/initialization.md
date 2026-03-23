---
sidebar_position: 2
title: SDK Initialization
---

# SDK Initialization

SDK initialization is a prerequisite for all features. This guide covers how to configure `TSKitConfigOptions` and complete SDK initialization.

## When to Initialize

Initialize in `AppDelegate`'s `application:didFinishLaunchingWithOptions:` method, before any other SDK calls.

## Basic Initialization

```objectivec
#import <TopStepComKit/TopStepComKit.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Create config (specify device platform and license)
    TSKitConfigOptions *options = [TSKitConfigOptions configOptionWithSDKType:eTSSDKTypeFIT
                                                                      license:@"YOUR_32_CHAR_LICENSE_KEY"];

    // Initialize SDK
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:options completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"SDK initialized successfully");
        } else {
            TSLog(@"SDK initialization failed: %@", error.localizedDescription);
        }
    }];

    return YES;
}
```

## TSKitConfigOptions Parameters

### Required Parameters

| Property | Type | Description |
|----------|------|-------------|
| `sdkType` | `TSSDKType` | Device platform type — must match your actual hardware |
| `license` | `NSString *` | 32-character license key provided by TopStep |

### SDK Types (TSSDKType)

| Enum Value | Description |
|------------|-------------|
| `eTSSDKTypeFIT` | Realtek (FIT) series devices (default) |
| `eTSSDKTypeFW` | BES (New Platform) series devices |
| `eTSSDKTypeSJ` | SJ (Shenju) series devices |
| `eTSSDKTypeCRP` | CRP (Moyang) series devices |
| `eTSSDKTypeUTE` | UTE series devices |
| `eTSSDKTypeTPB` | TPB series devices |

### Optional Parameters

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `isDevelopModel` | `BOOL` | `NO` | Enable verbose logging during development; disable in production |
| `isSaveLogEnable` | `BOOL` | `NO` | Write logs to the filesystem |
| `logFilePath` | `NSString *` | `nil` | Custom log file path; `nil` uses the default path |
| `logLevel` | `TopStepLogLevel` | `Debug` | Minimum log level (Debug / Info / Warning / Error) |
| `isCheckBluetoothAuthority` | `BOOL` | `NO` | Check Bluetooth permission before operations; recommended for production |
| `maxScanSearchDuration` | `NSInteger` | `15` | Maximum scan duration in seconds; 0 uses the default |
| `maxConnectTimeout` | `NSInteger` | `45` | Maximum connection timeout in seconds; 0 uses the default |
| `maxTryConnectCount` | `NSInteger` | `10` | Maximum reconnection attempts after disconnection |
| `autoConnectWhenAppLaunch` | `BOOL` | `NO` | Automatically reconnect to the last device on app launch |

## Full Configuration Example

```objectivec
TSKitConfigOptions *options = [[TSKitConfigOptions alloc] init];
options.sdkType = eTSSDKTypeFIT;
options.license = @"abcd1234efgh5678ijkl9012mnop3456"; // 32 characters

// Logging (development)
options.isDevelopModel  = YES;
options.isSaveLogEnable = YES;
options.logLevel        = TopStepLogLevelDebug;

// Connection
options.isCheckBluetoothAuthority = YES;
options.maxScanSearchDuration     = 30;
options.maxConnectTimeout         = 60;
options.maxTryConnectCount        = 5;
options.autoConnectWhenAppLaunch  = YES;

[[TopStepComKit sharedInstance] initSDKWithConfigOptions:options completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"SDK initialized — ready to scan for devices");
        // Trigger auto-reconnect or navigate to main screen
    } else {
        TSLog(@"Initialization failed: %@", error.localizedDescription);
        // Common causes: license is not 32 chars, or network validation failed
    }
}];
```

## Obtaining Feature Module Instances

After successful initialization, access feature modules directly as properties on `[TopStepComKit sharedInstance]`:

```objectivec
// BLE connection
id<TSBleConnectInterface> bleConnector = [TopStepComKit sharedInstance].bleConnector;

// Device find
id<TSPeripheralFindInterface> peripheralFind = [TopStepComKit sharedInstance].peripheralFind;

// Heart rate
id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

// Data sync
id<TSDataSyncInterface> dataSync = [TopStepComKit sharedInstance].dataSync;

// Blood oxygen
id<TSBloodOxygenInterface> bloodOxygen = [TopStepComKit sharedInstance].bloodOxygen;

// Blood pressure
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

// Sleep
id<TSSleepInterface> sleep = [TopStepComKit sharedInstance].sleep;

// Watch face
id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
```

All available module properties are listed in `TopStepComKit.h`.

:::tip Recommended Practice
`[TopStepComKit sharedInstance]` is already a singleton — call it directly anywhere without storing extra references.
:::

## Important Notes

1. `initSDKWithConfigOptions:completion:` must be called on the main thread
2. `license` must be exactly 32 alphanumeric characters
3. The completion callback is executed on the main thread
4. Set `isDevelopModel` to `NO` in production to avoid performance overhead
5. If you support multiple device platforms, initialize the SDK instance for each platform separately
