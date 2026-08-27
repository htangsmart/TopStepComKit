//
//  TSWorldClockModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/5/22.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Category for converting between TSWorldClockModel and FitCloudWorldClockModel
 * @chinese TSWorldClockModel和FitCloudWorldClockModel之间的转换分类
 */
@interface TSWorldClockModel (Fit)

/**
 * @brief Convert TSWorldClockModel to FitCloudWorldClockModel
 * @chinese 将TSWorldClockModel转换为FitCloudWorldClockModel
 *
 * @return 
 * EN: Converted FitCloudWorldClockModel object, nil if conversion fails
 * CN: 转换后的FitCloudWorldClockModel对象，转换失败时返回nil
 */
- (nullable FitCloudWorldClockModel *)toFitCloudWorldClockModel;

/**
 * @brief Convert array of TSWorldClockModel to array of FitCloudWorldClockModel
 * @chinese 将TSWorldClockModel数组转换为FitCloudWorldClockModel数组
 *
 * @param models 
 * EN: Array of TSWorldClockModel objects to be converted
 * CN: 需要转换的TSWorldClockModel对象数组
 *
 * @return 
 * EN: Array of converted FitCloudWorldClockModel objects
 * CN: 转换后的FitCloudWorldClockModel对象数组
 */
+ (NSArray<FitCloudWorldClockModel *> *)toFitCloudWorldClockModels:(NSArray<TSWorldClockModel *> *)models;

/**
 * @brief Create TSWorldClockModel from FitCloudWorldClockModel
 * @chinese 从FitCloudWorldClockModel创建TSWorldClockModel
 *
 * @param fitModel 
 * EN: FitCloudWorldClockModel object to be converted
 * CN: 需要转换的FitCloudWorldClockModel对象
 *
 * @return 
 * EN: Converted TSWorldClockModel object, nil if conversion fails
 * CN: 转换后的TSWorldClockModel对象，转换失败时返回nil
 */
+ (nullable TSWorldClockModel *)modelWithFitCloudWorldClockModel:(FitCloudWorldClockModel *)fitModel;

/**
 * @brief Convert array of FitCloudWorldClockModel to array of TSWorldClockModel
 * @chinese 将FitCloudWorldClockModel数组转换为TSWorldClockModel数组
 *
 * @param fitModels 
 * EN: Array of FitCloudWorldClockModel objects to be converted
 * CN: 需要转换的FitCloudWorldClockModel对象数组
 *
 * @return 
 * EN: Array of converted TSWorldClockModel objects
 * CN: 转换后的TSWorldClockModel对象数组
 */
+ (NSArray<TSWorldClockModel *> *)modelsWithFitCloudWorldClockModels:(NSArray<FitCloudWorldClockModel *> *)fitModels;

@end

NS_ASSUME_NONNULL_END
