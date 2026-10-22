//
//  TSAIASRMicrophoneConfig.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration of microphone speech recognition (record, then recognize the whole segment)
 * @chinese 麦克风语音识别配置（先录音，停止后整段识别）
 */
@interface TSAIASRMicrophoneConfig : NSObject <NSCopying>

/**
 * @brief Microphone: BuiltInMic (phone, default) or SCO (earbuds, captured by the SDK over HFP)
 * @chinese 麦克风：BuiltInMic（手机，默认）或 SCO（耳机，由 SDK 经 HFP 采集）
 *
 * @discussion
 * EN: SCO requires the earbuds microphone status of TSAIFeaturePCMRecognition to be usable
 *     (see -[TSAIAudioRoutingInterface earbudsMicrophoneStatusForFeature:]); it never falls back
 *     to the phone microphone.
 * CN: SCO 要求 TSAIFeaturePCMRecognition 的耳机麦克风状态可用
 *     （见 -[TSAIAudioRoutingInterface earbudsMicrophoneStatusForFeature:]）；不会回退到手机麦。
 */
@property (nonatomic, assign) TSAIAudioInputChannel audioInputChannel;

/**
 * @brief Recognition language; Unknown uses the App localization, Auto is invalid
 * @chinese 识别语言；Unknown 使用 App 本地化语言，Auto 为非法值
 */
@property (nonatomic, assign) TSAILanguage language;

/**
 * @brief Maximum recording duration in seconds, default and upper limit 60
 * @chinese 最长录音时长（秒），默认且上限 60
 *
 * @discussion
 * EN: Recording stops automatically and is recognized when reached.
 * CN: 到达后自动停止录音并开始识别。
 */
@property (nonatomic, assign) NSTimeInterval maximumDuration;

/**
 * @brief Create a configuration
 * @chinese 创建配置
 */
+ (instancetype)configWithAudioInputChannel:(TSAIAudioInputChannel)audioInputChannel
                                   language:(TSAILanguage)language;

@end

NS_ASSUME_NONNULL_END
