# TopStepComKit-Git

TopStepComKit-Git 是一个模块化的 iOS SDK，提供了一系列用于智能设备通信和数据处理的功能。

## 功能特点

- 模块化设计，支持按需集成
- 支持多种设备通信协议
- 提供完整的设备管理功能
- 支持数据同步和处理

## 安装要求

- iOS 12.0+
- Xcode 12.0+
- CocoaPods 1.10.0+

## 安装方法

在您的 Podfile 中添加以下内容：

```ruby
source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'

# 基础模块（必需）
pod 'TopStepComKit-Git/Foundation'

# 通信模块
pod 'TopStepComKit-Git/ComKit'

# 设备实现模块
pod 'TopStepComKit-Git/FitCoreImp'

# 支持框架模块（可选，仅在项目中没有 ABParTool、RTKLEFoundation、RTKOTASDK、RTKLocalPlaybackSDK 时使用）
# pod 'TopStepComKit-Git/FitCoreImpSupport'

# 其他设备支持（按需添加）
# pod 'TopStepComKit-Git/FwCoreImp'  # 未来支持
```

然后运行：
```bash
pod install
```

## 模块说明

### Foundation 模块
包含基础工具和接口定义，是其他模块的基础依赖。
- TopStepInterfaceKit.xcframework：提供所有接口定义
- TopStepToolKit.xcframework：提供基础工具类

### ComKit 模块
提供设备通信的核心功能。
- TopStepComKit.xcframework：提供设备通信接口

### FitCoreImp 模块
提供具体设备的实现。
- TopStepFitKit.xcframework：提供设备具体实现
- FitCloudKit.xcframework：FitCloud 核心功能
- FitCloudDFUKit.xcframework：设备固件升级功能
- FitCloudNWFKit.xcframework：NWF 相关功能
- FitCloudWFKit.xcframework：WF 相关功能

### FitCoreImpSupport 模块（可选）
包含可能与其他项目冲突的支持框架。**仅在您的项目中没有这些框架时使用**。

包含的框架：
- ABParTool.xcframework：图像转换工具（PAR格式）
- RTKLEFoundation.xcframework：RTK 蓝牙低功耗基础库
- RTKOTASDK.xcframework：RTK OTA 升级 SDK
- RTKLocalPlaybackSDK.xcframework：RTK 本地播放 SDK

> ⚠️ **重要提示**：如果您的项目已经手动集成了上述任意框架，请**不要**使用此子模块，以避免框架冲突。

### FwCoreImp 模块（仅支持真机 arm64）
FwCoreImp 只支持 arm64 架构（真机），不支持模拟器（x86_64/arm64-simulator）。
如需集成此模块，请务必在真机环境下开发和调试。

> ⚠️ lint 和发布时请使用如下命令跳过模拟器校验：
> 
> ```sh
> pod lib lint TopStepComKit-Git.podspec --skip-import-validation --allow-warnings --verbose
> pod trunk push TopStepComKit-Git.podspec --skip-import-validation --allow-warnings --verbose
> ```

## 使用示例

```objc
// 初始化 SDK
TSKitConfigOptions *configs = [TSKitConfigOptions configOptionWithSDKType:eTSSDKTypeFit license:@"abcdef1234567890abcdef1234567890"] ;
__weak typeof(self)weakSelf = self;
[[TopStepComKit sharedInstance] initSDKWithConfigOptions:configs completion:^(BOOL isSuccess, NSError * _Nullable error) {
    __strong typeof(weakSelf)strongSelf = weakSelf;
    // success
    if (isSuccess) {
        [[[TopStepComKit sharedInstance] log] quickConfigureWithSaveEnabled:YES completion:^(BOOL successed) {}];
        [strongSelf autoConnect];
    }
}];


// 扫描设备
__weak typeof(self)weakSelf = self;
[[[TopStepComKit sharedInstance] bleConnector] startSearchPeripheral:^(TSPeripheral * _Nonnull peripheral) {
    __strong typeof(weakSelf)strongSelf = weakSelf;
    if (peripheral) {
        if (peripheral.systemInfo.mac && peripheral.systemInfo.mac.length>0) {
            [strongSelf.periperalDict setObject:peripheral forKey:peripheral.systemInfo.mac];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.sourceArray = [strongSelf.periperalDict allValues];
            [strongSelf.sourceTableview reloadData];
        });
        }
} errorHandler:^(TSBleConnectionError errorCode) {
    NSLog(@"error : %lu",(unsigned long)errorCode);
}];

```

## 注意事项

1. Foundation 模块是必需的，其他模块可以根据需要选择使用
2. 使用 ComKit 模块时必须同时使用 Foundation 模块
3. 使用 FitCoreImp 或 FwCoreImp 模块时必须同时使用 Foundation 和 ComKit 模块
4. **框架冲突处理**：如果您的项目已经手动集成了 `ABParTool`、`RTKLEFoundation`、`RTKOTASDK` 或 `RTKLocalPlaybackSDK`，请**不要**使用 `FitCoreImpSupport` 子模块，以避免框架重复链接冲突

## 版本历史

- 1.0.0
  - 首次发布
  - 支持基础设备通信功能
  - 提供模块化集成方案

## 许可证

TopStepComKit-Git 使用 MIT 许可证，详情请查看 LICENSE 文件。

## 建议

- 建议用户加上 source，例如：

  ```ruby
  source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
  pod 'TopStepComKit-Git/Foundation'
  pod 'TopStepComKit-Git/ComKit'
  pod 'TopStepComKit-Git/FitCoreImp'
  
  # 如果项目中没有 ABParTool、RTKLEFoundation、RTKOTASDK、RTKLocalPlaybackSDK，可以添加：
  # pod 'TopStepComKit-Git/FitCoreImpSupport'
  ```

如需进一步细化依赖版本或有其他疑问，欢迎随时告诉我！
