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

### 方式一：使用正式版本（推荐）

在您的 Podfile 中添加以下内容：

```ruby
source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'

# 基础模块（必需）
pod 'TopStepComKit-Git/Foundation'

# 通信模块
pod 'TopStepComKit-Git/ComKit'

# 设备实现模块
pod 'TopStepComKit-Git/FitCoreImp'

# 其他设备支持（按需添加）
# pod 'TopStepComKit-Git/FwCoreImp'
```

### 方式二：使用开发分支（需要使用 FitCoreImpSupport 时）

如果您需要使用 `FitCoreImpSupport` 模块，请在 Podfile 中指定 `develop_fit_separate` 分支：

```ruby
source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'

# 基础模块（必需）
pod 'TopStepComKit-Git/Foundation', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'

# 通信模块
pod 'TopStepComKit-Git/ComKit', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'

# 设备实现模块
pod 'TopStepComKit-Git/FitCoreImp', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'

# 支持框架模块（可选，仅在项目中没有 ABParTool、RTKLEFoundation、RTKOTASDK、RTKLocalPlaybackSDK 时使用）
# 注意：此模块仅在 develop_fit_separate 分支可用
pod 'TopStepComKit-Git/FitCoreImpSupport', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'

# 其他设备支持（按需添加）
# pod 'TopStepComKit-Git/FwCoreImp', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'
```

### 方式三：使用本地路径（开发调试时）

如果您在本地开发，可以使用本地路径：

```ruby
# 基础模块（必需）
pod 'TopStepComKit-Git/Foundation', :path => '/path/to/TopStepComKit-github'

# 通信模块
pod 'TopStepComKit-Git/ComKit', :path => '/path/to/TopStepComKit-github'

# 设备实现模块
pod 'TopStepComKit-Git/FitCoreImp', :path => '/path/to/TopStepComKit-github'

# 支持框架模块（可选）
pod 'TopStepComKit-Git/FitCoreImpSupport', :path => '/path/to/TopStepComKit-github'
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

> ⚠️ **重要提示**：
> 1. 如果您的项目已经手动集成了上述任意框架，请**不要**使用此子模块，以避免框架冲突。
> 2. **分支要求**：`FitCoreImpSupport` 模块目前仅在 `develop_fit_separate` 分支可用。如需使用此模块，请在 Podfile 中指定分支：
>    ```ruby
>    pod 'TopStepComKit-Git/FitCoreImpSupport', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'
>    ```
>    或者使用本地路径（开发时）：
>    ```ruby
>    pod 'TopStepComKit-Git/FitCoreImpSupport', :path => '/path/to/TopStepComKit-github'
>    ```

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
TSKitConfigOptions *configs = [TSKitConfigOptions configOptionWithSDKType:eTSSDKTypeFIT license:@"abcdef1234567890abcdef1234567890"] ;
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
5. **手动引入 Framework 的依赖要求**：
   - 如果您手动引入 `RTKLEFoundation.xcframework`、`RTKOTASDK.xcframework` 或 `RTKLocalPlaybackSDK.xcframework`，**必须同时手动引入 `ABParTool.xcframework`**
   - `FitCoreImp` 模块中的 `TopStepFitKit.xcframework` 和 `FitCloudWFKit.xcframework` 依赖 `ABParTool.framework`
   - 所有手动引入的 framework 都需要正确配置 **"Embed Frameworks"** 阶段，确保 framework 被复制到 app bundle 中
6. **分支版本说明**：
   - `FitCoreImpSupport` 模块目前仅在 `develop_fit_separate` 分支可用
   - 如果使用正式版本（tag），将无法使用 `FitCoreImpSupport` 模块
   - 如需使用 `FitCoreImpSupport`，请参考"安装方法"中的"方式二"指定分支
   - 建议等待该功能合并到 main 分支并发布新版本后再使用正式版本

## 版本历史

- 1.0.0
  - 首次发布
  - 支持基础设备通信功能
  - 提供模块化集成方案

## 许可证

TopStepComKit-Git 使用 MIT 许可证，详情请查看 LICENSE 文件。

## 使用建议

### 标准使用（推荐）

```ruby
source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
pod 'TopStepComKit-Git/Foundation'
pod 'TopStepComKit-Git/ComKit'
pod 'TopStepComKit-Git/FitCoreImp'
```

### 需要使用 FitCoreImpSupport 时

```ruby
source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'

# 所有模块都需要指定 develop_fit_separate 分支
pod 'TopStepComKit-Git/Foundation', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'
pod 'TopStepComKit-Git/ComKit', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'
pod 'TopStepComKit-Git/FitCoreImp', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'

# 如果项目中没有 ABParTool、RTKLEFoundation、RTKOTASDK、RTKLocalPlaybackSDK，可以添加：
pod 'TopStepComKit-Git/FitCoreImpSupport', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'
```

> 💡 **提示**：建议等待 `FitCoreImpSupport` 功能合并到 main 分支并发布新版本后，再使用正式版本（tag）方式集成。

## 故障排除

### 问题：运行时提示 "Library not loaded: @rpath/ABParTool.framework/ABParTool"

**原因**：`FitCoreImp` 模块中的某些 framework（如 `TopStepFitKit.xcframework`、`FitCloudWFKit.xcframework`）依赖 `ABParTool.framework`，但该 framework 没有被正确引入或嵌入。

**解决方案**：

#### 方案一：使用 FitCoreImpSupport 模块（推荐）

如果您不想手动管理这些 framework，可以使用 `FitCoreImpSupport` 模块：

```ruby
pod 'TopStepComKit-Git/FitCoreImpSupport', :git => 'https://github.com/htangsmart/TopStepComKit.git', :branch => 'develop_fit_separate'
```

#### 方案二：手动引入并正确配置 Framework

如果您已经手动引入了 `RTKLEFoundation.xcframework` 等，需要：

1. **手动引入 `ABParTool.xcframework`**：
   - 从 `TopStepComKit-Git/Classes/FitCoreImp/` 目录中找到 `ABParTool.xcframework`
   - 将其拖入 Xcode 项目

2. **配置 Framework 嵌入**：
   - 在 Xcode 中选择项目 Target
   - 进入 **"Build Phases"** 标签
   - 展开 **"Link Binary With Libraries"**，确保所有 framework 都已添加
   - 展开 **"Embed Frameworks"**（如果没有，点击左上角 "+" 添加）
   - 将所有手动引入的 framework（包括 `ABParTool.xcframework`、`RTKLEFoundation.xcframework` 等）添加到 **"Embed Frameworks"** 中
   - 确保 **"Code Sign On Copy"** 选项已勾选

3. **验证 Framework 路径**：
   - 在 **"Build Settings"** 中搜索 **"Framework Search Paths"**
   - 确保包含所有 framework 所在的目录路径

**需要手动引入的 Framework 列表**（如果使用手动方式）：
- `ABParTool.xcframework`（必需，FitCoreImp 的依赖）
- `RTKLEFoundation.xcframework`（如果使用）
- `RTKOTASDK.xcframework`（如果使用）
- `RTKLocalPlaybackSDK.xcframework`（如果使用）

如需进一步细化依赖版本或有其他疑问，欢迎随时告诉我！
