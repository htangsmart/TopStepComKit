---
sidebar_position: 1
title: 安装与接入
---

# 安装与接入

本文介绍如何通过 CocoaPods 将 TopStepComKit SDK 集成到你的 iOS 项目中。

## 环境要求

| 环境 | 最低版本 |
|------|---------|
| iOS | 12.0 |
| Xcode | 13.0 |
| CocoaPods | 1.10.0 |
| Swift（可选） | 5.0 |

## 第 1 步：安装 CocoaPods

如果尚未安装 CocoaPods：

```bash
sudo gem install cocoapods
```

## 第 2 步：初始化 Podfile

在项目根目录执行：

```bash
cd YourProjectFolder
pod init
```

## 第 3 步：添加依赖

打开 `Podfile`，按设备类型添加对应子组件。

### 按设备平台选择 Pod

| 设备平台 | Pod 名称 | SDK 类型常量 |
|---------|---------|------------|
| 瑞昱（Realtek/FIT） | `TopStepFitKit` | `eTSSDKTypeFIT` |
| 恒玄（BES/FW） | `TopStepNewPlatformKit` | `eTSSDKTypeFW` |
| 伸聚（SJ） | `TopStepSJWatchKit` | `eTSSDKTypeSJ` |
| 魔样（CRP） | `TopStepCRPKit` | `eTSSDKTypeCRP` |
| 优创意（UTE） | `TopStepUTEKit` | `eTSSDKTypeUTE` |
| 拓步（TPB） | `TopStepTPBKit` | `eTSSDKTypeTPB` |

**Podfile 示例（接入单一平台）：**

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  # 核心接口层（必选）
  pod 'TopStepComKit'

  # 按设备类型选择一个或多个
  pod 'TopStepFitKit'       # 瑞昱设备
  # pod 'TopStepNewPlatformKit'  # 恒玄设备
  # pod 'TopStepSJWatchKit'      # 伸聚设备
end
```

**Podfile 示例（同时支持多平台）：**

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'TopStepComKit'
  pod 'TopStepFitKit'
  pod 'TopStepNewPlatformKit'
  pod 'TopStepSJWatchKit'
  pod 'TopStepCRPKit'
end
```

## 第 4 步：执行安装

```bash
pod install
```

安装完成后使用 `.xcworkspace` 打开项目（不要使用 `.xcodeproj`）。

## 第 5 步：配置蓝牙权限

在 `Info.plist` 中添加以下权限描述（缺少会导致应用崩溃或被 App Store 拒绝）：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限以连接智能穿戴设备</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要蓝牙权限以连接智能穿戴设备</string>
```

:::tip iOS 13+
iOS 13 及以上必须同时添加 `NSBluetoothAlwaysUsageDescription`，否则蓝牙功能无法正常工作。
:::

## 第 6 步：导入头文件

在需要使用 SDK 的文件中导入：

```objectivec
#import <TopStepComKit/TopStepComKit.h>
```

或在 `Prefix.pch` 中统一导入：

```objectivec
#ifdef __OBJC__
  #import <Foundation/Foundation.h>
  #import <UIKit/UIKit.h>
  #import <TopStepComKit/TopStepComKit.h>
#endif
```

## 常见问题

**Q: pod install 报错 "Unable to find a specification for TopStepComKit"**

检查 Podfile 中的 source 地址，确保可以访问到 TopStep 私有源：

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://your-topstep-spec-repo.git'  # 替换为实际源地址
```

**Q: 编译报错 "Undefined symbol: _OBJC_CLASS_$_TSComKit"**

确认已将对应平台的 Kit Pod（如 `TopStepFitKit`）也加入 Podfile，且已执行 `pod install`。

**Q: 运行时蓝牙权限弹窗不出现**

检查 `Info.plist` 是否正确添加了权限描述字段。模拟器不支持 BLE，请在真机上测试。
