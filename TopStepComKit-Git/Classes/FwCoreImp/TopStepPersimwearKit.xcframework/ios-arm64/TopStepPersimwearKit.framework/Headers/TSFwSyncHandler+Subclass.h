//
//  TSFwSyncHandler+Subclass.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//
//  文件说明:
//  暴露给 TSFwSyncHandler 子类重写的步骤方法与工具。
//  仅异构类型的 handler 子类（HR 静息 / DailyActivity 今日）导入本头，普通类型不需要。

#import "TSFwSyncHandler.h"
#import "TSFwHealthData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwSyncHandler (Subclass)

#pragma mark - 可重写步骤（默认实现见基类，子类按需重写）

/// 拉取：默认调 syncClass 的 queryDataWithStartTime:endTime:，包装成 TSFwHealthData
- (void)fetchWithContext:(TSFwSyncContext *)context
              completion:(void (^)(TSFwHealthData * _Nullable fwData))completion;

/// 入库：默认有数据才调 syncClass 入库；无数据直接完成
- (void)insertWithFwData:(TSFwHealthData *)fwData
                 hasData:(BOOL)hasData
                 context:(TSFwSyncContext *)context
              completion:(void (^)(void))completion;

/// 查库：默认调 syncClass 查库，包装成 TSHealthData
- (void)queryWithContext:(TSFwSyncContext *)context
              completion:(void (^)(TSHealthData *result))completion;

/// 推进锚点：有数据按真实 endTime，空数据推进到 requestEndTime
- (void)advanceAnchorWithFwData:(TSFwHealthData *)fwData
                        hasData:(BOOL)hasData
                        context:(TSFwSyncContext *)context;

#pragma mark - 子类可复用的工具

/// 有数据时用本次数据真实 endTime 推进 lastSyncTime（钳到 now，仅严格前进）
- (void)updateSyncTimeWithFwData:(TSFwHealthData *)healthData;

/// 空数据时把 lastSyncTime 推进到本次请求 endTime
- (void)advanceSyncTimeToRequestEndTime:(NSTimeInterval)requestEndTime;

@end

NS_ASSUME_NONNULL_END
