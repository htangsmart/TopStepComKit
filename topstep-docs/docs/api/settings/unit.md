---
sidebar_position: 2
title: 单位设置
---

# 单位设置（TSUnit）

TSUnit 模块提供了完整的单位管理功能，支持长度、温度、重量、时间格式等多种单位的设置和获取。开发者可以根据用户偏好灵活配置单位系统，以提供本地化的数据显示。

## 前提条件

1. 已集成 TopStepComKit iOS SDK
2. 已通过 `TopStepComKit` 完成 SDK 初始化
3. 用户已完成登录认证

## 数据模型

无独立数据模型，该模块通过枚举和回调块传递数据。

## 枚举与常量

### TSLengthUnit（长度单位）

| 枚举值 | 说明 |
|--------|------|
| `TSLengthUnitMetric` | 公制单位（千米/米） |
| `TSLengthUnitImperial` | 英制单位（英里/英尺） |

### TSTemperatureUnit（温度单位）

| 枚举值 | 说明 |
|--------|------|
| `TSTemperatureUnitCelsius` | 摄氏度（°C） |
| `TSTemperatureUnitFahrenheit` | 华氏度（°F） |

### TSWeightUnit（重量单位）

| 枚举值 | 说明 |
|--------|------|
| `TSWeightUnitKG` | 公斤（kg） |
| `TSWeightUnitLB` | 磅（lb） |

### TSTimeFormat（时间格式）

| 枚举值 | 说明 |
|--------|------|
| `TSTimeFormat12Hour` | 12 小时制 |
| `TSTimeFormat24Hour` | 24 小时制 |

### TSUnitSystem（单位系统）

| 枚举值 | 说明 |
|--------|------|
| `TSUnitSystemMetric` | 公制系统（长度和重量均为公制） |
| `TSUnitSystemImperial` | 英制系统（长度和重量均为英制） |

## 回调类型

| 回调类型 | 签名 | 说明 |
|---------|------|------|
| `TSCompletionBlock` | `void (^)(NSError * _Nullable error)` | 设置操作完成回调 |
| 长度单位获取回调 | `void (^)(TSLengthUnit unit, NSError * _Nullable error)` | 返回当前长度单位和错误信息 |
| 温度单位获取回调 | `void (^)(TSTemperatureUnit unit, NSError * _Nullable error)` | 返回当前温度单位和错误信息 |
| 重量单位获取回调 | `void (^)(TSWeightUnit unit, NSError * _Nullable error)` | 返回当前重量单位和错误信息 |
| 时间格式获取回调 | `void (^)(TSTimeFormat format, NSError * _Nullable error)` | 返回当前时间格式和错误信息 |
| 单位系统获取回调 | `void (^)(TSUnitSystem system, NSError * _Nullable error)` | 返回当前单位系统和错误信息 |

## 接口方法

### 设置长度单位

设置距离显示的长度单位，支持公制（千米/米）或英制（英里/英尺）。

```objc
- (void)setLengthUnit:(TSLengthUnit)unit
           completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `unit` | `TSLengthUnit` | 长度单位类型（公制或英制） |
| `completion` | `TSCompletionBlock` | 设置完成回调 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit setLengthUnit:TSLengthUnitMetric 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置长度单位失败: %@", error.localizedDescription);
    } else {
        TSLog(@"长度单位已设置为公制");
    }
}];
```

### 获取当前长度单位

获取当前设置的长度单位。

```objc
- (void)getCurrentLengthUnit:(void(^)(TSLengthUnit unit, NSError * _Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSLengthUnit, NSError *)` | 完成回调，返回当前长度单位 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit getCurrentLengthUnit:^(TSLengthUnit unit, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取长度单位失败: %@", error.localizedDescription);
    } else {
        NSString *unitStr = (unit == TSLengthUnitMetric) ? @"公制" : @"英制";
        TSLog(@"当前长度单位: %@", unitStr);
    }
}];
```

### 设置温度单位

设置温度显示的单位，支持摄氏度（°C）或华氏度（°F）。

```objc
- (void)setTemperatureUnit:(TSTemperatureUnit)unit
                completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `unit` | `TSTemperatureUnit` | 温度单位类型（摄氏度或华氏度） |
| `completion` | `TSCompletionBlock` | 设置完成回调 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit setTemperatureUnit:TSTemperatureUnitCelsius 
                     completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置温度单位失败: %@", error.localizedDescription);
    } else {
        TSLog(@"温度单位已设置为摄氏度");
    }
}];
```

### 获取当前温度单位

获取当前设置的温度单位。

```objc
- (void)getCurrentTemperatureUnit:(void(^)(TSTemperatureUnit unit, NSError * _Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSTemperatureUnit, NSError *)` | 完成回调，返回当前温度单位 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit getCurrentTemperatureUnit:^(TSTemperatureUnit unit, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取温度单位失败: %@", error.localizedDescription);
    } else {
        NSString *unitStr = (unit == TSTemperatureUnitCelsius) ? @"摄氏度" : @"华氏度";
        TSLog(@"当前温度单位: %@", unitStr);
    }
}];
```

### 设置重量单位

设置体重或质量显示的单位，支持公斤（kg）或磅（lb）。

```objc
- (void)setWeightUnit:(TSWeightUnit)unit
           completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `unit` | `TSWeightUnit` | 重量单位类型（公斤或磅） |
| `completion` | `TSCompletionBlock` | 设置完成回调 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit setWeightUnit:TSWeightUnitKG 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置重量单位失败: %@", error.localizedDescription);
    } else {
        TSLog(@"重量单位已设置为公斤");
    }
}];
```

### 获取当前重量单位

获取当前设置的重量单位。

```objc
- (void)getCurrentWeightUnit:(void(^)(TSWeightUnit unit, NSError * _Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSWeightUnit, NSError *)` | 完成回调，返回当前重量单位 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit getCurrentWeightUnit:^(TSWeightUnit unit, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取重量单位失败: %@", error.localizedDescription);
    } else {
        NSString *unitStr = (unit == TSWeightUnitKG) ? @"公斤" : @"磅";
        TSLog(@"当前重量单位: %@", unitStr);
    }
}];
```

### 设置时间格式

设置时间显示的格式，支持 12 小时制或 24 小时制。

```objc
- (void)setTimeFormat:(TSTimeFormat)format
           completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `format` | `TSTimeFormat` | 时间格式类型（12 或 24 小时制） |
| `completion` | `TSCompletionBlock` | 设置完成回调 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit setTimeFormat:TSTimeFormat24Hour 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置时间格式失败: %@", error.localizedDescription);
    } else {
        TSLog(@"时间格式已设置为 24 小时制");
    }
}];
```

### 获取当前时间格式

获取当前设置的时间格式。

```objc
- (void)getCurrentTimeFormat:(void(^)(TSTimeFormat format, NSError * _Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSTimeFormat, NSError *)` | 完成回调，返回当前时间格式 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit getCurrentTimeFormat:^(TSTimeFormat format, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取时间格式失败: %@", error.localizedDescription);
    } else {
        NSString *formatStr = (format == TSTimeFormat12Hour) ? @"12 小时制" : @"24 小时制";
        TSLog(@"当前时间格式: %@", formatStr);
    }
}];
```

### 设置单位系统

一次性设置整个单位系统（包括长度和重量单位），支持公制或英制。

```objc
- (void)setUnitSystem:(TSUnitSystem)system
           completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `system` | `TSUnitSystem` | 单位系统类型（公制或英制） |
| `completion` | `TSCompletionBlock` | 设置完成回调 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit setUnitSystem:TSUnitSystemMetric 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置单位系统失败: %@", error.localizedDescription);
    } else {
        TSLog(@"单位系统已设置为公制");
    }
}];
```

### 获取当前单位系统

获取当前设置的单位系统。

```objc
- (void)getUnitSystemCompletion:(void(^)(TSUnitSystem system, NSError * _Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSUnitSystem, NSError *)` | 完成回调，返回当前单位系统 |

**代码示例**

```objc
id<TSUnitInterface> unit = [TopStepComKit sharedInstance].unit;

[unit getUnitSystemCompletion:^(TSUnitSystem system, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取单位系统失败: %@", error.localizedDescription);
    } else {
        NSString *systemStr = (system == TSUnitSystemMetric) ? @"公制" : @"英制";
        TSLog(@"当前单位系统: %@", systemStr);
    }
}];
```

## 注意事项

1. 所有设置操作均为异步操作，必须通过完成回调获取结果，不得阻塞主线程。

2. 建议使用 `setUnitSystem:completion:` 统一设置整个单位系统，而不是分别设置长度和重量单位，以保持数据一致性。

3. 如果同时使用 `setUnitSystem:completion:` 和 `setLengthUnit:completion:`、`setWeightUnit:completion:` 等方法，可能导致单位设置不一致。

4. 温度单位和时间格式与单位系统无关，需独立设置。

5. 在获取或设置单位时，应检查返回的 `error` 对象，以便处理潜在的网络或权限问题。

6. 单位设置更改后会立即生效，已缓存的数据可能需要手动刷新以显示正确的单位。

7. 建议在应用启动时获取用户的单位偏好设置，以确保整个应用使用一致的单位系统。