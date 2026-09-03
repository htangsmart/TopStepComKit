//
//  TSFitDialInstallSession+Private.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/30.
//

#import "TSFitDialInstallSession.h"

typedef NS_ENUM(NSInteger, TSFitDialInstallTransport) {
    TSFitDialInstallTransportPending = 0,
    TSFitDialInstallTransportNewOTA,
    TSFitDialInstallTransportDirectDFU,
    TSFitDialInstallTransportEnteredDFU,
};

NS_ASSUME_NONNULL_BEGIN

@interface TSFitDialInstallSession ()

@property (nonatomic, strong) TSDialArtifact *artifact;
@property (nonatomic, copy) NSArray<NSNumber *> *moduleStyles;
@property (nonatomic, copy, nullable) NSString *preparedFilePath;
@property (nonatomic, copy, nullable) NSString *workingDirectoryPath;
@property (nonatomic, copy, nullable) TSDialInstallProgressBlock progressBlock;
@property (nonatomic, copy, nullable) TSDialInstallCompletionBlock completion;
@property (nonatomic, copy, nullable) NSError *deferredNewOTAError;
/// @brief Pending NewOTA cancellation callback retained until response or timeout
/// @chinese 等待 NewOTA 取消响应或超时时暂存的回调
@property (nonatomic, copy, nullable) TSCompletionBlock pendingNewOTACancelCompletion;
@property (nonatomic, assign) TSFitDialInstallTransport transport;
@property (nonatomic, assign) NSInteger targetSlotIndex;
@property (nonatomic, assign) NSInteger pushIndex;
@property (nonatomic, assign) NSUInteger installGeneration;
@property (nonatomic, assign) NSUInteger dfuGeneration;
@property (nonatomic, assign) NSUInteger cancelGeneration;
/// @brief Generation of the latest exit-DFU attempt
/// @chinese 最近一次退出 DFU 尝试的代次
@property (nonatomic, assign) NSUInteger exitDFUAttemptGeneration;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL cancellationRequested;
@property (nonatomic, assign) BOOL cancelCommandPending;
@property (nonatomic, assign) BOOL activationInFlight;
@property (nonatomic, assign) BOOL terminalInFlight;
@property (nonatomic, assign) BOOL resourcesReleased;
@property (nonatomic, assign) BOOL newOTAQuiescent;
@property (nonatomic, assign) BOOL preparationInFlight;
@property (nonatomic, assign) BOOL enterDFURequestPending;
@property (nonatomic, assign) BOOL exitDFURequestPending;
@property (nonatomic, assign) BOOL enteredDFUMode;
@property (nonatomic, assign) BOOL dfuTransportQuiescent;
@property (nonatomic, assign) BOOL dfuStartInvoked;
@property (nonatomic, assign) BOOL dfuStartAcknowledged;
/// @brief Whether one DFU transport terminal callback has already won the race
/// @chinese 是否已有一个 DFU 传输终态回调赢得竞态
@property (nonatomic, assign) BOOL dfuTerminalClaimed;
@property (nonatomic, assign) BOOL requiresDFUModeExitConfirmation;
/// @brief Recovery state for bounded exit-DFU retries
/// @chinese 退出 DFU 有限重试的恢复状态
@property (nonatomic, assign) BOOL exitDFURetryScheduled;
@property (nonatomic, assign) NSInteger exitDFURetryCount;
@property (nonatomic, assign) BOOL deferredNewOTAResultPending;
@property (nonatomic, assign) BOOL deferredNewOTARequiresActivation;
@property (nonatomic, assign) BOOL deferredNewOTASuccess;
@property (nonatomic, assign) NSInteger lastProgress;

- (void)transferWithDirectDFUAtPath:(NSString *)filePath;
- (void)transferAfterEnteringDFUAtPath:(NSString *)filePath;
- (void)finishAfterExitingDFUIfNeededWithResult:(TSDialInstallResult)result
                                           error:(NSError *)error;
- (void)scheduleDFUCancellationFallback;
/// @brief Schedule the bounded public timeout for one NewOTA cancellation generation
/// @chinese 为一次 NewOTA 取消代次安排有限的公开超时
/// @param generation EN: Cancellation generation. CN: 取消代次。
- (void)scheduleNewOTACancellationTimeoutForGeneration:(NSUInteger)generation;
- (BOOL)acquireDFUOwnership;
- (void)releaseDFUOwnershipIfQuiescent;
- (void)cleanupFinishedSessionIfSafe;
- (BOOL)acquireInstallOwnership;
- (void)releaseInstallOwnership;
- (void)activateInstalledDial;
- (void)emitProgressResult:(TSDialInstallResult)result progress:(NSInteger)progress;
- (void)finishWithResult:(TSDialInstallResult)result error:(nullable NSError *)error;
- (BOOL)isActive;
- (BOOL)isCancellationRequested;
- (NSError *)cancellationError;

/// @brief Freeze or apply one NewOTA terminal result according to cancellation state
/// @chinese 按取消状态冻结或应用一次 NewOTA 终态
/// @param success EN: Whether the operation succeeded. CN: 操作是否成功。
/// @param requiresActivation EN: Whether activation is still required. CN: 是否仍需激活表盘。
/// @param error EN: Optional operation error. CN: 可选的操作错误。
- (void)handleNewOTAResultSuccess:(BOOL)success
               requiresActivation:(BOOL)requiresActivation
                            error:(nullable NSError *)error;

/// @brief Check whether FitCloud explicitly reports that the device is not in DFU mode
/// @chinese 检查 FitCloud 是否明确报告设备已不在 DFU 模式
/// @param error EN: FitCloud exit error. CN: FitCloud 退出错误。
/// @return EN: YES only for the explicit not-DFU error. CN: 仅明确的非 DFU 错误返回 YES。
- (BOOL)isConfirmedNotDFUModeError:(nullable NSError *)error;

/// @brief Handle an ordinary connection event with a testable DFU snapshot
/// @chinese 使用可测试的 DFU 状态快照处理普通连接事件
/// @param currentDFUMode EN: Whether FitCloud still reports DFU mode. CN: FitCloud 是否仍处于 DFU 模式。
- (void)handleOrdinaryConnectionWithCurrentDFUMode:(BOOL)currentDFUMode;

/// @brief Handle a confirmed reconnect in DFU mode
/// @chinese 处理已确认的 DFU 模式重连事件
- (void)handleDFUModeReconnect;

/// @brief Receive the ordinary FitCloud connection notification
/// @chinese 接收 FitCloud 普通连接通知
/// @param notification EN: FitCloud connection notification. CN: FitCloud 连接通知。
- (void)fitDialPeripheralConnected:(NSNotification *)notification;

/// @brief Receive the FitCloud DFU reconnect notification
/// @chinese 接收 FitCloud DFU 模式重连通知
/// @param notification EN: FitCloud DFU reconnect notification. CN: FitCloud DFU 重连通知。
- (void)fitDialPeripheralReconnectedWithDFUMode:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
