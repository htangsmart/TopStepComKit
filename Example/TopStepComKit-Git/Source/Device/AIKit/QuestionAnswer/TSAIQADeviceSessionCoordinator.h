//
//  TSAIQADeviceSessionCoordinator.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepAIKit/TSAIStartRequest.h>

@class TSAIQADeviceRound;

NS_ASSUME_NONNULL_BEGIN

/// 设备协同问答会话已激活（手表发起或 App 发起均会发送），请求展示问答页面
FOUNDATION_EXTERN NSNotificationName const TSAIQADeviceSessionDidRequestPresentationNotification;
/// 会话状态变化
FOUNDATION_EXTERN NSNotificationName const TSAIQADeviceSessionDidChangeNotification;
/// 某一轮次收到新的累计快照（userInfo 携带轮次）
FOUNDATION_EXTERN NSNotificationName const TSAIQADeviceSessionDidUpdateRoundNotification;
/// 追加一行日志（userInfo 携带文本）
FOUNDATION_EXTERN NSNotificationName const TSAIQADeviceSessionDidAppendLogNotification;

/// userInfo key · TSAIQADeviceRound
FOUNDATION_EXTERN NSString * const TSAIQADeviceSessionRoundUserInfoKey;
/// userInfo key · NSString 日志行
FOUNDATION_EXTERN NSString * const TSAIQADeviceSessionLogLineUserInfoKey;

/**
 * @brief State of the App-owned device-coordinated question-answer session
 * @chinese App 持有的设备协同问答会话状态
 */
typedef NS_ENUM(NSInteger, TSAIQADeviceSessionState) {
    /// 未绑定 Context（设备未连接或未完成鉴权）
    TSAIQADeviceSessionStateUnbound = 0,
    /// Context 已绑定，但问答接口或设备会话接口不可用
    TSAIQADeviceSessionStateUnsupported,
    /// 已注册 VoiceQuestionAnswer 路由，空闲；手表发起或 App 发起都可开始一轮
    TSAIQADeviceSessionStateRegistered,
    /// 已收到本轮请求，本地准备中（等待 startDeviceQuestionAnswer completion 与设备同步）
    TSAIQADeviceSessionStatePreparing,
    /// 双端已激活，手表正在拾音
    TSAIQADeviceSessionStateListening,
    /// 拾音已结束，等待识别、回答与播放
    TSAIQADeviceSessionStateAnswering,
    /// App 主动停止中
    TSAIQADeviceSessionStateStopping,
};

/**
 * @brief Who started the current round
 * @chinese 当前轮次的发起方
 */
typedef NS_ENUM(NSInteger, TSAIQADeviceSessionOrigin) {
    /// 没有进行中的轮次
    TSAIQADeviceSessionOriginNone = 0,
    /// App 发起（startDeviceAISessionFromAppWithRequest:，能力位 0x25）
    TSAIQADeviceSessionOriginApp,
    /// 手表发起（设备请求 → prepareHandler，能力位 0x24）
    TSAIQADeviceSessionOriginDevice,
};

/**
 * @brief App-level owner of the device-coordinated question-answer route
 * @chinese 设备协同 AI 问答路由的 App 级持有者
 *
 * @discussion
 * [EN]: After the Context is authenticated it registers the
 *       `TSAIUseCaseVoiceQuestionAnswer` handlers with
 *       `registerDeviceAISessionHandlerForUseCase:...`. The prepare handler calls
 *       `startDeviceQuestionAnswerWithConfig:onEvent:completion:` exactly as the SDK's
 *       DeviceQuestionAnswerHistory integration example does, so both watch-initiated
 *       rounds (device capacity 0x24) and App-initiated rounds
 *       (`startDeviceAISessionFromAppWithRequest:`, device capacity 0x25) flow through the
 *       same handlers and the same `onEvent` observer. Events are grouped by
 *       `roundIdentifier` and re-published as notifications for pages.
 * [CN]: Context 鉴权完成后用 `registerDeviceAISessionHandlerForUseCase:...` 注册
 *       `TSAIUseCaseVoiceQuestionAnswer` 的四个 Handler；prepareHandler 内按 SDK 的
 *       DeviceQuestionAnswerHistory 接入示例调用
 *       `startDeviceQuestionAnswerWithConfig:onEvent:completion:`。手表发起（能力位 0x24）
 *       与 App 发起（`startDeviceAISessionFromAppWithRequest:`，能力位 0x25）共用同一组
 *       Handler 与同一个 `onEvent`，事件按 `roundIdentifier` 归组后以通知分发给页面。
 */
@interface TSAIQADeviceSessionCoordinator : NSObject <NSCopying, NSMutableCopying>

/**
 * @brief Shared coordinator
 * @chinese 共享协调器
 *
 * @return
 * EN: The process-wide coordinator
 * CN: 进程内共享的协调器
 */
+ (instancetype)sharedInstance;

/**
 * @brief Current session state
 * @chinese 当前会话状态
 */
@property (nonatomic, assign, readonly) TSAIQADeviceSessionState state;

/**
 * @brief Origin of the current round
 * @chinese 当前轮次的发起方
 */
@property (nonatomic, assign, readonly) TSAIQADeviceSessionOrigin origin;

/**
 * @brief Exact request of the current round, used by stop
 * @chinese 当前轮次的精确请求，用于停止
 */
@property (nonatomic, copy, readonly, nullable) TSAIStartRequest *currentRequest;

/**
 * @brief Identifier returned by `startDeviceQuestionAnswerWithConfig:`
 * @chinese `startDeviceQuestionAnswerWithConfig:` 返回的标识
 */
@property (nonatomic, copy, readonly, nullable) NSString *sessionTaskId;

/**
 * @brief Public device session identifier reported by events
 * @chinese 事件上报的对外设备会话标识
 */
@property (nonatomic, copy, readonly, nullable) NSString *sessionIdentifier;

/**
 * @brief Configuration used by the next prepare
 * @chinese 下一次准备时使用的配置
 */
@property (nonatomic, copy, readonly) TSAIQuestionAnswerConfig *config;

/**
 * @brief Rounds of the current binding, oldest first
 * @chinese 当前绑定期间的轮次，按时间正序
 */
@property (nonatomic, copy, readonly) NSArray<TSAIQADeviceRound *> *rounds;

/**
 * @brief Recent log lines, oldest first
 * @chinese 最近的日志行，按时间正序
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *logLines;

/**
 * @brief Most recent start, prepare or event failure
 * @chinese 最近一次启动、准备或事件失败
 */
@property (nonatomic, strong, readonly, nullable) NSError *lastError;

/**
 * @brief Bind an authenticated Context and register the question-answer route
 * @chinese 绑定已鉴权的 Context 并注册问答路由
 *
 * @param context
 * EN: Active and authenticated Context
 * CN: 已激活且鉴权完成的 Context
 */
- (void)bindAuthenticatedContext:(TSAIContext *)context;

/**
 * @brief Unbind a Context, unregistering the route and cancelling the active round locally
 * @chinese 解绑 Context，注销路由并在本地取消进行中的轮次
 *
 * @param context
 * EN: Context to unbind; nil unbinds unconditionally
 * CN: 要解绑的 Context；nil 表示无条件解绑
 */
- (void)unbindContext:(nullable TSAIContext *)context;

/**
 * @brief Replace the configuration used by the next round
 * @chinese 替换下一轮使用的配置
 *
 * @param config
 * EN: New configuration; an in-flight round keeps its own
 * CN: 新配置；进行中的轮次不受影响
 */
- (void)updateConfig:(TSAIQuestionAnswerConfig *)config;

/**
 * @brief Start one App-initiated round on the watch microphone
 * @chinese 由 App 发起一轮手表拾音的问答
 *
 * @discussion
 * [EN]: Builds `TSAIUseCaseVoiceQuestionAnswer` + scene QuestionAnswer + initiator App and
 *       calls `startDeviceAISessionFromAppWithRequest:`. Requires the watch to declare the
 *       App-initiated question-answer scene (capacity 0x25).
 * [CN]: 构造 `TSAIUseCaseVoiceQuestionAnswer` + QuestionAnswer 场景 + App 发起方并调用
 *       `startDeviceAISessionFromAppWithRequest:`；需要手表声明 App 发起的问答场景（能力位 0x25）。
 */
- (void)startRoundFromApp;

/**
 * @brief Stop the current round from the App
 * @chinese 由 App 停止当前轮次
 */
- (void)stopCurrentRound;

/**
 * @brief Remove all rounds
 * @chinese 清空轮次
 */
- (void)clearRounds;

/**
 * @brief Append one line to the shared log
 * @chinese 向共享日志追加一行
 *
 * @param line
 * EN: Log text without timestamp
 * CN: 不含时间戳的日志文本
 */
- (void)appendLogLine:(NSString *)line;

/**
 * @brief Round that has not reached a terminal phase, if any
 * @chinese 尚未到终态的轮次，可能为空
 *
 * @return
 * EN: The active round, or nil
 * CN: 进行中的轮次，没有时为 nil
 */
- (nullable TSAIQADeviceRound *)activeRound;

/**
 * @brief Question-answer interface of the bound Context
 * @chinese 已绑定 Context 的问答接口
 *
 * @return
 * EN: The interface, or nil when unbound
 * CN: 问答接口；未绑定时为 nil
 */
- (nullable id<TSAIQuestionAnswerInterface>)questionAnswerInterface;

/**
 * @brief Whether the bound Context supports App-initiated text question answering
 * @chinese 已绑定 Context 是否支持文字问答
 *
 * @return
 * EN: YES when `TSAIFeatureQuestionAnswering` is supported
 * CN: 支持 `TSAIFeatureQuestionAnswering` 时返回 YES
 */
- (BOOL)supportsTextQuestionAnswer;

/**
 * @brief Eligibility error of a device-coordinated round for one initiator
 * @chinese 指定发起方的设备协同问答启动资格错误
 *
 * @param initiator
 * EN: App (capacity 0x25) or Device (capacity 0x24)
 * CN: App（能力位 0x25）或 Device（能力位 0x24）
 *
 * @return
 * EN: nil when `startEligibilityForRequest:` reports Supported; otherwise the reason
 * CN: `startEligibilityForRequest:` 判定支持时为 nil，否则返回原因
 */
- (nullable NSError *)deviceRoundEligibilityErrorForInitiator:(TSAISessionInitiator)initiator;

/**
 * @brief Resolved device audio route for a configuration
 * @chinese 配置对应的已解析设备音频路由
 *
 * @discussion
 * [EN]: Device coordination rejects Automatic channels. Input is always Opus (FitCloud
 *       App-initiated sessions always request device Opus); an Automatic/Unknown output
 *       resolves to SystemDefault.
 * [CN]: 设备协同不接受 Automatic 通道。输入固定 Opus（FitCloud 的 App 发起会话固定请求设备
 *       Opus）；输出为 Automatic/Unknown 时解析为 SystemDefault。
 *
 * @param config
 * EN: Configuration whose route is resolved; nil uses defaults
 * CN: 要解析路由的配置；nil 时使用默认值
 *
 * @return
 * EN: A resolved route
 * CN: 已解析的路由
 */
+ (TSAIAudioRouteConfiguration *)resolvedDeviceRouteForConfig:(nullable TSAIQuestionAnswerConfig *)config;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
