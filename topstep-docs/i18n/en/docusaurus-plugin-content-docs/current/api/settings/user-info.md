---
sidebar_position: 1
title: UserInfo
---

# TSUserInfo

The TSUserInfo module provides comprehensive user information management capabilities for iOS applications. It enables retrieving user demographic data (height, weight, gender, age) from devices, setting this information, monitoring real-time changes, and validating data integrity with built-in BMI calculations and WHO-standard compliance checks.

## Prerequisites

- iOS 11.0 or later
- TopStepInterfaceKit framework properly imported
- Active connection to a compatible TopStep device
- User must have appropriate permissions to access and modify user information on the device

## Data Models

### TSUserInfoModel

User information model that stores and transfers basic user demographic data.

| Property | Type | Description |
|----------|------|-------------|
| `userId` | `NSString *` | Unique identifier for the user |
| `name` | `NSString *` | User's name (maximum 32 characters) |
| `gender` | `TSUserGender` | User's gender (Unknown, Female, or Male) |
| `age` | `UInt8` | User's age in years (valid range: 3-120) |
| `height` | `CGFloat` | User's height in centimeters (valid range: 80-220 cm) |
| `weight` | `CGFloat` | User's weight in kilograms (valid range: 20-200 kg) |

## Enumerations

### TSUserGender

Enumeration defining possible gender values for user information.

| Value | Numeric Value | Description |
|-------|---------------|-------------|
| `TSUserGenderUnknown` | -1 | Gender not specified |
| `TSUserGenderFemale` | 0 | Female gender |
| `TSUserGenderMale` | 1 | Male gender |

## Callback Types

### TSUserInfoResultBlock

Callback block type for user information retrieval operations.

```objc
typedef void(^TSUserInfoResultBlock)(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `userInfo` | `TSUserInfoModel * _Nullable` | User information model; nil if retrieval fails |
| `error` | `NSError * _Nullable` | Error information; nil if successful |

### TSCompletionBlock

Callback block type for general completion operations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the operation was successful |
| `error` | `NSError * _Nullable` | Error object if operation fails; nil if successful |

## API Reference

### Retrieve user information from device

Fetches basic user information stored on the connected device, including height, weight, gender, and age. The operation is performed asynchronously and returns results via completion callback.

```objc
- (void)getUserInfoWithCompletion:(nullable TSUserInfoResultBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSUserInfoResultBlock` | Callback block returning user information or error |

**Code Example:**

```objc
id<TSUserInfoInterface> userInfoInterface = (id<TSUserInfoInterface>)self.userInfoService;

[userInfoInterface getUserInfoWithCompletion:^(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get user info: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"User Info Retrieved:");
    TSLog(@"Name: %@", userInfo.name);
    TSLog(@"Gender: %ld", (long)userInfo.gender);
    TSLog(@"Age: %d", userInfo.age);
    TSLog(@"Height: %.1f cm", userInfo.height);
    TSLog(@"Weight: %.1f kg", userInfo.weight);
    
    float bmi = [userInfo calculateBMI];
    TSLog(@"BMI: %.2f", bmi);
}];
```

### Set user information to device

Configures user demographic information on the connected device. Validates all parameters before setting and ensures values are within acceptable ranges. The operation completes asynchronously through the completion callback.

```objc
- (void)setUserInfo:(TSUserInfoModel *)userInfo
         completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `userInfo` | `TSUserInfoModel *` | User information model with values to set |
| `completion` | `TSCompletionBlock` | Callback block returning operation result |

**Code Example:**

```objc
TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
userInfo.name = @"John Doe";
userInfo.gender = TSUserGenderMale;
userInfo.age = 28;
userInfo.height = 180.5;
userInfo.weight = 75.0;

// Validate before sending
NSError *validationError = [userInfo validate];
if (validationError) {
    TSLog(@"Validation failed: %@", validationError.localizedDescription);
    return;
}

id<TSUserInfoInterface> userInfoInterface = (id<TSUserInfoInterface>)self.userInfoService;

[userInfoInterface setUserInfo:userInfo completion:^(BOOL success, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set user info: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"User info set successfully");
    }
}];
```

### Register for user information change notifications

Subscribes to real-time notifications when user information is modified on the device. Pass nil to unregister from receiving further notifications.

```objc
- (void)registerUserInfoDidChangedBlock:(nullable TSUserInfoResultBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSUserInfoResultBlock` | Callback block triggered on information change; pass nil to unregister |

**Code Example:**

```objc
id<TSUserInfoInterface> userInfoInterface = (id<TSUserInfoInterface>)self.userInfoService;

// Register for notifications
[userInfoInterface registerUserInfoDidChangedBlock:^(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Error receiving user info notification: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"User info changed on device:");
    TSLog(@"Name: %@", userInfo.name);
    TSLog(@"Height: %.1f cm", userInfo.height);
    TSLog(@"Weight: %.1f kg", userInfo.weight);
}];

// Later, to unregister
[userInfoInterface registerUserInfoDidChangedBlock:nil];
```

### Validate user information

Validates that all user information values conform to defined ranges and health standards. Returns nil on successful validation or NSError with detailed failure information.

```objc
- (nullable NSError *)validate;
```

**Returns:**

| Type | Description |
|------|-------------|
| `NSError * _Nullable` | nil if validation succeeds; NSError object with detailed reason if validation fails |

**Code Example:**

```objc
TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
userInfo.age = 25;
userInfo.height = 175.0;
userInfo.weight = 70.0;
userInfo.gender = TSUserGenderMale;

NSError *validationError = [userInfo validate];
if (validationError) {
    TSLog(@"Validation failed - Code: %ld, Message: %@", 
          (long)validationError.code, 
          validationError.localizedDescription);
} else {
    TSLog(@"User information is valid");
}
```

### Calculate BMI value

Computes the Body Mass Index using the standard formula: BMI = weight(kg) / height(m)². Returns -1 if height or weight values are invalid.

```objc
- (float)calculateBMI;
```

**Returns:**

| Type | Description |
|------|-------------|
| `float` | Calculated BMI value; -1 if calculation fails due to invalid height or weight |

**Code Example:**

```objc
TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
userInfo.height = 170.0;  // cm
userInfo.weight = 65.0;   // kg

float bmi = [userInfo calculateBMI];

if (bmi < 0) {
    TSLog(@"BMI calculation failed - invalid height or weight");
    return;
}

TSLog(@"BMI: %.2f", bmi);

// Interpret BMI according to WHO standards
if (bmi < 16) {
    TSLog(@"Severe thinness");
} else if (bmi < 17) {
    TSLog(@"Moderate thinness");
} else if (bmi < 18.5) {
    TSLog(@"Mild thinness");
} else if (bmi < 25) {
    TSLog(@"Normal weight");
} else if (bmi < 30) {
    TSLog(@"Overweight");
} else {
    TSLog(@"Obese");
}
```

## Important Notes

1. **Asynchronous Operations**: All API methods operate asynchronously. Always provide completion handlers and do not assume immediate results.

2. **Validation Before Setting**: Always call the `validate` method on `TSUserInfoModel` before calling `setUserInfo:completion:` to catch validation errors early.

3. **Valid Ranges**: Strictly enforce these ranges when setting user information:
   - Age: 3-120 years
   - Height: 80-220 centimeters
   - Weight: 20-200 kilograms
   - BMI: 13-80 (calculated from height and weight)

4. **Notification Registration**: Pass nil to `registerUserInfoDidChangedBlock:` to unregister from change notifications and prevent memory leaks.

5. **BMI Calculation**: The BMI calculation uses metric units (weight in kg, height in cm converted to meters). Ensure height and weight are set before calculating BMI.

6. **Error Handling**: Always check the error parameter in completion blocks. Different error codes may indicate device communication failures, validation errors, or permission issues.

7. **Thread Safety**: Completion callbacks may be executed on background threads. Update UI only on the main thread by dispatching to `dispatch_get_main_queue()`.

8. **WHO Standards Compliance**: BMI ranges follow WHO (World Health Organization) classification standards as documented in the validation method.

9. **Maximum Name Length**: User name is limited to 32 characters maximum. Longer names will cause validation failure.

10. **Persistent Storage**: User information modifications are persisted on the device and survive device reboots. Changes made via the app will be reflected in future retrievals.