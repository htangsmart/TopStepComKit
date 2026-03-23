---
sidebar_position: 1
title: 消息通知
---

# 消息通知（TSMessage）

消息通知模块用于管理设备的各类消息通知设置，支持获取、设置和监听消息通知的启用状态。该模块提供了丰富的消息类型定义，覆盖电话、短信、社交应用、支付应用、音乐娱乐等多种场景。

## 前提条件

1. TopStepComKit iOS SDK 已正确集成到项目中
2. 已获得相应的设备权限和接口访问权限
3. 设备支持消息通知功能

## 数据模型

### TSMessageModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `type` | `TSMessageType` | 消息类型，表示当前消息的类型，详见 TSMessageType 枚举 |
| `enable` | `BOOL` | 是否启用，YES 表示启用该类型的通知，NO 表示禁用 |

## 枚举与常量

### TSMessageType

消息通知类型枚举，定义设备可能支持的所有消息通知类型。

| 枚举值 | 说明 |
|--------|------|
| `TSMessage_Total` | 总数 |
| `TSMessage_Phone` | 电话 |
| `TSMessage_Messages` | 短信 |
| `TSMessage_WeChat` | 微信 |
| `TSMessage_QQ` | QQ |
| `TSMessage_Facebook` | Facebook |
| `TSMessage_Twitter` | 推特 |
| `TSMessage_Instagram` | Instagram |
| `TSMessage_Skype` | Skype |
| `TSMessage_WhatsApp` | WhatsApp |
| `TSMessage_Line` | Line |
| `TSMessage_KakaoTalk` | KakaoTalk |
| `TSMessage_Email` | 邮件 |
| `TSMessage_Messenger` | Facebook Messenger |
| `TSMessage_Zalo` | Zalo |
| `TSMessage_Telegram` | Telegram |
| `TSMessage_Viber` | Viber |
| `TSMessage_NateOn` | NateOn |
| `TSMessage_Gmail` | Gmail |
| `TSMessage_Calendar` | 日历 |
| `TSMessage_DailyHunt` | DailyHunt |
| `TSMessage_Outlook` | Outlook |
| `TSMessage_Yahoo` | Yahoo |
| `TSMessage_Inshorts` | Inshorts |
| `TSMessage_Phonepe` | Phonepe |
| `TSMessage_Gpay` | Google Pay |
| `TSMessage_Paytm` | Paytm |
| `TSMessage_Swiggy` | Swiggy |
| `TSMessage_Zomato` | Zomato |
| `TSMessage_Uber` | Uber |
| `TSMessage_Ola` | Ola |
| `TSMessage_ReflexApp` | ReflexApp |
| `TSMessage_Snapchat` | Snapchat |
| `TSMessage_YtMusic` | YouTube Music |
| `TSMessage_YouTube` | YouTube |
| `TSMessage_LinkEdin` | LinkedIn |
| `TSMessage_Amazon` | Amazon |
| `TSMessage_Flipkart` | Flipkart |
| `TSMessage_NetFlix` | Netflix |
| `TSMessage_Hotstar` | Hotstar |
| `TSMessage_AmazonPrime` | Amazon Prime |
| `TSMessage_GoogleChat` | Google Chat |
| `TSMessage_Wynk` | Wynk |
| `TSMessage_GoogleDrive` | Google Drive |
| `TSMessage_Dunzo` | Dunzo |
| `TSMessage_Gaana` | Gaana |
| `TSMessage_MissCall` | 未接来电 |
| `TSMessage_WhatsAppBusiness` | WhatsApp Business |
| `TSMessage_Dingtalk` | 钉钉 |
| `TSMessage_Tiktok` | TikTok |
| `TSMessage_Lyft` | Lyft |
| `TSMessage_GoogleMaps` | Google Maps |
| `TSMessage_Slack` | Slack |
| `TSMessage_MicrosoftTeams` | Microsoft Teams |
| `TSMessage_MormaiiSmartwatches` | Mormaii Smartwatches |
| `TSMessage_Reddit` | Reddit |
| `TSMessage_Discord` | Discord |
| `TSMessage_Gojek` | Gojek |
| `TSMessage_Lark` | 飞书 |
| `TSMessage_Garb` | Garb |
| `TSMessage_Shopee` | Shopee |
| `TSMessage_Tokopedia` | Tokopedia |
| `TSMessage_Hinge` | Hinge |
| `TSMessage_Myntra` | Myntra |
| `TSMessage_Meesho` | Meesho |
| `TSMessage_Zivame` | Zivame |
| `TSMessage_Ajio` | Ajio |
| `TSMessage_Urbanic` | Urbanic |
| `TSMessage_Nykaa` | Nykaa |
| `TSMessage_Healthifyme` | Healthifyme |
| `TSMessage_Cultfit` | Cultfit |
| `TSMessage_Flo` | Flo |
| `TSMessage_Bumble` | Bumble |
| `TSMessage_Tira` | Tira |
| `TSMessage_Hike` | Hike |
| `TSMessage_AppleMusic` | Apple Music |
| `TSMessage_Zoom` | Zoom |
| `TSMessage_Fastrack` | Fastrack |
| `TSMessage_TitanSmartWorld` | Titan Smart World |
| `TSMessage_Pinterest` | Pinterest |
| `TSMessage_Alipay` | 支付宝 |
| `TSMessage_FaceTime` | FaceTime |
| `TSMessage_Hangouts` | Hangouts |
| `TSMessage_VK` | VK |
| `TSMessage_Weibo` | 微博 |
| `TSMessage_Other` | 其他 APP |

## 回调类型

### TSMessageListBlock

```objc
typedef void(^TSMessageListBlock)(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error);
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `notifications` | `NSArray<TSMessageModel *> *` | 消息模型数组，失败时为 nil |
| `error` | `NSError *` | 错误信息，操作成功时为 nil |

## 接口方法

### 获取启用的消息列表

```objc
- (void)getMessageEnableList:(nullable TSMessageListBlock)completion;
```

获取当前设备上所有消息的启用状态列表。

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSMessageListBlock` | 完成回调，返回消息模型数组 |

**代码示例：**

```objc
id<TSMessageInterface> messageInterface = [TopStepComKit sharedInstance].message;
[messageInterface getMessageEnableList:^(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取消息列表失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"获取消息列表成功，共 %lu 条", (unsigned long)notifications.count);
    for (TSMessageModel *msg in notifications) {
        TSLog(@"消息类型: %ld, 启用状态: %@", (long)msg.type, msg.isEnable ? @"YES" : @"NO");
    }
}];
```

### 设置启用的消息列表

```objc
- (void)setMessageEnableList:(NSArray<TSMessageModel *> *)messages
                 completion:(TSCompletionBlock)completion;
```

批量设置消息通知的启用状态。

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `messages` | `NSArray<TSMessageModel *> *` | 要设置的消息模型数组 |
| `completion` | `TSCompletionBlock` | 完成回调，返回操作成功与否及错误信息 |

**代码示例：**

```objc
NSMutableArray<TSMessageModel *> *messagesToSet = [NSMutableArray array];

// 启用微信通知
TSMessageModel *wechatModel = [TSMessageModel modelWithType:TSMessage_WeChat enable:YES];
[messagesToSet addObject:wechatModel];

// 启用 QQ 通知
TSMessageModel *qqModel = [TSMessageModel modelWithType:TSMessage_QQ enable:YES];
[messagesToSet addObject:qqModel];

// 禁用电话通知
TSMessageModel *phoneModel = [TSMessageModel modelWithType:TSMessage_Phone enable:NO];
[messagesToSet addObject:phoneModel];

id<TSMessageInterface> messageInterface = [TopStepComKit sharedInstance].message;
[messageInterface setMessageEnableList:messagesToSet completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置消息列表失败: %@", error.localizedDescription);
    } else {
        TSLog(@"设置消息列表成功");
    }
}];
```

### 获取设备支持的消息列表

```objc
- (void)getSupportMessageList:(nullable TSMessageListBlock)completion;
```

获取当前设备支持的所有消息类型列表。

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSMessageListBlock` | 完成回调，返回设备支持的消息模型数组 |

**代码示例：**

```objc
id<TSMessageInterface> messageInterface = [TopStepComKit sharedInstance].message;
[messageInterface getSupportMessageList:^(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取支持的消息列表失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"设备支持 %lu 种消息类型", (unsigned long)notifications.count);
    for (TSMessageModel *msg in notifications) {
        TSLog(@"支持的消息类型: %ld", (long)msg.type);
    }
}];
```

### 注册消息通知变化提醒

```objc
- (void)registerMessageDidChanged:(nullable TSMessageListBlock)messageDidChangedBlock;
```

监听设备/应用侧的消息通知配置变化，以便及时更新界面或本地存储。

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `messageDidChangedBlock` | `TSMessageListBlock` | 当消息通知配置发生变化时回调；返回当前通知快照及可选错误信息 |

**代码示例：**

```objc
id<TSMessageInterface> messageInterface = [TopStepComKit sharedInstance].message;
[messageInterface registerMessageDidChanged:^(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"消息通知监听发生错误: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"消息通知配置已变化，当前有 %lu 条消息", (unsigned long)notifications.count);
    for (TSMessageModel *msg in notifications) {
        TSLog(@"消息类型: %ld, 启用状态: %@", (long)msg.type, msg.isEnable ? @"启用" : @"禁用");
    }
}];
```

## 数据模型工厂方法

### 根据消息类型创建模型

```objc
+ (instancetype)modelWithType:(TSMessageType)type;
```

根据指定的消息类型创建消息模型，启用属性默认设置为 NO。

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `type` | `TSMessageType` | 要创建模型的消息类型 |

**返回值：** `TSMessageModel *` - 包含指定类型的新实例

**代码示例：**

```objc
TSMessageModel *wechatModel = [TSMessageModel modelWithType:TSMessage_WeChat];
TSLog(@"创建微信消息模型，类型: %ld, 启用状态: %@", (long)wechatModel.type, wechatModel.isEnable ? @"YES" : @"NO");
```

### 根据消息类型和启用状态创建模型

```objc
+ (instancetype)modelWithType:(TSMessageType)type enable:(BOOL)enable;
```

根据指定的消息类型和启用状态创建消息模型。

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `type` | `TSMessageType` | 要创建模型的消息类型 |
| `enable` | `BOOL` | 该消息类型是否启用 |

**返回值：** `TSMessageModel *` - 包含指定类型和启用状态的新实例

**代码示例：**

```objc
// 创建启用的微信消息模型
TSMessageModel *wechatEnabled = [TSMessageModel modelWithType:TSMessage_WeChat enable:YES];

// 创建禁用的电话通知模型
TSMessageModel *phoneDisabled = [TSMessageModel modelWithType:TSMessage_Phone enable:NO];

TSLog(@"微信通知: %@", wechatEnabled.isEnable ? @"启用" : @"禁用");
TSLog(@"电话通知: %@", phoneDisabled.isEnable ? @"启用" : @"禁用");
```

## 注意事项

1. 在获取消息列表失败时，务必检查返回的 error 参数以了解具体失败原因，notifications 参数将为 nil
2. 设置消息启用列表时，如果传入空数组，将返回参数错误
3. `getSupportMessageList:` 方法在当前版本中还未完全实现，将在后续版本中提供支持
4. 注册消息通知变化提醒后，每当设备或应用侧的消息通知配置发生变化时，都会触发对应的回调
5. 使用 `modelWithType:enable:` 方法创建的模型可直接用于 `setMessageEnableList:completion:` 调用
6. 消息类型包括系统消息（电话、短信）和第三方应用通知（社交、支付、娱乐等），根据设备能力可能不是全部支持
7. 建议在设置消息启用列表前，先调用 `getMessageEnableList:` 获取当前状态，避免覆盖不需要修改的配置