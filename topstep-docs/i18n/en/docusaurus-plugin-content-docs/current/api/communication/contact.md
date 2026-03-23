---
sidebar_position: 2
title: Contact
---

# Contact

The Contact module provides comprehensive contact management functionality for TopStep devices, including reading and writing regular contacts, managing emergency contacts, and monitoring contact changes in real-time. It supports both standard contact operations and emergency contact features with SOS capabilities.

## Prerequisites

- Device must be connected and paired with the app
- User must have appropriate permissions to access device contact data
- For emergency contact features, device must support the emergency contacts capability (verify using `isSupportEmergencyContacts`)
- Network or Bluetooth connection must be stable during contact synchronization

## Data Models

### TopStepContactModel

Represents contact information stored in the device address book, supporting both regular and emergency contacts.

| Property | Type | Description |
|----------|------|-------------|
| `name` | `NSString *` | Contact name. Supports Chinese and English characters. Maximum 32 bytes (auto-truncated if exceeded while preserving UTF-8 integrity). Cannot be empty. |
| `phoneNum` | `NSString *` | Contact phone number. Supports digits and plus sign (+). No spaces or special characters allowed. Maximum 20 bytes (auto-truncated if exceeded while preserving UTF-8 integrity). Cannot be empty. |
| `shortName` | `NSString *` | Short name for categorization, typically the first letter of the contact name. Used for indexing, search, and alphabetical sorting. |

## Callback Types

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(BOOL success, NSError *_Nullable error);
```

Generic completion callback for operations that return success status and optional error information.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Indicates whether the operation completed successfully |
| `error` | `NSError *` | Error information if operation failed; `nil` if successful |

### Contact Fetch Completion

```objc
void (^)(NSArray<TopStepContactModel *> *_Nullable allContacts, NSError *_Nullable error)
```

Callback for retrieving contact information from the device.

| Parameter | Type | Description |
|-----------|------|-------------|
| `allContacts` | `NSArray<TopStepContactModel *> *` | Array of retrieved contacts; `nil` if operation failed |
| `error` | `NSError *` | Error information if operation failed; `nil` if successful |

### Emergency Contact Fetch Completion

```objc
void (^)(NSArray<TopStepContactModel *> *_Nullable emergencyContact, BOOL isSosOn, NSError *_Nullable error)
```

Callback for retrieving emergency contact information and SOS status.

| Parameter | Type | Description |
|-----------|------|-------------|
| `emergencyContact` | `NSArray<TopStepContactModel *> *` | Array of emergency contacts; `nil` if operation failed |
| `isSosOn` | `BOOL` | Whether the emergency contact (SOS) feature is currently enabled |
| `error` | `NSError *` | Error information if operation failed; `nil` if successful |

### Contact Change Listener

```objc
void (^)(NSArray<TopStepContactModel *> *_Nullable allContacts, NSError *_Nullable error)
```

Callback triggered when contacts change on the device.

| Parameter | Type | Description |
|-----------|------|-------------|
| `allContacts` | `NSArray<TopStepContactModel *> *` | Updated array of all contacts after change |
| `error` | `NSError *` | Error information if operation failed; `nil` if successful |

### SOS Request Listener

```objc
void (^)(NSError *_Nullable error)
```

Callback triggered when the device sends an SOS request.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error information if listener registration failed; `nil` if successful |

## API Reference

### Get maximum number of supported contacts

Returns the maximum number of regular contacts the device can store.

```objc
- (NSInteger)supportMaxContacts;
```

**Return Value**

| Type | Description |
|------|-------------|
| `NSInteger` | Maximum number of contacts supported by the device |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];
NSInteger maxContacts = [contactInterface supportMaxContacts];
TSLog(@"Device supports max %ld contacts", (long)maxContacts);
```

### Retrieve all contacts from device

Fetches the complete list of all contacts stored on the device.

```objc
- (void)getAllContacts:(void (^)(NSArray<TopStepContactModel *> *_Nullable allContacts,
                                 NSError *_Nullable error))completion;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, NSError *)` | Callback block invoked when retrieval completes, provides contact array or error |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

[contactInterface getAllContacts:^(NSArray<TopStepContactModel *> * _Nullable allContacts, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get contacts: %@", error.localizedDescription);
        return;
    }
    
    if (allContacts) {
        TSLog(@"Retrieved %lu contacts", (unsigned long)allContacts.count);
        for (TopStepContactModel *contact in allContacts) {
            TSLog(@"Contact: %@ - %@", contact.name, contact.phoneNum);
        }
    }
}];
```

### Synchronize all contacts to device

Overwrites all existing contacts on the device with the provided contact list.

```objc
- (void)setAllContacts:(NSArray<TopStepContactModel *> *_Nullable)allContacts
            completion:(TSCompletionBlock)completion;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `allContacts` | `NSArray<TopStepContactModel *> *` | Array of contacts to synchronize to device; `nil` clears all contacts |
| `completion` | `TSCompletionBlock` | Callback block invoked when operation completes |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

TopStepContactModel *contact1 = [TopStepContactModel contactWithName:@"John Doe" phoneNum:@"13800138000"];
TopStepContactModel *contact2 = [TopStepContactModel contactWithName:@"Jane Smith" phoneNum:@"+1234567890"];

NSArray<TopStepContactModel *> *contacts = @[contact1, contact2];

[contactInterface setAllContacts:contacts completion:^(BOOL success, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set contacts: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"Contacts synchronized successfully");
    }
}];
```

### Get maximum number of supported emergency contacts

Returns the maximum number of emergency contacts the device can store.

```objc
- (NSInteger)supportMaxEmergencyContacts;
```

**Return Value**

| Type | Description |
|------|-------------|
| `NSInteger` | Maximum number of emergency contacts supported by the device |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];
NSInteger maxEmergencyContacts = [contactInterface supportMaxEmergencyContacts];
TSLog(@"Device supports max %ld emergency contacts", (long)maxEmergencyContacts);
```

### Check if device supports emergency contacts

Verifies whether the connected device supports emergency contact functionality.

```objc
- (BOOL)isSupportEmergencyContacts;
```

**Return Value**

| Type | Description |
|------|-------------|
| `BOOL` | `YES` if device supports emergency contacts, `NO` otherwise |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

if ([contactInterface isSupportEmergencyContacts]) {
    TSLog(@"Device supports emergency contacts");
} else {
    TSLog(@"Device does not support emergency contacts");
}
```

### Retrieve emergency contacts from device

Fetches the emergency contact list and SOS feature status from the device.

```objc
- (void)getEmergencyContacts:(void (^)(NSArray<TopStepContactModel *> *_Nullable emergencyContact, BOOL isSosOn,
                                       NSError *_Nullable error))completion;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, BOOL, NSError *)` | Callback block providing emergency contacts array, SOS status, and error |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

[contactInterface getEmergencyContacts:^(NSArray<TopStepContactModel *> * _Nullable emergencyContact, BOOL isSosOn, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get emergency contacts: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"SOS is %@", isSosOn ? @"ON" : @"OFF");
    
    if (emergencyContact) {
        TSLog(@"Retrieved %lu emergency contacts", (unsigned long)emergencyContact.count);
        for (TopStepContactModel *contact in emergencyContact) {
            TSLog(@"Emergency Contact: %@ - %@", contact.name, contact.phoneNum);
        }
    }
}];
```

### Synchronize emergency contacts to device

Overwrites emergency contacts on the device and sets the SOS feature status.

```objc
- (void)setEmergencyContacts:(NSArray<TopStepContactModel *> *_Nullable)emergencyContacts
                       sosOn:(BOOL)isSosOn
                  completion:(TSCompletionBlock)completion;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `emergencyContacts` | `NSArray<TopStepContactModel *> *` | Array of emergency contacts to set; `nil` clears all emergency contacts |
| `isSosOn` | `BOOL` | Whether to enable the SOS feature |
| `completion` | `TSCompletionBlock` | Callback block invoked when operation completes |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

// Verify emergency contacts are supported before setting
if (![contactInterface isSupportEmergencyContacts]) {
    TSLog(@"Device does not support emergency contacts");
    return;
}

TopStepContactModel *emergencyContact = [TopStepContactModel contactWithName:@"Emergency Service" phoneNum:@"911"];
NSArray<TopStepContactModel *> *emergencyContacts = @[emergencyContact];

[contactInterface setEmergencyContacts:emergencyContacts sosOn:YES completion:^(BOOL success, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set emergency contacts: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"Emergency contacts synchronized successfully");
    }
}];
```

### Register listener for contact changes

Registers a callback that triggers whenever the device contacts are modified.

```objc
- (void)registerContactsDidChangedBlock:(void (^)(NSArray<TopStepContactModel *> * _Nullable allContacts,
                                                   NSError * _Nullable error))completion;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, NSError *)` | Callback block invoked when contacts change on device |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

[contactInterface registerContactsDidChangedBlock:^(NSArray<TopStepContactModel *> * _Nullable allContacts, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to register contact change listener: %@", error.localizedDescription);
        return;
    }
    
    if (allContacts) {
        TSLog(@"Contacts changed! Current count: %lu", (unsigned long)allContacts.count);
        for (TopStepContactModel *contact in allContacts) {
            TSLog(@"Contact: %@ - %@", contact.name, contact.phoneNum);
        }
    }
}];
```

### Register listener for emergency contact changes

Registers a callback that triggers whenever the device emergency contacts are modified.

```objc
- (void)registerEmergencyContactsDidChangedBlock:(void (^)(NSArray<TopStepContactModel *> *_Nullable allContacts,
                                                            NSError * _Nullable error))completion;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(NSArray<TopStepContactModel *> *, NSError *)` | Callback block invoked when emergency contacts change on device |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

[contactInterface registerEmergencyContactsDidChangedBlock:^(NSArray<TopStepContactModel *> * _Nullable allContacts, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to register emergency contact change listener: %@", error.localizedDescription);
        return;
    }
    
    if (allContacts) {
        TSLog(@"Emergency contacts changed! Current count: %lu", (unsigned long)allContacts.count);
        for (TopStepContactModel *contact in allContacts) {
            TSLog(@"Emergency Contact: %@ - %@", contact.name, contact.phoneNum);
        }
    }
}];
```

### Register listener for SOS requests

Registers a callback that triggers when the device initiates an SOS request.

```objc
- (void)registerSOSRequestBlock:(void (^)(NSError *_Nullable error))completion;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(NSError *)` | Callback block invoked immediately when device triggers SOS |

**Code Example**

```objc
id<TSContactInterface> contactInterface = (id<TSContactInterface>)[device getInterface:@"TSContactInterface"];

[contactInterface registerSOSRequestBlock:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to register SOS listener: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"SOS request received from device!");
    // Handle SOS event - could trigger alert, notification, or emergency services
}];
```

### Create contact with name and phone number

Factory method to create a contact object with automatic short name generation.

```objc
+ (instancetype)contactWithName:(NSString *)name phoneNum:(NSString *)phoneNum;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `NSString *` | Contact name (required). Max 32 bytes; auto-truncated if exceeded while preserving UTF-8 integrity |
| `phoneNum` | `NSString *` | Contact phone number (required). Max 20 bytes; auto-truncated if exceeded while preserving UTF-8 integrity |

**Return Value**

| Type | Description |
|------|-------------|
| `instancetype` | Created contact object; `nil` if name or phoneNum is empty |

**Code Example**

```objc
TopStepContactModel *contact = [TopStepContactModel contactWithName:@"Alice Johnson" 
                                                             phoneNum:@"13912345678"];

if (contact) {
    TSLog(@"Contact created: %@ - %@ (Short: %@)", contact.name, contact.phoneNum, contact.shortName);
} else {
    TSLog(@"Failed to create contact - invalid parameters");
}
```

### Create contact with custom short name

Factory method to create a contact object with a custom short name for categorization.

```objc
+ (instancetype)contactWithName:(NSString *)name phoneNum:(NSString *)phoneNum shortName:(NSString *)shortName;
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `NSString *` | Contact name (required). Max 32 bytes; auto-truncated if exceeded while preserving UTF-8 integrity |
| `phoneNum` | `NSString *` | Contact phone number (required). Max 20 bytes; auto-truncated if exceeded while preserving UTF-8 integrity |
| `shortName` | `NSString *` | Custom short name for categorization (typically first letter of name) |

**Return Value**

| Type | Description |
|------|-------------|
| `instancetype` | Created contact object; `nil` if name or phoneNum is empty |

**Code Example**

```objc
TopStepContactModel *contact = [TopStepContactModel contactWithName:@"李明" 
                                                             phoneNum:@"+86 13912345678"
                                                            shortName:@"L"];

if (contact) {
    TSLog(@"Contact created: %@ - %@ (Short: %@)", contact.name, contact.phoneNum, contact.shortName);
} else {
    TSLog(@"Failed to create contact - invalid parameters");
}
```

## Important Notes

1. **Always verify emergency contact support** — Call `isSupportEmergencyContacts` before attempting emergency contact operations, as some devices may not support this feature.

2. **Contact data limits** — The device has strict storage limits for both regular contacts (typically 50-200) and emergency contacts (typically 1-5). Always check `supportMaxContacts` and `supportMaxEmergencyContacts` before batch operations.

3. **Character encoding and truncation** — Contact names are truncated at 32 bytes and phone numbers at 20 bytes if they exceed limits. The SDK preserves UTF-8 character integrity during truncation, so multi-byte characters (Chinese, emoji, etc.) may result in fewer visible characters.

4. **Phone number format** — Phone numbers support only digits and the plus sign (+). Remove spaces, dashes, or parentheses before creating contact objects. Invalid formats may cause synchronization to fail.

5. **Empty contact handling** — Passing `nil` or empty arrays to `setAllContacts:` or `setEmergencyContacts:` will clear all contacts on the device. This operation cannot be undone, so implement confirmation dialogs for user safety.

6. **Synchronous data replacement** — `setAllContacts:` completely overwrites all device contacts. It does not merge or update individual contacts. For selective updates, first retrieve all contacts, modify the array, then resynchronize.

7. **Contact change listener registration** — Multiple listeners can be registered. Callbacks are triggered for all subsequent changes. Listeners persist until the device disconnects.

8. **SOS feature relationship** — Emergency contacts feature is closely tied to the SOS (emergency call) feature. The `isSosOn` parameter controls whether the device will actively use emergency contacts during emergency events.

9. **Error handling in listeners** — When registering contact change listeners, errors indicate registration failure, not data retrieval failure. Listeners that fail to register will never trigger callbacks.

10. **Network stability during sync** — Contact synchronization is data-intensive. Ensure a stable Bluetooth connection and avoid interrupting operations. Device may become unresponsive if connection is lost during sync.