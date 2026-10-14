//
//  TSAIConversationTranslationInterface.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIContractDefines.h"
#import "TSAIConversationTranslationConfig.h"
#import "TSAIConversationTranslationDefines.h"
#import "TSAIConversationTranslationEvent.h"
#import "TSAIConversationTranslationSnapshot.h"
#import "TSAIStartEligibility.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Two-party conversation translation orchestrated by the SDK
 * @chinese 由 SDK 编排的双人对话翻译
 *
 * @discussion
 * [EN]: One session = device product mode + a sequence of single-speaker turns.
 *       The SDK owns the device product mode, the per-turn device session, the
 *       interpreter task, the audio route of each turn (who captures, who plays),
 *       text/TTS delivery to the charging case and every device-originated event
 *       (device key press, device exit, low battery, disconnect). The App only
 *       forwards user intent and renders `TSAIConversationTranslationSnapshot`.
 *       Only one participant can speak at a time; a press while the other
 *       participant is speaking is rejected with `TurnRejectedBusy`.
 *       All callbacks are delivered on the main thread.
 * [CN]: 一次会话 = 设备产品模式 + 一串单人发言轮次。SDK 负责产品模式进出、每轮设备会话、
 *       同传任务、每轮音频路由（谁收音、谁播报）、向充电仓下发文本/TTS，以及所有设备侧事件
 *       （设备按键、设备退出、低电量、断连）。App 只转发用户意图并渲染
 *       `TSAIConversationTranslationSnapshot`。一次只能一个人说话，对方发言期间按下会以
 *       `TurnRejectedBusy` 拒绝。所有回调都在主线程。
 */
@protocol TSAIConversationTranslationInterface <NSObject>

/**
 * @brief Evaluate whether a product-mode preset can start on the connected device now
 * @chinese 校验指定产品模式预设当前能否在已连接设备上启动
 *
 * @param mode
 * EN: Product mode to evaluate with its preset endpoints
 * CN: 待校验的产品模式，按其预设端点评估
 *
 * @return
 * EN: Same as `eligibilityForConfig:` with `[TSAIConversationTranslationConfig configWithMode:]`
 * CN: 等价于以 `[TSAIConversationTranslationConfig configWithMode:]` 调用 `eligibilityForConfig:`
 */
- (TSAIStartEligibility *)eligibilityForMode:(TSAIConversationTranslationMode)mode;

/**
 * @brief Evaluate whether a configuration (mode plus capture/playback endpoints) can start now
 * @chinese 校验配置（模式加收音/播报端）当前能否启动
 *
 * @param config
 * EN: Configuration to evaluate; languages are not checked here
 * CN: 待校验的配置；此处不校验语言
 *
 * @return
 * EN: Supported, or Unsupported with an exact error: ContextInactive, InvalidParameter
 *     (mode or endpoint), BridgeUnavailable (case disconnected), NotSupported (firmware
 *     does not declare the Self/Peer scenes), Busy (interpretation in progress),
 *     AudioRouteUnavailable (a participant's capture→listener playback route is
 *     unavailable, e.g. case playback without PCM support)
 * CN: 支持，或携带准确错误的不支持：ContextInactive、InvalidParameter（模式或端点非法）、
 *     BridgeUnavailable（充电仓未连接）、NotSupported（固件未声明 Self/Peer 场景）、
 *     Busy（同传进行中）、AudioRouteUnavailable（某参与者的收音→听众播报路由不可用，
 *     例如充电仓不支持 PCM 播放）
 */
- (TSAIStartEligibility *)eligibilityForConfig:(TSAIConversationTranslationConfig *)config;

/**
 * @brief Start a conversation-translation session
 * @chinese 启动一次对话翻译会话
 *
 * @param config
 * EN: Mode, both languages and playback preferences
 * CN: 模式、双方语言与播报偏好
 *
 * @param onSnapshot
 * EN: Called on every state or turn change with an immutable snapshot
 * CN: 每次状态或轮次变化时携带不可变快照回调
 *
 * @param onEvent
 * EN: Called for discrete events such as rejected presses or failed turns
 * CN: 离散事件回调，例如按下被拒绝、一轮失败
 *
 * @param completion
 * EN: Called exactly once when the session ends, with the reason and an optional error
 * CN: 会话结束时恰好回调一次，携带原因与可选错误
 *
 * @return
 * EN: Session identifier, or nil when the session cannot start (completion is
 *     then called with `Failure` and the error)
 * CN: 会话标识；无法启动时返回 nil，并以 `Failure` 与错误回调 completion
 */
- (nullable NSString *)startWithConfig:(TSAIConversationTranslationConfig *)config
                            onSnapshot:(nullable TSAIConversationTranslationSnapshotBlock)onSnapshot
                               onEvent:(nullable TSAIConversationTranslationEventBlock)onEvent
                            completion:(nullable TSAIConversationTranslationCompletionBlock)completion;

/**
 * @brief Begin a turn for one participant (press-to-talk pressed)
 * @chinese 为某个参与者开始一轮发言（按住说话按下）
 *
 * @param participant
 * EN: Speaking participant; its resolved capture endpoint decides which
 *     microphone records (phone, earbuds or charging case)
 * CN: 发言参与者；其解析后的收音端决定由哪个麦克风采集（手机、耳机或充电仓）
 *
 * @param sessionId
 * EN: Identifier returned by `startWithConfig:...`
 * CN: `startWithConfig:...` 返回的会话标识
 *
 * @discussion
 * [EN]: Ignored when the session is not Ready; a busy rejection is reported
 *       through `TurnRejectedBusy`. A participant captured on the charging case
 *       starts device recording through the App-initiated device session.
 *       Device-initiated turns (charging case key) never go through this method.
 * [CN]: 会话非 Ready 时忽略，忙碌拒绝通过 `TurnRejectedBusy` 事件通知。收音端为充电仓的
 *       参与者通过 App 发起的设备会话让充电仓开始采音。设备发起的轮次（充电仓按键）
 *       不经过本方法。
 */
- (void)beginTurnForParticipant:(TSAIConversationParticipant)participant
                      sessionId:(NSString *)sessionId;

/**
 * @brief End the current App-initiated turn (press-to-talk released)
 * @chinese 结束当前 App 发起的轮次（按住说话松开）
 *
 * @param sessionId
 * EN: Identifier returned by `startWithConfig:...`
 * CN: `startWithConfig:...` 返回的会话标识
 *
 * @discussion
 * [EN]: Idempotent. Recognition of the captured audio continues; the turn is
 *       final when its snapshot entry reports `isFinal`.
 * [CN]: 幂等。已采集音频继续识别，快照中该轮 `isFinal` 为 YES 时即为最终结果。
 */
- (void)endTurnWithSessionId:(NSString *)sessionId;

/**
 * @brief Stop the session and leave the device product mode
 * @chinese 结束会话并退出设备产品模式
 *
 * @param sessionId
 * EN: Identifier returned by `startWithConfig:...`
 * CN: `startWithConfig:...` 返回的会话标识
 *
 * @param completion
 * EN: Device command delivery result; the session completion is delivered
 *     separately with `UserExitApp`
 * CN: 设备命令发送结果；会话 completion 另行以 `UserExitApp` 回调
 */
- (void)stopWithSessionId:(NSString *)sessionId
               completion:(nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
