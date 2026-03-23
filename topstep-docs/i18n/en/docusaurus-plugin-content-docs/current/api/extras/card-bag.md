---
sidebar_position: 7
title: CardBag
---

# CardBag

The CardBag module provides comprehensive management of electronic cards stored on the device, including wallet payment codes and business cards. It offers methods to retrieve, create, modify, delete, and organize cards while respecting device storage constraints.

## Prerequisites

- The device must be connected and initialized through the TopStepComKit framework
- The application must have appropriate permissions to access device storage
- Card IDs must be unique within the range 0-255
- Card names and URLs must not exceed device firmware limits

## Data Models

### TSECardModel

Represents an electronic card with type, identity, and metadata information.

| Property | Type | Description |
|---|---|---|
| `cardId` | `NSInteger` | Unique identifier of the card (0-255). Used for sorting and deletion operations. |
| `cardType` | `TSECardType` | The type of card (wallet payment codes or business cards). Values 100-199 for wallet cards, 1000-1999 for business cards. |
| `cardName` | `NSString *` | The display name of the card. Cannot be nil. |
| `cardURL` | `NSString *` | The URL that can be used to generate a QR code for the card. Should be a valid URL string. |

## Enumerations

### TSECardType

Enumeration of supported card types organized into wallet and business card categories.

| Value | Name | Description |
|---|---|---|
| `0` | `TSECardTypeUnknow` | Unknown card type |
| `100` | `TSECardTypeWechatPay` | WeChat payment code |
| `101` | `TSECardTypeAlipay` | Alipay payment code |
| `102` | `TSECardTypePayPal` | PayPal payment code |
| `103` | `TSECardTypeQQPay` | QQ payment code |
| `104` | `TSECardTypePaytm` | Paytm payment code |
| `105` | `TSECardTypePhonePe` | PhonePe payment code |
| `106` | `TSECardTypeGPay` | GPay payment code |
| `107` | `TSECardTypeBHIM` | BHIM payment code |
| `108` | `TSECardTypeMomo` | Momo payment code |
| `109` | `TSECardTypeZalo` | Zalo payment code |
| `1000` | `TSECardTypeWechat` | WeChat business card |
| `1001` | `TSECardTypeAlipayBusiness` | Alipay business card |
| `1002` | `TSECardTypeQQ` | QQ business card |
| `1003` | `TSECardTypeFacebook` | Facebook business card |
| `1004` | `TSECardTypeWhatsApp` | WhatsApp business card |
| `1005` | `TSECardTypeTwitter` | Twitter business card |
| `1006` | `TSECardTypeInstagram` | Instagram business card |
| `1007` | `TSECardTypeMessenger` | Messenger business card |
| `1008` | `TSECardTypeLINE` | LINE business card |
| `1009` | `TSECardTypeSnapchat` | Snapchat business card |
| `1010` | `TSECardTypeSkype` | Skype business card |
| `1011` | `TSECardTypeEmail` | Email business card |
| `1012` | `TSECardTypePhone` | Phone business card |
| `1013` | `TSECardTypeLinkedIn` | LinkedIn business card |
| `1014` | `TSECardTypeNucleicAcid` | Nucleic acid code |

## Callback Types

### Card Retrieval Completion Handler

```objc
void (^)(NSArray<TSECardModel *>* _Nullable cards, NSError * _Nullable error)
```

| Parameter | Type | Description |
|---|---|---|
| `cards` | `NSArray<TSECardModel *> *` | Array of retrieved e-card models, or nil if an error occurred |
| `error` | `NSError *` | Error object if the operation failed, nil on success |

### Card Operation Completion Handler

```objc
void (^)(BOOL isSuccess, NSError * _Nullable error)
```

| Parameter | Type | Description |
|---|---|---|
| `isSuccess` | `BOOL` | Boolean indicating whether the operation succeeded |
| `error` | `NSError *` | Error object if the operation failed, nil on success |

## API Reference

### Get maximum supported cards count

Returns the maximum number of cards that the device can store.

```objc
- (NSInteger)supportMaxCardsCount;
```

| Parameter | Type | Description |
|---|---|---|
| `*return*` | `NSInteger` | The maximum number of cards supported by the device |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
NSInteger maxCards = [cardBag supportMaxCardsCount];
TSLog(@"Device supports maximum %ld cards", (long)maxCards);
```

### Get maximum card name length

Returns the maximum allowed byte length for a card name.

```objc
- (NSInteger)supportMaxCardNameLength;
```

| Parameter | Type | Description |
|---|---|---|
| `*return*` | `NSInteger` | The maximum number of bytes allowed for a card name |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
NSInteger maxLength = [cardBag supportMaxCardNameLength];
TSLog(@"Maximum card name length: %ld bytes", (long)maxLength);
```

### Get maximum card URL length

Returns the maximum allowed byte length for a card URL.

```objc
- (NSInteger)supportMaxCardURLLength;
```

| Parameter | Type | Description |
|---|---|---|
| `*return*` | `NSInteger` | The maximum number of bytes allowed for a card URL |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
NSInteger maxLength = [cardBag supportMaxCardURLLength];
TSLog(@"Maximum card URL length: %ld bytes", (long)maxLength);
```

### Get all wallet cards

Retrieves all wallet payment code cards (type 100-199) from the device.

```objc
- (void)getAllWalletCardsCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable walletCards, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `completion` | `void (^)(NSArray<TSECardModel *> *, NSError *)` | Completion handler called with wallet cards array and error |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
[cardBag getAllWalletCardsCompletion:^(NSArray<TSECardModel *> * _Nullable walletCards, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to retrieve wallet cards: %@", error.localizedDescription);
        return;
    }
    TSLog(@"Retrieved %ld wallet cards", (long)walletCards.count);
    for (TSECardModel *card in walletCards) {
        TSLog(@"Card: %@ (ID: %ld)", card.cardName, (long)card.cardId);
    }
}];
```

### Get all business cards

Retrieves all business cards (type 1000-1999) from the device.

```objc
- (void)getAllBusinessCardsCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable businessCards, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `completion` | `void (^)(NSArray<TSECardModel *> *, NSError *)` | Completion handler called with business cards array and error |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
[cardBag getAllBusinessCardsCompletion:^(NSArray<TSECardModel *> * _Nullable businessCards, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to retrieve business cards: %@", error.localizedDescription);
        return;
    }
    TSLog(@"Retrieved %ld business cards", (long)businessCards.count);
}];
```

### Get all electronic cards

Retrieves all electronic cards currently stored on the device.

```objc
- (void)getAllECardCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable allECards, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `completion` | `void (^)(NSArray<TSECardModel *> *, NSError *)` | Completion handler called with all e-cards array and error |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
[cardBag getAllECardCompletion:^(NSArray<TSECardModel *> * _Nullable allECards, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to retrieve cards: %@", error.localizedDescription);
        return;
    }
    TSLog(@"Total cards on device: %ld", (long)allECards.count);
}];
```

### Set a single electronic card

Adds or updates a single electronic card on the device.

```objc
- (void)setECard:(TSECardModel *)eCard completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `eCard` | `TSECardModel *` | The e-card model to be set on the device |
| `completion` | `void (^)(BOOL, NSError *)` | Completion handler indicating success and any error |

**Code Example:**

```objc
TSECardModel *card = [TSECardModel cardWithId:0
                                         type:TSECardTypeWechatPay
                                         name:@"WeChat Payment"
                                          url:@"https://example.com/wechat"];

id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
[cardBag setECard:card completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (!isSuccess) {
        TSLog(@"Failed to set card: %@", error.localizedDescription);
        return;
    }
    TSLog(@"Card set successfully");
}];
```

### Set all electronic cards

Replaces all electronic cards on the device with a new set.

```objc
- (void)setAllECards:(NSArray<TSECardModel *> *)eCards completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `eCards` | `NSArray<TSECardModel *> *` | Array of e-card models to be set on the device |
| `completion` | `void (^)(BOOL, NSError *)` | Completion handler indicating success and any error |

**Code Example:**

```objc
TSECardModel *card1 = [TSECardModel cardWithId:0
                                          type:TSECardTypeWechatPay
                                          name:@"WeChat Payment"
                                           url:@"https://example.com/wechat"];

TSECardModel *card2 = [TSECardModel cardWithId:1
                                          type:TSECardTypeAlipay
                                          name:@"Alipay"
                                           url:@"https://example.com/alipay"];

NSArray<TSECardModel *> *cards = @[card1, card2];

id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];
[cardBag setAllECards:cards completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (!isSuccess) {
        TSLog(@"Failed to set cards: %@", error.localizedDescription);
        return;
    }
    TSLog(@"All cards set successfully");
}];
```

### Delete a single electronic card

Removes a specific electronic card from the device.

```objc
- (void)deleteECard:(TSECardModel *)eCard completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `eCard` | `TSECardModel *` | The e-card model to be deleted from the device |
| `completion` | `void (^)(BOOL, NSError *)` | Completion handler indicating success and any error |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];

[cardBag getAllECardCompletion:^(NSArray<TSECardModel *> * _Nullable allECards, NSError * _Nullable error) {
    if (allECards.count == 0) {
        TSLog(@"No cards to delete");
        return;
    }
    
    TSECardModel *cardToDelete = allECards[0];
    [cardBag deleteECard:cardToDelete completion:^(BOOL isSuccess, NSError * _Nullable error) {
        if (!isSuccess) {
            TSLog(@"Failed to delete card: %@", error.localizedDescription);
            return;
        }
        TSLog(@"Card deleted successfully");
    }];
}];
```

### Delete multiple electronic cards by IDs

Removes multiple electronic cards from the device using their IDs.

```objc
- (void)deleteECardsWithIds:(NSArray<NSNumber *> *)cardIds completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `cardIds` | `NSArray<NSNumber *> *` | Array of card IDs to be deleted |
| `completion` | `void (^)(BOOL, NSError *)` | Completion handler indicating success and any error |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];

NSArray<NSNumber *> *cardIds = @[@0, @1, @2];

[cardBag deleteECardsWithIds:cardIds completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (!isSuccess) {
        TSLog(@"Failed to delete cards: %@", error.localizedDescription);
        return;
    }
    TSLog(@"Cards deleted successfully");
}];
```

### Sort electronic cards

Reorders electronic cards on the device according to the provided card ID sequence.

```objc
- (void)sortECardsWithIds:(NSArray<NSNumber *> *)cardIds completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|---|---|---|
| `cardIds` | `NSArray<NSNumber *> *` | Array of card IDs in the desired order |
| `completion` | `void (^)(BOOL, NSError *)` | Completion handler indicating success and any error |

**Code Example:**

```objc
id<TSECardBagInterface> cardBag = [TSDevice.sharedInstance getInterface:@protocol(TSECardBagInterface)];

NSArray<NSNumber *> *orderedIds = @[@2, @0, @1];

[cardBag sortECardsWithIds:orderedIds completion:^(BOOL isSuccess, NSError * _Nullable error) {
    if (!isSuccess) {
        TSLog(@"Failed to sort cards: %@", error.localizedDescription);
        return;
    }
    TSLog(@"Cards sorted successfully");
}];
```

## Important Notes

1. Card IDs must be unique and fall within the range 0-255. Attempting to set a card with an invalid ID will fail.

2. The `setAllECards:completion:` method performs a complete replacement of all cards on the device. It first clears existing cards, then writes the new set. If the operation fails midway, the device state may be inconsistent.

3. Card names and URLs must not exceed the maximum lengths defined by `supportMaxCardNameLength` and `supportMaxCardURLLength` respectively. Truncate strings to these limits before creating card models.

4. Wallet cards have types in the range 100-199, while business cards have types in the range 1000-1999. Setting cards with types outside these ranges may fail.

5. All operations are asynchronous and require completion handlers. Do not assume operations complete immediately; always check the completion handler results.

6. If the device has reached its maximum card capacity (see `supportMaxCardsCount`), attempts to add new cards will fail with an appropriate error.

7. When deleting multiple cards by ID, all specified card IDs must exist on the device. If any ID is not found, the entire operation fails without deleting any cards.

8. The order of cards returned by retrieval methods reflects the current sort order on the device. Use `sortECardsWithIds:completion:` to change the display order.

9. Card model initialization uses a factory method `cardWithId:type:name:url:` which validates all parameters. If any parameter is invalid, the method returns nil.

10. Always validate card data before attempting to write to the device. Use the validation methods on `TSECardModel` such as `isValid`, `isValidCardId`, `isWalletCard`, and `isBusinessCard`.