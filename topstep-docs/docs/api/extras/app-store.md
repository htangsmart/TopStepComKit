---
sidebar_position: 8
title: 应用商店
---

# 应用商店（TSAppStore）

应用商店模块提供手表设备应用管理的完整功能，包括应用列表获取、应用安装状态检查、以及应用变化监听等功能。通过该模块，可以实时掌握设备上的应用状态，并响应应用的安装、卸载、启用和禁用事件。

## 前提条件

1. 已初始化 TopStepComKit SDK
2. 已建立与手表设备的有效连接
3. 设备运行的系统支持应用管理功能

## 数据模型

### TSApplicationModel（应用模型）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `appId` | `NSString *` | 应用的唯一标识符，用于在系统中区分不同应用 |
| `appName` | `NSString *` | 应用的显示名称，用于界面显示和识别 |
| `appType` | `TSApplicationType` | 应用类型（系统应用或用户安装应用），默认为 `eTSApplicationTypeSystem` |
| `version` | `NSString *` | 应用版本字符串，如 "1.0.0" |
| `iconPath` | `NSString *` | 应用图标的本地文件路径或URL，用于显示应用图标 |
| `size` | `NSUInteger` | 应用大小（字节），表示应用占用的存储空间，未知时为0 |
| `isInstalled` | `BOOL` | 应用是否已安装在设备上，默认为 `NO` |
| `isEnabled` | `BOOL` | 应用当前是否启用，默认为 `YES` |
| `appPath` | `NSString *` | 应用在设备上的文件系统路径 |
| `appDescription` | `NSString *` | 应用功能的描述或摘要 |
| `packageName` | `NSString *` | 应用的包名或Bundle标识符 |
| `installTime` | `NSTimeInterval` | 应用安装时间戳（自1970-01-01起的秒数），未知时为0 |
| `updateTime` | `NSTimeInterval` | 应用最后更新的时间戳（自1970-01-01起的秒数），未知时为0 |

## 枚举与常量

### TSApplicationType（应用类型枚举）

| 枚举值 | 说明 |
|--------|------|
| `eTSApplicationTypeSystem` | 系统应用（内置应用，不可卸载） |
| `eTSApplicationTypeUserInstalled` | 用户安装的应用（可卸载） |

### TSApplicationStatus（应用状态枚举）

| 枚举值 | 说明 |
|--------|------|
| `eTSApplicationStatusUnknow` | 应用状态未知 |
| `eTSApplicationStatusInstalled` | 应用已被安装 |
| `eTSApplicationStatusUninstalled` | 应用已被卸载或删除 |
| `eTSApplicationStatusDisabled` | 应用已被禁用 |
| `eTSApplicationStatusEnabled` | 应用已被启用 |

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `TSApplicationListBlock` | 应用列表回调，包含应用模型数组和错误信息 |
| `TSApplicationChangeBlock` | 应用变化通知回调，包含变化的应用、变化类型和错误信息 |

## 接口方法

### 获取所有已安装的应用

```objc
- (void)fetchAllInstalledApplications:(TSApplicationListBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSApplicationListBlock` | 完成回调，返回所有已安装的应用模型数组 |

获取设备上所有当前已安装应用的信息。只返回 `isInstalled` 为 `YES` 的应用，包括系统应用和用户安装的应用。回调将在主线程执行。

**代码示例：**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore fetchAllInstalledApplications:^(NSArray<TSApplicationModel *> * _Nullable applications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取应用列表失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"获取应用列表成功，共 %lu 个应用", (unsigned long)applications.count);
    
    for (TSApplicationModel *app in applications) {
        TSLog(@"应用名称: %@, 版本: %@, 已安装: %@", app.appName, app.version, app.isInstalled ? @"是" : @"否");
    }
}];
```

---

### 检查指定应用是否已安装

```objc
- (void)checkApplicationInstalled:(TSApplicationModel *)application completion:(void (^)(BOOL isInstalled, NSError * _Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `application` | `TSApplicationModel *` | 要检查的应用模型，必须包含 `appId` 或 `packageName` 用于识别 |
| `completion` | `void (^)(BOOL, NSError *)` | 检查完成的回调，返回安装状态和错误信息 |

检查指定应用是否已安装在手表设备上。应用通过提供的 `TSApplicationModel` 中的 `appId` 或 `packageName` 进行识别。回调将在主线程执行。

**代码示例：**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

TSApplicationModel *targetApp = [[TSApplicationModel alloc] init];
targetApp.appId = @"com.example.myapp";

[appStore checkApplicationInstalled:targetApp completion:^(BOOL isInstalled, NSError * _Nullable error) {
    if (error) {
        TSLog(@"检查应用安装状态失败: %@", error.localizedDescription);
        return;
    }
    
    if (isInstalled) {
        TSLog(@"应用已安装");
    } else {
        TSLog(@"应用未安装");
    }
}];
```

---

### 注册应用列表变化监听

```objc
- (void)registerApplicationListDidChanged:(TSApplicationListBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSApplicationListBlock` | 应用列表发生变化时的回调，返回更新后的应用列表 |

当设备上的应用被安装、卸载、启用或禁用时，此回调会被触发，并返回更新后的应用列表快照。使用此方法保持UI与设备状态变化同步。回调将在主线程执行。要停止接收通知，需调用 `unregisterApplicationListDidChanged`。

**代码示例：**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore registerApplicationListDidChanged:^(NSArray<TSApplicationModel *> * _Nullable applications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"应用列表监听失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"应用列表已变化，当前共有 %lu 个应用", (unsigned long)applications.count);
    
    for (TSApplicationModel *app in applications) {
        TSLog(@"应用: %@, 已安装: %@, 已启用: %@", 
              app.appName, 
              app.isInstalled ? @"是" : @"否",
              app.isEnabled ? @"是" : @"否");
    }
}];
```

---

### 取消注册应用列表变化监听

```objc
- (void)unregisterApplicationListDidChanged;
```

移除已注册的应用列表变化监听器。调用此方法后，将不再接收变化通知。如果当前没有注册监听器，调用此方法不会有任何效果。

**代码示例：**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore unregisterApplicationListDidChanged];
TSLog(@"已取消应用列表变化监听");
```

---

### 注册应用变化通知监听

```objc
- (void)registerApplicationDidChanged:(TSApplicationChangeBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSApplicationChangeBlock` | 应用状态发生变化时的回调，包含应用信息、变化类型和错误信息 |

当设备上特定应用的状态发生变化时（安装、卸载、禁用、启用），此回调会被触发。与 `registerApplicationListDidChanged` 提供整个应用列表不同，此方法提供单个应用变化的细粒度通知。回调将在主线程执行。要停止接收通知，需调用 `unregisterApplicationDidChanged`。

**代码示例：**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore registerApplicationDidChanged:^(TSApplicationModel * _Nullable application, TSApplicationStatus changeType, NSError * _Nullable error) {
    if (error) {
        TSLog(@"应用变化通知失败: %@", error.localizedDescription);
        return;
    }
    
    if (!application) {
        TSLog(@"应用信息无效");
        return;
    }
    
    NSString *changeTypeStr = @"未知";
    switch (changeType) {
        case eTSApplicationStatusInstalled:
            changeTypeStr = @"已安装";
            break;
        case eTSApplicationStatusUninstalled:
            changeTypeStr = @"已卸载";
            break;
        case eTSApplicationStatusDisabled:
            changeTypeStr = @"已禁用";
            break;
        case eTSApplicationStatusEnabled:
            changeTypeStr = @"已启用";
            break;
        default:
            break;
    }
    
    TSLog(@"应用变化: %@, 变化类型: %@", application.appName, changeTypeStr);
}];
```

---

### 取消注册应用变化通知监听

```objc
- (void)unregisterApplicationDidChanged;
```

移除已注册的应用变化通知监听器。调用此方法后，将不再接收变化通知。如果当前没有注册监听器，调用此方法不会有任何效果。

**代码示例：**

```objc
id<TSAppStoreInterface> appStore = [TopStepComKit sharedInstance].appStore;

[appStore unregisterApplicationDidChanged];
TSLog(@"已取消应用变化通知监听");
```

## 注意事项

1. 应用列表和应用变化的回调都将在主线程执行，可以直接进行UI更新操作。

2. 在使用 `registerApplicationListDidChanged` 或 `registerApplicationDidChanged` 注册监听时，多次注册会覆盖之前的注册。

3. 使用完毕后必须调用相应的取消注册方法（`unregisterApplicationListDidChanged` 或 `unregisterApplicationDidChanged`）以避免内存泄漏。

4. 在 `checkApplicationInstalled` 方法中，如果同时提供了 `appId` 和 `packageName`，系统会优先使用 `appId` 进行识别。

5. `registerApplicationListDidChanged` 提供整个应用列表的快照，适合需要全局应用状态的场景；`registerApplicationDidChanged` 提供单个应用变化的细粒度通知，适合需要响应特定应用变化的场景。

6. 应用安装时间戳和更新时间戳为 `NSTimeInterval` 类型，表示自1970-01-01以来的秒数，可以通过 `[NSDate dateWithTimeIntervalSince1970:timestamp]` 转换为 `NSDate` 对象。

7. 系统应用（`eTSApplicationTypeSystem`）不可卸载，用户安装的应用（`eTSApplicationTypeUserInstalled`）可以卸载。

8. 应用的 `size` 属性表示应用占用的存储空间大小（字节），如果大小未知或尚未确定，值可能为0。