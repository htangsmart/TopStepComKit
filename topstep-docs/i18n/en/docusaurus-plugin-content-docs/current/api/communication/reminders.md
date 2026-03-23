---
sidebar_position: 4
title: Reminders
---

# TSReminders

The TSReminders module provides comprehensive reminder management functionality for TopStepComKit iOS SDK. It enables you to create, retrieve, update, and delete reminders on connected devices, supporting both built-in reminder types (sedentary, drinking water, taking medicine) and custom reminders with flexible scheduling options including point-in-time and period-based reminders with customizable intervals.

## Prerequisites

- Device must support reminder functionality
- Device must be connected and accessible via the SDK
- User must have appropriate permissions to manage reminders on the device
- For custom reminders, device must have available slots (check `supportMaxCustomeReminders`)

## Data Models

### TSRemindersModel

Represents a reminder on the device.

| Property | Type | Description |
|----------|------|-------------|
| `reminderId` | `NSString *` | Unique identifier for the reminder, automatically assigned by the system. Do not manually modify. |
| `reminderName` | `NSString *` | Name of the reminder (e.g., "Drink Water", "Take Medicine"). |
| `isEnabled` | `BOOL` | Indicates whether the reminder is active. |
| `reminderType` | `TSReminderType` | Type of the reminder (unknown, sedentary, drinking, medicine, or custom). |
| `repeatDays` | `TSReminderDays` | Days of the week the reminder repeats, using bitwise options. Combine with \| operator (e.g., `eTSReminderDayMonday \| eTSReminderDayFriday`). |
| `timeType` | `TSReminderTimeType` | Time type: point in time or period. When set to period, `startTime`, `endTime`, and `interval` are used. |
| `startTime` | `NSInteger` | Start time in minutes from midnight (0-1439). Example: 360 = 6:00 AM. |
| `endTime` | `NSInteger` | End time in minutes from midnight (0-1439). Example: 720 = 12:00 PM. |
| `interval` | `NSInteger` | Interval between reminders in minutes (used only when `timeType` is period). |
| `timePoints` | `NSArray<NSNumber *> *` | Array of specific time points in minutes from midnight. Example: @[@360, @720] = 6:00 AM and 12:00 PM. |
| `notes` | `NSString *` | Additional notes or description for the reminder. |
| `isLunchBreakDNDEnabled` | `BOOL` | Whether lunch break do-not-disturb mode is enabled. |
| `lunchBreakDNDStartTime` | `NSInteger` | Lunch break DND start time in minutes (recommended: 720 = 12:00 PM). |
| `lunchBreakDNDEndTime` | `NSInteger` | Lunch break DND end time in minutes (recommended: 840 = 2:00 PM). |

## Enumerations

### TSReminderType

Specifies the type of reminder.

| Value | Description |
|-------|-------------|
| `eTSReminderTypeUnknown` | Unknown reminder type. |
| `eTSReminderTypeSedentary` | Sedentary/activity reminder. |
| `eTSReminderTypeDrinking` | Drinking water reminder. |
| `eTSReminderTypeTakeMedicine` | Medicine reminder. |
| `eTSReminderTypeCustom` | Custom user-defined reminder. |

### TSReminderDays

Bitwise options for specifying days of the week. Can be combined using the `|` operator.

| Value | Description |
|-------|-------------|
| `eTSReminderDayMonday` | Monday. |
| `eTSReminderDayTuesday` | Tuesday. |
| `eTSReminderDayWednesday` | Wednesday. |
| `eTSReminderDayThursday` | Thursday. |
| `eTSReminderDayFriday` | Friday. |
| `eTSReminderDaySaturday` | Saturday. |
| `eTSReminderDaySunday` | Sunday. |
| `eTSReminderRepeatWorkday` | Monday through Friday. |
| `eTSReminderRepeatWeekday` | Saturday and Sunday. |
| `eTSReminderRepeatEveryday` | All seven days. |

### TSReminderTimeType

Specifies whether the reminder is set for a specific point in time or a time period.

| Value | Description |
|-------|-------------|
| `eTSReminderTimeTypePeriod` | Period of time (uses `startTime`, `endTime`, `interval`). |
| `eTSReminderTimeTypePoint` | Specific point in time (uses `timePoints`). |

## Callback Types

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(NSError * _Nullable error);
```

Completion callback that returns only error information.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError * _Nullable` | Error object if operation failed; nil if successful. |

### Custom Reminder Template Completion

```objc
void (^)(TSRemindersModel * _Nullable reminder, NSError * _Nullable error)
```

Completion callback for creating a custom reminder template.

| Parameter | Type | Description |
|-----------|------|-------------|
| `reminder` | `TSRemindersModel * _Nullable` | Ready-to-use reminder model with valid ID and defaults; nil if failed. |
| `error` | `NSError * _Nullable` | Error object if operation failed; nil if successful. |

### Get All Reminders Completion

```objc
void (^)(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error)
```

Completion callback for retrieving all reminders.

| Parameter | Type | Description |
|-----------|------|-------------|
| `reminders` | `NSArray<TSRemindersModel *> *` | Array of all reminder objects on the device. |
| `error` | `NSError * _Nullable` | Error object if operation failed; nil if successful. |

## API Reference

### Get Maximum Supported Custom Reminders

Returns the maximum number of custom reminders the connected device supports.

```objc
- (NSInteger)supportMaxCustomeReminders;
```

**Returns:** `NSInteger` — Maximum number of custom reminders that can be set on the device.

**Code Example:**

```objc
id<TSRemindersInterface> remindersInterface = // obtain interface
NSInteger maxReminders = [remindersInterface supportMaxCustomeReminders];
TSLog(@"Device supports up to %ld custom reminders", (long)maxReminders);
```

### Create Custom Reminder Template

Creates a new custom reminder template with automatically assigned ID and default values.

```objc
- (void)createCustomReminderTemplateWithCompletion:(void (^)(TSRemindersModel * _Nullable reminder, NSError * _Nullable error))completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSRemindersModel * _Nullable, NSError * _Nullable)` | Callback returning the reminder template and any error. |

**Code Example:**

```objc
id<TSRemindersInterface> remindersInterface = // obtain interface

[remindersInterface createCustomReminderTemplateWithCompletion:^(TSRemindersModel *reminder, NSError *error) {
    if (error) {
        TSLog(@"Failed to create reminder template: %@", error.localizedDescription);
        return;
    }
    
    // Configure the reminder
    reminder.reminderName = @"Drink Water";
    reminder.isEnabled = YES;
    reminder.timeType = eTSReminderTimeTypePeriod;
    reminder.startTime = 360;    // 6:00 AM
    reminder.endTime = 1320;     // 10:00 PM
    reminder.interval = 60;      // Every hour
    reminder.repeatDays = eTSReminderRepeatEveryday;
    
    TSLog(@"Reminder template created with ID: %@", reminder.reminderId);
}];
```

### Get All Reminders

Retrieves all reminder settings from the device.

```objc
- (void)getAllRemindersWithCompletion:(void (^)(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error))completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(NSArray<TSRemindersModel *> *, NSError * _Nullable)` | Callback returning array of all reminders and any error. |

**Code Example:**

```objc
id<TSRemindersInterface> remindersInterface = // obtain interface

[remindersInterface getAllRemindersWithCompletion:^(NSArray<TSRemindersModel *> *reminders, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch reminders: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Total reminders: %lu", (unsigned long)reminders.count);
    for (TSRemindersModel *reminder in reminders) {
        TSLog(@"Reminder: %@ (Type: %ld, Enabled: %d)", 
              reminder.reminderName, 
              (long)reminder.reminderType, 
              reminder.isEnabled);
    }
}];
```

### Set Reminders

Sets reminder settings by providing an array of reminder objects. This replaces existing reminders.

```objc
- (void)setReminders:(NSArray<TSRemindersModel *> *)reminders completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `reminders` | `NSArray<TSRemindersModel *> *` | Array of reminder objects to set on the device. |
| `completion` | `TSCompletionBlock` | Callback returning success status and any error. |

**Code Example:**

```objc
id<TSRemindersInterface> remindersInterface = // obtain interface

// Validate reminders before setting
NSError *validationError = [TSRemindersModel doesRemindersHasError:remindersArray];
if (validationError) {
    TSLog(@"Validation error: %@", validationError.localizedDescription);
    return;
}

[remindersInterface setReminders:remindersArray completion:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to set reminders: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Reminders set successfully");
}];
```

### Update Reminder

Updates an existing reminder or creates a new one if it doesn't exist (upsert behavior).

```objc
- (void)updateReminder:(TSRemindersModel *)reminder completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `reminder` | `TSRemindersModel *` | Reminder model containing the updated information. Must have valid `reminderId`. |
| `completion` | `TSCompletionBlock` | Callback returning success status and any error. |

**Code Example:**

```objc
id<TSRemindersInterface> remindersInterface = // obtain interface

// First, get existing reminders
[remindersInterface getAllRemindersWithCompletion:^(NSArray<TSRemindersModel *> *reminders, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch reminders: %@", error.localizedDescription);
        return;
    }
    
    // Find and modify a reminder
    for (TSRemindersModel *reminder in reminders) {
        if ([reminder.reminderId isEqualToString:@"reminder_001"]) {
            reminder.isEnabled = NO;  // Disable the reminder
            reminder.reminderName = @"Updated Name";
            
            [remindersInterface updateReminder:reminder completion:^(NSError *error) {
                if (error) {
                    TSLog(@"Failed to update reminder: %@", error.localizedDescription);
                    return;
                }
                
                TSLog(@"Reminder updated successfully");
            }];
            break;
        }
    }
}];
```

### Delete Reminder

Deletes a specific reminder from the device by its ID.

```objc
- (void)deleteReminderWithId:(NSString *)reminderId completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `reminderId` | `NSString *` | Unique identifier of the reminder to delete. |
| `completion` | `TSCompletionBlock` | Callback returning success status and any error. |

**Code Example:**

```objc
id<TSRemindersInterface> remindersInterface = // obtain interface

[remindersInterface deleteReminderWithId:@"custom_reminder_123" completion:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to delete reminder: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Reminder deleted successfully");
}];
```

### Validate Reminders Array

Class method to validate an array of reminder models.

```objc
+ (NSError *)doesRemindersHasError:(NSArray<TSRemindersModel *> *)reminders;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `reminders` | `NSArray<TSRemindersModel *> *` | Array of reminder models to validate. |

**Returns:** `NSError *` — First error found or nil if all models are valid.

**Code Example:**

```objc
NSArray<TSRemindersModel *> *remindersToValidate = @[reminder1, reminder2, reminder3];

NSError *error = [TSRemindersModel doesRemindersHasError:remindersToValidate];
if (error) {
    TSLog(@"Validation error in reminders array: %@", error.localizedDescription);
} else {
    TSLog(@"All reminders are valid");
}
```

## Important Notes

1. **Never manually create TSRemindersModel instances.** Always use `createCustomReminderTemplateWithCompletion:` to create new custom reminders, which automatically assigns a valid ID and sets appropriate defaults.

2. **Built-in reminders (sedentary, drinking water, taking medicine) cannot be deleted.** Only custom reminders can be permanently removed. Built-in reminders can only be disabled by setting `isEnabled` to `NO` and calling `updateReminder:`.

3. **Custom reminder IDs are automatically assigned.** Do not attempt to manually assign or modify the `reminderId` property. The system generates unique IDs through the template creation method.

4. **Time values are in minutes from midnight (0-1439).** For example: 360 = 6:00 AM, 720 = 12:00 PM, 1320 = 10:00 PM. Ensure time values are within valid range.

5. **Device capacity limits apply to custom reminders.** Always check `supportMaxCustomeReminders` before creating new custom reminders. Attempting to exceed the limit will result in an error.

6. **Repeat days use bitwise combinations.** Combine multiple days using the `|` operator (e.g., `eTSReminderDayMonday | eTSReminderDayWednesday | eTSReminderDayFriday` for specific weekdays).

7. **Two time specification methods exist: point-in-time or period-based.** Use `timePoints` array when `timeType` is `eTSReminderTimeTypePoint`; use `startTime`, `endTime`, and `interval` when `timeType` is `eTSReminderTimeTypePeriod`.

8. **Lunch break DND is optional but recommended.** When enabled with `isLunchBreakDNDEnabled`, set appropriate `lunchBreakDNDStartTime` and `lunchBreakDNDEndTime` values (typically 720-840 for 12:00 PM to 2:00 PM).

9. **Validate before batch operations.** Use `doesRemindersHasError:` to validate an array of reminders before calling `setReminders:` to avoid partial failures.

10. **Update is an upsert operation.** If a reminder with the specified ID doesn't exist, `updateReminder:` will create a new reminder (subject to device capacity limits). If it exists, it updates all properties of the existing reminder.