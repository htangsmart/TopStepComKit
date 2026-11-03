//
//  TSAIChatAudioProcessingConfiguration.h
//  TopStepAIKit
//
//  Created by Codex on 2026/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Echo-control policy for one chat session
 * @chinese 单次对话会话的回声控制策略
 */
typedef NS_ENUM(NSInteger, TSAIChatEchoControlPolicy) {
    /**
     * @brief Select available echo processing while preserving requested interruption
     * @chinese 自动选择可用回声处理，同时保留请求的语音打断能力
     */
    TSAIChatEchoControlPolicyAutomatic = 0,
    /**
     * @brief Require a usable echo-cancellation path when audio playback needs it
     * @chinese 音频播放需要回声控制时，必须具备可用的回声消除链路
     */
    TSAIChatEchoControlPolicyRequireAEC = 1,
};

/**
 * @brief Sensitivity of speech-start detection
 * @chinese 起声检测灵敏度
 */
typedef NS_ENUM(NSInteger, TSAIChatSpeechDetectionSensitivity) {
    /**
     * @brief Require stronger evidence before accepting speech
     * @chinese 需要更强的语音证据才采纳输入
     */
    TSAIChatSpeechDetectionSensitivityLow = 0,
    /**
     * @brief Balance weak speech and background-sound rejection
     * @chinese 平衡轻声保留与背景声音抑制
     */
    TSAIChatSpeechDetectionSensitivityNormal = 1,
    /**
     * @brief Prefer retaining weak speech
     * @chinese 优先保留轻声输入
     */
    TSAIChatSpeechDetectionSensitivityHigh = 2,
};

/**
 * @brief Session-scoped audio processing preferences for AI chat
 * @chinese AI 对话会话级音频处理偏好
 *
 * @discussion
 * [EN]: Copied when assigned to a chat configuration and frozen at session start.
 *       Applied to device Opus input with built-in speaker or system-default output;
 *       recording, translation and standalone ASR remain independent.
 * [CN]: 赋值给对话配置时复制，会话启动时冻结；作用于设备 Opus 拾音与手机扬声器或系统默认输出；
 *       录音、翻译和独立语音识别保持独立。
 */
@interface TSAIChatAudioProcessingConfiguration : NSObject <NSCopying>

/**
 * @brief Requested echo-control policy
 * @chinese 请求的回声控制策略
 *
 * @discussion
 * [EN]: Automatic keeps near-end speech enabled while its echo filter adapts.
 *       An unavailable required processing backend reports failure; it does not
 *       silently turn a requested voice-interruption session into half duplex.
 *       RequireAEC explicitly requires an echo-cancellation path.
 * [CN]: Automatic 在回声滤波适应期间继续接收近端人声；必要处理后端不可用时报告失败，
 *       不会把请求语音打断的会话静默变为半双工。RequireAEC 显式要求回声消除链路。
 *
 * @note
 * [EN]: Defaults to Automatic; only declared enum values are valid.
 * [CN]: 默认 Automatic；仅允许枚举中声明的取值。
 */
@property (nonatomic, assign) TSAIChatEchoControlPolicy echoControlPolicy;

/**
 * @brief Requested sensitivity of speech-start detection
 * @chinese 请求的起声检测灵敏度
 *
 * @discussion
 * [EN]: Maps to an internal route profile; it is not a microphone hardware gain.
 *       Higher sensitivity may admit more background speech.
 * [CN]: 映射到内部路由参数，不是麦克风硬件增益；更高灵敏度可能接纳更多背景人声。
 *
 * @note
 * [EN]: Defaults to Normal; only Low, Normal and High are valid.
 * [CN]: 默认 Normal；仅允许 Low、Normal、High。
 */
@property (nonatomic, assign) TSAIChatSpeechDetectionSensitivity speechDetectionSensitivity;

/**
 * @brief Create audio processing preferences with default values
 * @chinese 创建采用默认值的音频处理偏好
 *
 * @return
 * EN: A new mutable configuration using Automatic and Normal.
 * CN: 新的可变配置对象，采用 Automatic 和 Normal。
 */
+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
