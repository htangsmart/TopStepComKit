---
sidebar_position: 5
title: 表盘
---

# 表盘（TSDial）

表盘模块提供完整的外设表盘管理功能，包括表盘信息获取、推送、删除、切换以及变化监听等操作。支持内置表盘、云端表盘和自定义表盘的全生命周期管理。

## 前提条件

1. 已初始化 TopStepComKit SDK 并成功连接外设设备
2. 外设设备支持表盘功能（可通过 `isSupportSlideshowDial`、`isSupportVideoDial` 等方法检查）
3. 已完成 SDK 初始化
4. 对于自定义表盘，需要准备模板文件和资源文件

## 数据模型

### TSDialModel 表盘信息模型

| 属性 | 类型 | 说明 |
|------|------|------|
| `dialId` | `NSString *` | 表盘的唯一标识符 |
| `dialName` | `NSString *` | 表盘的显示名称 |
| `dialType` | `TSDialType` | 表盘类型（内置、自定义、云端） |
| `isCurrent` | `BOOL` | 是否为当前表盘 |
| `locationIndex` | `UInt8` | 表盘在设备上的位置索引 |
| `version` | `NSString *` | 表盘版本号 |
| `filePath` | `NSString *` | 表盘资源的本地文件路径 |

### TSCustomDial 自定义表盘模型

| 属性 | 类型 | 说明 |
|------|------|------|
| `dialId` | `NSString *` | 自定义表盘的唯一标识符 |
| `dialName` | `NSString *` | 自定义表盘的显示名称 |
| `dialType` | `TSCustomDialType` | 自定义表盘类型（单图片、多图片、视频） |
| `templateFilePath` | `NSString *` | 表盘模板 bin 文件的本地路径 |
| `previewImageItem` | `TSCustomDialItem *` | 表盘预览图片项 |
| `resourceItems` | `NSArray<TSCustomDialItem *> *` | 表盘资源项数组（必需） |

### TSCustomDialItem 表盘项模型

| 属性 | 类型 | 说明 |
|------|------|------|
| `dialType` | `TSCustomDialType` | 表盘项资源类型（图片或视频） |
| `videoLocalPath` | `NSString *` | 视频资源的本地路径（视频类型时使用） |
| `resourceImage` | `UIImage *` | 表盘背景图片对象（图片类型时使用） |
| `dialTime` | `TSCustomDialTime *` | 时间显示配置（必需） |

### TSCustomDialTime 时间配置模型

| 属性 | 类型 | 说明 |
|------|------|------|
| `timeImage` | `UIImage *` | 时间样式图片对象 |
| `timeImagePath` | `NSString *` | 时间样式图片的本地文件路径 |
| `timePosition` | `TSDialTimePosition` | 时间显示位置 |
| `timeRect` | `CGRect` | 时间显示区域矩形（优先于 timePosition） |
| `timeColor` | `UIColor *` | 时间显示颜色 |
| `style` | `TSDialTimeStyle` | 时间显示样式 |

## 枚举与常量

### TSDialType 表盘类型

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `eTSDialTypeBuiltIn` | 内置表盘（设备自带） |
| `1` | `eTSDialTypeCustomer` | 自定义表盘（用户创建） |
| `2` | `eTSDialTypeCloud` | 云端表盘（云服务器下载） |

### TSDialTimePosition 时间显示位置

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `eTSDialTimePositionTop` | 上方 |
| `1` | `eTSDialTimePositionBottom` | 下方 |
| `2` | `eTSDialTimePositionLeft` | 左方 |
| `3` | `eTSDialTimePositionRight` | 右方 |
| `4` | `eTSDialTimePositionTopLeft` | 左上 |
| `5` | `eTSDialTimePositionBottomLeft` | 左下 |
| `6` | `eTSDialTimePositionTopRight` | 右上 |
| `7` | `eTSDialTimePositionBottomRight` | 右下 |
| `8` | `eTSDialTimePositionCenter` | 中间 |

### TSDialPushResult 表盘推送结果

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `eTSDialPushResultStart` | 推送开始 |
| `0` | `eTSDialPushResultProgress` | 推送进行中 |
| `1` | `eTSDialPushResultSuccess` | 推送成功 |
| `2` | `eTSDialPushResultFailed` | 推送失败 |

### TSCustomDialType 自定义表盘类型

| 值 | 名称 | 说明 |
|----|------|------|
| `1` | `eTSCustomDialSingleImage` | 单图片自定义表盘 |
| `2` | `eTSCustomDialMultipleImage` | 多图片自定义表盘 |
| `3` | `eTSCustomDialVideo` | 视频自定义表盘 |

### TSDialTimeStyle 时间显示样式

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `eTSDialTimeStyleNone` | 无样式 |
| `1` | `eTSDialTimeStyle1` | 样式1 |
| `2` | `eTSDialTimeStyle2` | 样式2 |
| `3` | `eTSDialTimeStyle3` | 样式3 |
| `4` | `eTSDialTimeStyle4` | 样式4 |
| `5` | `eTSDialTimeStyle5` | 样式5 |
| `6` | `eTSDialTimeStyle6` | 样式6 |
| `7` | `eTSDialTimeStyle7` | 样式7 |

## 回调类型

| 回调类型 | 签名 | 说明 |
|---------|------|------|
| `TSDialCompletionBlock` | `void (^)(TSDialPushResult result, NSError *_Nullable error)` | 表盘操作完成回调，报告操作结果和错误信息 |
| `TSDialProgressBlock` | `void(^)(TSDialPushResult result, NSInteger progress)` | 表盘推送进度回调，报告当前推送进度（0-100） |
| `TSDialListBlock` | `void (^)(NSArray<TSDialModel *> *_Nullable dials, NSError *_Nullable error)` | 表盘列表回调，返回表盘模型数组 |
| `TSDialSpaceBlock` | `void (^)(NSInteger remainSpace, NSError *_Nullable error)` | 表盘空间信息回调，返回剩余存储空间 |
| `TSDialWidgetsBlock` | `void (^)(NSDictionary *_Nullable widgets, NSError *_Nullable error)` | 挂件列表回调，返回挂件信息字典 |

## 接口方法

### 获取当前表盘信息

```objc
- (void)fetchCurrentDial:(void (^)(TSDialModel *_Nullable dial,
                                   NSError *_Nullable error))completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void (^)(TSDialModel *_Nullable, NSError *_Nullable)` | 完成回调，返回当前表盘模型 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

[dialInterface fetchCurrentDial:^(TSDialModel *dial, NSError *error) {
    if (error) {
        TSLog(@"获取当前表盘失败: %@", error.localizedDescription);
        return;
    }
    
    if (dial) {
        TSLog(@"当前表盘: %@ (类型: %lu)", dial.dialName, (unsigned long)dial.dialType);
        TSLog(@"表盘ID: %@", dial.dialId);
    }
}];
```

### 获取所有表盘信息

```objc
- (void)fetchAllDials:(TSDialListBlock)completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSDialListBlock` | 完成回调，返回所有表盘模型数组 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

[dialInterface fetchAllDials:^(`NSArray<TSDialModel *>` *dials, NSError *error) {
    if (error) {
        TSLog(@"获取表盘列表失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"设备上共有 %lu 个表盘", (unsigned long)dials.count);
    for (TSDialModel *dial in dials) {
        NSString *typeStr = dial.dialType == eTSDialTypeBuiltIn ? @"内置" :
                           dial.dialType == eTSDialTypeCustomer ? @"自定义" : @"云端";
        NSString *current = dial.isCurrent ? @"(当前)" : @"";
        TSLog(@"表盘: %@ [%@] %@", dial.dialName, typeStr, current);
    }
}];
```

### 切换表盘

```objc
- (void)switchToDial:(`TSDialModel *`)dial
          completion:(nullable void(^)(BOOL isSuccess, NSError *_Nullable error))completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `dial` | `TSDialModel *` | 要切换的表盘模型 |
| `completion` | `void (^)(BOOL, NSError *_Nullable)` | 完成回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

// 假设已从 fetchAllDials 获得表盘列表
TSDialModel *targetDial = dials[0];

[dialInterface switchToDial:targetDial completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"成功切换表盘至: %@", targetDial.dialName);
    } else {
        TSLog(@"切换表盘失败: %@", error.localizedDescription);
    }
}];
```

### 生成自定义表盘ID

```objc
- (nonnull `NSString *`)generateCustomDialIdWithType:(TSCustomDialType)dialType;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `dialType` | `TSCustomDialType` | 自定义表盘类型 |

**返回值**

| 类型 | 说明 |
|------|------|
| `NSString *` | 生成的唯一表盘ID字符串 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

// 生成单图片自定义表盘ID
NSString *customDialId = [dialInterface generateCustomDialIdWithType:eTSCustomDialSingleImage];
TSLog(@"生成的自定义表盘ID: %@", customDialId);

// 生成视频自定义表盘ID
NSString *videoDialId = [dialInterface generateCustomDialIdWithType:eTSCustomDialVideo];
TSLog(@"生成的视频表盘ID: %@", videoDialId);
```

### 推送云端表盘到外设

```objc
- (void)installDownloadedCloudDial:(`TSDialModel *`)dial
                     progressBlock:(nullable TSDialProgressBlock)progressBlock
                        completion:(nullable TSDialCompletionBlock)completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `dial` | `TSDialModel *` | 云端表盘模型，dialType 应为 `eTSDialTypeCloud` |
| `progressBlock` | `TSDialProgressBlock` | 进度回调，报告推送进度（0-100） |
| `completion` | `TSDialCompletionBlock` | 完成回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

// 创建云端表盘模型
TSDialModel *cloudDial = [[TSDialModel alloc] init];
cloudDial.dialId = @"cloud_dial_001";
cloudDial.dialName = @"云端精美表盘";
cloudDial.dialType = eTSDialTypeCloud;
cloudDial.filePath = @"/path/to/downloaded/dial.bin"; // 本地缓存路径

[dialInterface installDownloadedCloudDial:cloudDial 
                            progressBlock:^(TSDialPushResult result, NSInteger progress) {
    TSLog(@"推送进度: %ld%%", (long)progress);
} completion:^(TSDialPushResult result, NSError *error) {
    if (result == eTSDialPushResultSuccess) {
        TSLog(@"云端表盘推送成功");
    } else if (result == eTSDialPushResultFailed) {
        TSLog(@"云端表盘推送失败: %@", error.localizedDescription);
    }
}];
```

### 推送自定义表盘到外设

```objc
- (void)installCustomDial:(`TSCustomDial *`)customDial
            progressBlock:(nullable TSDialProgressBlock)progressBlock
               completion:(nullable TSDialCompletionBlock)completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `customDial` | `TSCustomDial *` | 自定义表盘模型 |
| `progressBlock` | `TSDialProgressBlock` | 进度回调，报告推送进度（0-100） |
| `completion` | `TSDialCompletionBlock` | 完成回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

// 创建自定义表盘
TSCustomDial *customDial = [[TSCustomDial alloc] init];
customDial.dialId = [dialInterface generateCustomDialIdWithType:eTSCustomDialSingleImage];
customDial.dialName = @"我的自定义表盘";
customDial.dialType = eTSCustomDialSingleImage;
customDial.templateFilePath = @"/path/to/template.bin";

// 创建表盘项
TSCustomDialItem *item = [[TSCustomDialItem alloc] init];
item.dialType = eTSCustomDialSingleImage;
item.resourceImage = [UIImage imageNamed:@"dial_background"];

// 配置时间显示
item.dialTime = [[TSCustomDialTime alloc] init];
item.dialTime.timePosition = eTSDialTimePositionTop;
item.dialTime.timeImage = [UIImage imageNamed:@"time_style"];
item.dialTime.style = eTSDialTimeStyle1;

customDial.resourceItems = @[item];
customDial.previewImageItem = item;

// 推送自定义表盘
[dialInterface installCustomDial:customDial 
                   progressBlock:^(TSDialPushResult result, NSInteger progress) {
    TSLog(@"自定义表盘推送进度: %ld%%", (long)progress);
} completion:^(TSDialPushResult result, NSError *error) {
    if (result == eTSDialPushResultSuccess) {
        TSLog(@"自定义表盘推送成功");
    } else if (result == eTSDialPushResultFailed) {
        TSLog(@"自定义表盘推送失败: %@", error.localizedDescription);
    }
}];
```

### 删除表盘

```objc
- (void)deleteDial:(`TSDialModel *`)dial
        completion:(nullable void(^)(BOOL isSuccess, NSError *_Nullable error))completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `dial` | `TSDialModel *` | 要删除的表盘模型 |
| `completion` | `void (^)(BOOL, NSError *_Nullable)` | 完成回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

TSDialModel *dialToDelete = dials[2];

[dialInterface deleteDial:dialToDelete completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"成功删除表盘: %@", dialToDelete.dialName);
    } else {
        TSLog(@"删除表盘失败: %@", error.localizedDescription);
    }
}];
```

### 获取表盘剩余存储空间

```objc
- (void)fetchWatchFaceRemainingStorageSpace:(nullable TSDialSpaceBlock)completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSDialSpaceBlock` | 完成回调，返回剩余空间大小 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

[dialInterface fetchWatchFaceRemainingStorageSpace:^(NSInteger remainSpace, NSError *error) {
    if (error) {
        TSLog(@"获取剩余空间失败: %@", error.localizedDescription);
        return;
    }
    
    NSInteger remainMB = remainSpace / (1024 * 1024);
    TSLog(@"表盘剩余存储空间: %ld MB", (long)remainMB);
}];
```

### 注册表盘变化通知回调

```objc
- (void)registerDialDidChangedBlock:(void (^)(`NSArray<TSDialModel *>` *_Nullable allDials))completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void (^)(NSArray<TSDialModel *> *_Nullable)` | 表盘变化回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

[dialInterface registerDialDidChangedBlock:^(`NSArray<TSDialModel *>` *allDials) {
    if (allDials == nil) {
        TSLog(@"无法获取表盘信息或设备已断开连接");
        return;
    }
    
    TSLog(@"表盘发生变化，当前共有 %lu 个表盘", (unsigned long)allDials.count);
    for (TSDialModel *dial in allDials) {
        if (dial.isCurrent) {
            TSLog(@"当前表盘已切换为: %@", dial.dialName);
        }
    }
}];
```

### 取消正在进行的表盘推送操作

```objc
- (void)cancelPushDial:(TSCompletionBlock)completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSCompletionBlock` | 完成回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

[dialInterface cancelPushDial:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"成功取消表盘推送");
    } else {
        TSLog(@"取消表盘推送失败: %@", error.localizedDescription);
    }
}];
```

### 获取内置表盘的最大数量

```objc
- (NSInteger)maxInnerDialCount;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `NSInteger` | 设备支持的内置表盘最大数量 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

NSInteger maxCount = [dialInterface maxInnerDialCount];
TSLog(@"设备最多支持 %ld 个内置表盘", (long)maxCount);
```

### 获取支持的云端表盘最大数量

```objc
- (NSInteger)maxCanPushDialCount;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `NSInteger` | 设备可以存储的云端表盘最大数量 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

NSInteger maxPushCount = [dialInterface maxCanPushDialCount];
TSLog(@"设备最多支持推送 %ld 个表盘", (long)maxPushCount);
```

### 检查设备是否支持幻灯片表盘

```objc
- (BOOL)isSupportSlideshowDial;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `BOOL` | YES 表示支持幻灯片表盘，NO 表示不支持 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

if ([dialInterface isSupportSlideshowDial]) {
    TSLog(@"设备支持幻灯片表盘（相册表盘）");
} else {
    TSLog(@"设备不支持幻灯片表盘");
}
```

### 检查设备是否支持视频表盘

```objc
- (BOOL)isSupportVideoDial;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `BOOL` | YES 表示支持视频表盘，NO 表示不支持 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

if ([dialInterface isSupportVideoDial]) {
    TSLog(@"设备支持视频表盘");
} else {
    TSLog(@"设备不支持视频表盘");
}
```

### 检查设备是否支持表盘组件

```objc
- (BOOL)isSupportDialComponent;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `BOOL` | YES 表示支持表盘组件，NO 表示不支持 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

if ([dialInterface isSupportDialComponent]) {
    TSLog(@"设备支持表盘组件");
} else {
    TSLog(@"设备不支持表盘组件");
}
```

### 获取视频表盘的最大视频时长

```objc
- (NSInteger)maxVideoDialDuration;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `NSInteger` | 最大视频时长（秒），不支持时返回 0 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

NSInteger maxDuration = [dialInterface maxVideoDialDuration];
if (maxDuration > 0) {
    TSLog(@"设备支持最长 %ld 秒的视频表盘", (long)maxDuration);
} else {
    TSLog(@"设备不支持视频表盘");
}
```

### 获取外设所支持的挂件列表

```objc
- (void)requestSupportWidgetsFromPeripheralCompletion:(TSDialWidgetsBlock)completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSDialWidgetsBlock` | 完成回调，返回挂件信息字典 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

[dialInterface requestSupportWidgetsFromPeripheralCompletion:^(NSDictionary *widgets, NSError *error) {
    if (error) {
        TSLog(@"获取挂件列表失败: %@", error.localizedDescription);
        return;
    }
    
    if (widgets == nil) {
        TSLog(@"设备不支持挂件或不是Fw系列设备");
        return;
    }
    
    TSLog(@"获取挂件列表成功: %@", widgets);
}];
```

### 生成表盘预览图（方法1：使用图片和位置）

```objc
- (void)previewImageWith:(`UIImage *`)originImage 
                timeImage:(`UIImage *`)timeImage 
            timePosition:(TSDialTimePosition)timePosition 
              maxKBSize:(CGFloat)maxKBSize 
             completion:(void (^)(UIImage *_Nullable previewImage, `NSError *` _Nullable error))completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `originImage` | `UIImage *` | 背景图片 |
| `timeImage` | `UIImage *` | 时间显示图片 |
| `timePosition` | `TSDialTimePosition` | 时间图片位置 |
| `maxKBSize` | `CGFloat` | 最大文件大小（KB） |
| `completion` | `void (^)(UIImage *_Nullable, NSError *_Nullable)` | 完成回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

UIImage *bgImage = [UIImage imageNamed:@"dial_background"];
UIImage *timeImg = [UIImage imageNamed:@"time_display"];

[dialInterface previewImageWith:bgImage 
                      timeImage:timeImg 
                   timePosition:eTSDialTimePositionTop 
                     maxKBSize:300.0 
                    completion:^(UIImage *previewImage, NSError *error) {
    if (error) {
        TSLog(@"预览图生成失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"预览图生成成功: %@", previewImage);
    // 使用预览图显示或保存
}];
```

### 生成表盘预览图（方法2：使用自定义表盘项）

```objc
- (void)previewImageWithDialItem:(`TSCustomDialItem *`)dialItem 
                      maxKBSize:(CGFloat)maxKBSize 
                     completion:(void (^)(`UIImage *` _Nullable, `NSError *` _Nullable))completion;
```

**参数说明**

| 参数 | 类型 | 说明 |
|------|------|------|
| `dialItem` | `TSCustomDialItem *` | 包含背景图、时间图、位置配置的自定义表盘项 |
| `maxKBSize` | `CGFloat` | 最大文件大小（KB），推荐 100-500 |
| `completion` | `void (^)(UIImage *_Nullable, NSError *_Nullable)` | 完成回调 |

**代码示例**

```objc
id<TSPeripheralDialInterface> dialInterface = [TopStepComKit sharedInstance].dial;

// 创建自定义表盘项
TSCustomDialItem *dialItem = [[TSCustomDialItem alloc] init];
dialItem.dialType = eTSCustomDialSingleImage;
dialItem.resourceImage = [UIImage imageNamed:@"dial_background"];

// 配置时间显示
dialItem.dialTime = [[TSCustomDialTime alloc] init];
dialItem.dialTime.timePosition = eTSDialTimePositionCenter;
dialItem.dialTime.timeImage = [UIImage imageNamed:@"time_style"];
dialItem.dialTime.style = eTSDialTimeStyle1;

// 方法1：使用默认位置
[dialInterface previewImageWithDialItem:dialItem 
                             maxKBSize:300.0 
                            completion:^(UIImage *previewImage, NSError *error) {
    if (!error) {
        TSLog(@"预览图生成成功");
    }
}];

// 方法2：使用自定义矩形区域
dialItem.dialTime.timeRect = CGRectM
