---
sidebar_position: 1
title: Message
---

# TSMessage

The TSMessage module provides a comprehensive interface for managing message notifications on connected devices. It enables applications to query supported notification types, retrieve current notification settings, configure which notifications should be enabled or disabled, and monitor real-time changes to notification preferences.

## Prerequisites

- TopStepComKit iOS SDK must be properly integrated into your project
- The connected device must support message notification functionality
- You must have the appropriate permissions to access and modify device notification settings
- A valid connection to the device must be established before calling any message notification methods

## Data Models

### TSMessageModel

Message notification configuration model used to manage device message notification settings.

| Property | Type | Description |
|----------|------|-------------|
| `type` | `TSMessageType` | The message notification type, see TSMessageType enumeration for available types |
| `enable` | `BOOL` | Whether this notification type is enabled; YES to enable, NO to disable |

## Enumerations

### TSMessageType

Message notification types supported by the device. Each type represents a specific notification category.

| Value | Raw Value | Description |
|-------|-----------|-------------|
| `TSMessage_Total` | 0 | Total number of message types |
| `TSMessage_Phone` | 1 | Phone call notifications |
| `TSMessage_Messages` | 2 | SMS notifications |
| `TSMessage_WeChat` | 3 | WeChat notifications |
| `TSMessage_QQ` | 4 | QQ notifications |
| `TSMessage_Facebook` | 5 | Facebook notifications |
| `TSMessage_Twitter` | 6 | Twitter notifications |
| `TSMessage_Instagram` | 7 | Instagram notifications |
| `TSMessage_Skype` | 8 | Skype notifications |
| `TSMessage_WhatsApp` | 9 | WhatsApp notifications |
| `TSMessage_Line` | 10 | Line notifications |
| `TSMessage_KakaoTalk` | 11 | KakaoTalk notifications |
| `TSMessage_Email` | 12 | Email notifications |
| `TSMessage_Messenger` | 13 | Facebook Messenger notifications |
| `TSMessage_Zalo` | 14 | Zalo notifications |
| `TSMessage_Telegram` | 15 | Telegram notifications |
| `TSMessage_Viber` | 16 | Viber notifications |
| `TSMessage_NateOn` | 17 | NateOn notifications |
| `TSMessage_Gmail` | 18 | Gmail notifications |
| `TSMessage_Calendar` | 19 | Calendar notifications |
| `TSMessage_DailyHunt` | 20 | DailyHunt notifications |
| `TSMessage_Outlook` | 21 | Outlook notifications |
| `TSMessage_Yahoo` | 22 | Yahoo notifications |
| `TSMessage_Inshorts` | 23 | Inshorts notifications |
| `TSMessage_Phonepe` | 24 | Phonepe notifications |
| `TSMessage_Gpay` | 25 | Google Pay notifications |
| `TSMessage_Paytm` | 26 | Paytm notifications |
| `TSMessage_Swiggy` | 27 | Swiggy notifications |
| `TSMessage_Zomato` | 28 | Zomato notifications |
| `TSMessage_Uber` | 29 | Uber notifications |
| `TSMessage_Ola` | 30 | Ola notifications |
| `TSMessage_ReflexApp` | 31 | ReflexApp notifications |
| `TSMessage_Snapchat` | 32 | Snapchat notifications |
| `TSMessage_YtMusic` | 33 | YouTube Music notifications |
| `TSMessage_YouTube` | 34 | YouTube notifications |
| `TSMessage_LinkEdin` | 35 | LinkedIn notifications |
| `TSMessage_Amazon` | 36 | Amazon notifications |
| `TSMessage_Flipkart` | 37 | Flipkart notifications |
| `TSMessage_NetFlix` | 38 | Netflix notifications |
| `TSMessage_Hotstar` | 39 | Hotstar notifications |
| `TSMessage_AmazonPrime` | 40 | Amazon Prime notifications |
| `TSMessage_GoogleChat` | 41 | Google Chat notifications |
| `TSMessage_Wynk` | 42 | Wynk notifications |
| `TSMessage_GoogleDrive` | 43 | Google Drive notifications |
| `TSMessage_Dunzo` | 44 | Dunzo notifications |
| `TSMessage_Gaana` | 45 | Gaana notifications |
| `TSMessage_MissCall` | 46 | Missed call notifications |
| `TSMessage_WhatsAppBusiness` | 47 | WhatsApp Business notifications |
| `TSMessage_Dingtalk` | 48 | Dingtalk notifications |
| `TSMessage_Tiktok` | 49 | TikTok notifications |
| `TSMessage_Lyft` | 50 | Lyft notifications |
| `TSMessage_GoogleMaps` | 51 | Google Maps notifications |
| `TSMessage_Slack` | 52 | Slack notifications |
| `TSMessage_MicrosoftTeams` | 53 | Microsoft Teams notifications |
| `TSMessage_MormaiiSmartwatches` | 54 | Mormaii Smartwatches notifications |
| `TSMessage_Reddit` | 55 | Reddit notifications |
| `TSMessage_Discord` | 56 | Discord notifications |
| `TSMessage_Gojek` | 57 | Gojek notifications |
| `TSMessage_Lark` | 58 | Lark notifications |
| `TSMessage_Garb` | 59 | Garb notifications |
| `TSMessage_Shopee` | 60 | Shopee notifications |
| `TSMessage_Tokopedia` | 61 | Tokopedia notifications |
| `TSMessage_Hinge` | 62 | Hinge notifications |
| `TSMessage_Myntra` | 63 | Myntra notifications |
| `TSMessage_Meesho` | 64 | Meesho notifications |
| `TSMessage_Zivame` | 65 | Zivame notifications |
| `TSMessage_Ajio` | 66 | Ajio notifications |
| `TSMessage_Urbanic` | 67 | Urbanic notifications |
| `TSMessage_Nykaa` | 68 | Nykaa notifications |
| `TSMessage_Healthifyme` | 69 | Healthifyme notifications |
| `TSMessage_Cultfit` | 70 | Cultfit notifications |
| `TSMessage_Flo` | 71 | Flo notifications |
| `TSMessage_Bumble` | 72 | Bumble notifications |
| `TSMessage_Tira` | 73 | Tira notifications |
| `TSMessage_Hike` | 74 | Hike notifications |
| `TSMessage_AppleMusic` | 75 | Apple Music notifications |
| `TSMessage_Zoom` | 76 | Zoom notifications |
| `TSMessage_Fastrack` | 77 | Fastrack notifications |
| `TSMessage_TitanSmartWorld` | 78 | Titan Smart World notifications |
| `TSMessage_Pinterest` | 79 | Pinterest notifications |
| `TSMessage_Alipay` | 80 | Alipay notifications |
| `TSMessage_FaceTime` | 81 | FaceTime notifications |
| `TSMessage_Hangouts` | 82 | Hangouts notifications |
| `TSMessage_VK` | 83 | VK notifications |
| `TSMessage_Weibo` | 84 | Weibo notifications |
| `TSMessage_Other` | 85 | Other app notifications |

## Callback Types

### TSMessageListBlock

Callback block invoked when retrieving or modifying message notification lists.

```objc
typedef void(^TSMessageListBlock)(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `notifications` | `NSArray<TSMessageModel *> *` | Array of message models; nil if operation fails |
| `error` | `NSError *` | Error information if operation fails; nil on success |

## API Reference

### Create a message model with specified type

```objc
+ (instancetype)modelWithType:(TSMessageType)type;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | `TSMessageType` | The message type to create model for |

**Return Value:** `instancetype` — A new TSMessageModel instance with the specified type (enable property defaults to NO)

**Code Example:**

```objc
TSMessageModel *model = [TSMessageModel modelWithType:TSMessage_WeChat];
TSLog(@"Created model with type: %ld, enable: %d", (long)model.type, model.isEnable);
```

### Create a message model with specified type and enable status

```objc
+ (instancetype)modelWithType:(TSMessageType)type enable:(BOOL)enable;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | `TSMessageType` | The message type to create model for |
| `enable` | `BOOL` | Whether the message type is enabled |

**Return Value:** `instancetype` — A new TSMessageModel instance with the specified type and enable status

**Code Example:**

```objc
TSMessageModel *model = [TSMessageModel modelWithType:TSMessage_WeChat enable:YES];
TSLog(@"Created model: type=%ld, enable=%d", (long)model.type, model.isEnable);
```

### Get the list of enabled messages

```objc
- (void)getMessageEnableList:(nullable TSMessageListBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSMessageListBlock` | Completion callback returning array of message models and error information |

**Code Example:**

```objc
id<TSMessageInterface> messageInterface = (id<TSMessageInterface>)device;
[messageInterface getMessageEnableList:^(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get message enable list: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Retrieved %lu message notification settings:", (unsigned long)notifications.count);
    for (TSMessageModel *model in notifications) {
        TSLog(@"Type: %ld, Enabled: %d", (long)model.type, model.isEnable);
    }
}];
```

### Set the list of enabled messages

```objc
- (void)setMessageEnableList:(NSArray<TSMessageModel *> *)messages
                  completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `messages` | `NSArray<TSMessageModel *> *` | Array of message models with desired enable status |
| `completion` | `TSCompletionBlock` | Completion callback returning operation success status and error information |

**Code Example:**

```objc
id<TSMessageInterface> messageInterface = (id<TSMessageInterface>)device;

NSMutableArray<TSMessageModel *> *messagesToSet = [NSMutableArray array];
[messagesToSet addObject:[TSMessageModel modelWithType:TSMessage_WeChat enable:YES]];
[messagesToSet addObject:[TSMessageModel modelWithType:TSMessage_Phone enable:NO]];
[messagesToSet addObject:[TSMessageModel modelWithType:TSMessage_Messages enable:YES]];

[messageInterface setMessageEnableList:messagesToSet completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set message enable list: %@", error.localizedDescription);
        return;
    }
    TSLog(@"Message enable list updated successfully");
}];
```

### Get the list of supported messages

```objc
- (void)getSupportMessageList:(nullable TSMessageListBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSMessageListBlock` | Completion callback returning array of supported message models and error information |

**Code Example:**

```objc
id<TSMessageInterface> messageInterface = (id<TSMessageInterface>)device;
[messageInterface getSupportMessageList:^(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get supported message list: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Device supports %lu message types:", (unsigned long)notifications.count);
    for (TSMessageModel *model in notifications) {
        TSLog(@"Supported type: %ld", (long)model.type);
    }
}];
```

### Register for message notification changes

```objc
- (void)registerMessageDidChanged:(nullable TSMessageListBlock)messageDidChangedBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `messageDidChangedBlock` | `TSMessageListBlock` | Callback invoked when notification settings change on device or app side |

**Code Example:**

```objc
id<TSMessageInterface> messageInterface = (id<TSMessageInterface>)device;
[messageInterface registerMessageDidChanged:^(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Error observing message changes: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Message notification settings changed:");
    for (TSMessageModel *model in notifications) {
        TSLog(@"Type: %ld, Enable: %d", (long)model.type, model.isEnable);
    }
}];
```

## Important Notes

1. Always check the error parameter in completion blocks before processing the returned data; a nil error indicates successful operation while a non-nil error indicates failure.

2. When calling `setMessageEnableList:completion:`, ensure the messages array is not empty; passing an empty array will result in a parameter error.

3. The `enable` property of TSMessageModel uses a getter method `isEnable` to retrieve its value; use `model.isEnable` or `model.enable` to access this property.

4. Message notification changes can be triggered either by the device itself or by the connected application; register the change callback early to capture all modifications.

5. The `getSupportMessageList:` method is not yet fully supported and will be implemented in a future SDK version.

6. Use `modelWithType:` for creating models with default disabled status or `modelWithType:enable:` when you need to specify both type and enable status during model creation.

7. The TSMessage_Total type with value 0 represents the total count of message types and is not a valid notification type to enable or disable.