---
sidebar_position: 8
title: AppStore
---

# AppStore

The TSAppStore module provides a comprehensive interface for managing applications on watch devices. It enables you to retrieve installed applications, monitor application status changes, and track installation/uninstallation events in real time through callbacks.

## Prerequisites

- Watch device must be connected and available
- The host application must have appropriate permissions to query device application information
- Basic understanding of Objective-C blocks and callbacks

## Data Models

### TSApplicationModel

Represents an application installed on the watch device containing metadata and status information.

| Property | Type | Description |
|----------|------|-------------|
| `appId` | `NSString *` | Unique identifier for the application on the watch device |
| `appName` | `NSString *` | Display name of the application for UI identification |
| `appType` | `TSApplicationType` | Type of the application (system or user-installed) |
| `version` | `NSString *` | Version string of the application (e.g., "1.0.0") |
| `iconPath` | `NSString *` | Local file path or URL to the application icon image |
| `size` | `NSUInteger` | Size of the application in bytes representing storage space |
| `isInstalled` | `BOOL` | Whether the application is currently installed on the device |
| `isEnabled` | `BOOL` | Whether the application is currently enabled and usable |
| `appPath` | `NSString *` | File system path where the application is located on the device |
| `appDescription` | `NSString *` | Description or summary of the application's functionality |
| `packageName` | `NSString *` | Package name or bundle identifier of the application |
| `installTime` | `NSTimeInterval` | Timestamp when the application was installed (seconds since 1970-01-01) |
| `updateTime` | `NSTimeInterval` | Timestamp when the application was last updated (seconds since 1970-01-01) |

## Enumerations

### TSApplicationType

Defines different types of applications on the watch device.

| Value | Description |
|-------|-------------|
| `eTSApplicationTypeSystem` | Built-in system applications that cannot be uninstalled |
| `eTSApplicationTypeUserInstalled` | User-installed applications that can be uninstalled |

### TSApplicationStatus

Defines different states of application change notifications.

| Value | Description |
|-------|-------------|
| `eTSApplicationStatusUnknow` | Application status is unknown |
| `eTSApplicationStatusInstalled` | Application was newly installed |
| `eTSApplicationStatusUninstalled` | Application was uninstalled or deleted |
| `eTSApplicationStatusDisabled` | Application was disabled |
| `eTSApplicationStatusEnabled` | Application was enabled |

## Callback Types

### TSApplicationListBlock

Callback block type for application list operations.

```objc
typedef void (^TSApplicationListBlock)(NSArray<TSApplicationModel *> *_Nullable applications, NSError *_Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `applications` | `NSArray<TSApplicationModel *> *` | Array of application models; empty array if retrieval fails |
| `error` | `NSError *` | Error information if failed; nil if successful |

### TSApplicationChangeBlock

Callback block type for individual application state change notifications.

```objc
typedef void (^TSApplicationChangeBlock)(TSApplicationModel *_Nullable application, TSApplicationStatus changeType, NSError *_Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `application` | `TSApplicationModel *` | Application model that changed; nil if notification fails |
| `changeType` | `TSApplicationStatus` | Type of change that occurred (installed, uninstalled, disabled, enabled) |
| `error` | `NSError *` | Error information if notification fails; nil if successful |

## API Reference

### Fetch all installed applications on the device

```objc
- (void)fetchAllInstalledApplications:(TSApplicationListBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSApplicationListBlock` | Completion callback with array of all installed application models |

**Description:**

Retrieves information about all applications currently installed on the watch device. Only returns applications where `isInstalled` is `YES`, including both system applications and user-installed applications. The callback is executed on the main thread.

**Example:**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore fetchAllInstalledApplications:^(NSArray<TSApplicationModel *> *applications, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch applications: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Found %lu installed applications", (unsigned long)applications.count);
    for (TSApplicationModel *app in applications) {
        TSLog(@"App: %@ (v%@) - Size: %lu bytes", app.appName, app.version, (unsigned long)app.size);
    }
}];
```

### Check if a specific application is installed

```objc
- (void)checkApplicationInstalled:(TSApplicationModel *)application 
                       completion:(void (^)(BOOL isInstalled, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `application` | `TSApplicationModel *` | Application model to check; must contain appId or packageName |
| `completion` | `void (^)(BOOL, NSError *)` | Completion callback with installation status and optional error |

**Description:**

Checks whether a specific application is currently installed on the watch device. The application is identified by `appId` or `packageName` from the provided `TSApplicationModel`. Returns `YES` if the application is found and `isInstalled` is `YES`, `NO` otherwise. The callback is executed on the main thread.

**Example:**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

TSApplicationModel *appToCheck = [[TSApplicationModel alloc] init];
appToCheck.appId = @"com.example.myapp";

[appStore checkApplicationInstalled:appToCheck 
                         completion:^(BOOL isInstalled, NSError *error) {
    if (error) {
        TSLog(@"Check failed: %@", error.localizedDescription);
        return;
    }
    
    if (isInstalled) {
        TSLog(@"Application is installed on the device");
    } else {
        TSLog(@"Application is not installed on the device");
    }
}];
```

### Register application list change listener

```objc
- (void)registerApplicationListDidChanged:(TSApplicationListBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSApplicationListBlock` | Callback when the application list changes; returns updated list and optional error |

**Description:**

Registers a callback that is triggered when applications are installed, uninstalled, enabled, or disabled on the device. The callback provides a snapshot of the updated application list. Use this method to keep the UI synchronized with device state changes. The callback is executed on the main thread. Multiple registrations override previous ones. Call `unregisterApplicationListDidChanged` to stop receiving notifications and avoid memory leaks.

**Example:**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore registerApplicationListDidChanged:^(NSArray<TSApplicationModel *> *applications, NSError *error) {
    if (error) {
        TSLog(@"Application list change notification failed: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Application list updated. Total installed apps: %lu", (unsigned long)applications.count);
    for (TSApplicationModel *app in applications) {
        TSLog(@"- %@: installed=%d, enabled=%d", app.appName, app.isInstalled, app.isEnabled);
    }
}];

// Later, when done listening:
// [appStore unregisterApplicationListDidChanged];
```

### Unregister application list change listener

```objc
- (void)unregisterApplicationListDidChanged;
```

**Description:**

Removes the registered application list change listener. After calling this method, no more change notifications will be received. If no listener is currently registered, calling this method has no effect.

**Example:**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

// Stop receiving application list change notifications
[appStore unregisterApplicationListDidChanged];

TSLog(@"Application list change listener unregistered");
```

### Register application change notification listener

```objc
- (void)registerApplicationDidChanged:(TSApplicationChangeBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSApplicationChangeBlock` | Callback for individual application state changes with type and error info |

**Description:**

Registers a callback that is triggered when a specific application's state changes on the device. This includes installation, uninstallation, disabling, and enabling events. Unlike `registerApplicationListDidChanged` which provides the entire application list, this method provides granular notifications for individual application changes. The callback is executed on the main thread. Multiple registrations override previous ones. Call `unregisterApplicationDidChanged` to stop receiving notifications and avoid memory leaks.

**Example:**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore registerApplicationDidChanged:^(TSApplicationModel *application, TSApplicationStatus changeType, NSError *error) {
    if (error) {
        TSLog(@"Application change notification failed: %@", error.localizedDescription);
        return;
    }
    
    NSString *changeDescription = @"Unknown";
    switch (changeType) {
        case eTSApplicationStatusInstalled:
            changeDescription = @"Installed";
            break;
        case eTSApplicationStatusUninstalled:
            changeDescription = @"Uninstalled";
            break;
        case eTSApplicationStatusDisabled:
            changeDescription = @"Disabled";
            break;
        case eTSApplicationStatusEnabled:
            changeDescription = @"Enabled";
            break;
        default:
            break;
    }
    
    TSLog(@"Application '%@' was %@", application.appName, changeDescription);
}];

// Later, when done listening:
// [appStore unregisterApplicationDidChanged];
```

### Unregister application change notification listener

```objc
- (void)unregisterApplicationDidChanged;
```

**Description:**

Removes the registered application change notification listener. After calling this method, no more change notifications will be received. If no listener is currently registered, calling this method has no effect.

**Example:**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

// Stop receiving individual application change notifications
[appStore unregisterApplicationDidChanged];

TSLog(@"Application change listener unregistered");
```

## Important Notes

1. All callbacks are executed on the main thread; do not perform long-running operations directly in callbacks.

2. Multiple listener registrations will override previous ones; only one callback per listener type can be active at a time.

3. Always call the corresponding unregister method (`unregisterApplicationListDidChanged` or `unregisterApplicationDidChanged`) when done listening to avoid memory leaks, especially if the listener is registered in a view controller lifecycle.

4. When checking if an application is installed using `checkApplicationInstalled:completion:`, the `TSApplicationModel` parameter must contain at least `appId` or `packageName` for proper identification. If both are provided, `appId` takes precedence.

5. The `TSApplicationListBlock` callback receives an empty array if application retrieval fails; check the `error` parameter to determine if an actual failure occurred.

6. System applications (identified by `appType == eTSApplicationTypeSystem`) typically cannot be uninstalled and are always present on the device.

7. Application sizes and timestamps may be zero if the corresponding information is not available or not yet determined by the device.

8. The `registerApplicationListDidChanged:` method provides a complete snapshot of all applications whenever any change occurs, while `registerApplicationDidChanged:` provides granular, per-application notifications. Choose the appropriate method based on your UI update requirements.

9. Disabled applications still exist on the device (isInstalled remains YES) but cannot be used until re-enabled.

10. Icon paths, application paths, and descriptions may be nil if the corresponding information is not available on the device.