---
sidebar_position: 2
title: SDK 初始化
---

# SDK 初始化

SDK 初始化是使用所有功能的前提。本文介绍如何配置 `TSKitConfigOptions` 并完成 SDK 的初始化。

## 初始化时机

在 `AppDelegate` 的 `application:didFinishLaunchingWithOptions:` 方法中进行初始化，确保在调用任何其他 SDK 方法之前完成。

## 基本初始化

```objectivec
#import <TopStepComKit/TopStepComKit.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 创建配置项（指定设备平台和 License）
    TSKitConfigOptions *options = [TSKitConfigOptions configOptionWithSDKType:eTSSDKTypeFIT
                                                                      license:@"YOUR_32_CHAR_LICENSE_KEY"];

    // 初始化 SDK
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:options completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"SDK 初始化成功");
        } else {
            TSLog(@"SDK 初始化失败: %@", error.localizedDescription);
        }
    }];

    return YES;
}
```

## 配置参数说明（TSKitConfigOptions）

### 必填参数

| 属性 | 类型 | 说明 |
|------|------|------|
| `sdkType` | `TSSDKType` | 设备平台类型，必须与实际硬件匹配 |
| `license` | `NSString *` | 32 位许可证密钥，由 TopStep 提供 |

### SDK 类型（TSSDKType）

| 枚举值 | 说明 |
|--------|------|
| `eTSSDKTypeFIT` | 瑞昱（Realtek）系列设备（默认值） |
| `eTSSDKTypeFW` | 恒玄（BES）系列设备 |
| `eTSSDKTypeSJ` | 伸聚系列设备 |
| `eTSSDKTypeCRP` | 魔样（CRP）系列设备 |
| `eTSSDKTypeUTE` | 优创意（UTE）系列设备 |
| `eTSSDKTypeTPB` | 拓步（TPB）系列设备 |

### 可选参数

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `isDevelopModel` | `BOOL` | `NO` | 开发模式，启用后输出详细日志（生产环境关闭） |
| `isSaveLogEnable` | `BOOL` | `NO` | 是否将日志写入文件系统 |
| `logFilePath` | `NSString *` | `nil` | 自定义日志文件路径，nil 使用默认路径 |
| `logLevel` | `TopStepLogLevel` | `Debug` | 最低输出日志等级（Debug / Info / Warning / Error） |
| `isCheckBluetoothAuthority` | `BOOL` | `NO` | 操作前检查蓝牙权限，推荐生产环境开启 |
| `maxScanSearchDuration` | `NSInteger` | `15` | 最大扫描时长（秒），0 使用默认值 |
| `maxConnectTimeout` | `NSInteger` | `45` | 最大连接超时（秒），0 使用默认值 |
| `maxTryConnectCount` | `NSInteger` | `10` | 断线后最大重连次数 |
| `autoConnectWhenAppLaunch` | `BOOL` | `NO` | 应用启动时自动重连上次设备 |

## 完整配置示例

```objectivec
TSKitConfigOptions *options = [[TSKitConfigOptions alloc] init];
options.sdkType   = eTSSDKTypeFIT;
options.license   = @"abcd1234efgh5678ijkl9012mnop3456"; // 32位

// 日志配置（开发期间）
options.isDevelopModel  = YES;
options.isSaveLogEnable = YES;
options.logLevel        = TopStepLogLevelDebug;

// 连接配置
options.isCheckBluetoothAuthority = YES;
options.maxScanSearchDuration     = 30;
options.maxConnectTimeout         = 60;
options.maxTryConnectCount        = 5;
options.autoConnectWhenAppLaunch  = YES;

[[TopStepComKit sharedInstance] initSDKWithConfigOptions:options completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"SDK 初始化成功，开始扫描设备...");
        // 可以在此处触发自动重连或跳转到主界面
    } else {
        TSLog(@"SDK 初始化失败: %@", error.localizedDescription);
        // 常见原因：license 格式错误（需要 32 位）或网络验证失败
    }
}];
```

## 功能模块实例获取

SDK 初始化成功后，通过 `[TopStepComKit sharedInstance]` 直接访问各功能模块属性：

```objectivec
// 蓝牙连接
id<TSBleConnectInterface> bleConnector = [TopStepComKit sharedInstance].bleConnector;

// 设备查找
id<TSPeripheralFindInterface> peripheralFind = [TopStepComKit sharedInstance].peripheralFind;

// 心率
id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

// 数据同步
id<TSDataSyncInterface> dataSync = [TopStepComKit sharedInstance].dataSync;

// 血氧
id<TSBloodOxygenInterface> bloodOxygen = [TopStepComKit sharedInstance].bloodOxygen;

// 血压
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

// 睡眠
id<TSSleepInterface> sleep = [TopStepComKit sharedInstance].sleep;

// 表盘
id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
```

其余模块同理，完整属性列表见 `TopStepComKit.h`。

:::tip 推荐做法
`[TopStepComKit sharedInstance]` 本身即为单例，可在任意位置直接调用，无需额外保存引用。
:::

## 注意事项

1. `initSDKWithConfigOptions:completion:` 必须在主线程调用
2. `license` 长度必须恰好为 32 位，且只含字母和数字
3. 初始化完成回调在主线程执行
4. 生产环境请将 `isDevelopModel` 设为 `NO`，避免性能损耗
5. 如果支持多种设备平台，需要分别初始化对应平台的 SDK 实例
