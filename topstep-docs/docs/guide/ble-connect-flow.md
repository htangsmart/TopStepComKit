---
sidebar_position: 3
title: 蓝牙连接流程
---

# 蓝牙连接完整流程

本文介绍从搜索设备到成功连接的完整流程，以及断开、解绑等生命周期管理。

## 连接状态机

SDK 将连接过程分为 5 个阶段，完整走过以下状态机才代表设备可用：

```
eTSBleStateDisconnected（未连接）
         │
         │  调用 connectWithPeripheral:
         ▼
eTSBleStateConnecting（BLE 物理连接中）
         │
         │  物理连接建立
         ▼
eTSBleStateAuthenticating（绑定 / 登录认证中）
         │
         │  认证通过
         ▼
eTSBleStatePreparingData（拉取设备基础信息）
         │
         │  信息同步完成
         ▼
eTSBleStateConnected（已连接，可操作数据）
```

只有到达 `eTSBleStateConnected` 状态，才能调用健康数据、设置等其他功能接口。

## 完整流程代码

### 第 1 步：搜索设备

```objectivec
// 开始搜索（30秒超时）
[bleConnect startSearchPeripheral:30
               discoverPeripheral:^(TSPeripheral *peripheral) {
    // 每发现一个设备回调一次
    TSLog(@"发现设备: %@ | MAC: %@",
          peripheral.systemInfo.bleName,
          peripheral.systemInfo.macAddress);

    // 将设备加入列表，刷新 UI
    [self.peripheralList addObject:peripheral];
    [self.tableView reloadData];

} completion:^(TSScanCompletionReason reason, NSError *error) {
    switch (reason) {
        case eTSScanCompleteReasonTimeout:
            TSLog(@"搜索超时，共发现 %lu 台设备", (unsigned long)self.peripheralList.count);
            break;
        case eTSScanCompleteReasonUserStopped:
            TSLog(@"用户手动停止搜索");
            break;
        case eTSScanCompleteReasonPermissionDenied:
            TSLog(@"蓝牙权限被拒绝，请前往设置开启");
            [self showBluetoothPermissionAlert];
            break;
        default:
            if (error) TSLog(@"搜索出错: %@", error.localizedDescription);
            break;
    }
}];
```

### 第 2 步：用户选择设备后停止搜索

```objectivec
// 用户点击了列表中的某个设备
- (void)didSelectPeripheral:(TSPeripheral *)peripheral {
    // 立即停止扫描，节省电量
    [bleConnect stopSearchPeripheral];
    [self connectToPeripheral:peripheral];
}
```

### 第 3 步：首次连接（绑定）

首次连接需要提供 `authCode`（扫描设备二维码获取）：

```objectivec
- (void)connectToPeripheral:(TSPeripheral *)peripheral {
    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:self.userId];

    // 首次绑定时设置认证码（扫码获取）
    param.authCode = self.scannedAuthCode;

    // 手机信息（用于设备显示）
    param.brand         = @"Apple";
    param.model         = [UIDevice currentDevice].model;
    param.systemVersion = [UIDevice currentDevice].systemVersion;

    // 用户信息（用于设备个性化）
    TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
    userInfo.age    = 28;
    userInfo.gender = 1;   // 1=男，0=女
    userInfo.height = 175;
    userInfo.weight = 70;
    param.userInfo = userInfo;

    [bleConnect connectWithPeripheral:peripheral
                                param:param
                           completion:^(TSBleConnectionState state, NSError *error) {
        if (error) {
            TSLog(@"连接失败: %@", error.localizedDescription);
            [self showConnectFailedAlert:error];
            return;
        }

        switch (state) {
            case eTSBleStateConnecting:
                TSLog(@"正在建立 BLE 连接...");
                [self showLoadingWith:@"正在连接..."];
                break;
            case eTSBleStateAuthenticating:
                TSLog(@"正在认证设备...");
                [self showLoadingWith:@"正在认证..."];
                break;
            case eTSBleStatePreparingData:
                TSLog(@"正在同步设备信息...");
                [self showLoadingWith:@"准备就绪..."];
                break;
            case eTSBleStateConnected:
                TSLog(@"设备连接成功！");
                [self hideLoading];
                [self onDeviceConnected:peripheral];
                break;
            case eTSBleStateDisconnected:
                TSLog(@"连接失败，已断开");
                [self hideLoading];
                break;
        }
    }];
}
```

### 第 4 步：重连（已绑定设备）

后续启动 App 时，对已绑定设备使用 `reconnectWithPeripheral:`，无需二维码：

```objectivec
- (void)reconnectSavedDevice {
    // 从本地存储恢复上次的设备信息
    TSPeripheral *savedDevice = [self loadSavedPeripheral];
    if (!savedDevice) return;

    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:self.userId];

    [bleConnect reconnectWithPeripheral:savedDevice
                                  param:param
                             completion:^(TSBleConnectionState state, NSError *error) {
        if (state == eTSBleStateConnected) {
            TSLog(@"重连成功");
        } else if (error) {
            TSLog(@"重连失败: %@", error.localizedDescription);
            // 重连失败通常需要重新搜索并连接
        }
    }];
}
```

## 监听连接状态变化

在整个 App 生命周期内监听断线事件：

```objectivec
// 在 AppDelegate 或全局管理器中设置
[bleConnect setKitDelegate:self];

// 实现代理方法（具体方法名见 TSBleConnectInterface 协议）
- (void)bleConnectStateDidChanged:(TSBleConnectionState)state {
    if (state == eTSBleStateDisconnected) {
        TSLog(@"设备已断开连接");
        // 可以在此触发 UI 更新，或根据业务需求自动重连
        [self handleDeviceDisconnected];
    } else if (state == eTSBleStateConnected) {
        TSLog(@"设备已重连");
        [self handleDeviceConnected];
    }
}
```

## 断开连接

```objectivec
// 主动断开（保留绑定信息，下次可重连）
[bleConnect disconnectCompletion:^(BOOL isSuccess, NSError *error) {
    TSLog(@"断开连接: %@", isSuccess ? @"成功" : error.localizedDescription);
}];
```

## 解除绑定

```objectivec
// 彻底解绑（需要下次重新扫码绑定）
[bleConnect unbindPeripheralCompletion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        TSLog(@"解绑成功，清除本地设备信息");
        [self clearSavedDevice];
        [self navigateToDeviceList];
    }
}];
```

## 最佳实践

1. **首次连接**：使用 `connectWithPeripheral:param:completion:`，需要提供扫码获取的 `authCode`
2. **后续启动**：使用 `reconnectWithPeripheral:param:completion:`，无需 `authCode`
3. **开启自动重连**：在 `TSKitConfigOptions` 中设置 `autoConnectWhenAppLaunch = YES`，SDK 会在 App 启动时自动尝试连接上次的设备
4. **状态检查**：在调用任何功能接口前，先调用 `[bleConnect isConnected]` 确认设备已连接
5. **功能支持检查**：部分设备不支持所有功能，使用前调用 `[featureKit isSupport]` 检查

## 注意事项

1. 搜索和连接只能在真机上运行，iOS 模拟器不支持 BLE
2. `connectWithPeripheral:` 的 `completion` 会被多次回调（每个状态阶段一次）
3. 连接成功（`eTSBleStateConnected`）后才能调用其他功能模块
4. App 进入后台时蓝牙连接会维持，但部分功能（如数据同步）可能被系统限制
5. 一个 App 同时只能连接一台设备
