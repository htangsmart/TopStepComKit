//
//  TSAIConversationTranslationDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"

@class TSAIConversationTranslationSnapshot;
@class TSAIConversationTranslationEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Participant of one conversation-translation session
 * @chinese 一次对话翻译会话中的参与者
 *
 * @discussion
 * [EN]: Self is the local user; Peer is the other person. Each participant has a
 *       capture endpoint (which microphone records their speech) and a playback
 *       endpoint (where they hear the translation of the other's speech), see
 *       `TSAIConversationEndpoint`. The product mode supplies the default pair;
 *       the App may override either endpoint in `TSAIConversationTranslationConfig`.
 * [CN]: Self 为本机用户，Peer 为对方。每个参与者各有一个收音端（用哪个麦克风采集其发言）
 *       和一个播报端（在哪里听对方发言的译文），见 `TSAIConversationEndpoint`。产品模式
 *       提供默认组合，App 可在 `TSAIConversationTranslationConfig` 中分别覆盖。
 */
typedef NS_ENUM(NSInteger, TSAIConversationParticipant) {
    /// @brief No participant @chinese 无参与者
    TSAIConversationParticipantNone = 0,
    /// @brief Local user side @chinese 本机用户侧
    TSAIConversationParticipantSelf = 1,
    /// @brief Peer side @chinese 对方侧
    TSAIConversationParticipantPeer = 2,
};

/**
 * @brief Physical endpoint used to capture or play one participant's audio
 * @chinese 参与者收音或播报所用的物理端
 *
 * @discussion
 * [EN]: Capture maps Phone → built-in microphone, Earbuds → Bluetooth SCO
 *       microphone, Case → device Opus upload. Playback maps Phone → built-in
 *       speaker, Earbuds → system default route (A2DP), Case → device PCM
 *       playback. `Automatic` takes the preset of the product mode.
 * [CN]: 收音时 Phone → 手机内置麦，Earbuds → 蓝牙 SCO 麦，Case → 充电仓 Opus 上传；
 *       播报时 Phone → 手机扬声器，Earbuds → 系统默认路由（A2DP），Case → 充电仓 PCM 播放。
 *       `Automatic` 取产品模式的预设。
 */
typedef NS_ENUM(NSInteger, TSAIConversationEndpoint) {
    /// @brief Follow the product-mode preset @chinese 跟随产品模式预设
    TSAIConversationEndpointAutomatic = 0,
    /// @brief Phone microphone or speaker @chinese 手机麦克风或扬声器
    TSAIConversationEndpointPhone = 1,
    /// @brief Earbuds microphone (SCO) or earbuds playback (A2DP) @chinese 耳机麦克风（SCO）或耳机播放（A2DP）
    TSAIConversationEndpointEarbuds = 2,
    /// @brief Charging case microphone (Opus) or charging case playback (PCM) @chinese 充电仓麦克风（Opus）或充电仓播放（PCM）
    TSAIConversationEndpointCase = 3,
};

/**
 * @brief Lifecycle state of one conversation-translation session
 * @chinese 一次对话翻译会话的生命周期状态
 */
typedef NS_ENUM(NSInteger, TSAIConversationTranslationState) {
    /// @brief No session @chinese 无会话
    TSAIConversationTranslationStateIdle = 0,
    /// @brief Entering the device product mode @chinese 正在进入设备产品模式
    TSAIConversationTranslationStateEntering = 1,
    /// @brief Ready for either participant to speak @chinese 就绪，任一参与者可发言
    TSAIConversationTranslationStateReady = 2,
    /// @brief One participant is speaking @chinese 一名参与者正在发言
    TSAIConversationTranslationStateListening = 3,
    /// @brief Waiting for translation and playback of the current turn @chinese 等待本轮翻译与播报完成
    TSAIConversationTranslationStateTranslating = 4,
    /// @brief Leaving the device product mode @chinese 正在退出设备产品模式
    TSAIConversationTranslationStateExiting = 5,
};

/**
 * @brief Reason why a conversation-translation session ended
 * @chinese 对话翻译会话结束的原因
 */
typedef NS_ENUM(NSInteger, TSAIConversationTranslationEndReason) {
    /// @brief App asked to stop @chinese App 主动退出
    TSAIConversationTranslationEndReasonUserExitApp = 1,
    /// @brief The device screen left conversation translation @chinese 设备屏端退出对话翻译
    TSAIConversationTranslationEndReasonUserExitDevice = 2,
    /// @brief The device disconnected @chinese 设备断开连接
    TSAIConversationTranslationEndReasonDeviceDisconnected = 3,
    /// @brief The device reported low battery @chinese 设备上报低电量
    TSAIConversationTranslationEndReasonDeviceLowBattery = 4,
    /// @brief An incoming call interrupted the session @chinese 来电中断
    TSAIConversationTranslationEndReasonIncomingCall = 5,
    /// @brief The network became unavailable @chinese 网络异常
    TSAIConversationTranslationEndReasonNetworkError = 6,
    /// @brief The system audio session was interrupted @chinese 系统音频会话被抢占
    TSAIConversationTranslationEndReasonAudioInterrupted = 7,
    /// @brief The AI Context became inactive @chinese AI Context 失活
    TSAIConversationTranslationEndReasonContextInactive = 8,
    /// @brief Another failure; see the error @chinese 其他失败，见错误对象
    TSAIConversationTranslationEndReasonFailure = 9,
};

/**
 * @brief Event type delivered during a conversation-translation session
 * @chinese 对话翻译会话过程中的事件类型
 */
typedef NS_ENUM(NSInteger, TSAIConversationTranslationEventType) {
    /// @brief A turn started (App or device initiated) @chinese 一轮发言开始（App 或设备发起）
    TSAIConversationTranslationEventTypeTurnStarted = 1,
    /// @brief A turn ended normally @chinese 一轮发言正常结束
    TSAIConversationTranslationEventTypeTurnEnded = 2,
    /// @brief A turn failed; see the error @chinese 一轮发言失败，见错误对象
    TSAIConversationTranslationEventTypeTurnFailed = 3,
    /// @brief A turn was rejected because the other participant is speaking @chinese 因对方正在发言而拒绝新一轮
    TSAIConversationTranslationEventTypeTurnRejectedBusy = 4,
    /// @brief The device requested to leave but the session is still finishing @chinese 设备请求退出，会话正在收尾
    TSAIConversationTranslationEventTypeDeviceExitRequested = 5,
};

/**
 * @brief Snapshot callback
 * @chinese 快照回调
 */
typedef void (^TSAIConversationTranslationSnapshotBlock)(TSAIConversationTranslationSnapshot *snapshot);

/**
 * @brief Event callback
 * @chinese 事件回调
 */
typedef void (^TSAIConversationTranslationEventBlock)(TSAIConversationTranslationEvent *event);

/**
 * @brief Session completion callback
 * @chinese 会话结束回调
 */
typedef void (^TSAIConversationTranslationCompletionBlock)(TSAIConversationTranslationEndReason reason,
                                                           NSError * _Nullable error);

NS_ASSUME_NONNULL_END
