//
//  TSLockPasswordValidator.h
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Validator for lock password input (1–6 digits).
 * @chinese 锁密码输入校验器（1–6 位数字）
 *
 * @discussion
 * [EN]: Single responsibility: validate and normalize user input for lock password only.
 * [CN]: 单一职责：仅负责锁密码输入的校验与规范化。
 */
@interface TSLockPasswordValidator : NSObject

/**
 * @brief Validate raw input and return normalized password, or nil if invalid.
 * @chinese 校验原始输入并返回规范化密码，不合法则返回 nil
 *
 * @param raw Trimmed user input string.
 * @return Normalized 1–6 digit password, or nil if empty / non-digit / length > 6.
 */
+ (nullable NSString *)validatedPasswordFromRawInput:(NSString *)raw;

@end

NS_ASSUME_NONNULL_END
