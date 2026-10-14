//
//  TSAIConversationTranslationConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIConversationTranslationDefines.h"
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration of one conversation-translation session
 * @chinese 一次对话翻译会话的配置
 *
 * @discussion
 * [EN]: `mode` is the product mode sent to the device (it drives the charging
 *       case screen and key behaviour). Capture and playback endpoints are
 *       independent per participant: each defaults to the preset of `mode`
 *       (`Automatic`) and may be overridden individually. Per turn the SDK
 *       records from the speaker's capture endpoint and plays the translation on
 *       the listener's playback endpoint.
 * [CN]: `mode` 是下发给设备的产品模式（决定充电仓屏幕与按键行为）。每个参与者的收音端与
 *       播报端相互独立：默认跟随 `mode` 的预设（`Automatic`），也可以分别覆盖。每一轮
 *       SDK 从发言方的收音端采集，在听众的播报端播放译文。
 *
 * @note
 * [EN]: Presets — FaceToFace: Self Phone/Phone, Peer Case/Case; Private: Self
 *       Earbuds/Earbuds, Peer Case/Case; Portable: Self Earbuds/Earbuds, Peer
 *       Phone/Phone (capture/playback).
 * [CN]: 预设 —— 面对面：Self 手机/手机，Peer 仓/仓；私密听译：Self 耳机/耳机，Peer 仓/仓；
 *       便携交流：Self 耳机/耳机，Peer 手机/手机（收音/播报）。
 */
@interface TSAIConversationTranslationConfig : NSObject <NSCopying>

/**
 * @brief Device product mode: face-to-face, private or portable
 * @chinese 设备产品模式：面对面、私密听译或便携交流
 *
 * @note
 * [EN]: Must not be `TSAIConversationTranslationModeInvalid`. Choose the mode
 *       whose charging-case behaviour matches the endpoints you override.
 * [CN]: 不能为 `TSAIConversationTranslationModeInvalid`。覆盖端点时应选择充电仓行为
 *       与之匹配的模式。
 */
@property (nonatomic, assign) TSAIConversationTranslationMode mode;

/**
 * @brief Language spoken by the local user (Self)
 * @chinese 本机用户（Self）的语言
 *
 * @note
 * [EN]: Must be a concrete language; Auto is not accepted.
 * [CN]: 必须是具体语言，不接受 Auto。
 */
@property (nonatomic, assign) TSAILanguage selfLanguage;

/**
 * @brief Language spoken by the peer
 * @chinese 对方（Peer）的语言
 *
 * @note
 * [EN]: Must be a concrete language different from `selfLanguage`.
 * [CN]: 必须是与 `selfLanguage` 不同的具体语言。
 */
@property (nonatomic, assign) TSAILanguage peerLanguage;

/**
 * @brief Microphone that records the local user's speech
 * @chinese 采集本机用户发言的麦克风
 *
 * @note
 * [EN]: Default `Automatic` (preset of `mode`).
 * [CN]: 默认 `Automatic`（跟随 `mode` 预设）。
 */
@property (nonatomic, assign) TSAIConversationEndpoint selfCaptureEndpoint;

/**
 * @brief Endpoint where the local user hears the peer's translated speech
 * @chinese 本机用户收听对方译文的播报端
 *
 * @note
 * [EN]: Default `Automatic` (preset of `mode`).
 * [CN]: 默认 `Automatic`（跟随 `mode` 预设）。
 */
@property (nonatomic, assign) TSAIConversationEndpoint selfPlaybackEndpoint;

/**
 * @brief Microphone that records the peer's speech
 * @chinese 采集对方发言的麦克风
 *
 * @note
 * [EN]: Default `Automatic` (preset of `mode`).
 * [CN]: 默认 `Automatic`（跟随 `mode` 预设）。
 */
@property (nonatomic, assign) TSAIConversationEndpoint peerCaptureEndpoint;

/**
 * @brief Endpoint where the peer hears the local user's translated speech
 * @chinese 对方收听本机用户译文的播报端
 *
 * @note
 * [EN]: Default `Automatic` (preset of `mode`).
 * [CN]: 默认 `Automatic`（跟随 `mode` 预设）。
 */
@property (nonatomic, assign) TSAIConversationEndpoint peerPlaybackEndpoint;

/**
 * @brief Whether translations played on the phone start automatically
 * @chinese 手机作为播报端时是否自动播报译文
 *
 * @discussion
 * [EN]: Defaults to NO: the translation audio is still synthesized and archived
 *       in the turn so the App can play it on demand. Earbuds and case playback
 *       always start automatically.
 * [CN]: 默认 NO：译文音频仍会合成并归档到本轮，App 可按需播放。耳机与充电仓播报始终自动开始。
 */
@property (nonatomic, assign) BOOL autoSpeakOnPhone;

/**
 * @brief Silence timeout that ends an App-initiated turn automatically
 * @chinese 自动结束 App 发起轮次的静音超时
 *
 * @note
 * [EN]: Seconds since the last recognized text; 0 disables. Default 6. Only
 *       applies to turns captured on the phone or earbuds.
 * [CN]: 自最近一次识别文本起的秒数；0 表示关闭。默认 6。仅作用于手机或耳机收音的轮次。
 */
@property (nonatomic, assign) NSTimeInterval silenceTimeout;

/**
 * @brief Create a configuration with default values
 * @chinese 创建带默认值的配置
 *
 * @return
 * EN: Config with mode Invalid, languages Unknown, all endpoints Automatic,
 *     autoSpeakOnPhone NO and silenceTimeout 6
 * CN: mode 为 Invalid、语言为 Unknown、全部端点为 Automatic、autoSpeakOnPhone 为 NO、
 *     silenceTimeout 为 6 的配置
 */
+ (instancetype)defaultConfig;

/**
 * @brief Create a configuration preset for a product mode
 * @chinese 创建某产品模式的预设配置
 *
 * @param mode
 * EN: Product mode
 * CN: 产品模式
 *
 * @return
 * EN: Config with `mode` set and all endpoints Automatic
 * CN: 已设置 `mode`、全部端点为 Automatic 的配置
 */
+ (instancetype)configWithMode:(TSAIConversationTranslationMode)mode;

/**
 * @brief Resolved capture endpoint of a participant
 * @chinese 参与者解析后的收音端
 *
 * @param participant
 * EN: Self or Peer
 * CN: Self 或 Peer
 *
 * @return
 * EN: The overridden endpoint, or the preset of `mode` when Automatic; Phone
 *     when the mode is invalid
 * CN: 覆盖的端点；为 Automatic 时返回 `mode` 的预设；模式非法时返回 Phone
 */
- (TSAIConversationEndpoint)captureEndpointForParticipant:(TSAIConversationParticipant)participant;

/**
 * @brief Resolved playback endpoint of a participant
 * @chinese 参与者解析后的播报端
 *
 * @param participant
 * EN: Self or Peer (the listener)
 * CN: Self 或 Peer（听众）
 *
 * @return
 * EN: The overridden endpoint, or the preset of `mode` when Automatic; Phone
 *     when the mode is invalid
 * CN: 覆盖的端点；为 Automatic 时返回 `mode` 的预设；模式非法时返回 Phone
 */
- (TSAIConversationEndpoint)playbackEndpointForParticipant:(TSAIConversationParticipant)participant;

/**
 * @brief Whether the charging case captures or plays for any participant
 * @chinese 充电仓是否作为任一参与者的收音端或播报端
 *
 * @return
 * EN: YES when any resolved endpoint is Case
 * CN: 任一解析后的端点为 Case 时为 YES
 */
- (BOOL)caseParticipates;

@end

NS_ASSUME_NONNULL_END
