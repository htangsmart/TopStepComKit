//
//  TSWeatherCodeModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherCodeModel (Fw)

/**
 * @brief 获取天气大类代码字符串（用于 describe 字段）
 * @chinese 获取天气大类代码字符串（用于 describe 字段）
 *
 * @discussion
 * EN: Returns the weather category code string (0-15) for the describe field
 * CN: 返回天气大类代码字符串（0-15），用于 describe 字段
 */
- (NSString *)largeCategoryString;

/**
 * @brief 获取天气子类型代码字符串（用于 ext_type 字段）
 * @chinese 获取天气子类型代码字符串（用于 ext_type 字段）
 *
 * @discussion
 * EN: Returns the weather subtype code string (-1 to 47) for the ext_type field
 * CN: 返回天气子类型代码字符串（-1到47），用于 ext_type 字段
 */
- (NSString *)subTypeString;

/**
 * @brief 获取天气代码字符串（兼容旧方法，返回大类代码）
 * @chinese 获取天气代码字符串（兼容旧方法，返回大类代码）
 *
 * @deprecated 建议使用 largeCategoryString 或 subTypeString
 */
- (NSString *)weatherCodeString;

@end

NS_ASSUME_NONNULL_END
