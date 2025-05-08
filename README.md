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
source 'https://github.com/CocoaPods/Specs.git' 

# 基础模块（必需）
pod 'TopStepComKit-Git/Foundation'

# 通信模块
pod 'TopStepComKit-Git/ComKit'

# 设备实现模块
pod 'TopStepComKit-Git/FitCoreImp'

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

### FwCoreImp 模块（未来支持）
将提供其他设备的实现。
- TopStepFwKit.xcframework：提供其他设备实现

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
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'TopStepComKit-Git/Foundation'
  pod 'TopStepComKit-Git/ComKit'
  pod 'TopStepComKit-Git/FitCoreImp'
  ```

如需进一步细化依赖版本或有其他疑问，欢迎随时告诉我！
