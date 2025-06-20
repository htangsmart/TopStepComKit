//
//  TSSportModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMActivityDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSSportModel (SJ)

/**
 * @brief Convert WMActivityDataModel to TSSportModel
 * @chinese 将WMActivityDataModel转换为TSSportModel
 *
 * @param activityModel 
 * EN: WMActivityDataModel object to be converted
 * CN: 需要转换的WMActivityDataModel对象
 *
 * @return 
 * EN: Converted TSSportModel object, nil if conversion fails
 * CN: 转换后的TSSportModel对象，转换失败时返回nil
 */
+ (nullable TSSportModel *)modelWithWMActivityDataModel:(nullable WMActivityDataModel *)activityModel;

/**
 * @brief Convert array of WMActivityDataModel to array of TSSportModel
 * @chinese 将WMActivityDataModel数组转换为TSSportModel数组
 *
 * @param activityModels 
 * EN: Array of WMActivityDataModel objects to be converted
 * CN: 需要转换的WMActivityDataModel对象数组
 *
 * @return 
 * EN: Array of converted TSSportModel objects, empty array if conversion fails
 * CN: 转换后的TSSportModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSSportModel *> *)modelsWithWMActivityDataModels:(nullable NSArray<WMActivityDataModel *> *)activityModels;

@end

NS_ASSUME_NONNULL_END
