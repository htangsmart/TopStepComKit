//
//  TSLanguageConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//

#import "TSKitBaseModel.h"
#import "TSLanguageDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Language configuration management class
 * @chinese 语言配置管理类
 *
 * @discussion
 * [EN]: This class is responsible for managing all language configurations, including:
 *       1. Language code
 *       2. Native name
 *       3. Chinese name
 *       4. Language type
 * [CN]: 该类负责管理所有语言配置，包括：
 *       1. 语言代码
 *       2. 本地名称
 *       3. 中文名称
 *       4. 语言类型
 */
@interface TSLanguageConfig : TSKitBaseModel

/**
 * @brief Get language configuration dictionary
 * @chinese 获取语言配置字典
 *
 * @return 
 * EN: Dictionary containing all language configurations, key is language type, value is configuration dictionary
 * CN: 包含所有语言配置的字典，key为语言类型，value为配置字典
 */
+ (NSDictionary *)languageConfigMap;


+ (TSLanguageType)languageTypeWithCode:(NSString *)code ;

@end

NS_ASSUME_NONNULL_END 
