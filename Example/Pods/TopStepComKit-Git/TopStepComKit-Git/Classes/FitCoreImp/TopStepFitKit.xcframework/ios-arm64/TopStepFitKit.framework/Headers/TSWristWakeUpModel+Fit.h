//
//  TSWristWakeUpModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudWWUObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSWristWakeUpModel (Fit)

/**
 * @brief Convert TSWristWakeUpModel to FitCloudWWUObject
 * @chinese 将TSWristWakeUpModel转换为FitCloudWWUObject
 * 
 * @param model 
 * EN: TSWristWakeUpModel object to be converted
 * CN: 需要转换的TSWristWakeUpModel对象
 * 
 * @return 
 * EN: Converted FitCloudWWUObject object, nil if conversion fails
 * CN: 转换后的FitCloudWWUObject对象，转换失败时返回nil
 */
+ (nullable FitCloudWWUObject *)fitCloudWWUObjectWithModel:(nullable TSWristWakeUpModel *)model;

/**
 * @brief Convert FitCloudWWUObject to TSWristWakeUpModel
 * @chinese 将FitCloudWWUObject转换为TSWristWakeUpModel
 * 
 * @param wwuObject 
 * EN: FitCloudWWUObject object to be converted
 * CN: 需要转换的FitCloudWWUObject对象
 * 
 * @return 
 * EN: Converted TSWristWakeUpModel object, nil if conversion fails
 * CN: 转换后的TSWristWakeUpModel对象，转换失败时返回nil
 */
+ (nullable TSWristWakeUpModel *)modelWithFitCloudWWUObject:(nullable FitCloudWWUObject *)wwuObject;

@end

NS_ASSUME_NONNULL_END
