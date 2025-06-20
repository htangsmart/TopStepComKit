//
//  TSBOValueModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

@class WMBloodOxygenDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSBOValueModel (SJ)

/**
 * @brief Convert TSBOValueModel to WMBloodOxygenDataModel
 * @chinese 将TSBOValueModel转换为WMBloodOxygenDataModel
 *
 * @return 
 * EN: Converted WMBloodOxygenDataModel object
 * CN: 转换后的WMBloodOxygenDataModel对象
 */
- (WMBloodOxygenDataModel *)toWMBloodOxygenDataModel;

/**
 * @brief Convert TSBOValueModel array to WMBloodOxygenDataModel array
 * @chinese 将TSBOValueModel数组转换为WMBloodOxygenDataModel数组
 *
 * @param models 
 * EN: Array of TSBOValueModel objects to be converted
 * CN: 需要转换的TSBOValueModel对象数组
 * 
 * @return 
 * EN: Array of converted WMBloodOxygenDataModel objects
 * CN: 转换后的WMBloodOxygenDataModel对象数组
 */
+ (NSArray<WMBloodOxygenDataModel *> *)arrayWithTSBOValueModels:(NSArray<TSBOValueModel *> *)models;

/**
 * @brief Convert WMBloodOxygenDataModel to TSBOValueModel
 * @chinese 将WMBloodOxygenDataModel转换为TSBOValueModel
 *
 * @param model 
 * EN: WMBloodOxygenDataModel object to be converted
 * CN: 需要转换的WMBloodOxygenDataModel对象
 * 
 * @return 
 * EN: Converted TSBOValueModel object
 * CN: 转换后的TSBOValueModel对象
 */
+ (TSBOValueModel *)modelWithWMBloodOxygenDataModel:(WMBloodOxygenDataModel *)model;

/**
 * @brief Convert WMBloodOxygenDataModel array to TSBOValueModel array
 * @chinese 将WMBloodOxygenDataModel数组转换为TSBOValueModel数组
 *
 * @param models 
 * EN: Array of WMBloodOxygenDataModel objects to be converted
 * CN: 需要转换的WMBloodOxygenDataModel对象数组
 * 
 * @return 
 * EN: Array of converted TSBOValueModel objects
 * CN: 转换后的TSBOValueModel对象数组
 */
+ (NSArray<TSBOValueModel *> *)arrayWithWMBloodOxygenDataModels:(NSArray<WMBloodOxygenDataModel *> *)models;


+ (NSArray<TSBOValueModel *> *)modelsWithWMOxyBaseByDayModels:(NSArray<WMBaseByDayDataModel<WMBloodOxygenDataModel *> *> * _Nullable)wmModels ;

@end

NS_ASSUME_NONNULL_END
