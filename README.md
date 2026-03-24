# TopStepComKit

TopStepComKit 是 TopStep 智能穿戴设备的 iOS SDK，为 App 与手表设备之间提供完整的通信和数据管理能力。统一接口层覆盖蓝牙连接、健康数据、设备控制全场景，屏蔽底层多平台差异，开发者只需对接一套 API。

**[📖 完整文档](https://topstepcomkit-docs.vercel.app/)**

---

## 功能模块

| 模块 | 功能 |
|------|------|
| 蓝牙连接 | 设备搜索、配对、绑定、解绑，5 阶段状态机管理 |
| 健康数据 | 心率、血氧、血压、压力、体温、心电、睡眠、运动监测 |
| 数据同步 | 按时间范围批量获取历史健康数据 |
| 设备管理 | 电量状态、设备定位、屏幕锁定、固件 OTA 升级 |
| 表盘管理 | 推送内置、自定义及云端表盘 |
| 通讯功能 | 消息提醒、联系人、闹钟管理 |
| 系统设置 | 用户信息、单位、语言、时间、天气配置 |
| 扩展功能 | 音乐控制、相机快拍、女性健康、AI 聊天 |

---

## 环境要求

- iOS 12.0+
- Xcode 13.0+
- CocoaPods 1.10.0+

---

## 安装

在 Podfile 中添加：

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'

# 基础模块（必需）
pod 'TopStepComKit-Git/Foundation'

# 通信模块（必需）
pod 'TopStepComKit-Git/ComKit'

# 设备实现模块（按需选择）
pod 'TopStepComKit-Git/FitCoreImp'   # Fit 系列设备
# pod 'TopStepComKit-Git/FwCoreImp'  # 仅支持 arm64 真机
```

然后执行：

```bash
pod install
```

### Info.plist 权限配置

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限以连接智能穿戴设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要蓝牙权限以连接智能穿戴设备</string>
```

---

## 快速开始

### 1. 初始化 SDK

在 `AppDelegate.m` 中完成初始化：

```objc
#import <TopStepComKit/TopStepComKit.h>

TSKitConfigOptions *configs = [TSKitConfigOptions configOptionWithSDKType:TSSDKTypeFIT
                                                                  license:@"your_license_key"];
configs.isDebugMode = YES; // 发布时改为 NO

__weak typeof(self) weakSelf = self;
[[TopStepComKit sharedInstance] initSDKWithConfigOptions:configs
                                             completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        [[[TopStepComKit sharedInstance] log] quickConfigureWithSaveEnabled:YES completion:nil];
        [weakSelf autoConnect];
    }
}];
```

### 2. 扫描设备

```objc
[[[TopStepComKit sharedInstance] bleConnector]
    startSearchPeripheral:^(TSPeripheral *peripheral) {
        if (peripheral.systemInfo.mac.length > 0) {
            // 更新设备列表
        }
    }
    errorHandler:^(TSBleConnectionError errorCode) {
        // 处理扫描错误
    }];
```

### 3. 连接设备

```objc
TSConnectOptions *options = [[TSConnectOptions alloc] init];
options.userID   = @"user_id";
options.authCode = @"qr_auth_code"; // 扫描设备二维码获取

[[[TopStepComKit sharedInstance] bleConnector]
    connectWithPeripheral:peripheral
                  options:options
               completion:^(BOOL isSuccess, TSPeripheral *device, NSError *error) {
        if (isSuccess) {
            // 连接成功
        }
    }];
```

### 4. 读取健康数据

```objc
id<TSHeartRateInterface> hrInterface = [[TopStepComKit sharedInstance] heartRate];

if ([hrInterface isFuncSupported]) {
    [hrInterface getLatestHeartRateWithCompletion:^(TSHeartRateModel *model, NSError *error) {
        if (model) {
            NSLog(@"Heart rate: %ld bpm", (long)model.value);
        }
    }];
}
```

---

## 架构说明

```
┌─────────────────────────────────────┐
│           TopStepComKit             │  ← 统一入口，仅需一次 import
├─────────────────────────────────────┤
│        TopStepInterfaceKit          │  ← 协议、数据模型、枚举定义
├──────────┬──────────────────────────┤
│ FitKit   │  FwKit / SJKit / CRPKit  │  ← 各平台具体实现
├─────────────────────────────────────┤
│              BleMetaKit             │  ← BLE 指令封装与通信协议
├─────────────────────────────────────┤
│               ToolKit               │  ← 日志、数据库、加密工具
└─────────────────────────────────────┘
```

---

## 模块说明

| 模块 | 组件 | 说明 |
|------|------|------|
| Foundation | TopStepInterfaceKit.xcframework<br>TopStepToolKit.xcframework | 接口定义与基础工具，所有模块必需 |
| ComKit | TopStepComKit.xcframework | 设备通信核心，依赖 Foundation |
| FitCoreImp | TopStepFitKit.xcframework | Fit 系列设备实现，依赖 Foundation + ComKit |
| FwCoreImp | — | 仅支持 arm64 真机，依赖 Foundation + ComKit |

> **注意**：FwCoreImp 不支持模拟器（x86_64/arm64-simulator）。lint 和发布时需跳过模拟器校验：
> ```sh
> pod lib lint TopStepComKit-Git.podspec --skip-import-validation --allow-warnings
> pod trunk push TopStepComKit-Git.podspec --skip-import-validation --allow-warnings
> ```

---

## 文档

| 资源 | 链接 |
|------|------|
| 完整文档 | https://topstepcomkit-docs.vercel.app/ |
| 快速开始 | https://topstepcomkit-docs.vercel.app/docs/quick-start |
| API 参考 | https://topstepcomkit-docs.vercel.app/docs/api/ble-connect |
| 架构说明 | https://topstepcomkit-docs.vercel.app/docs/architecture |
| 更新日志 | https://topstepcomkit-docs.vercel.app/docs/changelog |

---

## 版本历史

### 1.0.0
- 首次发布
- 支持蓝牙连接、健康数据、数据同步等核心功能
- 提供模块化集成方案，适配 Fit 系列设备

---

## 许可证

TopStepComKit-Git 使用 MIT 许可证，详情请查看 [LICENSE](LICENSE) 文件。
