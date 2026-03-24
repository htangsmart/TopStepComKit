//
//  TSLanguageModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSLanguageModel (Fit)

/**
 * @brief Convert TSLanguageModel to FITCLOUDLANGUAGE
 * @chinese 将TSLanguageModel转换为FITCLOUDLANGUAGE
 *
 * @param model 
 * EN: TSLanguageModel object to be converted
 * CN: 需要转换的TSLanguageModel对象
 *
 * @return 
 * EN: Corresponding FITCLOUDLANGUAGE value, returns FITCLOUDLANGUAGE_NOTSET if conversion fails
 * CN: 对应的FITCLOUDLANGUAGE值，转换失败时返回FITCLOUDLANGUAGE_NOTSET
 */
+ (FITCLOUDLANGUAGE)fitCloudLanguageFromModel:(TSLanguageModel *)model;

/**
 * @brief 将FitCloud语言枚举转换为语言模型
 *
 * @param fitLanguage FitCloud语言枚举值
 * @return 对应的语言模型，如果是未知语言则返回nil
 */
+ (nullable TSLanguageModel *)modelFromFitCloudLanguage:(FITCLOUDLANGUAGE)fitLanguage;

/**
 * @brief 根据项目号获取支持的语言模型数组
 *
 * @param projectNumber 项目号，如：
 *                     - "980E": 支持基础语言集
 *                     - "8809"/"8800"/"8801": 支持扩展语言集
 *                     - 其他: 支持标准语言集
 *
 * @return 支持的语言模型数组，不同项目号返回不同的语言支持列表
 *
 * @discussion 支持的语言集：
 *            1. 基础语言集(980E)：en, de, es, fr, pt, ar, ru, zh
 *            2. 扩展语言集(8809/8800/8801)：en, de, es, fr, it, pt, ar, ru, vi, th, fa, zh
 *            3. 标准语言集(其他)：en, de, es, fr, it, pt, ar, ru, vi, th, zh
 */
+ (NSArray<TSLanguageModel *> *)supportedLanguageModelsForProject:(NSString *)projectNumber;

@end

NS_ASSUME_NONNULL_END
