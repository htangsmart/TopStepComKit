---
sidebar_position: 5
title: 相机控制
---

# 相机控制（TSCamera）

提供与外设设备的相机控制通信协议，支持相机模式控制、照片拍摄、视频预览等功能。主要用于实现App与智能设备（如智能手表、智能眼镜）之间的远程相机控制功能。

## 前提条件

- 设备已连接到App
- 设备支持相机控制功能
- 对于视频预览功能，设备需支持视频预览功能（可通过 `isSupportVideoPreview` 方法检查）

## 数据模型

### TSCameraVideoData

视频帧数据模型，用于承载编码后的视频数据和关键帧标志。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `data` | `NSData *` | 视频帧数据，包含编码后的视频帧字节 |
| `isKeyFrame` | `BOOL` | 是否为关键帧（I帧），关键帧包含完整的图像数据，可独立解码 |

## 枚举与常量

### TSCameraAction

相机动作枚举，定义所有可执行的相机操作。

| 枚举值 | 数值 | 说明 |
|--------|------|------|
| `TSCameraActionExitCamera` | 0 | 退出相机模式 |
| `TSCameraActionEnterCamera` | 1 | 进入相机模式 |
| `TSCameraActionTakePhoto` | 2 | 拍照 |
| `TSCameraActionSwitchBackCamera` | 3 | 切换到后置摄像头 |
| `TSCameraActionSwitchFrontCamera` | 4 | 切换到前置摄像头 |
| `TSCameraActionFlashOff` | 5 | 关闭闪光灯 |
| `TSCameraActionFlashAuto` | 6 | 闪光灯自动模式 |
| `TSCameraActionFlashOn` | 7 | 开启闪光灯 |

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `TSCameraActionBlock` | 相机动作回调，签名：`void (^)(TSCameraAction action)` |

## 接口方法

### 控制设备执行相机动作

```objc
- (void)controlCameraWithAction:(TSCameraAction)action completion:(TSCompletionBlock)completion;
```

**说明**：App向设备发送相机控制命令，控制设备执行特定的相机动作。目前仅支持退出相机和进入相机动作。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `action` | `TSCameraAction` | 要执行的相机动作。目前仅支持 `TSCameraActionExitCamera` 和 `TSCameraActionEnterCamera`。其他动作类型（拍照、切换摄像头、闪光控制）暂不支持 |
| `completion` | `TSCompletionBlock` | 操作完成的回调。包含操作结果和错误信息 |

**代码示例**：

```objc
// 控制设备进入相机模式
[cameraInterface controlCameraWithAction:TSCameraActionEnterCamera 
                              completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"相机已进入");
    } else {
        TSLog(@"进入相机失败: %@", error.localizedDescription);
    }
}];

// 控制设备退出相机模式
[cameraInterface controlCameraWithAction:TSCameraActionExitCamera 
                              completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"相机已退出");
    } else {
        TSLog(@"退出相机失败: %@", error.localizedDescription);
    }
}];
```

### 注册设备相机控制监听

```objc
- (void)registerAppCameraeControledByDevice:(nullable TSCameraActionBlock)cameraControlActionBlock;
```

**说明**：注册监听设备对App相机的控制。当设备主动控制App相机时（如通过按键或手势），指定的回调块会被触发，包含具体的操作动作。此方法支持所有相机动作类型。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `cameraControlActionBlock` | `TSCameraActionBlock` | 当设备控制App相机时的回调，包含具体的动作类型。传 `nil` 可取消注册 |

**代码示例**：

```objc
// 注册监听设备对App相机的控制
[cameraInterface registerAppCameraeControledByDevice:^(TSCameraAction action) {
    switch (action) {
        case TSCameraActionEnterCamera:
            TSLog(@"设备要求App进入相机模式");
            // 执行进入相机逻辑
            break;
        case TSCameraActionExitCamera:
            TSLog(@"设备要求App退出相机模式");
            // 执行退出相机逻辑
            break;
        case TSCameraActionTakePhoto:
            TSLog(@"设备要求App拍照");
            // 执行拍照逻辑
            break;
        case TSCameraActionSwitchBackCamera:
            TSLog(@"设备要求App切换到后置摄像头");
            // 切换到后置摄像头
            break;
        case TSCameraActionSwitchFrontCamera:
            TSLog(@"设备要求App切换到前置摄像头");
            // 切换到前置摄像头
            break;
        case TSCameraActionFlashOff:
            TSLog(@"设备要求App关闭闪光灯");
            // 关闭闪光灯
            break;
        case TSCameraActionFlashAuto:
            TSLog(@"设备要求App设置闪光灯为自动");
            // 设置闪光灯自动
            break;
        case TSCameraActionFlashOn:
            TSLog(@"设备要求App开启闪光灯");
            // 开启闪光灯
            break;
        default:
            break;
    }
}];

// 取消注册
[cameraInterface registerAppCameraeControledByDevice:nil];
```

### 检查设备是否支持视频预览

```objc
- (BOOL)isSupportVideoPreview;
```

**说明**：检查当前连接的设备是否支持视频预览功能。视频预览允许设备在相机模式下接收App发送的实时视频流。

| 返回值 | 类型 | 说明 |
|--------|------|------|
| 返回值 | `BOOL` | 如果设备支持视频预览返回 `YES`，否则返回 `NO`。若设备未连接返回 `NO` |

**代码示例**：

```objc
// 检查设备是否支持视频预览
if ([cameraInterface isSupportVideoPreview]) {
    TSLog(@"设备支持视频预览");
    // 可以启动视频预览功能
} else {
    TSLog(@"设备不支持视频预览");
}
```

### 获取视频预览尺寸

```objc
- (CGSize)videoPreviewSize;
```

**说明**：获取已连接设备的视频预览尺寸。预览尺寸表示设备在视频预览模式下能接收的视频流的分辨率，对于设置视频显示UI的宽高比很有用。

| 返回值 | 类型 | 说明 |
|--------|------|------|
| 返回值 | `CGSize` | 预览尺寸（宽 × 高），单位为像素。若设备未连接或尺寸不可用返回 `CGSizeZero` |

**代码示例**：

```objc
// 获取设备支持的视频预览尺寸
CGSize previewSize = [cameraInterface videoPreviewSize];
if (!CGSizeEqualToSize(previewSize, CGSizeZero)) {
    TSLog(@"视频预览尺寸: %.0f x %.0f", previewSize.width, previewSize.height);
    // 根据设备支持的尺寸配置视频采集和处理参数
} else {
    TSLog(@"设备不支持视频预览或未连接");
}
```

### 启动视频预览

```objc
- (void)startVideoPreviewWithFps:(NSInteger)fps completion:(TSCompletionBlock)completion;
```

**说明**：向设备发送启动视频预览的命令。设备启动视频预览后，App可以开始发送视频数据到设备。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `fps` | `NSInteger` | 视频预览的帧率（每秒帧数）。常用值：15、24、30、60。使用 0 或负值表示使用设备默认帧率 |
| `completion` | `TSCompletionBlock` | 操作完成的回调，包含操作结果和错误信息 |

**代码示例**：

```objc
// 启动视频预览，帧率为30fps
[cameraInterface startVideoPreviewWithFps:30 
                               completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"视频预览已启动");
        // 开始采集和发送视频数据
    } else {
        TSLog(@"启动视频预览失败: %@", error.localizedDescription);
    }
}];

// 使用设备默认帧率启动
[cameraInterface startVideoPreviewWithFps:0 
                               completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"视频预览已启动（使用设备默认帧率）");
    }
}];
```

### 停止视频预览

```objc
- (void)stopVideoPreviewCompletion:(TSCompletionBlock)completion;
```

**说明**：向设备发送停止视频预览的命令。停止后设备不再接收视频数据。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `TSCompletionBlock` | 操作完成的回调，包含操作结果和错误信息 |

**代码示例**：

```objc
// 停止视频预览
[cameraInterface stopVideoPreviewCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (isSuccess) {
        TSLog(@"视频预览已停止");
        // 停止采集视频数据
    } else {
        TSLog(@"停止视频预览失败: %@", error.localizedDescription);
    }
}];
```

### 发送CMSampleBuffer格式的视频预览数据

```objc
- (void)sendVideoPreviewSampleBuffer:(CMSampleBufferRef)sampleBuffer isBack:(BOOL)isBack;
```

**说明**：使用 `CMSampleBuffer` 向设备发送视频预览数据帧。此方法用于直接处理AVFoundation捕获的视频样本。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `sampleBuffer` | `CMSampleBufferRef` | 包含视频帧数据的CMSampleBuffer，通常从AVCaptureVideoDataOutputSampleBufferDelegate回调中获取 |
| `isBack` | `BOOL` | 使用后置摄像头返回 `YES`，使用前置摄像头返回 `NO`。此参数用于确定正确的编码方向 |

**代码示例**：

```objc
// 在AVCaptureVideoDataOutputSampleBufferDelegate中
- (void)captureOutput:(AVCaptureOutput *)output 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection {
    
    // 直接发送采集到的视频样本到设备（使用后置摄像头）
    [cameraInterface sendVideoPreviewSampleBuffer:sampleBuffer isBack:YES];
}
```

### 发送编码后的视频预览数据

```objc
- (void)sendVideoPreviewData:(TSCameraVideoData *)videoData;
```

**说明**：向设备发送已编码的视频预览数据。数据必须通过 `encodeYUVToH264WithYData:uData:vData:screenW:screenH:orientation:isBack:` 方法编码得到。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `videoData` | `TSCameraVideoData *` | 包含H264编码视频数据的对象，必须通过YUV转H264编码方法获得 |

**代码示例**：

```objc
// 编码YUV数据后发送到设备
TSCameraVideoData *encodedData = [cameraInterface encodeYUVToH264WithYData:yData 
                                                                       uData:uData 
                                                                       vData:vData 
                                                                     screenW:640 
                                                                     screenH:480 
                                                                 orientation:0 
                                                                      isBack:YES];

if (encodedData) {
    [cameraInterface sendVideoPreviewData:encodedData];
    TSLog(@"视频数据已发送，是否关键帧: %@", encodedData.isKeyFrame ? @"是" : @"否");
}
```

### YUV转H264视频数据编码

```objc
- (nullable TSCameraVideoData *)encodeYUVToH264WithYData:(NSData *)yData
                                                   uData:(NSData *)uData
                                                   vData:(nullable NSData *)vData
                                                 screenW:(NSInteger)screenW
                                                 screenH:(NSInteger)screenH
                                             orientation:(NSInteger)orientation
                                                  isBack:(BOOL)isBack;
```

**说明**：将原始YUV视频数据转换为H264编码格式。编码后的数据可通过 `sendVideoPreviewData:` 发送到设备。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `yData` | `NSData *` | Y平面数据（亮度分量） |
| `uData` | `NSData *` | U平面数据（色度分量） |
| `vData` | `NSData *` | V平面数据（色度分量）。某些YUV格式可传 `nil` |
| `screenW` | `NSInteger` | 视频画面宽度，单位像素 |
| `screenH` | `NSInteger` | 视频画面高度，单位像素 |
| `orientation` | `NSInteger` | 设备方向。0=竖屏，1=倒置竖屏，2=左横屏，3=右横屏 |
| `isBack` | `BOOL` | 使用后置摄像头返回 `YES`，使用前置摄像头返回 `NO` |

| 返回值 | 类型 | 说明 |
|--------|------|------|
| 返回值 | `TSCameraVideoData *` | 包含H264编码数据和关键帧标志的对象。编码失败或参数无效时返回 `nil` |

**代码示例**：

```objc
// 从YUV数据编码为H264
NSData *yData = ...; // Y平面数据
NSData *uData = ...; // U平面数据
NSData *vData = ...; // V平面数据

TSCameraVideoData *encodedData = [cameraInterface encodeYUVToH264WithYData:yData 
                                                                       uData:uData 
                                                                       vData:vData 
                                                                     screenW:640 
                                                                     screenH:480 
                                                                 orientation:0 
                                                                      isBack:YES];

if (encodedData != nil) {
    // 编码成功，发送到设备
    [cameraInterface sendVideoPreviewData:encodedData];
    TSLog(@"编码成功，帧大小: %lu 字节", (unsigned long)encodedData.data.length);
} else {
    TSLog(@"编码失败");
}
```

## 注意事项

1. **方法支持情况**：`controlCameraWithAction:completion:` 方法目前仅支持 `TSCameraActionExitCamera` 和 `TSCameraActionEnterCamera` 两个动作，其他动作类型（拍照、切换摄像头、闪光控制）暂不支持。

2. **设备连接**：所有方法都需要设备与App保持活跃连接。如果设备断开连接，方法调用会返回失败或返回默认值。

3. **视频预览前置条件**：在调用视频预览相关方法前，应先通过 `isSupportVideoPreview` 检查设备是否支持此功能，避免不必要的操作失败。

4. **视频预览生命周期**：必须先调用 `startVideoPreviewWithFps:completion:` 启动预览，才能开始发送视频数据；使用完毕应调用 `stopVideoPreviewCompletion:` 停止预览。

5. **视频数据格式**：发送给设备的视频数据必须是通过 `encodeYUVToH264WithYData:...` 方法编码得到的 `TSCameraVideoData` 对象，不要传递其他格式或来源的数据。

6. **YUV数据源**：YUV数据通常来自视频采集框架（AVFoundation）或其他视频处理库。需确保数据为YUV420格式（I420或NV12）。

7. **回调线程**：所有回调（包括 `completion` 和 `cameraControlActionBlock`）可能在子线程执行，如需更新UI应切换到主线程。

8. **错误处理**：所有操作的回调中应检查 `isSuccess` 标志和 `error` 对象，正确处理操作失败的情况。

9. **内存管理**：`CMSampleBufferRef` 参数由调用方管理生命周期；编码后的 `TSCameraVideoData` 对象可立即使用或保存供后续发送。

10. **监听注册**：设备控制App相机的监听注册后会持续生效，直到传入 `nil` 取消注册。在App生命周期中应妥善管理注册和注销。

