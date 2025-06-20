//
//  WMDistanceDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时内新增的距离（米）（Distance added per hour (m)）
@interface WMDistanceDataModel : WMBaseDataModel

/// 新增距离（米）（New distance (m)）
@property (nonatomic, assign) NSInteger distance;

@end

NS_ASSUME_NONNULL_END
