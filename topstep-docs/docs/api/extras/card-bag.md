---
sidebar_position: 7
title: 卡包
---

# 卡包模块 (TSCardBag)

卡包模块提供了对设备中电子卡片的管理功能，包括获取卡片信息、设置新卡片、删除卡片以及对卡片进行排序等操作。支持电子钱包卡片（如微信支付宝等收款码）和电子名片卡片（如微信名片、Facebook等）两大类别。

## 前提条件

1. 已成功建立与设备的连接
2. 设备固件支持电子卡片功能
3. 获得有效的 `TSECardBagInterface` 实例
4. 卡片数据必须符合设备限制（最大卡片数量、名称长度、URL长度等）

## 数据模型

### TSECardModel

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `cardId` | `NSInteger` | 卡片的唯一标识符，范围 0-255 |
| `cardType` | `TSECardType` | 卡片类型，如微信支付、微信名片等 |
| `cardName` | `NSString *` | 卡片的显示名称，不能为空 |
| `cardURL` | `NSString *` | 卡片URL，用于生成二维码 |

## 枚举与常量

### TSECardType 卡片类型枚举

| 枚举值 | 数值 | 说明 |
|-------|------|------|
| `TSECardTypeUnknow` | `0` | 未知类型 |
| `TSECardTypeWechatPay` | `100` | 微信收款码 |
| `TSECardTypeAlipay` | `101` | 支付宝收款码 |
| `TSECardTypePayPal` | `102` | PayPal 收款码 |
| `TSECardTypeQQPay` | `103` | QQ 收款码 |
| `TSECardTypePaytm` | `104` | Paytm 收款码 |
| `TSECardTypePhonePe` | `105` | PhonePe 收款码 |
| `TSECardTypeGPay` | `106` | GPay 收款码 |
| `TSECardTypeBHIM` | `107` | BHIM 收款码 |
| `TSECardTypeMomo` | `108` | Momo 收款码 |
| `TSECardTypeZalo` | `109` | Zalo 收款码 |
| `TSECardTypeWechat` | `1000` | 微信名片 |
| `TSECardTypeAlipayBusiness` | `1001` | 支付宝名片 |
| `TSECardTypeQQ` | `1002` | QQ 名片 |
| `TSECardTypeFacebook` | `1003` | Facebook 名片 |
| `TSECardTypeWhatsApp` | `1004` | WhatsApp 名片 |
| `TSECardTypeTwitter` | `1005` | Twitter 名片 |
| `TSECardTypeInstagram` | `1006` | Instagram 名片 |
| `TSECardTypeMessenger` | `1007` | Messenger 名片 |
| `TSECardTypeLINE` | `1008` | LINE 名片 |
| `TSECardTypeSnapchat` | `1009` | Snapchat 名片 |
| `TSECardTypeSkype` | `1010` | Skype 名片 |
| `TSECardTypeEmail` | `1011` | 邮箱名片 |
| `TSECardTypePhone` | `1012` | 电话名片 |
| `TSECardTypeLinkedIn` | `1013` | LinkedIn 名片 |
| `TSECardTypeNucleicAcid` | `1014` | 核酸码 |

## 回调类型

| 回调类型 | 参数 | 说明 |
|--------|------|------|
| `void (^)(NSArray<TSECardModel *>* _Nullable, NSError * _Nullable)` | 卡片数组、错误对象 | 用于获取卡片列表的回调 |
| `void (^)(BOOL, NSError * _Nullable)` | 成功标志、错误对象 | 用于卡片操作（增删改查）的回调 |

## 接口方法

### 获取设备支持的最大卡片数量

```objc
- (NSInteger)supportMaxCardsCount;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `NSInteger` - 设备可存储的最大卡片数量

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;
NSInteger maxCount = [eCardBag supportMaxCardsCount];
TSLog(@"设备最大支持卡片数: %ld", (long)maxCount);
```

---

### 获取卡片名称的最大字节长度

```objc
- (NSInteger)supportMaxCardNameLength;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `NSInteger` - 卡片名称的最大字节数

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;
NSInteger maxNameLength = [eCardBag supportMaxCardNameLength];
TSLog(@"卡片名称最大字节长度: %ld", (long)maxNameLength);
```

---

### 获取卡片URL的最大字节长度

```objc
- (NSInteger)supportMaxCardURLLength;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `NSInteger` - 卡片URL的最大字节数

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;
NSInteger maxURLLength = [eCardBag supportMaxCardURLLength];
TSLog(@"卡片URL最大字节长度: %ld", (long)maxURLLength);
```

---

### 获取所有电子钱包卡片

```objc
- (void)getAllWalletCardsCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable walletCards, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(NSArray<TSECardModel *>*, NSError *)` | 完成回调，返回所有钱包卡片数组和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;
[eCardBag getAllWalletCardsCompletion:^(NSArray<TSECardModel *> * _Nullable walletCards, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取钱包卡片失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"获取到 %ld 张钱包卡片", (long)walletCards.count);
    for (TSECardModel *card in walletCards) {
        TSLog(@"卡片: %@ (类型: %ld)", card.cardName, (long)card.cardType);
    }
}];
```

---

### 获取所有电子名片卡片

```objc
- (void)getAllBusinessCardsCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable businessCards, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(NSArray<TSECardModel *>*, NSError *)` | 完成回调，返回所有名片卡片数组和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;
[eCardBag getAllBusinessCardsCompletion:^(NSArray<TSECardModel *> * _Nullable businessCards, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取名片卡片失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"获取到 %ld 张名片卡片", (long)businessCards.count);
    for (TSECardModel *card in businessCards) {
        TSLog(@"名片: %@", card.cardName);
    }
}];
```

---

### 获取所有电子卡片

```objc
- (void)getAllECardCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable allECards, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(NSArray<TSECardModel *>*, NSError *)` | 完成回调，返回所有卡片数组和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;
[eCardBag getAllECardCompletion:^(NSArray<TSECardModel *> * _Nullable allECards, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取卡片失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"设备中共有 %ld 张卡片", (long)allECards.count);
    for (TSECardModel *card in allECards) {
        TSLog(@"ID: %ld, 名称: %@, URL: %@", (long)card.cardId, card.cardName, card.cardURL);
    }
}];
```

---

### 设置单张电子卡片

```objc
- (void)setECard:(TSECardModel *)eCard completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `eCard` | `TSECardModel *` | 要设置到设备的电子卡片模型 |
| `completion` | `void (^)(BOOL, NSError *)` | 完成回调，返回成功标志和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;

TSECardModel *newCard = [TSECardModel cardWithId:1
                                            type:TSECardTypeWechatPay
                                            name:@"微信收款"
                                             url:@"https://example.com/wechat"];
if (!newCard) {
    TSLog(@"创建卡片失败");
    return;
}

[eCardBag setECard:newCard completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置卡片失败: %@", error.localizedDescription);
        return;
    }
    if (isSuccess) {
        TSLog(@"卡片设置成功");
    } else {
        TSLog(@"卡片设置失败");
    }
}];
```

---

### 设置所有电子卡片

```objc
- (void)setAllECards:(NSArray<TSECardModel *> *)eCards completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `eCards` | `NSArray<TSECardModel *> *` | 要设置到设备的电子卡片模型数组 |
| `completion` | `void (^)(BOOL, NSError *)` | 完成回调，返回成功标志和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;

NSMutableArray<TSECardModel *> *cards = [NSMutableArray array];

TSECardModel *card1 = [TSECardModel cardWithId:1
                                         type:TSECardTypeWechatPay
                                         name:@"微信收款"
                                          url:@"https://example.com/wechat"];
[cards addObject:card1];

TSECardModel *card2 = [TSECardModel cardWithId:2
                                         type:TSECardTypeAlipay
                                         name:@"支付宝收款"
                                          url:@"https://example.com/alipay"];
[cards addObject:card2];

[eCardBag setAllECards:cards completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (error) {
        TSLog(@"批量设置卡片失败: %@", error.localizedDescription);
        return;
    }
    if (isSuccess) {
        TSLog(@"批量设置卡片成功");
    } else {
        TSLog(@"批量设置卡片失败");
    }
}];
```

---

### 删除单张电子卡片

```objc
- (void)deleteECard:(TSECardModel *)eCard completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `eCard` | `TSECardModel *` | 要删除的电子卡片模型 |
| `completion` | `void (^)(BOOL, NSError *)` | 完成回调，返回成功标志和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;

TSECardModel *cardToDelete = [TSECardModel cardWithId:1
                                                 type:TSECardTypeWechatPay
                                                 name:@"微信收款"
                                                  url:@"https://example.com/wechat"];

[eCardBag deleteECard:cardToDelete completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (error) {
        TSLog(@"删除卡片失败: %@", error.localizedDescription);
        return;
    }
    if (isSuccess) {
        TSLog(@"卡片删除成功");
    } else {
        TSLog(@"卡片删除失败");
    }
}];
```

---

### 批量删除电子卡片

```objc
- (void)deleteECardsWithIds:(NSArray<NSNumber *> *)cardIds completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `cardIds` | `NSArray<NSNumber *> *` | 要删除的卡片ID数组 |
| `completion` | `void (^)(BOOL, NSError *)` | 完成回调，返回成功标志和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;

NSArray<NSNumber *> *cardIds = @[@1, @2, @3];

[eCardBag deleteECardsWithIds:cardIds completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (error) {
        TSLog(@"批量删除卡片失败: %@", error.localizedDescription);
        return;
    }
    if (isSuccess) {
        TSLog(@"批量删除卡片成功");
    } else {
        TSLog(@"批量删除卡片失败");
    }
}];
```

---

### 对电子卡片进行排序

```objc
- (void)sortECardsWithIds:(NSArray<NSNumber *> *)cardIds completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `cardIds` | `NSArray<NSNumber *> *` | 按期望顺序排列的卡片ID数组 |
| `completion` | `void (^)(BOOL, NSError *)` | 完成回调，返回成功标志和错误对象 |

**代码示例：**

```objc
id<TSECardBagInterface> eCardBag = [TopStepComKit sharedInstance].eCardBag;

// 将卡片按 ID 为 3, 1, 2 的顺序排列
NSArray<NSNumber *> *sortedIds = @[@3, @1, @2];

[eCardBag sortECardsWithIds:sortedIds completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (error) {
        TSLog(@"排序卡片失败: %@", error.localizedDescription);
        return;
    }
    if (isSuccess) {
        TSLog(@"卡片排序成功");
    } else {
        TSLog(@"卡片排序失败");
    }
}];
```

---

### 创建卡片模型

```objc
+ (instancetype)cardWithId:(NSInteger)cardId
                      type:(TSECardType)cardType
                      name:(NSString *)cardName
                       url:(NSString *)cardURL;
```

| 参数 | 类型 | 说明 |
|-----|------|------|
| `cardId` | `NSInteger` | 卡片ID，范围 0-255 |
| `cardType` | `TSECardType` | 卡片类型 |
| `cardName` | `NSString *` | 卡片名称 |
| `cardURL` | `NSString *` | 卡片URL |

**返回值：** `TSECardModel *` - 创建的卡片模型实例，参数无效时返回 `nil`

**代码示例：**

```objc
TSECardModel *card = [TSECardModel cardWithId:1
                                        type:TSECardTypeWechatPay
                                        name:@"微信收款"
                                         url:@"https://example.com/wechat"];

if (card) {
    TSLog(@"卡片创建成功: %@", card.cardName);
} else {
    TSLog(@"卡片创建失败，参数无效");
}
```

---

### 检查是否为钱包卡

```objc
- (BOOL)isWalletCard;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `BOOL` - 是钱包卡返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
TSECardModel *card = /* 获取卡片实例 */;
if ([card isWalletCard]) {
    TSLog(@"这是一张钱包卡");
} else {
    TSLog(@"这不是钱包卡");
}
```

---

### 检查是否为名片卡

```objc
- (BOOL)isBusinessCard;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `BOOL` - 是名片卡返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
TSECardModel *card = /* 获取卡片实例 */;
if ([card isBusinessCard]) {
    TSLog(@"这是一张名片卡");
} else {
    TSLog(@"这不是名片卡");
}
```

---

### 获取卡片类型的默认名称

```objc
- (NSString *)defaultCardName;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `NSString *` - 卡片类型的默认显示名称

**代码示例：**

```objc
TSECardModel *card = [TSECardModel cardWithId:1
                                        type:TSECardTypeWechatPay
                                        name:@"自定义名称"
                                         url:@"https://example.com"];

NSString *defaultName = [card defaultCardName];
TSLog(@"默认名称: %@", defaultName);
```

---

### 检查卡片是否有效

```objc
- (BOOL)isValid;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `BOOL` - 卡片有效返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
TSECardModel *card = /* 获取卡片实例 */;
if ([card isValid]) {
    TSLog(@"卡片有效");
} else {
    TSLog(@"卡片无效");
}
```

---

### 检查卡片ID是否有效

```objc
- (BOOL)isValidCardId;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `BOOL` - 卡片ID在 0-255 范围内返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
TSECardModel *card = /* 获取卡片实例 */;
if ([card isValidCardId]) {
    TSLog(@"卡片ID有效");
} else {
    TSLog(@"卡片ID无效");
}
```

---

### 获取所有钱包卡类型

```objc
+ (NSArray<NSNumber *> *)allWalletCardTypes;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `NSArray<NSNumber *> *` - 所有钱包卡类型数组

**代码示例：**

```objc
NSArray<NSNumber *> *walletTypes = [TSECardModel allWalletCardTypes];
TSLog(@"支持的钱包卡类型数: %ld", (long)walletTypes.count);
for (NSNumber *type in walletTypes) {
    TSLog(@"类型: %@", type);
}
```

---

### 获取所有名片卡类型

```objc
+ (NSArray<NSNumber *> *)allBusinessCardTypes;
```

| 参数 | 类型 | 说明 |
|-----|------|------|

**返回值：** `NSArray<NSNumber *> *` - 所有名片卡类型数组

**代码示例：**

```objc
NSArray<NSNumber *> *businessTypes = [TSECardModel allBusinessCardTypes];
TSLog(@"支持的名片卡类型数: %ld", (long)businessTypes.count);
for (NSNumber *type in businessTypes) {
    TSLog(@"类型: %@", type);
}
```

---

## 注意事项

1. **卡片ID限制** - 卡片ID 必须在 0-255 之间，超出此范围将导致创建失败。

2. **卡片数量限制** - 在设置卡片前，应先调用 `supportMaxCardsCount` 获取设备支持的最大卡片数量，避免超过设备容量。

3. **名称和URL长度限制** - 分别调用 `supportMaxCardNameLength` 和 `supportMaxCardURLLength` 获取长度限制，确保卡片名称和URL不超过允许的字节长度。

4. **卡片类型范围** - 钱包卡类型范围为 100-199，名片卡类型范围为 1000-1999，其他值为未知类型。

5. **批量操作的原子性** - `setAllECards:` 方法会先清除所有现有卡片再设置新卡片，请确保传入的卡片数组完整。

6. **参数验证** - 创建卡片时，若任何参数无效，`cardWithId:type:name:url:` 方法会返回 `nil`，应检查返回值。

7. **异步操作** - 所有涉及设备通信的方法都是异步的，需要提供完成回调，完成回调运行在不确定的线程上，UI 操作需要切换到主线程。

8. **卡片唯一性** - 同一设备中不能存在两张相同 ID 的卡片，新增卡片前应确保 ID 未被使用。

9. **排序操作验证** - 排序时提供的卡片ID数组必须与设备中现有卡片的ID完全匹配，否则操作会失败。

10. **错误处理** - 始终检查完成回调中的 `error` 参数，根据错误信息判断失败原因并进行适当的用户提示。

