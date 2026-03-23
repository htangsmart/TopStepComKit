---
sidebar_position: 6
title: 世界时钟
---

# 世界时钟（TSWorldClock）

该模块提供了世界时钟的管理功能，支持设备上多个时区时钟的设置、查询和删除操作。用户可以为不同的城市添加世界时钟，并管理其时区信息和显示格式。

## 前提条件

- TopStepComKit iOS SDK 已正确集成到项目中
- 设备已连接并初始化完成
- 已完成 SDK 初始化

## 数据模型

### TSWorldClockModel

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `clockId` | `UInt8` | 时钟条目的唯一标识符，取值范围为 0-255，由系统自动分配 |
| `cityName` | `NSString *` | 城市名称 |
| `timeZoneIdentifier` | `NSString *` | IANA 时区标识符，例如 "Asia/Shanghai" |
| `utcOffsetInSeconds` | `NSInteger` | UTC 偏移量（秒），范围为 -43200 到 +43200。正值表示比 UTC 快（东区），负值表示比 UTC 慢（西区） |

## 接口方法

### 获取设备支持的最大世界时钟数量

```objc
- (NSInteger)supportMaxWorldClockCount;
```

**说明：** 获取设备支持的最大世界时钟数量

**返回值：** 可以设置的世界时钟最大数量

**代码示例：**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;
NSInteger maxCount = [worldClock supportMaxWorldClockCount];
TSLog(@"设备最多支持 %ld 个世界时钟", (long)maxCount);
```

---

### 设置设备的世界时钟

```objc
- (void)setWorldClocks:(NSArray<TSWorldClockModel *> *)worldClocks
            completion:(TSCompletionBlock)completion;
```

**参数表格：**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `worldClocks` | `NSArray<TSWorldClockModel *> *` | 要设置的世界时钟模型数组 |
| `completion` | `TSCompletionBlock` | 操作完成后的回调块 |

**代码示例：**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

// 创建世界时钟模型
TSWorldClockModel *shanghaiClock = [TSWorldClockModel modelWithClockId:0
                                                               cityName:@"Shanghai"
                                                    timeZoneIdentifier:@"Asia/Shanghai"
                                                    utcOffsetInSeconds:28800];

TSWorldClockModel *nyaClock = [TSWorldClockModel modelWithClockId:1
                                                            cityName:@"New York"
                                                 timeZoneIdentifier:@"America/New_York"
                                                 utcOffsetInSeconds:-18000];

NSArray<TSWorldClockModel *> *clocks = @[shanghaiClock, nyaClock];

// 设置世界时钟
[worldClock setWorldClocks:clocks completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置世界时钟失败: %@", error.localizedDescription);
    } else {
        TSLog(@"世界时钟设置成功");
    }
}];
```

---

### 查询设备中的所有世界时钟

```objc
- (void)queryWorldClockCompletion:(void(^)(NSArray<TSWorldClockModel *> *_Nullable allWorldClocks, NSError * _Nullable error))completion;
```

**参数表格：**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `void (^)(NSArray<TSWorldClockModel *> *_Nullable, NSError *_Nullable)` | 返回世界时钟模型数组和可能发生的错误的回调块 |

**代码示例：**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

[worldClock queryWorldClockCompletion:^(NSArray<TSWorldClockModel *> * _Nullable allWorldClocks, NSError * _Nullable error) {
    if (error) {
        TSLog(@"查询世界时钟失败: %@", error.localizedDescription);
    } else {
        TSLog(@"查询到 %lu 个世界时钟", (unsigned long)allWorldClocks.count);
        for (TSWorldClockModel *clock in allWorldClocks) {
            TSLog(@"城市: %@, 时区: %@, UTC偏移: %ld秒", 
                  clock.cityName, 
                  clock.timeZoneIdentifier, 
                  (long)clock.utcOffsetInSeconds);
        }
    }
}];
```

---

### 删除特定的世界时钟

```objc
- (void)deleteWorldClock:(TSWorldClockModel *)worldClock completion:(TSCompletionBlock)completion;
```

**参数表格：**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `worldClock` | `TSWorldClockModel *` | 要删除的世界时钟模型 |
| `completion` | `TSCompletionBlock` | 操作完成后的回调块 |

**代码示例：**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

// 假设已获取到要删除的时钟对象
TSWorldClockModel *clockToDelete = /* 获取时钟模型 */;

[worldClock deleteWorldClock:clockToDelete completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"删除世界时钟失败: %@", error.localizedDescription);
    } else {
        TSLog(@"世界时钟删除成功");
    }
}];
```

---

### 删除所有世界时钟

```objc
- (void)deleteAllWorldClockCompletion:(TSCompletionBlock)completion;
```

**参数表格：**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 操作完成后的回调块 |

**代码示例：**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

[worldClock deleteAllWorldClockCompletion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"删除所有世界时钟失败: %@", error.localizedDescription);
    } else {
        TSLog(@"所有世界时钟已删除");
    }
}];
```

---

### 比较两个世界时钟模型是否相等

```objc
- (BOOL)isEqualToWorldClockModel:(TSWorldClockModel *)otherModel;
```

**参数表格：**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `otherModel` | `TSWorldClockModel *` | 要比较的另一个世界时钟模型 |

**返回值：** `BOOL` - 如果两个模型相等返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
TSWorldClockModel *clock1 = [TSWorldClockModel modelWithClockId:0
                                                        cityName:@"Shanghai"
                                             timeZoneIdentifier:@"Asia/Shanghai"
                                             utcOffsetInSeconds:28800];

TSWorldClockModel *clock2 = [TSWorldClockModel modelWithClockId:0
                                                        cityName:@"Shanghai"
                                             timeZoneIdentifier:@"Asia/Shanghai"
                                             utcOffsetInSeconds:28800];

if ([clock1 isEqualToWorldClockModel:clock2]) {
    TSLog(@"两个世界时钟模型相同");
} else {
    TSLog(@"两个世界时钟模型不同");
}
```

---

### 创建世界时钟模型

```objc
+ (instancetype)modelWithClockId:(UInt8)clockId
                        cityName:(NSString *)cityName
              timeZoneIdentifier:(NSString *)timeZoneIdentifier
              utcOffsetInSeconds:(NSInteger)utcOffsetInSeconds;
```

**参数表格：**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `clockId` | `UInt8` | 时钟条目的唯一标识符，取值范围为 0-255 |
| `cityName` | `NSString *` | 城市名称 |
| `timeZoneIdentifier` | `NSString *` | IANA 时区标识符 |
| `utcOffsetInSeconds` | `NSInteger` | UTC 偏移量（秒），范围为 -43200 到 +43200 |

**返回值：** `TSWorldClockModel *` - 新创建的世界时钟模型实例

**代码示例：**

```objc
// 创建上海时钟
TSWorldClockModel *shanghaiClock = [TSWorldClockModel modelWithClockId:0
                                                               cityName:@"Shanghai"
                                                    timeZoneIdentifier:@"Asia/Shanghai"
                                                    utcOffsetInSeconds:28800];

// 创建纽约时钟
TSWorldClockModel *nyaClock = [TSWorldClockModel modelWithClockId:1
                                                            cityName:@"New York"
                                                 timeZoneIdentifier:@"America/New_York"
                                                 utcOffsetInSeconds:-18000];

TSLog(@"创建了两个世界时钟: %@, %@", shanghaiClock.cityName, nyaClock.cityName);
```

---

## 注意事项

1. **时钟ID范围：** `clockId` 的取值范围是 0-255，系统会自动为新创建的时钟分配唯一 ID
2. **UTC 偏移量范围：** `utcOffsetInSeconds` 的有效范围是 -43200 到 +43200 秒，对应 UTC-12 到 UTC+12
3. **时区标识符：** 使用标准 IANA 时区标识符（例如 "Asia/Shanghai"、"America/New_York"），确保兼容性
4. **操作原子性：** 调用 `setWorldClocks:completion:` 时，该操作会替换设备上的所有世界时钟，而不是追加
5. **设备支持限制：** 在设置世界时钟前，应先调用 `supportMaxWorldClockCount` 获取设备支持的最大数量，避免超限
6. **模型创建限制：** `TSWorldClockModel` 的 `init`、`new`、`copy` 和 `mutableCopy` 方法不可用，必须使用提供的工厂方法创建实例
7. **不可用属性：** `timeFormat`、`longitude` 和 `latitude` 属性暂不可用，请勿使用
8. **回调执行线程：** 所有完成回调均在主线程执行
9. **错误处理：** 始终检查回调中的 `error` 参数，不为 `nil` 时表示操作失败
10. **模型比较：** 两个世界时钟模型相等的条件是 `clockId`、`cityName`、`timeZoneIdentifier` 和 `utcOffsetInSeconds` 都相同