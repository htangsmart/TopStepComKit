//
//  TSLanguageModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMLanguageModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSLanguageModel (SJ)

/**
 * @brief Convert TSLanguageModel to WMLanguageModel
 * @chinese 将TSLanguageModel转换为WMLanguageModel
 *
 * @param tsModel 
 * EN: TSLanguageModel object to be converted
 * CN: 需要转换的TSLanguageModel对象
 *
 * @return 
 * EN: Converted WMLanguageModel object, nil if conversion fails
 * CN: 转换后的WMLanguageModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts TSLanguageModel to WMLanguageModel:
 *     - Converts language code to BCP format
 *     - Sets the current language
 * CN: 该方法将TSLanguageModel转换为WMLanguageModel：
 *     - 将语言代码转换为BCP格式
 *     - 设置当前语言
 */
+ (nullable WMLanguageModel *)wmModelWithTSLanguageModel:(nullable TSLanguageModel *)tsModel;

/**
 * @brief Convert WMLanguageModel to TSLanguageModel
 * @chinese 将WMLanguageModel转换为TSLanguageModel
 *
 * @param wmModel 
 * EN: WMLanguageModel object to be converted
 * CN: 需要转换的WMLanguageModel对象
 *
 * @return 
 * EN: Converted TSLanguageModel object, nil if conversion fails
 * CN: 转换后的TSLanguageModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts WMLanguageModel to TSLanguageModel:
 *     - Converts BCP language code to our format
 *     - Sets appropriate native name and Chinese name based on language code
 * CN: 该方法将WMLanguageModel转换为TSLanguageModel：
 *     - 将BCP语言代码转换为我们的格式
 *     - 根据语言代码设置相应的本地名称和中文名称
 */
+ (nullable TSLanguageModel *)modelWithWMLanguageModel:(nullable WMLanguageModel *)wmModel;

/**
 * @brief Convert language code array to TSLanguageModel array
 * @chinese 将语言代码字符串数组转换为TSLanguageModel数组
 *
 * @param languageCodes 
 * EN: Array of language codes (supports both simple and BCP format)
 * CN: 语言代码字符串数组（支持简单格式和BCP格式）
 *
 * @return 
 * EN: Array of TSLanguageModel objects, empty array if conversion fails
 * CN: TSLanguageModel对象数组，如果转换失败则返回空数组
 *
 * @discussion
 * EN: This method converts an array of language codes to TSLanguageModel array:
 *     - Supports both simple (e.g., "en") and BCP format (e.g., "zh-CN")
 *     - Automatically sets native name and Chinese name for each language
 *     - Filters out invalid or unsupported language codes
 * CN: 该方法将语言代码字符串数组转换为TSLanguageModel数组：
 *     - 支持简单格式（如"en"）和BCP格式（如"zh-CN"）的语言代码
 *     - 自动设置每种语言的本地名称和中文名称
 *     - 过滤掉无效或不支持的语言代码
 */
+ (NSArray<TSLanguageModel *> *)modelsWithLanguageCodes:(NSArray<NSString *> *)languageCodes;

@end

NS_ASSUME_NONNULL_END
