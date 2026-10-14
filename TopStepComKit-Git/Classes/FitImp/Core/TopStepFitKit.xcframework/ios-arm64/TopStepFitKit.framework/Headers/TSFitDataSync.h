//
//  TSFitDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitDataSync : TSFitKitBase<TSDataSyncInterface>

/**
 * @brief Whether any Fit data sync currently owns the shared sync state
 * @chinese 当前是否有 Fit 数据同步占用全局同步状态
 *
 * @discussion
 * [EN]: FitCloudKit rejects every other command with FITCLOUDKITERROR_BLOCKBYDATASYNC (40003)
 *       while a manual sync is transferring. Callers that must not collide with a sync
 *       (for example App-origin AI session start) read this flag before sending.
 * [CN]: 手动同步传输期间 FitCloudKit 会以 40003 拒绝其它命令；不能与同步冲突的调用方
 *       （例如 App 发起 AI 会话）在发送命令前读取该状态。线程安全。
 */
+ (BOOL)isSyncInProgress;

@end

NS_ASSUME_NONNULL_END
