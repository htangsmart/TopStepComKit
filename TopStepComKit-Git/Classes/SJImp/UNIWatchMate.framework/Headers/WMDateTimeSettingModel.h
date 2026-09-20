//
//  WMDateTimeSettingModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseSettingModel.h"
#import "WMDateTimeModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 同步时间（只有设置接口，其他获取、监听接口无效） (Synchronize time (only the setting interface, other acquisition and listening interfaces are invalid))
@interface WMDateTimeSettingModel : WMBaseSettingModel<WMDateTimeModel *>

@end

NS_ASSUME_NONNULL_END
