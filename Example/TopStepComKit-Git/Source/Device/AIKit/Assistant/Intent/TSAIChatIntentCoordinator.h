//
//  TSAIChatIntentCoordinator.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSAIChatIntent;
@class TSAIChatIntentCoordinator;
@class TSAIChatRoundModel;
@class TSAIChatDeviceSessionCoordinator;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Delegate that reflects intent handling on the UI
 * @chinese 把意图处理进度反映到 UI 的委托
 */
@protocol TSAIChatIntentCoordinatorDelegate <NSObject>

/**
 * @brief The round's intent status / progress text changed; refresh it
 * @chinese 本轮意图状态或进度文案变化，需要刷新
 * @param coordinator EN: Sender. CN: 发送者。
 * @param round EN: Affected round. CN: 受影响的轮次。
 */
- (void)intentCoordinator:(TSAIChatIntentCoordinator *)coordinator didUpdateRound:(TSAIChatRoundModel *)round;

/**
 * @brief Intent handling failed; the round should be marked as error
 * @chinese 意图处理失败，本轮应置为出错
 * @param coordinator EN: Sender. CN: 发送者。
 * @param round EN: Affected round. CN: 受影响的轮次。
 * @param reason EN: Short reason for the meta line. CN: 简短原因（状态行）。
 * @param bodyText EN: Explanation for the bubble body. CN: 气泡正文说明。
 * @param actionTitle EN: Optional banner action title (e.g. "去设置"). CN: 可选横幅动作标题（如「去设置」）。
 * @param action EN: Banner action handler. CN: 横幅动作回调。
 * @param endsSession EN: Whether the App should stop the current session (single round). CN: App 是否应结束当前会话（单轮）。
 */
- (void)intentCoordinator:(TSAIChatIntentCoordinator *)coordinator
             didFailRound:(TSAIChatRoundModel *)round
                   reason:(NSString *)reason
                 bodyText:(NSString *)bodyText
              actionTitle:(nullable NSString *)actionTitle
                   action:(nullable void (^)(void))action
              endsSession:(BOOL)endsSession;

/**
 * @brief A command intent this device / App cannot execute got no answer; close the round now
 * @chinese 当前设备 / App 执行不了的指令意图没有等到回答：立即收口本轮
 *
 * @discussion
 * [EN]: For command intents (music / volume / photo / call ...) the cloud usually sends
 *       no answer text or voice and expects the client to execute. Nothing executes
 *       them here, so instead of waiting for the 15s idle timeout the round is closed
 *       with an explicit notice. `round.intentStatus` is already `Unsupported`.
 * [CN]: 对音乐 / 音量 / 拍照 / 通话等指令意图，云端通常不出回答文本和语音，等端侧执行；
 *       本 Demo 与当前设备都执行不了，因此不再空等 15s 空闲超时，而是立即以明确提示收口本轮。
 *       回调时 `round.intentStatus` 已置为 `Unsupported`。
 * @param coordinator EN: Sender. CN: 发送者。
 * @param round EN: Affected round. CN: 受影响的轮次。
 * @param reason EN: Short status for the meta line (e.g. "暂不支持"). CN: 简短状态（状态行，如「暂不支持」）。
 * @param notice EN: Notice for the bubble / banner (e.g. "已识别：播放《西安人的歌》· 当前设备暂不支持"). CN: 气泡 / 横幅提示（如「已识别：播放《西安人的歌》· 当前设备暂不支持」）。
 * @param endsSession EN: Whether the App should stop the current session (single round). CN: App 是否应结束当前会话（单轮）。
 */
- (void)intentCoordinator:(TSAIChatIntentCoordinator *)coordinator
 didCloseUnsupportedRound:(TSAIChatRoundModel *)round
                   reason:(NSString *)reason
                   notice:(NSString *)notice
              endsSession:(BOOL)endsSession;

@end

/**
 * @brief Dispatches intents recognized in an AI chat round to App-side handlers
 * @chinese 把 AI 对话轮次中识别到的意图分发给 App 侧处理
 *
 * @discussion
 * [EN]: Mirrors the aibuds Flutter `AiChatLocationCoordinator` / `AiChatIntentEndPolicy`.
 *       - `TSAIChatIntentTypeLocationQuery` is executed: obtain a location (prompting
 *         for permission when needed), push it to the SDK via `updateCurrentLocationFromApp:`,
 *         then replay the round as "我现在的位置在{地名}，{原问题}". One location intent is
 *         handled at a time; duplicates for the same round are ignored.
 *       - Command intents nothing here can execute (music / volume / photo / video / call /
 *         device control ...): if the round already has an answer it is kept and only the
 *         intent is marked unsupported; otherwise, after a short grace period for a late
 *         answer, the round is closed with "已识别：{指令} · 当前设备暂不支持".
 *       - Dialog exit / unknown intents are recorded for display only.
 * [CN]: 对应 aibuds Flutter 的 `AiChatLocationCoordinator` / `AiChatIntentEndPolicy`。
 *       - 执行 `TSAIChatIntentTypeLocationQuery`：取定位（必要时申请权限）→
 *         `updateCurrentLocationFromApp:` 交给 SDK → 以「我现在的位置在{地名}，{原问题}」重发本轮。
 *         同一时间只处理一个定位意图，同轮重复意图忽略。
 *       - 执行不了的指令意图（音乐 / 音量 / 拍照录像 / 通话 / 设备控制等）：本轮已有回答则保留回答、
 *         只把意图标为暂不支持；否则短暂等待迟到的回答，仍没有就以「已识别：{指令} · 当前设备暂不支持」立即收口本轮，
 *         不再空等 15s 空闲超时。
 *       - 退出对话 / 未知意图：只记录在轮次上用于展示。
 */
@interface TSAIChatIntentCoordinator : NSObject

/**
 * @brief UI delegate
 * @chinese UI 委托
 */
@property (nonatomic, weak, nullable) id<TSAIChatIntentCoordinatorDelegate> delegate;

/**
 * @brief Session coordinator used to push location / replay the round
 * @chinese 用于下发定位与重发轮次的会话协调器
 */
@property (nonatomic, strong) TSAIChatDeviceSessionCoordinator *sessionCoordinator;

/**
 * @brief Create a coordinator bound to a session coordinator
 * @chinese 创建绑定到会话协调器的意图协调器
 * @param sessionCoordinator EN: Session coordinator. CN: 会话协调器。
 */
- (instancetype)initWithSessionCoordinator:(TSAIChatDeviceSessionCoordinator *)sessionCoordinator;

/**
 * @brief Handle an intent that arrived for a round
 * @chinese 处理某一轮收到的意图
 * @param intent EN: Intent from `TSAIChatContentTypeIntent`. CN: 来自 `TSAIChatContentTypeIntent` 的意图。
 * @param round EN: Round it belongs to. CN: 所属轮次。
 */
- (void)handleIntent:(TSAIChatIntent *)intent round:(TSAIChatRoundModel *)round;

/**
 * @brief An answer arrived for the round: pending intent handling is complete
 * @chinese 本轮收到回答：待处理的意图视为已完成；待收口的「暂不支持」指令保留回答、不再收口
 * @param round EN: Round that received an answer. CN: 收到回答的轮次。
 */
- (void)roundDidReceiveAnswer:(TSAIChatRoundModel *)round;

/**
 * @brief The SDK gave up waiting for the App (IntentActionTimedOut)
 * @chinese SDK 放弃等待 App（IntentActionTimedOut）
 * @param round EN: Affected round. CN: 受影响的轮次。
 */
- (void)handleIntentActionTimedOutForRound:(TSAIChatRoundModel *)round;

/**
 * @brief Whether a location intent is being handled right now
 * @chinese 当前是否正在处理定位意图
 */
- (BOOL)isHandlingLocationIntent;

/**
 * @brief Silently warm up the location context (no permission prompt)
 * @chinese 静默预热位置上下文（不弹权限框）
 *
 * @discussion
 * [EN]: Call when entering the chat page. If permission is already granted,
 *       fetches a fix, pushes it to the SDK and caches the place name so the
 *       next session start can put it into `initialPrompt`.
 * [CN]: 进入对话页时调用。已有权限时取一次定位，交给 SDK 并缓存地名，
 *       供下一次会话启动写入 `initialPrompt`。
 */
- (void)prepareLocationContextSilently;

/**
 * @brief Append the location segment to an initial prompt when a place name is known
 * @chinese 已知地名时把位置段追加到初始 prompt
 * @param prompt EN: Existing prompt, may be nil. CN: 既有 prompt，可为 nil。
 * @return EN: Prompt with the location segment, or the input unchanged. CN: 追加位置段后的 prompt；无地名时原样返回。
 */
+ (nullable NSString *)initialPromptByAppendingLocationToPrompt:(nullable NSString *)prompt;

/**
 * @brief Reset state (session ended / page left)
 * @chinese 重置状态（会话结束 / 离开页面）
 */
- (void)reset;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
