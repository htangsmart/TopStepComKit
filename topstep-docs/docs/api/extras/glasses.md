---
sidebar_position: 2
title: 眼镜
---

# 眼镜（TSGlasses）

TopStepComKit iOS SDK 中的眼镜模块提供了智能眼镜设备的完整控制接口，包括视频预览、音频录制、视频录制、拍照以及设备存储和媒体管理等功能。通过本模块，您可以方便地与连接的智能眼镜设备进行交互和数据传输。

## 前提条件

1. 设备已成功连接到智能眼镜
2. 已完成 SDK 初始化
3. 确保设备电量充足
4. 网络连接稳定（某些功能可能需要蓝牙或网络传输）

## 数据模型

### TSGlassesMediaCount

智能眼镜设备上的媒体文件数量统计模型。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `videoCount` | `NSInteger` | 设备上的视频文件总数（包括录制和下载的视频）|
| `audioRecordingCount` | `NSInteger` | 设备上的录音文件总数（包括语音备忘录和其他音频录制）|
| `musicCount` | `NSInteger` | 设备上的音乐文件总数（包括上传和系统音乐）|
| `photoCount` | `NSInteger` | 设备上的照片文件总数（由设备摄像头拍摄）|

### TSGlassesStorageInfo

智能眼镜设备的存储信息模型，包括总存储空间和可用存储空间。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `totalSpace` | `unsigned long long` | 设备总存储容量（字节），表示设备的最大可用存储空间 |
| `availableSpace` | `unsigned long long` | 设备可用存储空间（字节），表示可用于存储文件的剩余空间 |

## 枚举与常量

### TSVideoPreviewStatus

视频预览状态枚举。

| 枚举值 | 说明 |
|--------|------|
| `TSVideoPreviewUnknown` | 未知状态 |
| `TSVideoPreviewInactive` | 预览未进行 |
| `TSVideoPreviewActive` | 预览进行中 |

### TSAudioRecordingStatus

音频录制状态枚举。

| 枚举值 | 说明 |
|--------|------|
| `TSAudioRecordingUnknown` | 未知状态 |
| `TSAudioRecordingInactive` | 未在录制 |
| `TSAudioRecordingActive` | 录制进行中 |

### TSVideoRecordingStatus

视频录制状态枚举。

| 枚举值 | 说明 |
|--------|------|
| `TSVideoRecordingUnknown` | 未知状态 |
| `TSVideoRecordingInactive` | 未在录制 |
| `TSVideoRecordingActive` | 录制进行中 |

## 回调类型

| 类型名 | 签名 | 说明 |
|--------|------|------|
| `PreviewVideoStatusChangedBlock` | `void (^)(TSVideoPreviewStatus status)` | 视频预览状态变化时的回调，返回新的预览状态 |
| `AudioRecordingStatusChangedBlock` | `void (^)(TSAudioRecordingStatus status)` | 音频录制状态变化时的回调，返回新的录制状态 |
| `VideoRecordingStatusChangedBlock` | `void (^)(TSVideoRecordingStatus status)` | 视频录制状态变化时的回调，返回新的录制状态 |
| `PhotoCaptureResultBlock` | `void (^)(BOOL isSuccess, NSError * _Nullable error)` | 拍照结果回调，返回是否成功及错误信息 |
| `DidReceiveVideoDataBlock` | `void (^)(NSData *videoData)` | 接收视频数据的回调，返回原始视频数据 |
| `DidCompleteVideoPreviewBlock` | `void (^)(NSError * _Nullable error)` | 视频预览完成的回调，返回错误信息（正常结束时为 nil）|

## 接口方法

### 检查设备是否支持视频预览

```objc
- (BOOL)isSupportVideoPreview;
```

检查连接的智能眼镜设备是否支持视频预览功能。

| 参数 | 类型 | 说明 |
|------|------|------|
| 返回值 | `BOOL` | 如果设备支持视频预览返回 `YES`，否则返回 `NO` |

**代码示例：**

```objc
if ([glassesInterface isSupportVideoPreview]) {
    TSLog(@"设备支持视频预览");
} else {
    TSLog(@"设备不支持视频预览");
}
```

### 启动视频预览

```objc
- (void)startVideoPreview:(TSCompletionBlock)completion
              didReceiveData:(DidReceiveVideoDataBlock)didReceiveData
              completionHandler:(DidCompleteVideoPreviewBlock)completionHandler;
```

启动智能眼镜的视频预览，并持续接收视频数据。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 启动操作完成回调，返回操作成功状态和错误信息 |
| `didReceiveData` | `DidReceiveVideoDataBlock` | 视频数据接收回调，每当接收到视频数据时调用 |
| `completionHandler` | `DidCompleteVideoPreviewBlock` | 视频预览完成回调，预览结束时调用 |

**代码示例：**

```objc
[glassesInterface startVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"视频预览启动成功");
    } else {
        TSLog(@"视频预览启动失败: %@", error.localizedDescription);
    }
} didReceiveData:^(NSData *videoData) {
    // 处理接收到的视频数据
    TSLog(@"接收到视频数据，大小: %lu 字节", (unsigned long)videoData.length);
    // 可以将视频数据写入文件或进行处理
} completionHandler:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"视频预览异常结束: %@", error.localizedDescription);
    } else {
        TSLog(@"视频预览正常结束");
    }
}];
```

### 停止视频预览

```objc
- (void)stopVideoPreview:(TSCompletionBlock)completion;
```

停止正在进行的视频预览。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 停止操作完成回调，返回操作成功状态和错误信息 |

**代码示例：**

```objc
[glassesInterface stopVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"视频预览已停止");
    } else {
        TSLog(@"停止视频预览失败: %@", error.localizedDescription);
    }
}];
```

### 获取视频预览状态

```objc
- (void)getVideoPreviewStatus:(void(^)(TSVideoPreviewStatus status, NSError * _Nullable error))completion;
```

获取当前的视频预览状态。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void(^)(TSVideoPreviewStatus, NSError *)` | 状态查询完成回调，返回当前预览状态和错误信息 |

**代码示例：**

```objc
[glassesInterface getVideoPreviewStatus:^(TSVideoPreviewStatus status, NSError * _Nullable error) {
    if (!error) {
        switch (status) {
            case TSVideoPreviewActive:
                TSLog(@"视频预览进行中");
                break;
            case TSVideoPreviewInactive:
                TSLog(@"视频预览未进行");
                break;
            case TSVideoPreviewUnknown:
            default:
                TSLog(@"视频预览状态未知");
                break;
        }
    } else {
        TSLog(@"获取视频预览状态失败: %@", error.localizedDescription);
    }
}];
```

### 注册视频预览状态变化监听

```objc
- (void)registerVideoPreviewStatusChangedBlock:(PreviewVideoStatusChangedBlock)statusChangedBlock;
```

注册一个块来监听视频预览状态的变化。当预览状态改变时会自动调用该块。

| 参数 | 类型 | 说明 |
|------|------|------|
| `statusChangedBlock` | `PreviewVideoStatusChangedBlock` | 状态变化监听块，状态改变时调用；传 `nil` 可移除监听 |

**代码示例：**

```objc
[glassesInterface registerVideoPreviewStatusChangedBlock:^(TSVideoPreviewStatus status) {
    switch (status) {
        case TSVideoPreviewActive:
            TSLog(@"视频预览已启动");
            break;
        case TSVideoPreviewInactive:
            TSLog(@"视频预览已停止");
            break;
        case TSVideoPreviewUnknown:
        default:
            TSLog(@"视频预览状态变为未知");
            break;
    }
}];

// 移除监听
[glassesInterface registerVideoPreviewStatusChangedBlock:nil];
```

### 启动音频录制

```objc
- (void)startAudioRecording:(TSCompletionBlock)completion;
```

启动智能眼镜的音频录制功能。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 启动操作完成回调，返回操作成功状态和错误信息 |

**代码示例：**

```objc
[glassesInterface startAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"音频录制已启动");
    } else {
        TSLog(@"启动音频录制失败: %@", error.localizedDescription);
    }
}];
```

### 停止音频录制

```objc
- (void)stopAudioRecording:(TSCompletionBlock)completion;
```

停止正在进行的音频录制。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 停止操作完成回调，返回操作成功状态和错误信息 |

**代码示例：**

```objc
[glassesInterface stopAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"音频录制已停止");
    } else {
        TSLog(@"停止音频录制失败: %@", error.localizedDescription);
    }
}];
```

### 获取音频录制状态

```objc
- (void)getAudioRecordingStatus:(void(^)(TSAudioRecordingStatus status, NSError * _Nullable error))completion;
```

获取当前的音频录制状态。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void(^)(TSAudioRecordingStatus, NSError *)` | 状态查询完成回调，返回当前录制状态和错误信息 |

**代码示例：**

```objc
[glassesInterface getAudioRecordingStatus:^(TSAudioRecordingStatus status, NSError * _Nullable error) {
    if (!error) {
        switch (status) {
            case TSAudioRecordingActive:
                TSLog(@"音频录制进行中");
                break;
            case TSAudioRecordingInactive:
                TSLog(@"音频录制未进行");
                break;
            case TSAudioRecordingUnknown:
            default:
                TSLog(@"音频录制状态未知");
                break;
        }
    } else {
        TSLog(@"获取音频录制状态失败: %@", error.localizedDescription);
    }
}];
```

### 注册音频录制状态变化监听

```objc
- (void)registerAudioRecordingStatusChangedBlock:(AudioRecordingStatusChangedBlock)statusChangedBlock;
```

注册一个块来监听音频录制状态的变化。当录制状态改变时会自动调用该块。

| 参数 | 类型 | 说明 |
|------|------|------|
| `statusChangedBlock` | `AudioRecordingStatusChangedBlock` | 状态变化监听块，状态改变时调用；传 `nil` 可移除监听 |

**代码示例：**

```objc
[glassesInterface registerAudioRecordingStatusChangedBlock:^(TSAudioRecordingStatus status) {
    switch (status) {
        case TSAudioRecordingActive:
            TSLog(@"音频录制已启动");
            break;
        case TSAudioRecordingInactive:
            TSLog(@"音频录制已停止");
            break;
        case TSAudioRecordingUnknown:
        default:
            TSLog(@"音频录制状态变为未知");
            break;
    }
}];

// 移除监听
[glassesInterface registerAudioRecordingStatusChangedBlock:nil];
```

### 启动视频录制

```objc
- (void)startVideoRecording:(TSCompletionBlock)completion;
```

启动智能眼镜的视频录制功能。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 启动操作完成回调，返回操作成功状态和错误信息 |

**代码示例：**

```objc
[glassesInterface startVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"视频录制已启动");
    } else {
        TSLog(@"启动视频录制失败: %@", error.localizedDescription);
    }
}];
```

### 停止视频录制

```objc
- (void)stopVideoRecording:(TSCompletionBlock)completion;
```

停止正在进行的视频录制。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 停止操作完成回调，返回操作成功状态和错误信息 |

**代码示例：**

```objc
[glassesInterface stopVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"视频录制已停止");
    } else {
        TSLog(@"停止视频录制失败: %@", error.localizedDescription);
    }
}];
```

### 获取视频录制状态

```objc
- (void)getVideoRecordingStatus:(void(^)(TSVideoRecordingStatus status, NSError * _Nullable error))completion;
```

获取当前的视频录制状态。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void(^)(TSVideoRecordingStatus, NSError *)` | 状态查询完成回调，返回当前录制状态和错误信息 |

**代码示例：**

```objc
[glassesInterface getVideoRecordingStatus:^(TSVideoRecordingStatus status, NSError * _Nullable error) {
    if (!error) {
        switch (status) {
            case TSVideoRecordingActive:
                TSLog(@"视频录制进行中");
                break;
            case TSVideoRecordingInactive:
                TSLog(@"视频录制未进行");
                break;
            case TSVideoRecordingUnknown:
            default:
                TSLog(@"视频录制状态未知");
                break;
        }
    } else {
        TSLog(@"获取视频录制状态失败: %@", error.localizedDescription);
    }
}];
```

### 注册视频录制状态变化监听

```objc
- (void)registerVideoRecordingStatusChangedBlock:(VideoRecordingStatusChangedBlock)statusChangedBlock;
```

注册一个块来监听视频录制状态的变化。当录制状态改变时会自动调用该块。

| 参数 | 类型 | 说明 |
|------|------|------|
| `statusChangedBlock` | `VideoRecordingStatusChangedBlock` | 状态变化监听块，状态改变时调用；传 `nil` 可移除监听 |

**代码示例：**

```objc
[glassesInterface registerVideoRecordingStatusChangedBlock:^(TSVideoRecordingStatus status) {
    switch (status) {
        case TSVideoRecordingActive:
            TSLog(@"视频录制已启动");
            break;
        case TSVideoRecordingInactive:
            TSLog(@"视频录制已停止");
            break;
        case TSVideoRecordingUnknown:
        default:
            TSLog(@"视频录制状态变为未知");
            break;
    }
}];

// 移除监听
[glassesInterface registerVideoRecordingStatusChangedBlock:nil];
```

### 拍照

```objc
- (void)takePhoto:(TSCompletionBlock)completion;
```

使用智能眼镜拍摄一张照片。拍摄的照片将保存到设备存储中。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 拍照操作完成回调，返回操作成功状态和错误信息 |

**代码示例：**

```objc
[glassesInterface takePhoto:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"拍照成功");
    } else {
        TSLog(@"拍照失败: %@", error.localizedDescription);
    }
}];
```

### 注册拍照结果监听

```objc
- (void)registerPhotoCaptureResultBlock:(PhotoCaptureResultBlock)resultBlock;
```

注册一个块来监听拍照结果。当拍照完成时会自动调用该块。

| 参数 | 类型 | 说明 |
|------|------|------|
| `resultBlock` | `PhotoCaptureResultBlock` | 拍照结果监听块；传 `nil` 可移除监听 |

**代码示例：**

```objc
[glassesInterface registerPhotoCaptureResultBlock:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"拍照操作完成，照片已保存");
    } else {
        TSLog(@"拍照操作失败: %@", error.localizedDescription);
    }
}];

// 移除监听
[glassesInterface registerPhotoCaptureResultBlock:nil];
```

### 获取媒体文件数量

```objc
- (void)getMediaCount:(void(^)(TSGlassesMediaCount * _Nullable mediaCount, NSError * _Nullable error))completion;
```

获取智能眼镜设备上各类型媒体文件的数量统计。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void(^)(TSGlassesMediaCount *, NSError *)` | 数量查询完成回调，返回媒体数量模型和错误信息 |

**代码示例：**

```objc
[glassesInterface getMediaCount:^(TSGlassesMediaCount * _Nullable mediaCount, NSError * _Nullable error) {
    if (!error && mediaCount) {
        TSLog(@"视频数: %ld", (long)mediaCount.videoCount);
        TSLog(@"录音数: %ld", (long)mediaCount.audioRecordingCount);
        TSLog(@"音乐数: %ld", (long)mediaCount.musicCount);
        TSLog(@"照片数: %ld", (long)mediaCount.photoCount);
        TSLog(@"总媒体数: %ld", (long)[mediaCount totalMediaCount]);
        
        if ([mediaCount hasAnyMedia]) {
            TSLog(@"设备中有媒体文件");
        } else {
            TSLog(@"设备中没有媒体文件");
        }
    } else {
        TSLog(@"获取媒体数量失败: %@", error.localizedDescription);
    }
}];
```

### 获取存储信息

```objc
- (void)getStorageInfo:(void(^)(TSGlassesStorageInfo * _Nullable storageInfo, NSError * _Nullable error))completion;
```

获取智能眼镜设备的存储容量和可用空间信息。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void(^)(TSGlassesStorageInfo *, NSError *)` | 存储信息查询完成回调，返回存储信息模型和错误信息 |

**代码示例：**

```objc
[glassesInterface getStorageInfo:^(TSGlassesStorageInfo * _Nullable storageInfo, NSError * _Nullable error) {
    if (!error && storageInfo) {
        unsigned long long totalSpaceGB = storageInfo.totalSpace / (1024 * 1024 * 1024);
        unsigned long long usedSpaceGB = [storageInfo usedSpace] / (1024 * 1024 * 1024);
        unsigned long long availableSpaceGB = storageInfo.availableSpace / (1024 * 1024 * 1024);
        double usagePercentage = [storageInfo usagePercentage];
        
        TSLog(@"总存储空间: %llu GB", totalSpaceGB);
        TSLog(@"已使用空间: %llu GB", usedSpaceGB);
        TSLog(@"可用空间: %llu GB", availableSpaceGB);
        TSLog(@"使用百分比: %.2f%%", usagePercentage);
        TSLog(@"存储信息: %@", [storageInfo formattedStorageInfo]);
        
        // 检查是否有足够空间录制 500MB 的视频
        unsigned long long requiredSize = 500 * 1024 * 1024;
        if ([storageInfo hasEnoughSpaceForSize:requiredSize]) {
            TSLog(@"设备有足够空间");
        } else {
            TSLog(@"设备空间不足");
        }
    } else {
        TSLog(@"获取存储信息失败: %@", error.localizedDescription);
    }
}];
```

## 注意事项

1. **设备连接状态**：所有接口方法都需要确保设备已成功连接，否则会返回错误。

2. **视频数据处理**：在 `startVideoPreview` 方法的 `didReceiveData` 回调中接收到的视频数据需要及时处理，避免内存溢出。

3. **状态监听的生命周期**：注册的状态变化监听块会一直保持活动状态，直到传入 `nil` 移除监听或对象被释放。

4. **并发操作限制**：不应同时启动多个录制或预览操作（如同时进行视频录制和音频录制需谨慎处理）。

5. **存储空间检查**：在进行视频或音频录制前，建议先通过 `getStorageInfo` 查询可用空间，确保有足够的存储容量。

6. **错误处理**：所有操作都可能由于设备断连、电量不足、存储满等原因失败，需要妥善处理返回的错误信息。

7. **资源释放**：当不再需要监听状态变化时，应及时调用相应的注册方法并传入 `nil` 来移除监听，避免内存泄漏。

8. **数据格式**：存储空间相关的数据以字节（bytes）为单位，计算 GB/MB 时需要按照 1GB = 1024³ 字节进行转换。