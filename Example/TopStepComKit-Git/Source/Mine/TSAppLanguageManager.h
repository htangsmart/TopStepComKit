//
//  TSAppLanguageManager.h
//  TopStepComKit_Example
//
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 应用内语言偏好：nil = 跟随系统，否则为语言 code（en / zh-Hans / hi）
FOUNDATION_EXTERN NSString *const TSAppLanguageUserDefaultsKey;

/**
 * @brief App language preference manager: apply at launch, follow system or use stored language.
 * @chinese 应用语言偏好管理：启动时生效，支持跟随系统或使用已选语言。
 */
@interface TSAppLanguageManager : NSObject

/// 在 App 启动时调用，根据存储的偏好设置 AppleLanguages（未设置则跟随系统）
+ (void)applyStoredLanguageIfNeeded;

/// 当前生效的语言 code：若有存储则返回存储值，否则返回系统首选（若不在支持列表则返回 @"en"）
+ (NSString *)currentLanguageCode;

/// 当前语言的展示名称（用于 Mine 页 detail）：跟随系统 / English / 简体中文 / हिंदी
+ (NSString *)currentLanguageDisplayName;

/// 保存用户选择的语言 code，nil 表示跟随系统；保存后需重启 App 生效
+ (void)savePreferredLanguageCode:(nullable NSString *)code;

@end

NS_ASSUME_NONNULL_END
