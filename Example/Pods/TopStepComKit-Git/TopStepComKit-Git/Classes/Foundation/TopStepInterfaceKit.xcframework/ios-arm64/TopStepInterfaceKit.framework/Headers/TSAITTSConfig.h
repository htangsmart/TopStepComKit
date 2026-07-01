//
//  TSAITTSConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TTS request configuration
 * @chinese 文本转语音请求配置
 *
 * @discussion
 * [EN]: Configuration for a single TTS request. Currently exposes the speaker
 *       identifier only; more options (speed/volume/pitch/format/sampleRate)
 *       can be added later without breaking the API.
 * [CN]: 单次 TTS 请求的配置。当前仅暴露发音人标识；
 *       后续可在不破坏接口的前提下扩展语速、音量、音调、格式、采样率等选项。
 */
@interface TSAITTSConfig : NSObject

/**
 * @brief Speaker (voice) identifier
 * @chinese 发音人标识
 *
 * @discussion
 * [EN]: String ID identifying the voice. The value space is defined by the
 *       backend AI provider (e.g. "xiaogang", "aiqi"). Using a string instead
 *       of an enum avoids SDK upgrades whenever the server adds a new voice.
 * [CN]: 标识发音人的字符串 ID，取值由后端 AI 提供方定义（如 "xiaogang"、"aiqi"）。
 *       使用字符串而非枚举，是为了让服务端新增发音人时无需升级 SDK。
 */
@property (nonatomic, copy) NSString *speakerId;

/**
 * @brief Create a config with the given speaker ID
 * @chinese 通过发音人 ID 创建配置
 *
 * @param speakerId
 * EN: Speaker identifier
 * CN: 发音人标识
 *
 * @return
 * EN: A new config instance
 * CN: 新创建的配置对象
 */
+ (instancetype)configWithSpeakerId:(NSString *)speakerId;

@end

NS_ASSUME_NONNULL_END
