//
//  TSFitAIWatchFaceSession.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI watch-face session state
 * @chinese AI 表盘会话状态
 */
typedef NS_ENUM(NSInteger, TSFitAIWatchFaceSessionState) {
    TSFitAIWatchFaceSessionStateIdle = 0,
    TSFitAIWatchFaceSessionStateCollectingPCM,
    TSFitAIWatchFaceSessionStateRecognizing,
    TSFitAIWatchFaceSessionStateWaitingGenerateRequest,
    TSFitAIWatchFaceSessionStateGeneratingImage,
    TSFitAIWatchFaceSessionStateSendingResult,
    TSFitAIWatchFaceSessionStateSendingPreview,
    TSFitAIWatchFaceSessionStateWaitingConfirmation,
    TSFitAIWatchFaceSessionStateResolvingTemplate,
    TSFitAIWatchFaceSessionStateDownloadingTemplate,
    TSFitAIWatchFaceSessionStatePreparingDial,
    TSFitAIWatchFaceSessionStateInstallingDial,
    TSFitAIWatchFaceSessionStateFinished,
    TSFitAIWatchFaceSessionStateFailed,
    TSFitAIWatchFaceSessionStateCancelled,
};

/**
 * @brief State and PCM storage for one AI watch-face flow
 * @chinese 单轮 AI 表盘流程的状态与 PCM 存储
 */
@interface TSFitAIWatchFaceSession : NSObject

/** @brief Current state @chinese 当前状态 */
@property (nonatomic, assign, readonly) TSFitAIWatchFaceSessionState state;

/** @brief Current generation token @chinese 当前轮次令牌 */
@property (nonatomic, copy, readonly, nullable) NSString *token;

/**
 * @brief Start a new session
 * @chinese 开始新会话
 *
 * @return
 * EN: New token, or nil while a dial installation is in progress
 * CN: 新轮次令牌；正在安装表盘时返回 nil
 */
- (nullable NSString *)beginSession;

/**
 * @brief Check whether a token belongs to the current session
 * @chinese 检查令牌是否属于当前会话
 *
 * @param token EN: Token to check. CN: 待检查令牌。
 * @return EN: YES when current. CN: 属于当前会话时返回 YES。
 */
- (BOOL)isCurrentToken:(NSString *)token;

/**
 * @brief Move the session through a legal state transition
 * @chinese 按合法状态路径推进会话
 *
 * @param state EN: Destination state. CN: 目标状态。
 * @param token EN: Current session token. CN: 当前会话令牌。
 * @return EN: YES when the transition succeeded. CN: 状态推进成功时返回 YES。
 */
- (BOOL)transitionToState:(TSFitAIWatchFaceSessionState)state token:(NSString *)token;

/**
 * @brief Append decoded incremental PCM data
 * @chinese 追加解码后的增量 PCM 数据
 *
 * @param pcmData EN: Incremental PCM bytes. CN: 增量 PCM 字节。
 * @param token EN: Current session token. CN: 当前会话令牌。
 * @return EN: YES when accepted. CN: 数据被接受时返回 YES。
 */
- (BOOL)appendDeltaPCMData:(nullable NSData *)pcmData token:(NSString *)token;

/**
 * @brief Resolve complete recognition input, preferring full stop data
 * @chinese 获取识别输入，优先使用停止回调的完整数据
 *
 * @param fullPCMData EN: Complete PCM from the stop event. CN: 停止事件携带的完整 PCM。
 * @param token EN: Current session token. CN: 当前会话令牌。
 * @return EN: Full data when non-empty, otherwise accumulated deltas. CN: 完整数据非空时返回完整数据，否则返回增量拼接结果。
 */
- (nullable NSData *)voiceDataPreferringFullData:(nullable NSData *)fullPCMData
                                           token:(NSString *)token;

/**
 * @brief Finish the current session with a terminal state
 * @chinese 以终态结束当前会话
 *
 * @param state EN: Finished, failed or cancelled. CN: 完成、失败或取消终态。
 * @param token EN: Current session token. CN: 当前会话令牌。
 * @return EN: YES when accepted. CN: 终态生效时返回 YES。
 */
- (BOOL)finishWithState:(TSFitAIWatchFaceSessionState)state token:(NSString *)token;

/**
 * @brief Reset a terminal session to idle
 * @chinese 将终态会话重置为空闲
 *
 * @param token EN: Current session token. CN: 当前会话令牌。
 * @return EN: YES when reset. CN: 重置成功时返回 YES。
 */
- (BOOL)resetToIdleWithToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
