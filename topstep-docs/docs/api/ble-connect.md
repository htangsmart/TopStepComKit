---
sidebar_position: 1
title: 蓝牙连接（TSBleConnect）
---

# 蓝牙连接（TSBleConnect）

TSBleConnect 模块提供了完整的蓝牙设备连接管理功能，包括设备搜索、连接、绑定、认证和数据同步等操作。所有回调均在主线程执行，确保 UI 操作的线程安全性。

## 前提条件

1. 在应用 Info.plist 中配置蓝牙权限：
   - `NSBluetoothPeripheralUsageDescription` - 蓝牙访问权限说明
   - `NSBluetoothAlwaysAndWhenInUseUsageDescription` - 始终使用蓝牙权限说明（iOS 13+）

2. 确保设备蓝牙已启用且处于可用状态

3. 导入必要的头文件：
   ```objc
   #import <TopStepComKit/TSBleConnect.h>
   ```

## 数据模型

### TSBluetoothInfo

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `macAddress` | `NSString *` | 蓝牙MAC地址（冒号分隔格式，如 "DE:82:47:15:28:B0"），在某些平台可能为 nil |
| `name` | `NSString *` | 蓝牙名称 |
| `status` | `TSBleStatus` | 蓝牙适配器连接状态（0=未连接，1=已连接，2=已就绪） |

### TSBluetoothSystem

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `bleInfo` | `TSBluetoothInfo *` | BLE（低功耗蓝牙）信息 |
| `btInfo` | `TSBluetoothInfo *` | BT（经典蓝牙）信息 |

### TSPeripheralSystem

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `peripheral` | `CBPeripheral *` | 蓝牙外设对象 |
| `central` | `CBCentralManager *` | 蓝牙中心管理器 |
| `uuid` | `NSString *` | 外设UUID字符串（只读） |
| `mac` | `NSString *` | 设备MAC地址（冒号分隔标准格式） |
| `bleName` | `NSString *` | 设备蓝牙名称 |
| `RSSI` | `NSNumber *` | 蓝牙信号强度（RSSI值） |
| `advertisementData` | `NSDictionary *` | 广播数据字典 |

### TSPeripheralScreen

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `shape` | `TSPeriphShape` | 设备形状（圆形、正方形、矩形等） |
| `screenSize` | `CGSize` | 屏幕尺寸（像素） |
| `screenBorderRadius` | `CGFloat` | 屏幕圆角半径（像素） |
| `dialPreviewSize` | `CGSize` | 表盘预览图尺寸（像素） |
| `dialPreviewBorderRadius` | `CGFloat` | 表盘预览图圆角半径（像素） |
| `videoPreviewSize` | `CGSize` | 视频预览流尺寸（像素） |
| `videoPreviewBorderRadius` | `CGFloat` | 视频预览流圆角半径（像素） |

### TSPeripheralProject

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `projectId` | `NSString *` | 项目标识符 |
| `companyId` | `NSString *` | 公司标识符 |
| `brand` | `NSString *` | 设备品牌 |
| `model` | `NSString *` | 设备型号 |
| `firmVersion` | `NSString *` | 固件版本号 |
| `virtualVersion` | `NSString *` | 虚拟版本号 |
| `serialNumber` | `NSString *` | 设备序列号 |
| `mainProjNum` | `NSString *` | 主项目号 |
| `subProjNum` | `NSString *` | 子项目号 |

### TSPeripheral

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `systemInfo` | `TSPeripheralSystem *` | 系统相关信息 |
| `screenInfo` | `TSPeripheralScreen *` | 屏幕相关信息 |
| `projectInfo` | `TSPeripheralProject *` | 项目相关信息 |
| `capability` | `TSPeripheralCapability *` | 设备能力信息 |
| `limitation` | `TSPeripheralLimitations *` | 设备功能限制 |

### TSPeripheralCapability

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `originAbility` | `NSData *` | 从设备获取的原始能力数据（最多16字节） |
| `supportCapabilities` | `TSPeripheralSupportAbility` | 解析后的功能支持标志集 |
| `featureAbility` | `TSFeatureAbility *` | 功能模块能力（粗粒度） |
| `messageAbility` | `TSMessageAbility *` | 消息通知能力（细粒度） |
| `dailyActivityAbility` | `TSDailyActivityAbility *` | 每日活动能力（细粒度） |

### TSPeripheralConnectParam

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `userId` | `NSString *` | 设备连接的用户ID（必需） |
| `userInfo` | `TSUserInfoModel *` | 设备连接的用户信息模型 |
| `authCode` | `NSString *` | 设备绑定时获得的随机码 |
| `allowConnectWithBT` | `BOOL` | 是否允许蓝牙连接 |
| `brand` | `NSString *` | 手机品牌信息 |
| `model` | `NSString *` | 手机型号信息 |
| `systemVersion` | `NSString *` | 手机系统版本 |

### TSPeripheralScanParam

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `userId` | `NSString *` | 设备连接的用户ID（必需） |
| `serviceUUIDs` | `NSArray<CBUUID *> *` | 过滤用的服务UUID数组，nil表示不过滤 |
| `solicitedServiceUUIDs` | `NSArray<CBUUID *> *` | Solicited Service UUID过滤，nil表示不过滤 |
| `deviceName` | `NSString *` | 设备名称过滤，nil表示不过滤 |
| `macAddress` | `NSString *` | MAC地址过滤，nil表示不过滤 |
| `onlyUnconnected` | `BOOL` | 是否只返回未连接的外设（默认NO） |
| `allowDuplicates` | `BOOL` | 是否允许重复发现同一设备（默认NO） |
| `scanTimeout` | `NSInteger` | 扫描超时时间（秒），0表示无超时 |

### TSPeripheralLimitations

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `maxAlarmCount` | `UInt8` | 最大闹钟数量（0表示不支持） |
| `maxContactCount` | `UInt8` | 最大联系人数量（0表示不支持） |
| `maxEmergencyContactCount` | `UInt8` | 最大紧急联系人数量（0=不支持，255=无限制） |
| `maxPushDialCount` | `UInt8` | 最大可推送表盘位置数量（0表示不支持） |
| `maxInnerDialCount` | `UInt8` | 设备预装的表盘数量 |
| `maxWorldClockCount` | `UInt8` | 最大世界时钟数量（0=不支持，255=无限制） |
| `maxSedentaryReminderCount` | `UInt8` | 最大久坐提醒数量（0=不支持，255=无限制） |
| `maxWaterDrinkingReminderCount` | `UInt8` | 最大喝水提醒数量（0=不支持，255=无限制） |
| `maxMedicationReminderCount` | `UInt8` | 最大吃药提醒数量（0=不支持，255=无限制） |
| `maxCustomReminderCount` | `UInt8` | 最大自定义提醒数量（0=不支持，255=无限制） |

### TSDailyActivityAbility

| 属性名 | 类型 | 说明 |
|-------|------|------|
| 无属性 | - | 通过方法访问 |

### TSFeatureAbility

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `originAbility` | `NSData *` | 从设备获取的原始能力数据 |
| `supportCapabilities` | `TSPeripheralSupportAbility` | 解析后的功能支持标志集 |
| `isSupportStepCounting` | `BOOL` | 是否支持计步功能 |
| `isSupportHeartRate` | `BOOL` | 是否支持心率监测 |
| `isSupportBloodPressure` | `BOOL` | 是否支持血压监测 |
| `isSupportSleep` | `BOOL` | 是否支持睡眠监测 |
| `isSupportDailyActivity` | `BOOL` | 是否支持每日活动 |
| `isSupportAppNotifications` | `BOOL` | 是否支持应用通知 |
| `isSupportCallManagement` | `BOOL` | 是否支持来电管理 |
| `isSupportWeatherDisplay` | `BOOL` | 是否支持天气显示 |

### TSMessageAbility

| 属性名 | 类型 | 说明 |
|-------|------|------|
| 无属性 | - | 通过方法访问 |

## 枚举与常量

### TSBleConnectionState

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `eTSBleStateDisconnected` | 未连接（初始状态或任何失败后） |
| `1` | `eTSBleStateConnecting` | 连接中（建立BLE物理连接） |
| `2` | `eTSBleStateAuthenticating` | 认证中（执行绑定/登录认证） |
| `3` | `eTSBleStatePreparingData` | 准备数据中（获取设备信息） |
| `4` | `eTSBleStateConnected` | 已连接且就绪（完全功能可用） |

### TSScanCompletionReason

| 值 | 名称 | 说明 |
|----|------|------|
| `1000` | `eTSScanCompleteReasonTimeout` | 扫描超时 |
| `1001` | `eTSScanCompleteReasonBleNotReady` | 蓝牙未准备好 |
| `1002` | `eTSScanCompleteReasonPermissionDenied` | 权限被拒绝 |
| `1003` | `eTSScanCompleteReasonUserStopped` | 用户主动停止 |
| `1004` | `eTSScanCompleteReasonSystemError` | 系统错误 |
| `1005` | `eTSScanCompleteReasonNotSupport` | 不支持 |

### TSBleStatus

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `TSBleDisconnected` | 未连接 |
| `1` | `TSBleConnected` | 已连接 |
| `2` | `TSBleReady` | 已就绪（已连接且Notify/SPP已打开） |

### TSPeriphShape

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `eTSPeriphShapeUnknow` | 未知形状 |
| `1` | `eTSPeriphShapeCircle` | 圆形设备 |
| `2` | `eTSPeriphShapeSquare` | 正方形设备 |
| `3` | `eTSPeriphShapeVerticalRectangle` | 纵向矩形设备 |
| `4` | `eTSPeriphShapeTransverseRectangle` | 横向矩形设备 |

## 回调类型

| 回调类型 | 参数 | 说明 |
|---------|------|------|
| `TSScanDiscoveryBlock` | `TSPeripheral *peripheral` | 设备发现回调，当扫描到新设备时触发 |
| `TSScanCompletionBlock` | `TSScanCompletionReason reason, NSError *error` | 扫描完成回调，包含完成原因和可选错误 |
| `TSBleConnectionStateCallback` | `TSBleConnectionState connectionState` | 连接状态变化回调，用于进度更新 |
| `TSBleConnectionCompletionBlock` | `TSBleConnectionState connectionState, NSError *error` | 连接完成回调，返回最终连接状态和错误 |
| `TSCompletionBlock` | `NSError *error` | 通用完成回调 |

## 接口方法

### 获取蓝牙连接状态

获取当前蓝牙设备的连接状态。

```objc
- (void)getConnectState:(TSBleConnectionStateCallback)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSBleConnectionStateCallback` | 返回当前连接状态的回调 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

[bleConnect getConnectState:^(TSBleConnectionState connectionState) {
    switch (connectionState) {
        case eTSBleStateDisconnected:
            TSLog(@"设备未连接");
            break;
        case eTSBleStateConnecting:
            TSLog(@"设备连接中...");
            break;
        case eTSBleStateAuthenticating:
            TSLog(@"设备认证中...");
            break;
        case eTSBleStatePreparingData:
            TSLog(@"设备准备数据中...");
            break;
        case eTSBleStateConnected:
            TSLog(@"设备已连接且就绪");
            break;
    }
}];
```

### 开始搜索蓝牙设备

使用基础参数开始搜索蓝牙设备。

```objc
- (void)startSearchPeripheral:(NSTimeInterval)timeout
           discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                   completion:(TSScanCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `timeout` | `NSTimeInterval` | 扫描超时时间（秒），0表示使用默认30秒 |
| `discoverPeripheral` | `TSScanDiscoveryBlock` | 发现新设备时触发的回调 |
| `completion` | `TSScanCompletionBlock` | 扫描完成或超时时的回调 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

[bleConnect startSearchPeripheral:30  // 30秒超时
           discoverPeripheral:^(TSPeripheral *peripheral) {
    TSLog(@"发现设备: %@", peripheral.systemInfo.bleName);
    // 更新UI显示设备列表
} completion:^(TSScanCompletionReason reason, NSError *error) {
    if (error) {
        TSLog(@"扫描出错: %@", error.localizedDescription);
    } else {
        switch (reason) {
            case eTSScanCompleteReasonTimeout:
                TSLog(@"扫描超时");
                break;
            case eTSScanCompleteReasonUserStopped:
                TSLog(@"用户停止扫描");
                break;
            default:
                TSLog(@"扫描完成，原因: %ld", (long)reason);
        }
    }
}];
```

### 使用高级参数开始搜索蓝牙设备

使用高级参数（如过滤条件）开始搜索蓝牙设备。

```objc
- (void)startSearchPeripheralWithParam:(TSPeripheralScanParam *)param
                    discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                            completion:(TSScanCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `param` | `TSPeripheralScanParam *` | 扫描参数，包含过滤条件和超时设置 |
| `discoverPeripheral` | `TSScanDiscoveryBlock` | 发现新设备时触发的回调 |
| `completion` | `TSScanCompletionBlock` | 扫描完成回调 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

TSPeripheralScanParam *param = [[TSPeripheralScanParam alloc] init];
param.userId = @"user123";
param.scanTimeout = 60;  // 60秒超时
param.allowDuplicates = YES;  // 允许重复发现，便于实时获取RSSI
param.onlyUnconnected = YES;  // 仅显示未连接设备

[bleConnect startSearchPeripheralWithParam:param
                      discoverPeripheral:^(TSPeripheral *peripheral) {
    TSLog(@"发现设备: %@, RSSI: %@", 
          peripheral.systemInfo.bleName, 
          peripheral.systemInfo.RSSI);
} completion:^(TSScanCompletionReason reason, NSError *error) {
    TSLog(@"扫描完成, 原因: %ld", (long)reason);
}];
```

### 停止搜索蓝牙设备

停止当前的蓝牙设备搜索。

```objc
- (void)stopSearchPeripheral;
```

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

// 停止搜索
[bleConnect stopSearchPeripheral];
TSLog(@"已停止搜索设备");
```

### 连接蓝牙设备

首次连接蓝牙设备，包含绑定操作。

```objc
- (void)connectWithPeripheral:(TSPeripheral *)peripheral
                        param:(TSPeripheralConnectParam *)param
                   completion:(TSBleConnectionCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `peripheral` | `TSPeripheral *` | 要连接的外设 |
| `param` | `TSPeripheralConnectParam *` | 包含用户ID等绑定信息的连接参数 |
| `completion` | `TSBleConnectionCompletionBlock` | 连接完成回调，会被多次触发，返回不同状态 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;
TSPeripheral *selectedPeripheral = /* 扫描结果中选中的设备 */;

// 创建连接参数
TSPeripheralConnectParam *connectParam = 
    [[TSPeripheralConnectParam alloc] initWithUserId:@"user123"];
connectParam.brand = @"Apple";
connectParam.model = @"iPhone 15 Pro";
connectParam.systemVersion = @"17.0";
connectParam.authCode = @"SCAN_CODE_FROM_QR";  // 从二维码获得
connectParam.userInfo = /* 用户信息 */;

// 开始连接
[bleConnect connectWithPeripheral:selectedPeripheral
                           param:connectParam
                      completion:^(TSBleConnectionState connectionState, NSError *error) {
    if (error) {
        TSLog(@"连接失败: %@", error.localizedDescription);
        return;
    }
    
    switch (connectionState) {
        case eTSBleStateConnecting:
            TSLog(@"正在建立BLE物理连接...");
            // 更新进度条 25%
            break;
        case eTSBleStateAuthenticating:
            TSLog(@"正在认证设备...");
            // 更新进度条 50%
            break;
        case eTSBleStatePreparingData:
            TSLog(@"正在获取设备信息...");
            // 更新进度条 75%
            break;
        case eTSBleStateConnected:
            TSLog(@"设备连接成功!");
            // 更新进度条 100%，进入主界面
            break;
        case eTSBleStateDisconnected:
            TSLog(@"连接已断开");
            break;
    }
}];
```

### 重新连接蓝牙设备

重新连接到之前绑定的设备。

```objc
- (void)reconnectWithPeripheral:(TSPeripheral *)peripheral
                          param:(TSPeripheralConnectParam *)param
                     completion:(TSBleConnectionCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `peripheral` | `TSPeripheral *` | 要重连的外设 |
| `param` | `TSPeripheralConnectParam *` | 连接参数（必须使用原绑定的用户ID） |
| `completion` | `TSBleConnectionCompletionBlock` | 重连完成回调 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;
TSPeripheral *boundPeripheral = /* 之前绑定的设备 */;

// 创建重连参数
TSPeripheralConnectParam *reconnectParam = 
    [[TSPeripheralConnectParam alloc] initWithUserId:@"user123"];
reconnectParam.brand = @"Apple";
reconnectParam.model = @"iPhone 15 Pro";
reconnectParam.systemVersion = @"17.0";

// 开始重连
[bleConnect reconnectWithPeripheral:boundPeripheral
                              param:reconnectParam
                         completion:^(TSBleConnectionState connectionState, NSError *error) {
    if (error) {
        TSLog(@"重连失败: %@", error.localizedDescription);
        return;
    }
    
    switch (connectionState) {
        case eTSBleStateConnected:
            TSLog(@"重连成功!");
            break;
        case eTSBleStateDisconnected:
            TSLog(@"重连失败");
            break;
        default:
            TSLog(@"重连状态: %ld", (long)connectionState);
    }
}];
```

### 断开设备连接

断开当前连接的设备，但保留绑定信息。

```objc
- (void)disconnectCompletion:(TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 断开完成回调 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

[bleConnect disconnectCompletion:^(NSError *error) {
    if (error) {
        TSLog(@"断开失败: %@", error.localizedDescription);
    } else {
        TSLog(@"设备已断开连接");
    }
}];
```

### 解除设备绑定

完全解除设备绑定，清除所有配对信息。

```objc
- (void)unbindPeripheralCompletion:(TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 解绑完成回调 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

[bleConnect unbindPeripheralCompletion:^(NSError *error) {
    if (error) {
        TSLog(@"解绑失败: %@", error.localizedDescription);
    } else {
        TSLog(@"设备已解绑");
        // 返回到首页或设备列表
    }
}];
```

### 检查设备是否已连接

快速检查设备是否处于连接状态。

```objc
- (BOOL)isConnected;
```

**返回值**

| 返回值 | 说明 |
|-------|------|
| `YES` | 设备已连接 |
| `NO` | 设备未连接 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

if ([bleConnect isConnected]) {
    TSLog(@"设备已连接，可以执行数据操作");
} else {
    TSLog(@"设备未连接");
}
```

### 获取蓝牙适配器信息

获取完整的蓝牙系统信息，包含BLE和经典蓝牙的详细信息。

```objc
- (void)getBluetoothInfo:(void(^)(TSBluetoothSystem * _Nullable bluetoothInfo, NSError * _Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | block | 返回蓝牙系统信息或错误的回调 |

**代码示例**

```objc
id<TSBleConnectInterface> bleConnect = [TopStepComKit sharedInstance].bleConnector;

[bleConnect getBluetoothInfo:^(TSBluetoothSystem *bluetoothInfo, NSError *error) {
    if (error) {
        TSLog(@"获取蓝牙信息失败: %@", error.localizedDescription);
        return;
    }
    
    if (bluetoothInfo.bleInfo) {
        TSLog(@"BLE状态: %ld", (long)bluetoothInfo.bleInfo.status);
        TSLog(@"BLE名称: %@", bluetoothInfo.bleInfo.name);
        if (bluetoothInfo.bleInfo.macAddress) {
            TSLog(@"BLE MAC: %@", bluetoothInfo.bleInfo.macAddress);
        }
    }
    
    if (bluetoothInfo.btInfo) {
        TSLog(@"BT状态: %ld", (long)bluetoothInfo.btInfo.status);
        TSLog(@"BT名称: %@", bluetoothInfo.btInfo.name);
    }
}];
```

### 获取屏幕宽度

从屏幕信息中获取屏幕宽度。

```objc
- (CGFloat)screenWidth;
```

**代码示例**

```objc
TSPeripheral *peripheral = /* 获取的外设 */;
CGFloat screenWidth = [peripheral.screenInfo screenWidth];
TSLog(@"屏幕宽度: %.0f pixels", screenWidth);
```

### 获取屏幕高度

从屏幕信息中获取屏幕高度。

```objc
- (CGFloat)screenHeight;
```

**代码示例**

```objc
TSPeripheral *peripheral = /* 获取的外设 */;
CGFloat screenHeight = [peripheral.screenInfo screenHeight];
TSLog(@"屏幕高度: %.0f pixels", screenHeight);
```

### 检查设备是否已连接（外设对象）

检查特定外设是否已连接。

```objc
- (BOOL)isConnected;
```

**返回值**

| 返回值 | 说明 |
|-------|------|
| `YES` | 设备已连接 |
| `NO` | 设备未连接 |

**代码示例**

```objc
TSPeripheral *peripheral = /* 获取的外设 */;

if ([peripheral isConnected]) {
    TSLog(@"设备已连接");
} else {
    TSLog(@"设备未连接");
}
```

### 打印设备信息日志

打印设备的简要信息日志，用于调试。

```objc
- (void)shortLog;
```

**代码