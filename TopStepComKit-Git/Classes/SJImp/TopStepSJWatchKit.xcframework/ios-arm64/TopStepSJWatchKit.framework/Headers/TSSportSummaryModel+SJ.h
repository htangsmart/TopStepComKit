//
//  TSSportSummaryModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMActivityDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSSportSummaryModel (SJ)

/**
 * @brief Convert WMActivityDataModel to TSSportSummaryModel
 * @chinese 将WMActivityDataModel转换为TSSportSummaryModel
 *
 * @param activityModel 
 * EN: WMActivityDataModel object to be converted
 * CN: 需要转换的WMActivityDataModel对象
 *
 * @return 
 * EN: Converted TSSportSummaryModel object, nil if conversion fails
 * CN: 转换后的TSSportSummaryModel对象，转换失败时返回nil
 */
+ (nullable TSSportSummaryModel *)modelWithWMActivityDataModel:(nullable WMActivityDataModel *)activityModel;

@end

NS_ASSUME_NONNULL_END
