//
//  TSFwDailyActivitySyncHandler.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//
//  文件说明:
//  每日活动异构 handler：Fw 端历史活动拉完后，若 endTime 落在今天，需额外拉取设备当天实时聚合，
//  查库时用它覆盖 DB 里陈旧的当天数据（按 anchorDayStart 对齐）。

#import "TSFwSyncHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwDailyActivitySyncHandler : TSFwSyncHandler

@end

NS_ASSUME_NONNULL_END
