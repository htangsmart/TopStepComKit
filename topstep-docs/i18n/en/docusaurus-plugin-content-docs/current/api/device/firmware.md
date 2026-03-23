---
sidebar_position: 4
title: FirmwareUpgrade
---

# TSFirmwareUpgrade Module

The TSFirmwareUpgrade module provides comprehensive firmware upgrade functionality for TopStep devices. It enables checking upgrade preconditions, initiating firmware upgrades with progress tracking, and canceling ongoing upgrade operations. This module ensures device safety through pre-upgrade validation checks including battery level, file validity, version compatibility, and device connection status.

## Prerequisites

- Device must be connected and in a valid state
- Device battery level must be above 30%
- Firmware file must be valid and compatible with the device
- Device must not be in an unstable or upgrading state
- Application must remain in foreground during upgrade process

## Data Models

### TSFileTransferModel

| Property | Type | Description |
|----------|------|-------------|
| `firmwareFile` | `NSURL *` | Path to the firmware file to be transferred or upgraded |
| `fileSize` | `NSUInteger` | Total size of the firmware file in bytes |
| `fileName` | `NSString *` | Name of the firmware file |
| `version` | `NSString *` | Target firmware version after upgrade |
| `checksum` | `NSString *` | Checksum value for file integrity verification |

## Enumerations

This module does not define custom enumerations. Refer to `TSFileTransferDefines.h` for file transfer related constants.

## Callback Types

### TSFileTransferProgressBlock

```objc
typedef void (^TSFileTransferProgressBlock)(NSUInteger progress);
```

Progress callback block invoked multiple times during file transfer or upgrade.

| Parameter | Type | Description |
|-----------|------|-------------|
| `progress` | `NSUInteger` | Current progress percentage (0-100) |

### TSFileTransferSuccessBlock

```objc
typedef void (^TSFileTransferSuccessBlock)(void);
```

Success callback block invoked when file transfer or upgrade completes successfully.

### TSFileTransferFailureBlock

```objc
typedef void (^TSFileTransferFailureBlock)(NSError *)` |

Failure callback block invoked when file transfer or upgrade fails or is canceled.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error object containing failure details |

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(BOOL success, `NSError *` _Nullable error);
```

Completion callback block invoked when operation completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the operation completed successfully |
| `error` | `NSError *` | Error object if operation failed; nil if successful |

## API Reference

### Check if device can be upgraded

```objc
- (void)checkFirmwareUpgradeConditions:(`TSFileTransferModel *`)model 
                             completion:(void (^)(BOOL canUpgrade, `NSError *` _Nullable error))completion;
```

Validates whether the device meets all requirements for firmware upgrade before initiating the process.

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | `TSFileTransferModel *` | Firmware upgrade model containing upgrade information and file details |
| `completion` | `void (^)(BOOL, NSError *)` | Completion callback with upgrade eligibility status and error details |

**Code Example:**

```objc
TSFileTransferModel *upgradeModel = [[TSFileTransferModel alloc] init];
upgradeModel.firmwareFile = [NSURL fileURLWithPath:@"/path/to/firmware.bin"];
upgradeModel.fileSize = 1024 * 1024;  // 1MB example
upgradeModel.fileName = @"firmware.bin";
upgradeModel.version = @"2.0.0";
upgradeModel.checksum = @"abc123def456";

[firmwareUpgradeInterface checkFirmwareUpgradeConditions:upgradeModel 
                                              completion:^(BOOL canUpgrade, `NSError *` _Nullable error) {
    if (canUpgrade) {
        TSLog(@"Device can be upgraded");
    } else {
        TSLog(@"Cannot upgrade: %@", error.localizedDescription);
    }
}];
```

### Start firmware upgrade

```objc
- (void)startFirmwareUpgrade:(`TSFileTransferModel *`)model
                     progress:(nullable TSFileTransferProgressBlock)progress
                      success:(nullable TSFileTransferSuccessBlock)success
                      failure:(nullable TSFileTransferFailureBlock)failure;
```

Initiates the firmware upgrade process with progress tracking and completion callbacks.

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | `TSFileTransferModel *` | Firmware upgrade model containing upgrade information and file path |
| `progress` | `TSFileTransferProgressBlock` | Progress callback invoked multiple times during upgrade (0-100) |
| `success` | `TSFileTransferSuccessBlock` | Success callback invoked when upgrade completes successfully |
| `failure` | `TSFileTransferFailureBlock` | Failure callback invoked if upgrade fails or is canceled |

**Code Example:**

```objc
TSFileTransferModel *upgradeModel = [[TSFileTransferModel alloc] init];
upgradeModel.firmwareFile = [NSURL fileURLWithPath:@"/path/to/firmware.bin"];
upgradeModel.fileSize = 1024 * 1024;
upgradeModel.fileName = @"firmware.bin";
upgradeModel.version = @"2.0.0";
upgradeModel.checksum = @"abc123def456";

[firmwareUpgradeInterface startFirmwareUpgrade:upgradeModel
                                     progress:^(NSUInteger progress) {
    TSLog(@"Upgrade progress: %lu%%", (unsigned long)progress);
    // Update UI with progress
} success:^{
    TSLog(@"Firmware upgrade completed successfully");
    // Device will reboot automatically
} failure:^(NSError *error) {
    TSLog(@"Firmware upgrade failed: %@", error.localizedDescription);
}];
```

### Cancel firmware upgrade

```objc
- (void)cancelFirmwareUpgrade:(TSCompletionBlock)completion;
```

Cancels the currently ongoing firmware upgrade operation.

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion callback with cancellation status and error details |

**Code Example:**

```objc
[firmwareUpgradeInterface cancelFirmwareUpgrade:^(BOOL success, `NSError *` _Nullable error) {
    if (success) {
        TSLog(@"Firmware upgrade cancelled successfully");
    } else {
        TSLog(@"Failed to cancel upgrade: %@", error.localizedDescription);
    }
}];
```

## Important Notes

1. **Pre-upgrade Validation**: Always call `checkFirmwareUpgradeConditions:completion:` before starting an upgrade to ensure the device is in a valid state.

2. **Connection Stability**: Do not disconnect the device from the application during any firmware upgrade operation; disconnection will cause the upgrade to fail and may leave the device in an unstable state.

3. **Application Foreground**: Keep the application in the foreground throughout the entire upgrade process; backgrounding the application may cause the upgrade to be interrupted.

4. **Battery Level Requirement**: Ensure the device battery level is maintained above 30% throughout the upgrade process; low battery may cause upgrade failures or device damage.

5. **Device Power**: Do not power off or restart the device during the upgrade process; only allow the device to reboot automatically after upgrade completion.

6. **Progress Callback Frequency**: The progress callback will be invoked multiple times (not just once) during the upgrade; track these updates to provide accurate user feedback.

7. **Cancellation Risks**: Avoid canceling upgrades during critical upgrade phases; such cancellations may leave the device in an unstable state requiring additional recovery procedures.

8. **Error Handling**: Implement proper error handling for all callbacks; some errors may be recoverable while others may require device recovery through other means.