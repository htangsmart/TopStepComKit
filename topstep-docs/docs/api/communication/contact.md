---
sidebar_position: 2
title: 联系人
---

# 联系人 (TSContact)

该模块定义了与设备通讯录相关的所有操作，包括普通联系人的读写、紧急联系人的读写以及通讯录变化的实时监听。开发者可以通过该模块管理设备上的联系人信息、设置紧急联系人并监听相关事件。

## 前提条件

1. 设备已连接并初始化
2. 已获得 `TSContactInterface` 协议的实例
3. 对于紧急联系人功能，建议先调用 `isSupportEmergencyContacts` 检查设备是否支持
4. 在设置大量联系人前，使用 `supportMaxContacts` 和 `supportMaxEmergencyContacts` 了解设备容量限制

## 数据模型

### TopStepContactModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `name` | `NSString *` | 联系人姓名。支持中英文字符，不能为空，超过 32 字节会自动截断（保持 UTF-8 完整性）|
| `phoneNum` | `NSString *` | 联系人电话号码。仅支持数字和加号(+)，不能为空，超过 20 字节会自动截断（保持 UTF-8 完整性）|
| `shortName` | `NSString *` | 分类简称，用于联系人列表索引、搜索和字母排序，通常为姓名首字母 |

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(NSArray<TopStepContactModel *> * _Nullable allContacts, NSError * _Nullable error)` | 通讯录变化监听回调，返回更新后的联系人数组和错误信息 |
| `void (^)(NSArray<TopStepContactModel *> * _Nullable emergencyContact, BOOL isSosOn, NSError * _Nullable error)` | 获取紧急联系人回调，返回紧急联系人数组、开关状态和错误信息 |
| `void (^)(NSError * _Nullable error)` | SOS 请求回调，返回错误信息 |
| `TSCompletionBlock` | 标准完成回调，返回操作成功状态和错误信息 |

## 接口方法

### 获取设备支持的最大联系人数量

```objc
- (NSInteger)supportMaxContacts;
```

**说明：** 返回设备可以存储的最大联系人数量。此限制因设备型号和固件版本而异。

**返回值：** 设备支持的最大联系人数量

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;
NSInteger maxContacts = [contact supportMaxContacts];
TSLog(@"设备最多可存储 %ld 个联系人", (long)maxContacts);
```

---

### 获取所有联系人

```objc
- (void)getAllContacts:(void (^)(NSArray<TopStepContactModel *> *_Nullable allContacts,
                                 NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, NSError *)` | 获取完成的回调。成功时 `allContacts` 为联系人数组、`error` 为 `nil`；失败时 `allContacts` 为 `nil`、`error` 包含错误信息 |

**说明：** 从设备获取所有已保存的联系人信息。

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

[contact getAllContacts:^(NSArray<TopStepContactModel *> *allContacts, 
                                    NSError *error) {
    if (error) {
        TSLog(@"获取联系人失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"成功获取 %lu 个联系人", (unsigned long)allContacts.count);
    for (TopStepContactModel *contact in allContacts) {
        TSLog(@"联系人: %@, 电话: %@", contact.name, contact.phoneNum);
    }
}];
```

---

### 设置所有联系人

```objc
- (void)setAllContacts:(NSArray<TopStepContactModel *> *_Nullable)allContacts
            completion:(TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `allContacts` | `NSArray<TopStepContactModel *> *` | 要设置的联系人数组。此操作会覆盖设备上已有的所有联系人 |
| `completion` | `TSCompletionBlock` | 设置完成的回调。返回操作是否成功和错误信息 |

**说明：** 将联系人列表同步到设备，会覆盖设备上已有的所有联系人。

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

// 创建联系人数组
NSMutableArray<TopStepContactModel *> *contacts = [NSMutableArray array];
[contacts addObject:[TopStepContactModel contactWithName:@"张三" phoneNum:@"13800138000"]];
[contacts addObject:[TopStepContactModel contactWithName:@"李四" phoneNum:@"+86 13900139000"]];

// 设置到设备
[contact setAllContacts:contacts completion:^(BOOL success, NSError *error) {
    if (error) {
        TSLog(@"设置联系人失败: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"成功设置 %lu 个联系人到设备", (unsigned long)contacts.count);
    } else {
        TSLog(@"设置联系人失败");
    }
}];
```

---

### 获取设备支持的最大紧急联系人数量

```objc
- (NSInteger)supportMaxEmergencyContacts;
```

**说明：** 返回设备可以存储的最大紧急联系人数量。此限制因设备型号和固件版本而异。

**返回值：** 设备支持的最大紧急联系人数量

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;
NSInteger maxEmergencyContacts = [contact supportMaxEmergencyContacts];
TSLog(@"设备最多可存储 %ld 个紧急联系人", (long)maxEmergencyContacts);
```

---

### 检查是否支持紧急联系人功能

```objc
- (BOOL)isSupportEmergencyContacts;
```

**说明：** 检查连接的设备是否支持紧急联系人功能。一些较老的设备或特定型号的设备可能不支持此功能。建议在使用紧急联系人相关操作之前先调用此方法进行检查。

**返回值：** 如果设备支持紧急联系人功能返回 `YES`，否则返回 `NO`

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

if ([contact isSupportEmergencyContacts]) {
    TSLog(@"设备支持紧急联系人功能");
} else {
    TSLog(@"设备不支持紧急联系人功能");
}
```

---

### 获取紧急联系人

```objc
- (void)getEmergencyContacts:(void (^)(NSArray<TopStepContactModel *> *_Nullable emergencyContact, BOOL isSosOn,
                                       NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, BOOL, NSError *)` | 获取完成的回调。返回紧急联系人数组、SOS 开关状态和错误信息 |

**说明：** 从设备获取已设置的紧急联系人信息。

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

[contact getEmergencyContacts:^(NSArray<TopStepContactModel *> *emergencyContact, BOOL isSosOn,
                                         NSError *error) {
    if (error) {
        TSLog(@"获取紧急联系人失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"SOS 开关状态: %@", isSosOn ? @"开启" : @"关闭");
    TSLog(@"成功获取 %lu 个紧急联系人", (unsigned long)emergencyContact.count);
    for (TopStepContactModel *contact in emergencyContact) {
        TSLog(@"紧急联系人: %@, 电话: %@", contact.name, contact.phoneNum);
    }
}];
```

---

### 设置紧急联系人

```objc
- (void)setEmergencyContacts:(NSArray<TopStepContactModel *> *_Nullable)emergencyContacts
                       sosOn:(BOOL)isSosOn
                  completion:(TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `emergencyContacts` | `NSArray<TopStepContactModel *> *` | 要设置的紧急联系人数组（可多个）|
| `isSosOn` | `BOOL` | 是否打开紧急联系人功能开关 |
| `completion` | `TSCompletionBlock` | 设置完成的回调。返回操作是否成功和错误信息 |

**说明：** 将紧急联系人信息同步到设备。

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

// 创建紧急联系人数组
NSMutableArray<TopStepContactModel *> *emergencyContacts = [NSMutableArray array];
[emergencyContacts addObject:[TopStepContactModel contactWithName:@"紧急联系人1" 
                                                          phoneNum:@"120"]];
[emergencyContacts addObject:[TopStepContactModel contactWithName:@"紧急联系人2" 
                                                          phoneNum:@"110"]];

// 设置紧急联系人（并打开 SOS 开关）
[contact setEmergencyContacts:emergencyContacts 
                                sosOn:YES 
                           completion:^(BOOL success, NSError *error) {
    if (error) {
        TSLog(@"设置紧急联系人失败: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"成功设置 %lu 个紧急联系人，SOS 开关已开启", (unsigned long)emergencyContacts.count);
    } else {
        TSLog(@"设置紧急联系人失败");
    }
}];
```

---

### 注册通讯录变化监听

```objc
- (void)registerContactsDidChangedBlock:(void (^)(NSArray<TopStepContactModel *> * _Nullable allContacts,
                                                   NSError * _Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, NSError *)` | 通讯录变化时的回调。当设备端通讯录发生变化时此回调会被触发，返回更新后的联系人数组和错误信息 |

**说明：** 当设备端通讯录发生变化时，此回调会被触发。

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

[contact registerContactsDidChangedBlock:^(NSArray<TopStepContactModel *> *allContacts, 
                                                     NSError *error) {
    if (error) {
        TSLog(@"监听通讯录变化失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"设备通讯录已更新，现有 %lu 个联系人", (unsigned long)allContacts.count);
    for (TopStepContactModel *contact in allContacts) {
        TSLog(@"联系人: %@, 电话: %@", contact.name, contact.phoneNum);
    }
}];
```

---

### 注册紧急联系人变化监听

```objc
- (void)registerEmergencyContactsDidChangedBlock:(void (^)(NSArray<TopStepContactModel *> *_Nullable allContacts,
                                                           NSError * _Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, NSError *)` | 紧急联系人变化时的回调。当设备端紧急联系人发生变化时此回调会被触发，返回更新后的紧急联系人数组和错误信息 |

**说明：** 当设备端紧急联系人发生变化时，此回调会被触发。部分设备可能不支持此功能，此时会返回相应的错误信息。

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

[contact registerEmergencyContactsDidChangedBlock:^(NSArray<TopStepContactModel *> *allContacts, 
                                                              NSError *error) {
    if (error) {
        TSLog(@"监听紧急联系人变化失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"设备紧急联系人已更新，现有 %lu 个紧急联系人", (unsigned long)allContacts.count);
    for (TopStepContactModel *contact in allContacts) {
        TSLog(@"紧急联系人: %@, 电话: %@", contact.name, contact.phoneNum);
    }
}];
```

---

### 注册 SOS 请求监听

```objc
- (void)registerSOSRequestBlock:(void (^)(NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSError *)` | SOS 请求触发时的回调。当设备发送 SOS 请求时此回调会被立即调用，返回错误信息 |

**说明：** 当设备发送 SOS 请求时，此回调会被触发。回调会在 SOS 被触发时立即被调用。

**代码示例：**
```objc
id<TSContactInterface> contact = [TopStepComKit sharedInstance].contact;

[contact registerSOSRequestBlock:^(NSError *error) {
    if (error) {
        TSLog(@"SOS 监听设置失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"SOS 请求已收到，设备触发了紧急求救");
    // 这里可以进行相应的处理，如发送通知、记录日志等
}];
```

---

### 创建联系人（自动生成简称）

```objc
+ (instancetype)contactWithName:(NSString *)name phoneNum:(NSString *)phoneNum;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `name` | `NSString *` | 联系人姓名，不能为空。超过 32 字节会自动截断（保持 UTF-8 完整性）|
| `phoneNum` | `NSString *` | 联系人电话号码，不能为空。超过 20 字节会自动截断（保持 UTF-8 完整性）|

**返回值：** 创建的联系人对象，如果参数无效（空字符串）则返回 `nil`

**说明：** 工厂方法创建联系人对象，会根据提供的姓名自动生成 `shortName`。

**代码示例：**
```objc
// 创建单个联系人
TopStepContactModel *contact = [TopStepContactModel contactWithName:@"张三" 
                                                             phoneNum:@"13800138000"];
if (contact) {
    TSLog(@"创建联系人成功: %@, 简称: %@", contact.name, contact.shortName);
} else {
    TSLog(@"创建联系人失败，参数无效");
}

// 创建多个联系人
NSMutableArray<TopStepContactModel *> *contacts = [NSMutableArray array];
TopStepContactModel *contact1 = [TopStepContactModel contactWithName:@"李四" 
                                                             phoneNum:@"13900139000"];
TopStepContactModel *contact2 = [TopStepContactModel contactWithName:@"王五" 
                                                             phoneNum:@"+86 13700137000"];
if (contact1) [contacts addObject:contact1];
if (contact2) [contacts addObject:contact2];
```

---

### 创建联系人（自定义简称）

```objc
+ (instancetype)contactWithName:(NSString *)name phoneNum:(NSString *)phoneNum shortName:(NSString *)shortName;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `name` | `NSString *` | 联系人姓名，不能为空。超过 32 字节会自动截断（保持 UTF-8 完整性）|
| `phoneNum` | `NSString *` | 联系人电话号码，不能为空。超过 20 字节会自动截断（保持 UTF-8 完整性）|
| `shortName` | `NSString *` | 用于分类的简称，通常是姓名的首字母 |

**返回值：** 创建的联系人对象，如果参数无效（空字符串）则返回 `nil`

**说明：** 工厂方法创建联系人对象，支持指定自定义的 `shortName`。

**代码示例：**
```objc
// 创建具有自定义简称的联系人
TopStepContactModel *contact = [TopStepContactModel contactWithName:@"张三" 
                                                            phoneNum:@"13800138000" 
                                                           shortName:@"ZS"];
if (contact) {
    TSLog(@"创建联系人成功: %@, 简称: %@", contact.name, contact.shortName);
} else {
    TSLog(@"创建联系人失败，参数无效");
}

// 创建紧急联系人
TopStepContactModel *emergencyContact = [TopStepContactModel contactWithName:@"紧急" 
                                                                     phoneNum:@"120" 
                                                                    shortName:@"E"];
```

---

## 注意事项

1. **字符串长度限制**：`name` 属性最多 32 字节，`phoneNum` 属性最多 20 字节。超过限制会自动截断，但会保持 UTF-8 字符完整性，建议使用较短的名字和标准电话号码格式以避免截断。

2. **电话号码格式**：仅支持数字和加号(+)，不支持空格、连字符、括号等其他特殊字符。建议统一清理电话号码格式后再使用。

3. **空值检查**：创建联系人时，如果 `name` 或 `phoneNum` 为空字符串或 `nil`，工厂方法会返回 `nil`，使用时需进行判空处理。

4. **数据覆盖**：调用 `setAllContacts:completion:` 会覆盖设备上的所有联系人，建议先调用 `getAllContacts:` 备份现有数据，或明确确认要覆盖后再操作。

5. **容量检查**：在设置联系人前，建议使用 `supportMaxContacts` 检查设备容量，避免因超出容量而导致操作失败。

6. **紧急联系人功能检查**：在使用紧急联系人相关操作前，务必先调用 `isSupportEmergencyContacts` 确认设备是否支持此功能，某些设备可能不支持。

7. **异步操作**：所有读写操作都是异步的，必须通过回调处理结果，不要在同步代码中等待操作完成。

8. **监听注册**：一旦注册了监听回调（如 `registerContactsDidChangedBlock:`），在设备断开连接前此回调会持续被触发，无需重复注册。

9. **SOS 功能**：SOS 请求通常由设备硬件触发，确保设备已正确配置并设置了有效的紧急联系人。

10. **错误处理**：总是检查回调中的 `error` 参数，当 `error` 不为 `nil` 时表示操作失败，应根据错误信息进行相应的用户提示或重试逻辑。