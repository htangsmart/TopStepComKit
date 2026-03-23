---
sidebar_position: 1
title: 用户信息
---

# 用户信息 (TSUserInfo)

TSUserInfo 模块提供了完整的用户基本信息管理功能，包括获取、设置和监听用户信息变化。该模块支持用户身高、体重、性别、年龄等基本生理数据的管理，并提供数据验证和 BMI 计算功能。

## 前提条件

- iOS 设备已与 SDK 完成连接
- 用户已授权访问用户信息权限
- 设备固件版本支持用户信息功能

## 数据模型

### TSUserInfoModel

用户信息数据模型，用于存储和传递用户的基本信息。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `userId` | `NSString *` | 用户ID |
| `name` | `NSString *` | 用户姓名，最大长度32个字符 |
| `gender` | `TSUserGender` | 用户性别，使用 TSUserGender 枚举值 |
| `age` | `UInt8` | 用户年龄（岁），有效范围：3-120 |
| `height` | `CGFloat` | 用户身高（厘米），有效范围：80-220 |
| `weight` | `CGFloat` | 用户体重（千克），有效范围：20-200 |

## 枚举与常量

### TSUserGender

用户性别枚举，定义用户信息中可能的性别值。

| 枚举值 | 数值 | 说明 |
|--------|------|------|
| `TSUserGenderUnknown` | -1 | 未知性别，性别未指定 |
| `TSUserGenderFemale` | 0 | 女性 |
| `TSUserGenderMale` | 1 | 男性 |

## 回调类型

| 回调类型 | 参数说明 |
|----------|---------|
| `TSUserInfoResultBlock` | `void(^)(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error)` — 用户信息获取回调。userInfo 为用户信息模型，获取失败时为 nil；error 为错误信息，成功时为 nil |
| `TSCompletionBlock` | 标准完成回调，用于设置操作结果返回 |

## 接口方法

### 从设备获取用户信息

从设备中获取用户的基本信息，包括身高、体重、性别、年龄等。

```objc
- (void)getUserInfoWithCompletion:(nullable TSUserInfoResultBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSUserInfoResultBlock` | 回调 block，返回用户信息或错误。userInfo 为用户信息模型，获取失败时为 nil；error 为错误对象，成功时为 nil |

**代码示例**

```objc
// 获取用户信息
[self.userInfoInterface getUserInfoWithCompletion:^(TSUserInfoModel *userInfo, NSError *error) {
    if (error) {
        TSLog(@"获取用户信息失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"用户信息:");
    TSLog(@"  姓名: %@", userInfo.name);
    TSLog(@"  性别: %ld", (long)userInfo.gender);
    TSLog(@"  年龄: %d岁", userInfo.age);
    TSLog(@"  身高: %.1f厘米", userInfo.height);
    TSLog(@"  体重: %.1f千克", userInfo.weight);
    TSLog(@"  BMI: %.1f", [userInfo calculateBMI]);
}];
```

---

### 设置用户信息到设备

向设备设置用户的基本信息。如果任何属性超出有效范围，将返回参数错误。

```objc
- (void)setUserInfo:(TSUserInfoModel *)userInfo
         completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `userInfo` | `TSUserInfoModel *` | 要设置的用户信息模型 |
| `completion` | `TSCompletionBlock` | 回调 block，返回设置结果。success 表示是否设置成功；error 为错误对象，成功时为 nil |

**代码示例**

```objc
// 创建用户信息
TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
userInfo.name = @"张三";
userInfo.gender = TSUserGenderMale;
userInfo.age = 30;
userInfo.height = 175.0;
userInfo.weight = 70.0;

// 验证用户信息
NSError *validateError = [userInfo validate];
if (validateError) {
    TSLog(@"用户信息验证失败: %@", validateError.localizedDescription);
    return;
}

// 设置用户信息到设备
[self.userInfoInterface setUserInfo:userInfo completion:^(BOOL success, NSError *error) {
    if (error) {
        TSLog(@"设置用户信息失败: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"用户信息设置成功");
    }
}];
```

---

### 注册用户信息变化通知

注册用户信息变化通知，当设备端的用户信息发生变化时，会触发回调。

```objc
- (void)registerUserInfoDidChangedBlock:(nullable TSUserInfoResultBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSUserInfoResultBlock` | 用户信息变化时触发的回调 block。userInfo 为新的用户信息模型；error 为获取新信息失败时的错误对象，成功时为 nil。传入 nil 可以取消注册通知 |

**代码示例**

```objc
// 注册用户信息变化通知
[self.userInfoInterface registerUserInfoDidChangedBlock:^(TSUserInfoModel *userInfo, NSError *error) {
    if (error) {
        TSLog(@"获取用户信息变化失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"用户信息已变化:");
    TSLog(@"  姓名: %@", userInfo.name);
    TSLog(@"  性别: %ld", (long)userInfo.gender);
    TSLog(@"  年龄: %d岁", userInfo.age);
    TSLog(@"  身高: %.1f厘米", userInfo.height);
    TSLog(@"  体重: %.1f千克", userInfo.weight);
}];

// 取消注册通知
[self.userInfoInterface registerUserInfoDidChangedBlock:nil];
```

---

## TSUserInfoModel 方法

### 验证用户信息

验证用户信息中的各项属性是否符合有效范围和合理的 BMI 值。

```objc
- (nullable NSError *)validate;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `NSError *` | 验证失败时返回 NSError 对象，包含具体原因；验证通过时返回 nil |

**验证规则**

- 年龄：3-120 岁
- 身高：80-220 厘米
- 体重：20-200 千克
- BMI：13-80（根据 WHO 标准）

**代码示例**

```objc
TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
userInfo.age = 25;
userInfo.height = 170.0;
userInfo.weight = 65.0;
userInfo.gender = TSUserGenderMale;
userInfo.name = @"李四";

NSError *error = [userInfo validate];
if (error) {
    TSLog(@"验证失败: %@", error.localizedDescription);
} else {
    TSLog(@"用户信息验证通过");
}
```

---

### 计算 BMI 值

根据当前用户的身高和体重计算 BMI 值。

```objc
- (float)calculateBMI;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `float` | BMI 值，计算失败时返回 -1 |

**计算公式**

BMI = 体重(kg) / 身高(m)²

**代码示例**

```objc
TSUserInfoModel *userInfo = [[TSUserInfoModel alloc] init];
userInfo.height = 175.0;
userInfo.weight = 70.0;

float bmi = [userInfo calculateBMI];
if (bmi > 0) {
    TSLog(@"BMI 值: %.1f", bmi);
    
    // BMI 分类
    if (bmi < 16) {
        TSLog(@"BMI 分类: 重度消瘦");
    } else if (bmi < 17) {
        TSLog(@"BMI 分类: 中度消瘦");
    } else if (bmi < 18.5) {
        TSLog(@"BMI 分类: 轻度消瘦");
    } else if (bmi < 25) {
        TSLog(@"BMI 分类: 正常范围");
    } else if (bmi < 30) {
        TSLog(@"BMI 分类: 超重");
    } else if (bmi < 35) {
        TSLog(@"BMI 分类: 肥胖 I 度");
    } else if (bmi < 40) {
        TSLog(@"BMI 分类: 肥胖 II 度");
    } else {
        TSLog(@"BMI 分类: 肥胖 III 度");
    }
} else {
    TSLog(@"BMI 计算失败");
}
```

---

## 注意事项

1. **数据有效范围**：设置用户信息时，所有属性必须在指定的有效范围内，否则设置会失败并返回参数错误。

2. **异步操作**：所有用户信息相关的操作都是异步的，必须通过回调 block 来获取结果，不能阻塞主线程。

3. **BMI 计算**：BMI 值为参考值，具体的健康评估应结合医学专业意见进行。WHO 标准中 BMI 合理范围为 13-80，范围外的数据被认为无效。

4. **性别枚举**：使用 `TSUserGender` 枚举值设置用户性别，其中 -1 表示未知/未指定，0 表示女性，1 表示男性。

5. **信息同步**：获取到的用户信息应在使用前通过 `validate` 方法进行验证，确保数据的合法性。

6. **通知取消**：调用 `registerUserInfoDidChangedBlock:` 方法时传入 nil 可以取消注册用户信息变化通知。

7. **线程安全**：所有回调 block 都会在主线程中执行，UI 更新操作可以直接进行。