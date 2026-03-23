---
sidebar_position: 2
title: 快速开始
---

# 快速开始

5 步完成 SDK 接入，从安装到读取心率数据。

## 第 1 步：安装 SDK

在 `Podfile` 中添加：

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'TopStepComKit'
  pod 'TopStepFitKit'   # 按实际设备平台选择
end
```

执行：

```bash
pod install
```

在 `Info.plist` 添加蓝牙权限：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限以连接智能穿戴设备</string>
```

## 第 2 步：初始化 SDK

在 `AppDelegate.m` 中：

```objectivec
#import <TopStepComKit/TopStepComKit.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    TSKitConfigOptions *options = [TSKitConfigOptions configOptionWithSDKType:eTSSDKTypeFIT
                                                                      license:@"YOUR_32_CHAR_LICENSE"];
    options.isDevelopModel = YES; // 开发期间开启，上线前关闭

    id<TSComKitInterface> comKit = [objc_getClass("TSComKit") sharedInstance];
    [comKit initSDKWithConfigOptions:options completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            TSLog(@"SDK 初始化成功");
        }
    }];

    return YES;
}
```

## 第 3 步：搜索设备

```objectivec
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

[bleConnect startSearchPeripheral:30
               discoverPeripheral:^(TSPeripheral *peripheral) {
    TSLog(@"发现设备: %@", peripheral.systemInfo.bleName);
    [self.deviceList addObject:peripheral];
    [self.tableView reloadData];
} completion:^(TSScanCompletionReason reason, NSError *error) {
    TSLog(@"搜索结束，发现 %lu 台设备", (unsigned long)self.deviceList.count);
}];
```

## 第 4 步：连接设备

```objectivec
// 用户选择设备后停止扫描并连接
[bleConnect stopSearchPeripheral];

TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:@"YOUR_USER_ID"];
param.authCode = @"qr_code_scanned_from_device"; // 首次绑定需要扫描设备二维码

[bleConnect connectWithPeripheral:selectedDevice
                            param:param
                       completion:^(TSBleConnectionState state, NSError *error) {
    if (state == eTSBleStateConnected) {
        TSLog(@"设备连接成功！");
        [self onDeviceConnected];
    } else if (error) {
        TSLog(@"连接失败: %@", error.localizedDescription);
    }
}];
```

## 第 5 步：读取健康数据

```objectivec
id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

// 检查设备是否支持
if (![heartRate isSupport]) return;

// 主动测量实时心率
[heartRate startMeasureWithParam:nil
                    startHandler:^(BOOL isSuccess, NSError *error) {
    TSLog(@"开始测量: %@", isSuccess ? @"成功" : error.localizedDescription);
} dataHandler:^(TSHRValueItem *data, NSError *error) {
    TSLog(@"当前心率: %ld bpm", (long)data.value);
} endHandler:^(BOOL isSuccess, NSError *error) {
    TSLog(@"测量结束");
}];
```

---

## 下一步

- [安装与接入](./guide/installation) — 详细配置 CocoaPods 和权限
- [SDK 初始化](./guide/initialization) — 所有配置参数说明
- [蓝牙连接流程](./guide/ble-connect-flow) — 完整连接状态机
- [蓝牙连接 API](./api/ble-connect) — 接口参考文档
- [心率 API](./api/health/heart-rate) — 健康数据接口
