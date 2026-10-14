//
//  TSLanguageModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/29.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSLanguageModel (Npk)

/**
 * @brief Convert TSMetaLanguageModel to TSLanguageModel
 * @chinese 将TSMetaLanguageModel转换为TSLanguageModel
 *
 * @param metaLanguageModel 
 * EN: TSMetaLanguageModel object to be converted
 * CN: 需要转换的TSMetaLanguageModel对象
 *
 * @return 
 * EN: Converted TSLanguageModel object, nil if conversion fails
 * CN: 转换后的TSLanguageModel对象，转换失败时返回nil
 */
+ (nullable TSLanguageModel *)modelWithTSMetaLanguageModel:(nullable TSMetaLanguageModel *)metaLanguageModel;

/**
 * @brief Convert TSMetaLanguageList to array of TSLanguageModel
 * @chinese 将TSMetaLanguageList转换为TSLanguageModel数组
 *
 * @param metaLanguageList 
 * EN: TSMetaLanguageList object to be converted
 * CN: 需要转换的TSMetaLanguageList对象
 *
 * @return 
 * EN: Array of converted TSLanguageModel objects, empty array if conversion fails
 * CN: 转换后的TSLanguageModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSLanguageModel *> *)modelsWithTSMetaLanguageList:(nullable TSMetaLanguageList *)metaLanguageList;

/**
 * @brief Convert TSLanguageModel to TSMetaLanguageModel
 * @chinese 将TSLanguageModel转换为TSMetaLanguageModel
 *
 * @param languageModel 
 * EN: TSLanguageModel object to be converted
 * CN: 需要转换的TSLanguageModel对象
 *
 * @return 
 * EN: Converted TSMetaLanguageModel object, nil if conversion fails
 * CN: 转换后的TSMetaLanguageModel对象，转换失败时返回nil
 */
+ (nullable TSMetaLanguageModel *)tsMetaLanguageModelWithModel:(nullable TSLanguageModel *)languageModel;

@end

NS_ASSUME_NONNULL_END
