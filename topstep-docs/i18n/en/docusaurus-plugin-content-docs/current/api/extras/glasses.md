---
sidebar_position: 2
title: Glasses
---

# Glasses

The Glasses module provides a comprehensive interface for controlling smart glasses devices, enabling video preview and recording, audio recording, photo capture, and device storage management. It allows developers to monitor real-time status changes and retrieve media counts and storage information from the connected glasses device.

## Prerequisites

- Smart glasses device must be connected and paired with the iOS application
- Required permissions for camera and audio access must be granted by the user
- Device firmware must support the requested operations (e.g., video preview capability)
- SDK must be initialized via `TopStepComKit` before use

## Data Models

### TSGlassesMediaCount

Represents the count of different types of media files stored on the smart glasses device.

| Property | Type | Description |
|----------|------|-------------|
| `videoCount` | `NSInteger` | Number of video files on the device |
| `audioRecordingCount` | `NSInteger` | Number of audio recording files on the device |
| `musicCount` | `NSInteger` | Number of music files on the device |
| `photoCount` | `NSInteger` | Number of photo files on the device |

### TSGlassesStorageInfo

Represents the storage information of the smart glasses device, including total and available storage space.

| Property | Type | Description |
|----------|------|-------------|
| `totalSpace` | `unsigned long long` | Total storage space of the device in bytes |
| `availableSpace` | `unsigned long long` | Available storage space in bytes |

## Enumerations

### TSVideoPreviewStatus

Video preview status enumeration.

| Value | Name | Description |
|-------|------|-------------|
| `0` | `TSVideoPreviewUnknown` | Unknown status |
| `1` | `TSVideoPreviewInactive` | Not active |
| `2` | `TSVideoPreviewActive` | Active |

### TSAudioRecordingStatus

Audio recording status enumeration.

| Value | Name | Description |
|-------|------|-------------|
| `0` | `TSAudioRecordingUnknown` | Unknown status |
| `1` | `TSAudioRecordingInactive` | Not recording |
| `2` | `TSAudioRecordingActive` | Recording |

### TSVideoRecordingStatus

Video recording status enumeration.

| Value | Name | Description |
|-------|------|-------------|
| `0` | `TSVideoRecordingUnknown` | Unknown status |
| `1` | `TSVideoRecordingInactive` | Not recording |
| `2` | `TSVideoRecordingActive` | Recording |

## Callback Types

### PreviewVideoStatusChangedBlock

Block type for video preview status change notification.

```objc
typedef void (^_Nullable PreviewVideoStatusChangedBlock)(TSVideoPreviewStatus status);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | `TSVideoPreviewStatus` | New video preview status |

### AudioRecordingStatusChangedBlock

Block type for audio recording status change notification.

```objc
typedef void (^_Nullable AudioRecordingStatusChangedBlock)(TSAudioRecordingStatus status);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | `TSAudioRecordingStatus` | New audio recording status |

### VideoRecordingStatusChangedBlock

Block type for video recording status change notification.

```objc
typedef void (^_Nullable VideoRecordingStatusChangedBlock)(TSVideoRecordingStatus status);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | `TSVideoRecordingStatus` | New video recording status |

### PhotoCaptureResultBlock

Block type for photo capture result notification.

```objc
typedef void (^_Nullable PhotoCaptureResultBlock)(BOOL isSuccess, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `isSuccess` | `BOOL` | YES if photo capture succeeded, NO if failed |
| `error` | `NSError * _Nullable` | Error object if photo capture failed, nil if successful |

### DidReceiveVideoDataBlock

Block type for video data reception from device.

```objc
typedef void (^_Nullable DidReceiveVideoDataBlock)(NSData *videoData);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `videoData` | `NSData *` | Raw video data received from device |

### DidCompleteVideoPreviewBlock

Block type for video preview completion notification.

```objc
typedef void (^_Nullable DidCompleteVideoPreviewBlock)(NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError * _Nullable` | Error object if video preview ended due to error, nil if normal end |

## API Reference

### Check video preview support

Determine if the connected device supports video preview functionality.

```objc
- (BOOL)isSupportVideoPreview;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| Return | `BOOL` | YES if device supports video preview, NO otherwise |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

BOOL isSupported = [glasses isSupportVideoPreview];
if (isSupported) {
    TSLog(@"Device supports video preview");
} else {
    TSLog(@"Device does not support video preview");
}
```

### Start video preview

Begin video preview on the smart glasses device and receive streaming video data.

```objc
- (void)startVideoPreview:(TSCompletionBlock)completion
              didReceiveData:(DidReceiveVideoDataBlock)didReceiveData
              completionHandler:(DidCompleteVideoPreviewBlock)completionHandler;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when start operation finishes (isSuccess, error) |
| `didReceiveData` | `DidReceiveVideoDataBlock` | Block called when video data arrives (videoData) |
| `completionHandler` | `DidCompleteVideoPreviewBlock` | Block called when preview ends (error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses startVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Video preview started successfully");
    } else {
        TSLog(@"Failed to start video preview: %@", error.localizedDescription);
    }
} didReceiveData:^(NSData *videoData) {
    TSLog(@"Received video data: %lu bytes", (unsigned long)videoData.length);
    // Process video data
} completionHandler:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Video preview ended with error: %@", error.localizedDescription);
    } else {
        TSLog(@"Video preview ended normally");
    }
}];
```

### Stop video preview

Terminate the video preview on the smart glasses device.

```objc
- (void)stopVideoPreview:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when stop operation finishes (isSuccess, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses stopVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Video preview stopped successfully");
    } else {
        TSLog(@"Failed to stop video preview: %@", error.localizedDescription);
    }
}];
```

### Get video preview status

Retrieve the current video preview status from the device.

```objc
- (void)getVideoPreviewStatus:(void(^)(TSVideoPreviewStatus status, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSVideoPreviewStatus, NSError *)` | Block called with status result (status, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses getVideoPreviewStatus:^(TSVideoPreviewStatus status, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get video preview status: %@", error.localizedDescription);
    } else {
        switch (status) {
            case TSVideoPreviewActive:
                TSLog(@"Video preview is active");
                break;
            case TSVideoPreviewInactive:
                TSLog(@"Video preview is inactive");
                break;
            case TSVideoPreviewUnknown:
                TSLog(@"Video preview status is unknown");
                break;
        }
    }
}];
```

### Register video preview status change listener

Register a block to receive notifications when video preview status changes.

```objc
- (void)registerVideoPreviewStatusChangedBlock:(PreviewVideoStatusChangedBlock)statusChangedBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `statusChangedBlock` | `PreviewVideoStatusChangedBlock` | Block called on status change (status), pass nil to unregister |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses registerVideoPreviewStatusChangedBlock:^(TSVideoPreviewStatus status) {
    switch (status) {
        case TSVideoPreviewActive:
            TSLog(@"Video preview status changed to: Active");
            break;
        case TSVideoPreviewInactive:
            TSLog(@"Video preview status changed to: Inactive");
            break;
        case TSVideoPreviewUnknown:
            TSLog(@"Video preview status changed to: Unknown");
            break;
    }
}];

// To unregister
[glasses registerVideoPreviewStatusChangedBlock:nil];
```

### Start audio recording

Begin audio recording on the smart glasses device.

```objc
- (void)startAudioRecording:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when start operation finishes (isSuccess, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses startAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Audio recording started successfully");
    } else {
        TSLog(@"Failed to start audio recording: %@", error.localizedDescription);
    }
}];
```

### Stop audio recording

Terminate audio recording on the smart glasses device.

```objc
- (void)stopAudioRecording:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when stop operation finishes (isSuccess, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses stopAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Audio recording stopped successfully");
    } else {
        TSLog(@"Failed to stop audio recording: %@", error.localizedDescription);
    }
}];
```

### Get audio recording status

Retrieve the current audio recording status from the device.

```objc
- (void)getAudioRecordingStatus:(void(^)(TSAudioRecordingStatus status, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAudioRecordingStatus, NSError *)` | Block called with status result (status, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses getAudioRecordingStatus:^(TSAudioRecordingStatus status, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get audio recording status: %@", error.localizedDescription);
    } else {
        switch (status) {
            case TSAudioRecordingActive:
                TSLog(@"Audio recording is active");
                break;
            case TSAudioRecordingInactive:
                TSLog(@"Audio recording is inactive");
                break;
            case TSAudioRecordingUnknown:
                TSLog(@"Audio recording status is unknown");
                break;
        }
    }
}];
```

### Register audio recording status change listener

Register a block to receive notifications when audio recording status changes.

```objc
- (void)registerAudioRecordingStatusChangedBlock:(AudioRecordingStatusChangedBlock)statusChangedBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `statusChangedBlock` | `AudioRecordingStatusChangedBlock` | Block called on status change (status), pass nil to unregister |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses registerAudioRecordingStatusChangedBlock:^(TSAudioRecordingStatus status) {
    switch (status) {
        case TSAudioRecordingActive:
            TSLog(@"Audio recording status changed to: Active");
            break;
        case TSAudioRecordingInactive:
            TSLog(@"Audio recording status changed to: Inactive");
            break;
        case TSAudioRecordingUnknown:
            TSLog(@"Audio recording status changed to: Unknown");
            break;
    }
}];

// To unregister
[glasses registerAudioRecordingStatusChangedBlock:nil];
```

### Start video recording

Begin video recording on the smart glasses device.

```objc
- (void)startVideoRecording:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when start operation finishes (isSuccess, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses startVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Video recording started successfully");
    } else {
        TSLog(@"Failed to start video recording: %@", error.localizedDescription);
    }
}];
```

### Stop video recording

Terminate video recording on the smart glasses device.

```objc
- (void)stopVideoRecording:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when stop operation finishes (isSuccess, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses stopVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Video recording stopped successfully");
    } else {
        TSLog(@"Failed to stop video recording: %@", error.localizedDescription);
    }
}];
```

### Get video recording status

Retrieve the current video recording status from the device.

```objc
- (void)getVideoRecordingStatus:(void(^)(TSVideoRecordingStatus status, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSVideoRecordingStatus, NSError *)` | Block called with status result (status, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses getVideoRecordingStatus:^(TSVideoRecordingStatus status, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get video recording status: %@", error.localizedDescription);
    } else {
        switch (status) {
            case TSVideoRecordingActive:
                TSLog(@"Video recording is active");
                break;
            case TSVideoRecordingInactive:
                TSLog(@"Video recording is inactive");
                break;
            case TSVideoRecordingUnknown:
                TSLog(@"Video recording status is unknown");
                break;
        }
    }
}];
```

### Register video recording status change listener

Register a block to receive notifications when video recording status changes.

```objc
- (void)registerVideoRecordingStatusChangedBlock:(VideoRecordingStatusChangedBlock)statusChangedBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `statusChangedBlock` | `VideoRecordingStatusChangedBlock` | Block called on status change (status), pass nil to unregister |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses registerVideoRecordingStatusChangedBlock:^(TSVideoRecordingStatus status) {
    switch (status) {
        case TSVideoRecordingActive:
            TSLog(@"Video recording status changed to: Active");
            break;
        case TSVideoRecordingInactive:
            TSLog(@"Video recording status changed to: Inactive");
            break;
        case TSVideoRecordingUnknown:
            TSLog(@"Video recording status changed to: Unknown");
            break;
    }
}];

// To unregister
[glasses registerVideoRecordingStatusChangedBlock:nil];
```

### Take a photo

Trigger the smart glasses to capture a single photo.

```objc
- (void)takePhoto:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when photo capture finishes (isSuccess, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses takePhoto:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Photo captured successfully");
    } else {
        TSLog(@"Failed to capture photo: %@", error.localizedDescription);
    }
}];
```

### Register photo capture result listener

Register a block to receive notifications when photo capture results are available.

```objc
- (void)registerPhotoCaptureResultBlock:(PhotoCaptureResultBlock)resultBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `resultBlock` | `PhotoCaptureResultBlock` | Block called when photo capture result is available (isSuccess, error), pass nil to unregister |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses registerPhotoCaptureResultBlock:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"Photo capture result: Success");
    } else {
        TSLog(@"Photo capture result: Failed with error: %@", error.localizedDescription);
    }
}];

// To unregister
[glasses registerPhotoCaptureResultBlock:nil];
```

### Get media file count

Retrieve the count of different types of media files stored on the device.

```objc
- (void)getMediaCount:(void(^)(TSGlassesMediaCount * _Nullable mediaCount, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSGlassesMediaCount *, NSError *)` | Block called when count retrieval finishes (mediaCount, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses getMediaCount:^(TSGlassesMediaCount * _Nullable mediaCount, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get media count: %@", error.localizedDescription);
    } else {
        TSLog(@"Media Count - Videos: %ld, Audio Recordings: %ld, Music: %ld, Photos: %ld",
              (long)mediaCount.videoCount,
              (long)mediaCount.audioRecordingCount,
              (long)mediaCount.musicCount,
              (long)mediaCount.photoCount);
        TSLog(@"Total media files: %ld", (long)[mediaCount totalMediaCount]);
        
        if ([mediaCount hasAnyMedia]) {
            TSLog(@"Device has media files");
        } else {
            TSLog(@"Device has no media files");
        }
    }
}];
```

### Get storage information

Retrieve storage information including total and available space on the device.

```objc
- (void)getStorageInfo:(void(^)(TSGlassesStorageInfo * _Nullable storageInfo, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSGlassesStorageInfo *, NSError *)` | Block called when storage retrieval finishes (storageInfo, error) |

**Code Example:**

```objc
id<TSGlassesInterface> glasses = [TopStepComKit sharedInstance].glasses;

[glasses getStorageInfo:^(TSGlassesStorageInfo * _Nullable storageInfo, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get storage info: %@", error.localizedDescription);
    } else {
        TSLog(@"Total Storage: %llu bytes", storageInfo.totalSpace);
        TSLog(@"Available Storage: %llu bytes", storageInfo.availableSpace);
        TSLog(@"Used Storage: %llu bytes", [storageInfo usedSpace]);
        TSLog(@"Storage Usage: %.2f%%", [storageInfo usagePercentage]);
        TSLog(@"Formatted Storage Info: %@", [storageInfo formattedStorageInfo]);
        
        // Check if there's enough space for a 100MB file
        if ([storageInfo hasEnoughSpaceForSize:100 * 1024 * 1024]) {
            TSLog(@"Device has enough space for 100MB file");
        } else {
            TSLog(@"Device does not have enough space for 100MB file");
        }
    }
}];
```

## Important Notes

1. All operations with smart glasses require an active device connection. Ensure the device is properly connected and authenticated before attempting any operations.

2. Video preview and video recording cannot operate simultaneously on the device. Stop video preview before starting video recording and vice versa.

3. Multiple media operations may be limited by device firmware. Check device status before initiating conflicting operations (e.g., audio recording while video recording).

4. The `didReceiveData` block in `startVideoPreview` will be called continuously as video data arrives. Ensure efficient data processing to avoid blocking the main thread or causing memory issues with high-frequency callbacks.

5. Status change callbacks are delivered on the device's internal callback queue. Update UI elements by dispatching to the main thread using `dispatch_async(dispatch_get_main_queue(), ^{ ... })`.

6. When registering status change listeners, pass `nil` to the corresponding registration method to unregister and prevent memory leaks.

7. Photo capture results may be delivered asynchronously through the registered `PhotoCaptureResultBlock`. Register this block before calling `takePhoto` to ensure you receive the result.

8. Storage information reflects the device's current state. Call `getStorageInfo` again after recording operations to get updated values.

9. The `totalMediaCount` from `TSGlassesMediaCount` provides a quick way to check if any media files exist without checking individual counts.

10. All completion blocks may receive `NSError` objects. Always check the error parameter before processing results to handle failures appropriately.