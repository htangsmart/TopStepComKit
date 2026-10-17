//
//  TSAIChatAudioPreference.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TopStepAIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Pick-up (input) option shown in the audio sheet
 * @chinese 音频面板里的拾音选项
 *
 * @discussion
 * [EN]: Raw values are persisted; do not reorder. Display order comes from
 *       `orderedInputOptions`.
 * [CN]: 原始值已持久化，不要调整顺序；显示顺序由 `orderedInputOptions` 决定。
 */
typedef NS_ENUM(NSInteger, TSAIChatAudioInputOption) {
    /// 自动：蓝牙耳机 > 耳机仓 > 手机（默认）
    TSAIChatAudioInputOptionAuto = 0,
    /// 耳机仓：Opus 经 BLE 上传（FitCloud 数据链路）
    TSAIChatAudioInputOptionDevice,
    /// 耳机：系统蓝牙耳机通话麦（HFP / SCO）
    TSAIChatAudioInputOptionSCO,
    /// 手机麦克风（BuiltInMic）
    TSAIChatAudioInputOptionPhone,
};

/**
 * @brief Playback (output) option shown in the audio sheet
 * @chinese 音频面板里的语音播放选项
 *
 * @discussion
 * [EN]: Raw values are persisted; do not reorder. Display order comes from
 *       `orderedOutputOptions`.
 * [CN]: 原始值已持久化，不要调整顺序；显示顺序由 `orderedOutputOptions` 决定。
 */
typedef NS_ENUM(NSInteger, TSAIChatAudioOutputOption) {
    /// 耳机仓：PCM 经 BLE 推给设备播放（Opus，默认）
    TSAIChatAudioOutputOptionDevice = 0,
    /// 耳机：系统蓝牙音频（A2DP，需在 iOS 蓝牙中配对）
    TSAIChatAudioOutputOptionA2DP,
    /// 手机播放器（BuiltInSpeaker）
    TSAIChatAudioOutputOptionPhone,
    /// 跟随系统（SystemDefault）
    TSAIChatAudioOutputOptionSystem,
    /// 不播放语音（None）
    TSAIChatAudioOutputOptionNone,
};

/**
 * @brief Pick-up / playback preference of one AI chat line (spec §2.8)
 * @chinese AI 对话页某一条对话线路的拾音 / 语音播放偏好（规范 §2.8）
 *
 * @discussion
 * [EN]: AI chat (对话, SingleRound) and AI flow (畅聊, Continuous) are two
 *       independent lines; each keeps its own persisted selection and they never
 *       affect each other. The chat line never involves the charging case: no
 *       case pick-up and no case playback, so neither text nor press-to-talk
 *       rounds open the device AI chat. The flow line offers every option and
 *       always opens the device AI chat (see
 *       `TSAIChatConfig.opensDeviceChatSession`). Availability is resolved
 *       against two independent links: the BLE data link to the case
 *       (`caseConnected`, Opus in / out) and the system Bluetooth audio pairing
 *       of the earbuds (`isSystemBluetoothAudioConnected`, HFP / SCO in, A2DP
 *       out). Unavailable options fall back while the preference itself is kept.
 * [CN]: AI 对话（SingleRound）与 AI 畅聊（Continuous）是两条独立线路，各自持久化
 *       自己的选择，互不影响。AI 对话线路不涉及耳机仓：没有「耳机仓」拾音与播放，
 *       文字提问与按住说话都不会打开设备端 AI 对话。AI 畅聊线路提供全部选项，并始终
 *       打开设备端 AI 对话（见 `TSAIChatConfig.opensDeviceChatSession`）。
 *       可用性由两条独立链路决定：耳机仓 BLE 数据链路（`caseConnected`，Opus 上传 / 下发）
 *       与耳机在 iOS 系统蓝牙中的音频配对（`isSystemBluetoothAudioConnected`，
 *       HFP/SCO 拾音、A2DP 播放）。不可用时生效项回落，偏好本身保留。
 */
@interface TSAIChatAudioPreference : NSObject

/**
 * @brief Preference of the line that runs a conversation mode
 * @chinese 某会话模式所在线路的偏好
 *
 * @param mode
 * EN: SingleRound → AI chat line, Continuous → AI flow line
 * CN: SingleRound → AI 对话线路，Continuous → AI 畅聊线路
 *
 * @return
 * EN: Shared instance of that line
 * CN: 该线路的共享实例
 */
+ (instancetype)preferenceForConversationMode:(TSAIChatConversationMode)mode;

/** @brief Conversation mode of this line @chinese 本线路的会话模式 */
@property (nonatomic, assign, readonly) TSAIChatConversationMode conversationMode;

/** @brief Input preference @chinese 拾音偏好 */
@property (nonatomic, assign) TSAIChatAudioInputOption input;

/** @brief Output preference @chinese 语音播放偏好 */
@property (nonatomic, assign) TSAIChatAudioOutputOption output;

/** @brief Whether this line offers the charging case options (flow only) @chinese 本线路是否提供「耳机仓」选项（仅畅聊） */
@property (nonatomic, assign, readonly) BOOL offersCaseOptions;

/** @brief Input options of this line in display order @chinese 本线路的拾音选项（显示顺序） */
- (NSArray<NSNumber *> *)orderedInputOptions;

/** @brief Output options of this line in display order @chinese 本线路的播放选项（显示顺序） */
- (NSArray<NSNumber *> *)orderedOutputOptions;

/**
 * @brief Whether a Bluetooth headset is attached to the system audio session (playback options only)
 * @chinese 系统音频里是否有蓝牙耳机（HFP / A2DP / LE Audio 端口），只用于「耳机」播放项
 *
 * @discussion
 * [EN]: Reads AVAudioSession's current route and available inputs. Earbuds pickup does not use
 *       this: it follows the SDK earbuds microphone status (`earbudsMicrophoneStatus`).
 * [CN]: 读取 AVAudioSession 当前路由与可用输入。「耳机」拾音不用它，而是看 SDK 的耳机麦克风状态
 *       （`earbudsMicrophoneStatus`）。
 */
+ (BOOL)isSystemBluetoothAudioConnected;

/**
 * @brief Earbuds microphone status of AI chat from the SDK
 * @chinese SDK 给出的 AI 对话耳机麦克风状态
 *
 * @return EN: nil when no Context is active. CN: 没有活动 Context 时为 nil。
 */
+ (nullable TSAIEarbudsMicrophoneStatus *)earbudsMicrophoneStatus;

/**
 * @brief Whether the earbuds pickup option can be chosen (SDK status Likely / Verified or a permission state)
 * @chinese 「耳机」拾音项是否可选（SDK 状态为 Likely / Verified 或权限相关状态）
 */
+ (BOOL)isEarbudsMicrophoneSelectable;

/** @brief Resolved input for the link state @chinese 按链路状态解析后的拾音项 */
- (TSAIChatAudioInputOption)effectiveInputWithHeadset:(BOOL)caseConnected;

/** @brief Resolved output for the link state @chinese 按链路状态解析后的播放项 */
- (TSAIChatAudioOutputOption)effectiveOutputWithHeadset:(BOOL)caseConnected;

/** @brief SDK input channel for the link state @chinese 按链路状态解析的 SDK 输入通道 */
- (TSAIAudioInputChannel)inputChannelWithHeadset:(BOOL)caseConnected;

/** @brief SDK output channel for the link state @chinese 按链路状态解析的 SDK 输出通道 */
- (TSAIAudioOutputChannel)outputChannelWithHeadset:(BOOL)caseConnected;

/** @brief Whether an input option needs the case BLE link @chinese 拾音项是否依赖耳机仓 BLE 链路 */
+ (BOOL)inputOptionRequiresCase:(TSAIChatAudioInputOption)option;

/** @brief Whether an input option needs a system Bluetooth headset @chinese 拾音项是否依赖系统蓝牙耳机 */
+ (BOOL)inputOptionRequiresBluetoothHeadset:(TSAIChatAudioInputOption)option;

/** @brief Whether an output option needs the case BLE link @chinese 播放项是否依赖耳机仓 BLE 链路 */
+ (BOOL)outputOptionRequiresCase:(TSAIChatAudioOutputOption)option;

/** @brief Whether an output option needs a system Bluetooth headset @chinese 播放项是否依赖系统蓝牙耳机 */
+ (BOOL)outputOptionRequiresBluetoothHeadset:(TSAIChatAudioOutputOption)option;

/** @brief Input option that displays an SDK input channel (effective route) @chinese SDK 输入通道（生效路由）对应的显示项 */
+ (TSAIChatAudioInputOption)inputOptionForChannel:(TSAIAudioInputChannel)channel;

/** @brief Output option that displays an SDK output channel (effective route) @chinese SDK 输出通道（生效路由）对应的显示项 */
+ (TSAIChatAudioOutputOption)outputOptionForChannel:(TSAIAudioOutputChannel)channel;

/** @brief Title / short title / subtitle / SDK code / SF Symbol of an input option @chinese 拾音项的标题 / 短名 / 副标 / SDK 名 / 图标 */
+ (NSString *)titleForInputOption:(TSAIChatAudioInputOption)option;
+ (NSString *)shortTitleForInputOption:(TSAIChatAudioInputOption)option;
+ (NSString *)subtitleForInputOption:(TSAIChatAudioInputOption)option;
+ (NSString *)codeForInputOption:(TSAIChatAudioInputOption)option;
+ (NSString *)symbolForInputOption:(TSAIChatAudioInputOption)option;

/** @brief Title / short title / subtitle / SDK code / SF Symbol of an output option @chinese 播放项的标题 / 短名 / 副标 / SDK 名 / 图标 */
+ (NSString *)titleForOutputOption:(TSAIChatAudioOutputOption)option;
+ (NSString *)shortTitleForOutputOption:(TSAIChatAudioOutputOption)option;
+ (NSString *)subtitleForOutputOption:(TSAIChatAudioOutputOption)option;
+ (NSString *)codeForOutputOption:(TSAIChatAudioOutputOption)option;
+ (NSString *)symbolForOutputOption:(TSAIChatAudioOutputOption)option;

@end

NS_ASSUME_NONNULL_END
