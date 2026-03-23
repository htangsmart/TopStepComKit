---
sidebar_position: 5
title: Camera
---

# TSCamera

The TSCamera module provides comprehensive camera control functionality for remote camera operations between iOS apps and peripheral devices (such as smartwatches or smart glasses). It supports camera mode switching, photo capture actions, flash control, and video preview streaming with H.264 encoding capabilities.

## Prerequisites

- Active connection to a peripheral device that supports camera control functionality
- For video preview: device must support video preview capability
- For video encoding: valid YUV420 format video data from AVFoundation capture session
- iOS SDK with AVFoundation and CoreGraphics frameworks available

## Data Models

### TSCameraVideoData

Represents encoded video frame data for streaming to a peripheral device.

| Property | Type | Description |
|----------|------|-------------|
| `data` | `NSData *` | Raw video frame data received from or sent to the device. Contains H.264 encoded video data. |
| `isKeyFrame` | `BOOL` | Indicates whether this frame is a key frame (I-frame). Key frames contain complete image data and can be decoded independently, while non-key frames (P/B-frames) require previous frames. |

## Enumerations

### TSCameraAction

Defines all possible camera actions that can be performed on a peripheral device.

| Constant | Value | Description |
|----------|-------|-------------|
| `TSCameraActionExitCamera` | 0 | Exit camera mode |
| `TSCameraActionEnterCamera` | 1 | Enter camera mode |
| `TSCameraActionTakePhoto` | 2 | Capture a photo |
| `TSCameraActionSwitchBackCamera` | 3 | Switch to back (rear) camera |
| `TSCameraActionSwitchFrontCamera` | 4 | Switch to front camera |
| `TSCameraActionFlashOff` | 5 | Turn flash off |
| `TSCameraActionFlashAuto` | 6 | Set flash to automatic mode |
| `TSCameraActionFlashOn` | 7 | Turn flash on |

## Callback Types

### TSCameraActionBlock

```objc
typedef void (^TSCameraActionBlock)(TSCameraAction action);
```

Callback invoked when the peripheral device controls the app's camera with a specific action.

| Parameter | Type | Description |
|-----------|------|-------------|
| `action` | `TSCameraAction` | The camera action performed by the device |

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(BOOL isSuccess, NSError *error);
```

Completion callback for asynchronous operations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `isSuccess` | `BOOL` | `YES` if operation succeeded, `NO` if failed |
| `error` | `NSError *` | Error object if operation failed, `nil` if successful |

## API Reference

### Control camera with specific action

Send camera control commands from the app to the peripheral device. Currently supports enter and exit camera actions only.

```objc
- (void)controlCameraWithAction:(TSCameraAction)action completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `action` | `TSCameraAction` | The camera action to perform. Currently only `TSCameraActionExitCamera` (0) and `TSCameraActionEnterCamera` (1) are supported. |
| `completion` | `TSCompletionBlock` | Callback invoked when the operation completes with success status and error information |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

[cameraInterface controlCameraWithAction:TSCameraActionEnterCamera 
                               completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"Camera entered successfully");
    } else {
        TSLog(@"Failed to enter camera: %@", error.localizedDescription);
    }
}];
```

### Register listener for device-controlled camera actions

Register a callback to receive camera control actions initiated by the peripheral device.

```objc
- (void)registerAppCameraeControledByDevice:(nullable TSCameraActionBlock)cameraControlActionBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `cameraControlActionBlock` | `TSCameraActionBlock` | Callback invoked when device controls the app's camera with specific action. Supports all `TSCameraAction` types including take photo, switch camera, and flash control. Pass `nil` to unregister. |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

[cameraInterface registerAppCameraeControledByDevice:^(TSCameraAction action) {
    switch (action) {
        case TSCameraActionTakePhoto:
            TSLog(@"Device requested take photo");
            // Trigger photo capture
            break;
        case TSCameraActionSwitchFrontCamera:
            TSLog(@"Device requested switch to front camera");
            // Switch to front camera
            break;
        case TSCameraActionFlashOn:
            TSLog(@"Device requested flash on");
            // Enable flash
            break;
        default:
            TSLog(@"Device requested action: %ld", (long)action);
            break;
    }
}];
```

### Check if device supports video preview

Determine whether the currently connected device has video preview capability.

```objc
- (BOOL)isSupportVideoPreview;
```

**Return Value:**

| Type | Description |
|------|-------------|
| `BOOL` | `YES` if device supports video preview, `NO` otherwise or if no device is connected |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

if ([cameraInterface isSupportVideoPreview]) {
    TSLog(@"Device supports video preview");
} else {
    TSLog(@"Device does not support video preview");
}
```

### Get video preview size

Retrieve the video preview dimensions supported by the connected device.

```objc
- (CGSize)videoPreviewSize;
```

**Return Value:**

| Type | Description |
|------|-------------|
| `CGSize` | Video preview dimensions in pixels. Returns `CGSizeZero` if device not connected or preview size unavailable. |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

CGSize previewSize = [cameraInterface videoPreviewSize];
if (!CGSizeEqualToSize(previewSize, CGSizeZero)) {
    TSLog(@"Video preview size: %.0f x %.0f", previewSize.width, previewSize.height);
    // Configure video display UI with preview size
} else {
    TSLog(@"Preview size not available");
}
```

### Start video preview

Initiate video preview streaming from the peripheral device.

```objc
- (void)startVideoPreviewWithFps:(NSInteger)fps completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `fps` | `NSInteger` | Desired frame rate in frames per second (15, 24, 30, 60). Use 0 or negative value for device default. |
| `completion` | `TSCompletionBlock` | Completion callback with operation success status and error information |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

[cameraInterface startVideoPreviewWithFps:30 completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"Video preview started successfully");
    } else {
        TSLog(@"Failed to start video preview: %@", error.localizedDescription);
    }
}];
```

### Stop video preview

Terminate video preview streaming from the peripheral device.

```objc
- (void)stopVideoPreviewCompletion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion callback with operation success status and error information |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

[cameraInterface stopVideoPreviewCompletion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"Video preview stopped successfully");
    } else {
        TSLog(@"Failed to stop video preview: %@", error.localizedDescription);
    }
}];
```

### Send video preview sample buffer

Stream video frames from AVFoundation capture session directly to the device using CMSampleBuffer.

```objc
- (void)sendVideoPreviewSampleBuffer:(CMSampleBufferRef)sampleBuffer isBack:(BOOL)isBack;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `sampleBuffer` | `CMSampleBufferRef` | CMSampleBuffer containing video frame data from AVCaptureVideoDataOutputSampleBufferDelegate callback. Must contain video data convertible to YUV format. |
| `isBack` | `BOOL` | `YES` if using back camera, `NO` if using front camera. Determines encoding orientation and settings. |

**Code Example:**

```objc
// In AVCaptureVideoDataOutputSampleBufferDelegate callback
- (void)captureOutput:(AVCaptureOutput *)output 
       didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
              fromConnection:(AVCaptureConnection *)connection {
    
    id<TSCameraInterface> cameraInterface = /* obtained camera interface */;
    BOOL isBackCamera = /* determine camera position */;
    
    [cameraInterface sendVideoPreviewSampleBuffer:sampleBuffer isBack:isBackCamera];
}
```

### Send video preview data

Stream H.264 encoded video data to the peripheral device.

```objc
- (void)sendVideoPreviewData:(TSCameraVideoData *)videoData;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `videoData` | `TSCameraVideoData *` | Video data object containing H.264 encoded frame bytes and key frame flag. Must be obtained from `encodeYUVToH264WithYData:uData:vData:screenW:screenH:orientation:isBack:` method. |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

// Assuming videoData is obtained from YUV encoding
TSCameraVideoData *videoData = [cameraInterface encodeYUVToH264WithYData:yPlaneData
                                                                   uData:uPlaneData
                                                                   vData:vPlaneData
                                                                 screenW:640
                                                                 screenH:480
                                                             orientation:0
                                                                  isBack:YES];

if (videoData) {
    [cameraInterface sendVideoPreviewData:videoData];
} else {
    TSLog(@"Failed to encode video data");
}
```

### Convert YUV to H.264

Encode raw YUV video data to H.264 compressed format for transmission to the device.

```objc
- (nullable TSCameraVideoData *)encodeYUVToH264WithYData:(NSData *)yData
                                                   uData:(NSData *)uData
                                                   vData:(nullable NSData *)vData
                                                 screenW:(NSInteger)screenW
                                                 screenH:(NSInteger)screenH
                                             orientation:(NSInteger)orientation
                                                  isBack:(BOOL)isBack;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `yData` | `NSData *` | Y plane (luminance) data of the video frame in YUV420 format |
| `uData` | `NSData *` | U plane (chrominance) data of the video frame in YUV420 format |
| `vData` | `NSData *` | V plane (chrominance) data. Can be `nil` for certain YUV formats like NV12. |
| `screenW` | `NSInteger` | Screen width in pixels |
| `screenH` | `NSInteger` | Screen height in pixels |
| `orientation` | `NSInteger` | Device orientation: 0=Portrait, 1=PortraitUpsideDown, 2=LandscapeLeft, 3=LandscapeRight |
| `isBack` | `BOOL` | `YES` for back camera, `NO` for front camera |

**Return Value:**

| Type | Description |
|------|-------------|
| `TSCameraVideoData *` | Encoded video data object with H.264 data and key frame flag, or `nil` if encoding fails |

**Code Example:**

```objc
id<TSCameraInterface> cameraInterface = /* obtained camera interface */;

// Extract YUV planes from video buffer
// yData, uData, vData are obtained from CVPixelBuffer
NSData *yPlaneData = /* extracted Y plane */;
NSData *uPlaneData = /* extracted U plane */;
NSData *vPlaneData = /* extracted V plane */;

TSCameraVideoData *encodedVideoData = [cameraInterface encodeYUVToH264WithYData:yPlaneData
                                                                         uData:uPlaneData
                                                                         vData:vPlaneData
                                                                       screenW:640
                                                                       screenH:480
                                                                   orientation:0
                                                                        isBack:YES];

if (encodedVideoData) {
    TSLog(@"Encoding successful. IsKeyFrame: %@", encodedVideoData.isKeyFrame ? @"YES" : @"NO");
    [cameraInterface sendVideoPreviewData:encodedVideoData];
} else {
    TSLog(@"Failed to encode YUV to H.264");
}
```

## Important Notes

1. **Limited Control Actions**: The `controlCameraWithAction:completion:` method only supports `TSCameraActionExitCamera` and `TSCameraActionEnterCamera` actions. Photo capture, camera switching, and flash control through this method are not supported on peripheral devices.

2. **Full Device Control Support**: The `registerAppCameraeControledByDevice:` callback supports all camera actions including take photo, switch camera, and flash control when initiated by the peripheral device.

3. **Video Preview Requirements**: Video preview functionality requires an active device connection and the device must support video preview capability. Use `isSupportVideoPreview` to verify support before starting preview.

4. **Frame Rate Configuration**: Common frame rates are 15, 24, 30, and 60 fps. Pass 0 or negative value to `startVideoPreviewWithFps:completion:` to use the device's default frame rate.

5. **H.264 Encoding Pipeline**: When streaming video data, either use `sendVideoPreviewSampleBuffer:isBack:` for direct CMSampleBuffer streaming, or convert YUV data using `encodeYUVToH264WithYData:uData:vData:screenW:screenH:orientation:isBack:` and send via `sendVideoPreviewData:`.

6. **YUV Format Requirements**: YUV data must be in YUV420 format (I420 or NV12). The `vData` parameter can be `nil` for NV12 format. Ensure planes are correctly extracted from video buffers before encoding.

7. **Key Frame Handling**: Key frames (I-frames) in `TSCameraVideoData` contain complete image data and mark synchronization points. Non-key frames (P/B-frames) depend on previous frames for decoding.

8. **Orientation Parameter**: Use device orientation values: 0 for portrait, 1 for portrait upside down, 2 for landscape left, 3 for landscape right. This ensures correct video encoding orientation.

9. **Camera Selection**: The `isBack` parameter in video methods specifies camera position. Use `YES` for rear-facing camera and `NO` for front-facing camera.

10. **Null Callback Unregistration**: Pass `nil` to `registerAppCameraeControledByDevice:` to unregister the camera control listener when no longer needed.