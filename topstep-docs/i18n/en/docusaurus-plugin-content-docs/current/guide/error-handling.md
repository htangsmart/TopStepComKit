---
sidebar_position: 5
title: Error Handling
---

# Error Handling

All async APIs in the SDK return error information via `NSError`. This guide covers the error structure, complete error codes, and best practices.

## Error Structure

Every `NSError` returned by the SDK contains:

| Field | Description |
|-------|-------------|
| `domain` | Error domain in the format `TS[Module]ErrorDomain`, e.g. `TSBleErrorDomain` |
| `code` | Numeric error code (see categories below) |
| `userInfo[NSLocalizedDescriptionKey]` | Human-readable error description |
| `userInfo[NSUnderlyingErrorKey]` | Underlying system error, if any |

## Callback Conventions

The SDK uses two callback patterns:

### 1. TSCompletionBlock (success/failure)

```objectivec
typedef void(^TSCompletionBlock)(BOOL isSuccess, NSError * _Nullable error);
```

```objectivec
[[TopStepComKit sharedInstance].bleConnector disconnectCompletion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        // Operation succeeded
    } else {
        [self handleError:error];
    }
}];
```

### 2. Data Callback (error-only check)

```objectivec
[[TopStepComKit sharedInstance].heartRate getHistoryDataFrom:startDate to:endDate
                   completion:^(NSArray *records, NSError *error) {
    if (error) {
        [self handleError:error];
        return;
    }
    // Process records normally
}];
```

## General Error Codes (TSErrorCode)

Applies to all modules. Defined in `TSErrorEnum.h`.

### System Errors (1001–1004)

| Enum | Code | Meaning |
|------|------|---------|
| `eTSErrorUnknown` | 1001 | Unknown error |
| `eTSErrorSDKInitFailed` | 1002 | SDK initialization failed |
| `eTSErrorLicenseIncorrect` | 1003 | SDK license error |
| `eTSErrorSDKConfigError` | 1004 | SDK configuration error |

### Device Status Errors (2001–2006)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSErrorNotReady` | 2001 | Device not ready | Wait for connection to complete, then retry |
| `eTSErrorLowBattery` | 2002 | Battery too low (< 30%) | Prompt user to charge the device |
| `eTSErrorUnConnected` | 2003 | Device not connected | Prompt user to reconnect |
| `eTSErrorNotSupport` | 2004 | Feature not supported | Hide the corresponding UI entry |
| `eTSErrorNoSpace` | 2005 | Device storage full | Prompt user to free up device space |
| `eTSErrorIsBusy` | 2006 | Device is busy | Retry after a short delay |

### Parameter Errors (3001–3004)

| Enum | Code | Meaning |
|------|------|---------|
| `eTSErrorInvalidParam` | 3001 | Parameter does not exist |
| `eTSErrorParamError` | 3002 | Parameter error |
| `eTSErrorInvalidTypeError` | 3003 | Invalid parameter type |
| `eTSErrorParamSizeError` | 3004 | Invalid parameter size |

### Data Operation Errors (4001–4004)

| Enum | Code | Meaning |
|------|------|---------|
| `eTSErrorDataGetFailed` | 4001 | Data retrieval failed |
| `eTSErrorDataSetFailed` | 4002 | Data setting failed |
| `eTSErrorDataFormatError` | 4003 | Data format error |
| `eTSErrorDataIsEmpty` | 4004 | Data is empty |

### Task Errors (5001–5003)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSErrorPreTaskExecuting` | 5001 | Task in progress (e.g. OTA) | Wait for completion before retrying |
| `eTSErrorTaskExecutionFailed` | 5002 | Task execution failed | Prompt user to retry |
| `eTSErrorTaskNotStarted` | 5003 | Task not started | Check call sequence |

### Communication Errors (6001–6008)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSErrorTimeoutError` | 6001 | Communication timeout | Retry the operation |
| `eTSErrorTransmissionInterrupted` | 6002 | Data transmission interrupted | Check device proximity, retry |
| `eTSErrorSignalInterference` | 6003 | Signal interference or loss | Reduce interference sources, retry |
| `eTSErrorPacketLoss` | 6004 | Packet loss | Retry the operation |
| `eTSErrorProtocolMismatch` | 6005 | Protocol mismatch | Upgrade SDK or firmware |
| `eTSErrorConnectionReset` | 6006 | Connection reset by peer | Reconnect the device |
| `eTSErrorBufferOverflow` | 6007 | Buffer overflow | Reduce send frequency |
| `eTSErrorChannelBusy` | 6008 | Channel busy | Retry after a short delay |

### User Operation Errors (7001)

| Enum | Code | Meaning |
|------|------|---------|
| `eTSErrorUserCancelled` | 7001 | User cancelled operation |

## Bluetooth Connection Error Codes (TSBleConnectionError)

Bluetooth-specific errors defined in `TSErrorEnum.h`, accessible via `error.code`.

### Parameter Errors (9001–9004)

| Enum | Code | Meaning |
|------|------|---------|
| `eTSBleErrorInvalidRandomCode` | 9001 | Invalid QR code parameter |
| `eTSBleErrorInvalidUserId` | 9002 | Invalid user ID parameter |
| `eTSBleErrorInvalidParam` | 9003 | Invalid parameter |
| `eTSBleErrorInvalidHandle` | 9004 | Invalid handle |

### General Errors (9101–9106)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSBleErrorUnknown` | 9101 | Unknown error | Prompt user to retry |
| `eTSBleErrorTimeout` | 9102 | Connection timeout | Check if device is in range; retry |
| `eTSBleErrorDisconnected` | 9103 | Connection unexpectedly dropped | Prompt user to reconnect |
| `eTSBleErrorOutOfSpace` | 9104 | Out of storage space | Prompt user to free up device space |
| `eTSBleErrorUUIDNotAllowed` | 9105 | UUID not allowed | Check device compatibility |
| `eTSBleErrorAlreadyAdvertising` | 9106 | Already advertising | Wait for advertising to finish |

### Permission & System Errors (9201–9206)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSBleErrorBluetoothOff` | 9201 | Bluetooth is off | Prompt user to turn on system Bluetooth |
| `eTSBleErrorBluetoothUnsupported` | 9202 | Bluetooth not supported | Inform user device doesn't support BLE |
| `eTSBleErrorPermissionDenied` | 9203 | Bluetooth permission denied | Guide user to Settings → Privacy → Bluetooth |
| `eTSBleErrorSystemServiceUnavailable` | 9204 | System BT service unavailable | Prompt user to restart phone |
| `eTSBleErrorBluetoothStateUnknown` | 9205 | Bluetooth state unknown | Wait for BT ready, then retry |
| `eTSBleErrorBluetoothResetting` | 9206 | Bluetooth is resetting | Wait for reset to complete, then retry |

### Connection Process Errors (9301–9308)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSBleErrorConnectionFailed` | 9301 | General connection failure | Retry connection |
| `eTSBleErrorGattConnectFailed` | 9302 | GATT connection failed | Restart Bluetooth and retry |
| `eTSBleErrorDeviceOutOfRange` | 9303 | Device out of range | Move closer to device and retry |
| `eTSBleErrorWeakSignal` | 9304 | Signal too weak | Move closer to device and retry |
| `eTSBleErrorSignalLost` | 9305 | Signal lost | Move closer to device and retry |
| `eTSBleErrorConnectionLimitReached` | 9306 | Connection limit reached | Disconnect other devices first |
| `eTSBleErrorUnknownDevice` | 9307 | Unknown device | Re-scan and re-select device |
| `eTSBleErrorOperationNotSupported` | 9308 | Operation not supported | Check device firmware version |

### Authentication Errors (9404–9413, 9499)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSBleErrorEncryptionFailed` | 9404 | Encryption failed | Re-bind the device |
| `eTSBleErrorPeerRemovedPairingInfo` | 9405 | Pairing info removed by peer | Re-bind the device |
| `eTSBleErrorEncryptionTimeout` | 9406 | Encryption timed out | Retry connection |
| `eTSBleErrorUserIdMismatch` | 9407 | User ID mismatch | Check the `userId` parameter |
| `eTSBleErrorBindCancelledByUser` | 9408 | Binding cancelled by user | Guide user to retry |
| `eTSBleErrorBindTimeout` | 9409 | Binding timed out | Reinitiate binding |
| `eTSBleErrorClassicBluetoothNotConnected` | 9410 | Classic BT not connected | Check classic Bluetooth state |
| `eTSBleErrorLowBatteryCannotDeleteData` | 9411 | Battery too low to delete data | Prompt user to charge device |
| `eTSBleErrorDeviceFactoryResetting` | 9412 | Device factory resetting | Wait for reset to complete |
| `eTSBleErrorFactoryResetRequired` | 9413 | Factory reset required to re-bind | Ask user to factory reset the device |
| `eTSBleErrorAuthenticationUnknown` | 9499 | Auth failed (unknown reason) | Retry connection |

### Device State Errors (9501–9506)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSBleErrorConnectedByOthers` | 9501 | Device connected by another host | Ask user to disconnect from other phone |
| `eTSBleErrorDeviceAlreadyBound` | 9502 | Device already bound | Ask user to unbind first |
| `eTSBleErrorLowBattery` | 9503 | Device battery too low | Prompt user to charge device |
| `eTSBleErrorDFUMode` | 9504 | Device in DFU mode | Wait for DFU to finish or restart device |
| `eTSBleErrorDeviceSleeping` | 9505 | Device is sleeping | Wake device and retry |
| `eTSBleErrorTooManyPairedDevices` | 9506 | Too many paired devices | Remove some paired records |

### Service & Protocol Errors (9601–9605)

| Enum | Code | Meaning | Suggested Action |
|------|------|---------|-----------------|
| `eTSBleErrorPeripheralNotFound` | 9601 | Peripheral not found | Re-scan for devices |
| `eTSBleErrorServiceNotFound` | 9602 | Required service not found | Check device firmware version |
| `eTSBleErrorCharacteristicNotFound` | 9603 | Characteristic not found | Check device firmware version |
| `eTSBleErrorProtocolVersionMismatch` | 9604 | Protocol version mismatch | Upgrade SDK or firmware |
| `eTSBleErrorMtuNegotiationFailed` | 9605 | MTU negotiation failed | Retry connection |

### User Actions (9701–9702)

| Enum | Code | Meaning |
|------|------|---------|
| `eTSBleErrorDisconnectedByUser` | 9701 | Disconnected by user |
| `eTSBleErrorCancelledByUser` | 9702 | Connection cancelled by user |

## Scan Completion Reasons (TSScanCompletionReason)

| Enum Value | Description | Suggested Action |
|------------|-------------|-----------------|
| `eTSScanCompleteReasonTimeout` | Scan timed out | Inform user no device found; offer retry |
| `eTSScanCompleteReasonBleNotReady` | Bluetooth not ready | Wait for BT initialization and retry |
| `eTSScanCompleteReasonPermissionDenied` | Permission denied | Guide user to enable Bluetooth in Settings |
| `eTSScanCompleteReasonUserStopped` | User stopped scan | Normal termination; no action needed |
| `eTSScanCompleteReasonSystemError` | System error | Restart Bluetooth and retry |

## Feature Support Check

Always call `isSupport` before invoking a feature interface:

```objectivec
id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

if (![heartRate isSupport]) {
    TSLog(@"Heart rate not supported on this device");
    return;
}

[heartRate startMeasureWithParam:nil ...];
```

## Unified Error Handler

Centralizing error handling reduces boilerplate:

```objectivec
- (void)handleSDKError:(NSError *)error context:(NSString *)context {
    if (!error) return;

    TSLog(@"[%@] domain=%@ code=%ld: %@",
          context,
          error.domain,
          (long)error.code,
          error.localizedDescription);

    switch (error.code) {
        // Permission / BT state → guide user
        case eTSBleErrorPermissionDenied:
        case eTSBleErrorBluetoothOff:
            [self showBluetoothSettingsAlert];
            break;

        // Timeout / signal → retryable
        case eTSBleErrorTimeout:
        case eTSBleErrorSignalLost:
        case eTSErrorTimeoutError:
            [self retryWithDelay];
            break;

        // Busy → retry later
        case eTSErrorIsBusy:
        case eTSBleErrorChannelBusy:
            [self scheduleRetry];
            break;

        // Not supported → hide UI
        case eTSErrorNotSupport:
            [self hideUnsupportedFeature:context];
            break;

        default:
            [self showErrorAlert:error.localizedDescription];
            break;
    }
}
```

## Bluetooth Permission Alert

```objectivec
- (void)showBluetoothSettingsAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Bluetooth Access Required"
                         message:@"Please go to Settings → Privacy → Bluetooth to enable access."
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Open Settings"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}
```

## Important Notes

1. **Never ignore the `error` parameter** — always check `error` before assuming success, even when `isSuccess = YES`
2. **UI updates on the main thread** — all SDK callbacks execute on the main thread; you can update UI directly
3. **Recoverable vs. non-recoverable errors** — timeout errors can be retried; permission errors require user action; unsupported-feature errors should hide the corresponding UI entry
4. **Log and report errors** — send `error.domain` and `error.code` to your backend for diagnostics
