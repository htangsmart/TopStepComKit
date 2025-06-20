//
//  TSSportItemModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMActivityDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSSportItemModel (SJ)

/**
 * @brief Convert WMActivityDataModel to array of TSSportItemModel
 * @chinese 将WMActivityDataModel转换为TSSportItemModel数组
 *
 * @param activityModel 
 * EN: WMActivityDataModel object to be converted
 * CN: 需要转换的WMActivityDataModel对象
 *
 * @return 
 * EN: Array of converted TSSportItemModel objects, nil if conversion fails
 * CN: 转换后的TSSportItemModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSSportItemModel *> *)modelArrayWithWMActivityDataModel:(nullable WMActivityDataModel *)activityModel;

@end

NS_ASSUME_NONNULL_END
