//
//  TSUgreenConfigModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/10/14.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Conversion between TSUgreenConfigModel and FitCloudUgreenConfig
 * @chinese TSUgreenConfigModel 与 FitCloudUgreenConfig 互转
 *
 * @discussion
 * [EN]: setUgreenConfig:completion: overwrites the whole configuration on the device, so the mapping must cover
 *       every FitCloudUgreenConfig property. When FitCloudKit adds a property, add it to TSUgreenConfigModel too,
 *       otherwise a set call resets it to the FitCloudUgreenConfig default.
 * [CN]: setUgreenConfig:completion: 会覆盖设备上的整包配置，映射必须覆盖 FitCloudUgreenConfig 的全部属性。
 *       FitCloudKit 新增属性时 TSUgreenConfigModel 要同步新增，否则一次 set 会把该属性重置为 FitCloudUgreenConfig 默认值。
 */
@interface TSUgreenConfigModel (Fit)

/**
 * @brief Create a model from a FitCloud UGREEN configuration
 * @chinese 由 FitCloud 绿联配置创建模型
 *
 * @param config
 * EN: Configuration returned by FitCloudKit
 * CN: FitCloudKit 返回的配置
 *
 * @return
 * EN: Converted model
 * CN: 转换后的模型
 */
+ (instancetype)modelWithFitCloudUgreenConfig:(FitCloudUgreenConfig *)config;

/**
 * @brief Convert to a FitCloud UGREEN configuration
 * @chinese 转换为 FitCloud 绿联配置
 *
 * @return
 * EN: FitCloud configuration carrying every field of this model
 * CN: 携带本模型全部字段的 FitCloud 配置
 */
- (FitCloudUgreenConfig *)toFitCloudUgreenConfig;

@end

NS_ASSUME_NONNULL_END
