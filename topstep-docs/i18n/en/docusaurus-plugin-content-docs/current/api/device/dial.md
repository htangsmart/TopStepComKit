---
sidebar_position: 5
title: Watch Face
---

# Watch Face

The Dial module provides comprehensive watch face management functionality for peripheral devices, including operations to push, delete, switch, and query watch faces. It supports management of built-in watch faces, cloud-based watch faces, and custom user-created watch faces with full lifecycle management capabilities.

## Prerequisites

- Device must be connected and authenticated
- Device firmware must support watch face operations
- For cloud watch faces: Internet connectivity required for downloading
- For custom watch faces: Required resources (images/videos) must be available locally
- Sufficient storage space on the device for new watch faces

## Data Models

### TSDialModel

| Property | Type | Description |
|----------|------|-------------|
| `dialId` | `NSString *` | Unique identifier for the watch face, typically assigned by system or server |
| `dialName` | `NSString *` | Human-readable display name shown in the user interface |
| `dialType` | `TSDialType` | Type of watch face: built-in, custom, or cloud |
| `isCurrent` | `BOOL` | Indicates whether this is the currently active watch face on the device |
| `locationIndex` | `UInt8` | Position index where the watch face is stored on the device (typically 0-9 or 0-19) |
| `version` | `NSString *` | Version number of the watch face for version control and update management |
| `filePath` | `NSString *` | Local file system path to watch face resources; may be nil for built-in watch faces |

### TSCustomDial

| Property | Type | Description |
|----------|------|-------------|
| `dialId` | `NSString *` | Unique identifier for the custom watch face |
| `dialName` | `NSString *` | Human-readable name for user selection and display (optional) |
| `dialType` | `TSCustomDialType` | Custom dial type: single image, multiple images, or video |
| `templateFilePath` | `NSString *` | Local file path to the watch face template bin file |
| `previewImageItem` | `TSCustomDialItem *` | Preview image item for UI display (optional; SDK generates automatically if nil) |
| `resourceItems` | `NSArray<TSCustomDialItem *> *` | Array of background image/video items; must contain at least one item |

### TSCustomDialItem

| Property | Type | Description |
|----------|------|-------------|
| `dialType` | `TSCustomDialType` | Type of resource: single image, multiple images, or video |
| `videoLocalPath` | `NSString *` | Local file path for video resources; ignored for image types |
| `resourceImage` | `UIImage *` | UIImage object for dial background; required for image types, must match `TSPeripheralScreen.screenSize` |
| `dialTime` | `TSCustomDialTime *` | Time display configuration (required; automatically initialized) |

### TSCustomDialTime

| Property | Type | Description |
|----------|------|-------------|
| `timeImage` | `UIImage *` | UIImage object for time display style; takes priority over `timeImagePath` |
| `timeImagePath` | `NSString *` | Local file path to time style image; supports absolute and relative paths |
| `timePosition` | `TSDialTimePosition` | Position of time display (top, bottom, left, right, corners, center); used as fallback when `timeRect` is not set |
| `timeRect` | `CGRect` | Rectangle area for time display; has priority over `timePosition` |
| `timeColor` | `UIColor *` | Color for time display text (optional; only set when applying color to monochrome images) |
| `style` | `TSDialTimeStyle` | Time display style enumeration (style1 to style7); default is `eTSDialTimeStyle1` |

## Enumerations

### TSDialType

| Value | Name | Description |
|-------|------|-------------|
| `0` | `eTSDialTypeBuiltIn` | Built-in watch face that comes with the device |
| `1` | `eTSDialTypeCustomer` | Custom watch face created by users |
| `2` | `eTSDialTypeCloud` | Watch face downloaded from cloud server |

### TSDialTimePosition

| Value | Name | Description |
|-------|------|-------------|
| `0` | `eTSDialTimePositionTop` | Top position |
| `1` | `eTSDialTimePositionBottom` | Bottom position |
| `2` | `eTSDialTimePositionLeft` | Left position |
| `3` | `eTSDialTimePositionRight` | Right position |
| `4` | `eTSDialTimePositionTopLeft` | Top-left corner |
| `5` | `eTSDialTimePositionBottomLeft` | Bottom-left corner |
| `6` | `eTSDialTimePositionTopRight` | Top-right corner |
| `7` | `eTSDialTimePositionBottomRight` | Bottom-right corner |
| `8` | `eTSDialTimePositionCenter` | Center position |

### TSDialPushResult

| Value | Name | Description |
|-------|------|-------------|
| `0` | `eTSDialPushResultStart` | Push operation started |
| `0` | `eTSDialPushResultProgress` | Push in progress |
| `1` | `eTSDialPushResultSuccess` | Push successful |
| `2` | `eTSDialPushResultFailed` | Push failed |

### TSCustomDialType

| Value | Name | Description |
|-------|------|-------------|
| `1` | `eTSCustomDialSingleImage` | Single image-based custom watch face |
| `2` | `eTSCustomDialMultipleImage` | Multiple images-based custom watch face |
| `3` | `eTSCustomDialVideo` | Video-based custom watch face |

### TSDialTimeStyle

| Value | Name | Description |
|-------|------|-------------|
| `0` | `eTSDialTimeStyleNone` | No time style |
| `1` | `eTSDialTimeStyle1` | Time display style 1 |
| `2` | `eTSDialTimeStyle2` | Time display style 2 |
| `3` | `eTSDialTimeStyle3` | Time display style 3 |
| `4` | `eTSDialTimeStyle4` | Time display style 4 |
| `5` | `eTSDialTimeStyle5` | Time display style 5 |
| `6` | `eTSDialTimeStyle6` | Time display style 6 |
| `7` | `eTSDialTimeStyle7` | Time display style 7 |

## Callback Types

### TSDialCompletionBlock

```objc
typedef void (^TSDialCompletionBlock)(TSDialPushResult result, NSError *_Nullable error);
```

Watch face operation completion callback.

| Parameter | Type | Description |
|-----------|------|-------------|
| `result` | `TSDialPushResult` | Operation result: progress, success, or failed |
| `error` | `NSError *` | Error information if failed; nil if successful |

### TSDialProgressBlock

```objc
typedef void (^TSDialProgressBlock)(TSDialPushResult result, NSInteger progress);
```

Watch face push progress callback.

| Parameter | Type | Description |
|-----------|------|-------------|
| `result` | `TSDialPushResult` | Current push status |
| `progress` | `NSInteger` | Current push progress (0-100) |

### TSDialListBlock

```objc
typedef void (^TSDialListBlock)(NSArray<TSDialModel *> *_Nullable dials, NSError *_Nullable error);
```

Watch face list callback.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dials` | `NSArray<TSDialModel *> *` | Array of watch face models; empty array if retrieval fails |
| `error` | `NSError *` | Error information if failed; nil if successful |

### TSDialSpaceBlock

```objc
typedef void (^TSDialSpaceBlock)(NSInteger remainSpace, NSError *_Nullable error);
```

Watch face space information callback.

| Parameter | Type | Description |
|-----------|------|-------------|
| `remainSpace` | `NSInteger` | Remaining space available for watch faces in bytes |
| `error` | `NSError *` | Error information if failed; nil if successful |

### TSDialWidgetsBlock

```objc
typedef void (^TSDialWidgetsBlock)(NSDictionary *_Nullable widgets, NSError *_Nullable error);
```

Widget list callback for Fw series devices.

| Parameter | Type | Description |
|-----------|------|-------------|
| `widgets` | `NSDictionary *` | Dictionary containing widget information; nil if device doesn't support widgets |
| `error` | `NSError *` | Error information if failed; nil if successful |

## API Reference

### Get current watch face information

Retrieve the currently active watch face on the device.

```objc
- (void)fetchCurrentDial:(void (^)(TSDialModel *_Nullable dial,
                                   NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSDialModel *, NSError *)` | Completion callback with current watch face model |

**Example:**

```objc
[dialInterface fetchCurrentDial:^(TSDialModel *dial, NSError *error) {
    if (!error && dial) {
        TSLog(@"Current dial: %@", dial.dialName);
        TSLog(@"Dial ID: %@", dial.dialId);
        TSLog(@"Dial Type: %ld", (long)dial.dialType);
    } else {
        TSLog(@"Failed to fetch current dial: %@", error.localizedDescription);
    }
}];
```

### Fetch all watch face information

Retrieve information about all watch faces on the device, including built-in, custom, and cloud watch faces.

```objc
- (void)fetchAllDials:(TSDialListBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSDialListBlock` | Completion callback with array of all watch face models |

**Example:**

```objc
[dialInterface fetchAllDials:^(NSArray<TSDialModel *> *dials, NSError *error) {
    if (!error && dials) {
        TSLog(@"Total dials: %ld", (long)dials.count);
        for (TSDialModel *dial in dials) {
            TSLog(@"Dial: %@ (Type: %ld, Current: %@)", 
                  dial.dialName, (long)dial.dialType, 
                  dial.isCurrent ? @"YES" : @"NO");
        }
    } else {
        TSLog(@"Failed to fetch dials: %@", error.localizedDescription);
    }
}];
```

### Switch current watch face

Switch the device's currently displayed watch face.

```objc
- (void)switchToDial:(TSDialModel *)dial
          completion:(nullable void(^)(BOOL isSuccess, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dial` | `TSDialModel *` | Watch face model to switch to; must already exist on device |
| `completion` | `void (^)(BOOL, NSError *)` | Completion callback with success status |

**Example:**

```objc
TSDialModel *targetDial = [[TSDialModel alloc] init];
targetDial.dialId = @"dial_001";
targetDial.dialName = @"My Watch Face";

[dialInterface switchToDial:targetDial completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"Successfully switched to dial");
    } else {
        TSLog(@"Failed to switch dial: %@", error.localizedDescription);
    }
}];
```

### Generate custom watch face ID

Generate a unique identifier for a custom watch face.

```objc
- (nonnull NSString *)generateCustomDialIdWithType:(TSCustomDialType)dialType;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dialType` | `TSCustomDialType` | Custom watch face type (single image, multiple images, or video) |

**Return Value:** Generated unique watch face ID string.

**Example:**

```objc
NSString *customDialId = [dialInterface generateCustomDialIdWithType:eTSCustomDialSingleImage];
TSLog(@"Generated dial ID: %@", customDialId);
```

### Push cloud watch face to device

Install a cloud-based watch face that has been downloaded to the device.

```objc
- (void)installDownloadedCloudDial:(TSDialModel *)dial
                     progressBlock:(nullable TSDialProgressBlock)progressBlock
                        completion:(nullable TSDialCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dial` | `TSDialModel *` | Cloud watch face model with valid dialId and dialType (`eTSDialTypeCloud`) |
| `progressBlock` | `TSDialProgressBlock` | Progress callback (optional); called during push to report progress (0-100) |
| `completion` | `TSDialCompletionBlock` | Completion callback (optional); called multiple times during push process |

**Example:**

```objc
TSDialModel *cloudDial = [[TSDialModel alloc] init];
cloudDial.dialId = @"cloud_dial_123";
cloudDial.dialName = @"Cloud Watch Face";
cloudDial.dialType = eTSDialTypeCloud;
cloudDial.filePath = @"/path/to/downloaded/dial.bin";

[dialInterface installDownloadedCloudDial:cloudDial 
                            progressBlock:^(TSDialPushResult result, NSInteger progress) {
    TSLog(@"Push progress: %ld%%", (long)progress);
} completion:^(TSDialPushResult result, NSError *error) {
    if (result == eTSDialPushResultSuccess) {
        TSLog(@"Cloud dial pushed successfully");
    } else if (result == eTSDialPushResultFailed) {
        TSLog(@"Failed to push cloud dial: %@", error.localizedDescription);
    } else if (result == eTSDialPushResultProgress) {
        TSLog(@"Pushing cloud dial...");
    }
}];
```

### Push custom watch face to device

Install a custom-created watch face with user-provided resources.

```objc
- (void)installCustomDial:(TSCustomDial *)customDial
            progressBlock:(nullable TSDialProgressBlock)progressBlock
               completion:(nullable TSDialCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `customDial` | `TSCustomDial *` | Custom watch face model with resources and configuration |
| `progressBlock` | `TSDialProgressBlock` | Progress callback (optional); reports push progress (0-100) |
| `completion` | `TSDialCompletionBlock` | Completion callback (optional); called on success, failure, and completion |

**Example:**

```objc
// Create custom dial item
TSCustomDialItem *dialItem = [[TSCustomDialItem alloc] init];
dialItem.dialType = eTSCustomDialSingleImage;
dialItem.resourceImage = [UIImage imageNamed:@"watchface_bg"];

// Configure time display
dialItem.dialTime.timePosition = eTSDialTimePositionTop;
dialItem.dialTime.timeImage = [UIImage imageNamed:@"time_style"];
dialItem.dialTime.style = eTSDialTimeStyle1;

// Create custom dial
TSCustomDial *customDial = [[TSCustomDial alloc] init];
customDial.dialId = [dialInterface generateCustomDialIdWithType:eTSCustomDialSingleImage];
customDial.dialName = @"My Custom Dial";
customDial.dialType = eTSCustomDialSingleImage;
customDial.templateFilePath = @"/path/to/template.bin";
customDial.resourceItems = @[dialItem];

// Push custom dial
[dialInterface installCustomDial:customDial 
                   progressBlock:^(TSDialPushResult result, NSInteger progress) {
    TSLog(@"Custom dial push progress: %ld%%", (long)progress);
} completion:^(TSDialPushResult result, NSError *error) {
    if (result == eTSDialPushResultSuccess) {
        TSLog(@"Custom dial installed successfully");
    } else if (result == eTSDialPushResultFailed) {
        TSLog(@"Failed to install custom dial: %@", error.localizedDescription);
    }
}];
```

### Delete watch face

Remove a watch face from the device by its model.

```objc
- (void)deleteDial:(TSDialModel *)dial
        completion:(nullable void(^)(BOOL isSuccess, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dial` | `TSDialModel *` | Watch face model to delete; must exist on device |
| `completion` | `void (^)(BOOL, NSError *)` | Completion callback with success status |

**Example:**

```objc
TSDialModel *dialToDelete = [[TSDialModel alloc] init];
dialToDelete.dialId = @"dial_to_remove";

[dialInterface deleteDial:dialToDelete completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"Dial deleted successfully");
    } else {
        TSLog(@"Failed to delete dial: %@", error.localizedDescription);
    }
}];
```

### Fetch watch face remaining storage space

Query the available storage space for watch faces on the device.

```objc
- (void)fetchWatchFaceRemainingStorageSpace:(nullable TSDialSpaceBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSDialSpaceBlock` | Completion callback with remaining space information |

**Example:**

```objc
[dialInterface fetchWatchFaceRemainingStorageSpace:^(NSInteger remainSpace, NSError *error) {
    if (!error) {
        TSLog(@"Remaining space for watch faces: %ld bytes", (long)remainSpace);
        TSLog(@"Remaining space: %.2f MB", remainSpace / (1024.0 * 1024.0));
    } else {
        TSLog(@"Failed to fetch storage space: %@", error.localizedDescription);
    }
}];
```

### Register callback for watch face change notification

Monitor and respond to watch face changes on the device.

```objc
- (void)registerDialDidChangedBlock:(void (^)(NSArray<TSDialModel *> *_Nullable allDials))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSArray<TSDialModel *> *)` | Callback invoked when watch face changes; receives array of all watch faces |

**Example:**

```objc
[dialInterface registerDialDidChangedBlock:^(NSArray<TSDialModel *> *allDials) {
    if (allDials) {
        TSLog(@"Watch face changed! Total dials: %ld", (long)allDials.count);
        for (TSDialModel *dial in allDials) {
            if (dial.isCurrent) {
                TSLog(@"Current dial: %@", dial.dialName);
            }
        }
    } else {
        TSLog(@"Failed to retrieve dial information");
    }
}];
```

### Cancel ongoing watch face push operation

Abort a watch face push operation in progress.

```objc
- (void)cancelPushDial:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion callback with cancellation status |

**Example:**

```objc
[dialInterface cancelPushDial:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"Push operation cancelled successfully");
    } else {
        TSLog(@"Failed to cancel push: %@", error.localizedDescription);
    }
}];
```

### Get maximum number of built-in watch faces

Retrieve the maximum number of built-in watch faces supported by the device.

```objc
- (NSInteger)maxInnerDialCount;
```

**Return Value:** Maximum number of built-in watch faces supported by the device.

**Example:**

```objc
NSInteger maxBuiltIn = [dialInterface maxInnerDialCount];
TSLog(@"Max built-in dials: %ld", (long)maxBuiltIn);
```

### Get maximum number of supported cloud watch faces

Retrieve the maximum number of cloud watch faces that can be stored on the device.

```objc
- (NSInteger)maxCanPushDialCount;
```

**Return Value:** Maximum number of cloud watch faces the device can store.

**Example:**

```objc
NSInteger maxCloud = [dialInterface maxCanPushDialCount];
TSLog(@"Max cloud dials: %ld", (long)maxCloud);
```

### Check if device supports slideshow watch face

Determine whether the device supports photo album watch faces with automatic or manual switching.

```objc
- (BOOL)isSupportSlideshowDial;
```

**Return Value:** `YES` if device supports slideshow watch face; `NO` otherwise.

**Example:**

```objc
if ([dialInterface isSupportSlideshowDial]) {
    TSLog(@"Device supports slideshow dials");
} else {
    TSLog(@"Device does not support slideshow dials");
}
```

### Check if device supports video watch face

Determine whether the device supports video-based watch faces.

```objc
- (BOOL)isSupportVideoDial;
```

**Return Value:** `YES` if device supports video watch face; `NO` otherwise.

**Example:**

```objc
if ([dialInterface isSupportVideoDial]) {
    TSLog(@"Device supports video dials");
} else {
    TSLog(@"Device does not support video dials");
}
```

### Check if device supports dial component

Determine whether the device supports dial component functionality.

```objc
- (BOOL)isSupportDialComponent;
```

**Return Value:** `YES` if device supports dial component; `NO` otherwise.

**Example:**

```objc
if ([dialInterface isSupportDialComponent]) {
    TSLog(@"Device supports dial components");
} else {
    TSLog(@"Device does not support dial components");
}
```

### Get maximum video duration for video watch face

Retrieve the maximum allowed video duration for video-based watch faces.

```objc
- (NSInteger)maxVideoDialDuration;
```

**Return Value:** Maximum video duration in seconds (typically 30 seconds or less); returns 0 if device doesn't support video watch faces.

**Example:**

```objc
NSInteger maxDuration = [dialInterface maxVideoDialDuration];
if (maxDuration > 0) {
    TSLog(@"Max video dial duration: %ld seconds", (long)maxDuration);
} else {
    TSLog(@"Device does not support video dials");
}
```

### Fetch supported widgets list from peripheral device

Retrieve the list of supported widgets from Fw series devices.

```objc
- (void)requestSupportWidgetsFromPeripheralCompletion:(TSDialWidgetsBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSDialWidgetsBlock` | Completion callback with widget information dictionary |

**Example:**

```objc
[dialInterface requestSupportWidgetsFromPeripheralCompletion:^(NSDictionary *widgets, NSError *error) {
    if (!error && widgets) {
        TSLog(@"Supported widgets: %@", widgets);
    } else {
        TSLog(@"Failed to fetch widgets or device does not support widgets");
    }
}];
```

### Generate watch face preview image by compositing images

Create a preview image by combining a background image and time display image at a specified position.

```objc
- (void)previewImageWith:(UIImage *)originImage 
                timeImage:(UIImage *)timeImage 
            timePosition:(TSDialTimePosition)timePosition 
              maxKBSize:(CGFloat)maxKBSize 
             completion:(void (^)(UIImage *_Nullable previewImage, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `originImage` | `UIImage *` | Background image for the watch face |
| `timeImage` | `UIImage *` | Time display image to composite onto background |
| `timePosition` | `TSDialTimePosition` | Position where time image should be placed |
| `maxKBSize` | `CGFloat` | Maximum file size for preview image in kilobytes |
| `completion` | `void (^)(UIImage *, NSError *)` | Completion callback with generated preview image |

**Example:**

```objc
UIImage *backgroundImage = [UIImage imageNamed:@"dial_background"];
UIImage *timeDisplayImage = [UIImage imageNamed:@"time_display"];

[dialInterface previewImageWith:backgroundImage 
                      timeImage:timeDisplayImage 
                   timePosition:eTSDialTimePositionTop 
                     maxKBSize:300.0 
                    completion:^(UIImage *previewImage, NSError *error) {
    if (!error && previewImage) {
        TSLog(@"Preview image generated successfully");
        // Use previewImage in UI
    } else {
        TSLog(@"Failed to generate preview: %@", error.localizedDescription);
    }
}];
```

### Generate watch face preview image from custom dial item

Create a preview image from a custom dial item with automatic time position calculation or custom rectangle.

```objc
- (void)previewImageWithDialItem:(TSCustomDialItem *)dialItem 
                        maxKBSize:(CGFloat)maxKBSize 
                       completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dialItem` | `TSCustomDialItem *` | Custom dial item with background, time image, and position configuration |
| `maxKBSize` | `CGFloat` | Maximum file size for preview image in kilobytes (default 300 KB if 0 or negative) |
| `completion` | `void (^)(UIImage *, NSError *)` | Completion callback with generated preview image |

**Example:**

```objc
// Create dial item with configuration
TSCustomDialItem *dialItem = [[TSCustomDialItem alloc] init];
dialItem.dialType = eTSCustomDialSingleImage;
dialItem.resourceImage = [UIImage imageNamed:@"watchface_background"];

// Configure time display with custom rectangle
dialItem.dialTime.timeImage = [UIImage imageNamed:@"time_style"];
dialItem.dialTime.timeRect = CGRectMake(50, 50, 200, 100);
dialItem.dialTime.style = eTSDialTimeStyle1;

// Generate preview
[dialInterface previewImageWithDialItem:dialItem 
                              maxKBSize:300.0 
                             completion:^(UIImage *previewImage, NSError *error) {
    if (!error && previewImage) {
        TSLog(@"Preview generated from dial item");
        // Display preview in UI
    } else {
        TSLog(@"Failed to generate preview: %@", error.localizedDescription);
    }
}];
```

**Alternative example with timePosition:**

```objc
// Create dial item with position-based time placement
TSCustomDialItem *dialItem = [[TSCustomDialItem alloc] init];
dialItem.dialType = eTSCustomDialSingleImage;
dialItem.resourceImage = [UIImage imageNamed:@"watchface_background"];

// Use predefined position instead of custom rectangle
dialItem.dialTime.timeImage = [UIImage imageNamed:@"time_style"];
dialItem.dialTime.timePosition = eTSDialTimePositionCenter;
dialItem.dialTime.style = eTSDialTimeStyle2;
dialItem.dialTime.timeColor = [UIColor whiteColor];

// Generate preview
[dialInterface previewImageWithDialItem:dialItem 
                              maxKBSize:250.0 
                             completion:^(UIImage *previewImage, NSError *error) {
    if (!error && previewImage) {
        TSLog(@"Preview with position-based time generated");
    } else {
        TSLog(@"Error: %@", error.localizedDescription);
    }
}];
```

## Important Notes

1. **Two Watch Face Models:** The SDK uses two different models for different purposes:
   - `TSDialModel`: Use for device watch face information, cloud watch face operations, and device queries
   - `TSCustomDial`: Use for creating and pushing custom watch faces with user-provided resources

2. **Built-in Watch Faces Cannot Be Deleted:** Only custom and cloud watch faces can be removed from the device; built-in watch faces are permanent system resources.

3. **Storage Space Management:** Always check remaining storage space with `fetchWatchFaceRemainingStorageSpace` before pushing new watch faces to avoid failed push operations.

4. **Progress and Completion Callbacks:** Progress callbacks are called multiple times during push operations. Completion callbacks may be called multiple times with different results (progress, success, failed, completed).

5. **Time Position Priority:** When configuring time display in `TSCustomDialTime`:
   - If `timeRect` is set (not `CGRectZero`), it takes priority
   - If `timeRect` is not set, `timePosition` is used as fallback
   - Both cannot be ignored; at least one must be properly configured

6. **Image Size Requirements:** Images must match device specifications:
   - Preview images: Must match `TSPeripheralScreen.dialPreviewSize`
   - Background images: Must match `TSPeripheralScreen.screenSize`
   - Incorrect sizes may cause push failures or display issues

7. **Custom Dial ID Generation:** Always use `generateCustomDialIdWithType:` to create unique identifiers for custom watch faces; do not manually create IDs.

8. **Video Watch Face Limitations:** Video watch faces have strict duration and encoding requirements; check device capabilities with `isSupportVideoDial` and `maxVideoDialDuration` before implementation.

9. **Callback Thread:** All completion and change notification callbacks are executed on the main thread; perform UI updates directly without additional thread dispatching.

10. **Device Capability Queries:** Use support checking methods (`isSupportSlideshowDial`, `isSupportVideoDial`, `isSupportDialComponent`) before implementing device-specific features to ensure broad device compatibility.