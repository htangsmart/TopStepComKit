//
//  TSLanguageModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSLanguageModel (Fw)

/**
 * @brief Get language model by local name
 * @chinese 根据本地语言名称获取对应的语言模型
 *
 * @param fwLanguageName
 * EN: Local name of the language (e.g., "English" for English, "中文" for Chinese)
 * CN: 语言的本地名称（例如：英语显示为"English"，中文显示为"中文"）
 *
 * @return
 * EN: Corresponding language model, nil if not found
 * CN: 对应的语言模型，未找到时返回nil
 */
+ (nullable TSLanguageModel *)languageWithFwName:(NSString *)fwLanguageName;

/**
 * @brief Get firmware language name for current language model
 * @chinese 获取当前语言模型对应的固件语言名称
 *
 * @return
 * EN: Firmware language name string (e.g., "en-US", "zh-Hans")
 * CN: 固件语言名称字符串（例如："en-US", "zh-Hans"）
 */
- (NSString *)fwLanguageName;

/**
 * @brief Get all supported language models
 * @chinese 获取所有支持的语言模型
 *
 * @return
 * EN: Array of supported TSLanguageModel objects
 * CN: 支持的语言模型对象数组
 */
+ (NSArray<TSLanguageModel *> *)supportLanguagesModels;

@end

NS_ASSUME_NONNULL_END
