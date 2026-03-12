//
//  TSLanguageModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//

#import "TSKitBaseModel.h"
#import "TSLanguageDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSLanguageModel : TSKitBaseModel


/**
 * @brief Language type enum value
 * @chinese 语言类型枚举值
 *
 * @discussion
 * [EN]: The enum value representing the language type (e.g., TSLanguage_ENGLISH for English)
 * [CN]: 表示语言类型的枚举值（例如：TSLanguage_ENGLISH表示英语）
 *
 * @note
 * [EN]: This property is used for type-safe language identification and switching
 * [CN]: 此属性用于类型安全的语言识别和切换
 */
@property (nonatomic, assign) TSLanguageType type;

/**
 * @brief Language code of the current language
 * @chinese 当前语言的代码
 *
 * @discussion
 * [EN]: The language code follows ISO 639-1 standard (e.g., "en" for English, "zh" for Chinese)
 * [CN]: 语言代码遵循ISO 639-1标准（例如："en"表示英语，"zh"表示中文）
 *
 * @note
 * [EN]: This code is used for system language identification and switching
 * [CN]: 此代码用于系统语言识别和切换
 */
@property (nonatomic, copy) NSString *code;

/**
 * @brief Native name of the language
 * @chinese 语言的本地名称
 *
 * @discussion
 * [EN]: The name of the language in its own language (e.g., "English" for English, "中文" for Chinese)
 * [CN]: 语言在其自身语言中的名称（例如：英语显示为"English"，中文显示为"中文"）
 *
 * @note
 * [EN]: Used for displaying language options in the language selection interface
 * [CN]: 用于在语言选择界面显示语言选项
 */
@property (nonatomic, copy) NSString *nativeName;

/**
 * @brief Chinese name of the language
 * @chinese 语言的中文名称
 *
 * @discussion
 * [EN]: The name of the language in Chinese (e.g., "英语" for English, "中文" for Chinese)
 * [CN]: 语言的中文名称（例如：英语显示为"英语"，中文显示为"中文"）
 *
 * @note
 * [EN]: Used for displaying language options in Chinese interface
 * [CN]: 用于在中文界面显示语言选项
 */
@property (nonatomic, copy) NSString *chineseName;


/**
 * @brief Create language model instance with language code
 * @chinese 根据语言代码创建语言模型实例
 *
 * @param code
 * EN: Language code following ISO 639-1 standard (e.g., "en" for English, "zh" for Chinese)
 * CN: 遵循ISO 639-1标准的语言代码（例如："en"表示英语，"zh"表示中文）
 *
 * @return
 * EN: TSLanguageModel instance, nil if language code is invalid
 * CN: TSLanguageModel实例，语言代码无效时返回nil
 */
+ (nullable instancetype)languageWithCode:(NSString *)code;

/**
 * @brief Create language model instance with language type
 * @chinese 根据语言类型创建语言模型实例
 *
 * @param type
 * EN: Language type enum value (e.g., TSLanguage_ENGLISH for English, TSLanguage_CHINESESIMPLIFIED for Chinese)
 * CN: 语言类型枚举值（例如：TSLanguage_ENGLISH表示英语，TSLanguage_CHINESESIMPLIFIED表示简体中文）
 *
 * @return
 * EN: TSLanguageModel instance, nil if language type is invalid or not supported
 * CN: TSLanguageModel实例，语言类型无效或不支持时返回nil
 */
+ (nullable instancetype)languageWithType:(TSLanguageType)type;


@end

NS_ASSUME_NONNULL_END
