//
//  TSMessageModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMessageModel (Npk)

/// TSMessageModel数组 -> TSMetaNotificationModel
+ (nullable TSMetaNotificationModel *)tsMetaNotificationModelWithMessages:(nullable NSArray<TSMessageModel *> *)messages;

/// TSMetaNotificationModel -> TSMessageModel数组
+ (NSArray<TSMessageModel *> *)modelsWithTSMetaNotificationModel:(nullable TSMetaNotificationModel *)notificationModel;

@end

NS_ASSUME_NONNULL_END
