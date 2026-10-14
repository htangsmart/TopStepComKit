//
//  TSAIInterpretationRequest.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAIDefines.h"
#import "TSAIInterpretationDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Everything the App decides before a simultaneous-interpretation session starts
 * @chinese App 在同声传译会话开始前决定的全部参数
 *
 * @discussion
 * [EN]: Session-level parameters. None of them can change mid-session; to
 *       switch the pickup or a language, stop the session and start a new one.
 *       Routing (input channel, device coordination, screen text, TTS output)
 *       is derived from `pickup` by the SDK — the App never assembles an
 *       audio route or a device request itself.
 * [CN]: 会话级参数，中途不可修改；需要更换拾音设备或语言时，结束会话后重新开始。
 *       路由（输入通道、设备协同、屏端文本、TTS 出口）由 SDK 根据 `pickup`
 *       推导，App 不再自行拼装音频路由或设备请求。
 */
@interface TSAIInterpretationRequest : NSObject <NSCopying>

/**
 * @brief Source language; `TSAILanguageAuto` requests backend detection
 * @chinese 源语言；`TSAILanguageAuto` 表示由后端自动检测
 */
@property (nonatomic, assign) TSAILanguage sourceLanguage;

/**
 * @brief Target language; must be concrete
 * @chinese 目标语言；必须为具体语言
 */
@property (nonatomic, assign) TSAILanguage targetLanguage;

/**
 * @brief Microphone source
 * @chinese 拾音设备
 */
@property (nonatomic, assign) TSAIInterpretationPickup pickup;

/**
 * @brief Whether translated text is also synthesized to audio; default YES
 * @chinese 是否合成译文音频；默认 YES
 */
@property (nonatomic, assign) BOOL enableVoiceOutput;

/**
 * @brief Preferred playback channel for translated audio; default Automatic
 * @chinese 译文音频的期望播放出口；默认 Automatic
 *
 * @discussion
 * [EN]: Automatic follows the pickup: Phone → built-in speaker, Earbuds → SCO,
 *       ChargingCase → Opus downlink to the case when the device can play it,
 *       otherwise the phone speaker. Any explicit channel is validated against
 *       the current route capabilities and falls back the same way.
 * [CN]: Automatic 跟随拾音设备：手机 → 手机扬声器，耳机 → SCO，充电仓 → 设备可播放时
 *       Opus 下行到仓，否则手机扬声器。显式指定的出口会按当前路由能力校验，
 *       不可用时同样回退。
 */
@property (nonatomic, assign) TSAIAudioOutputChannel voiceOutputChannel;

/**
 * @brief TTS speaker id; nil uses the backend default
 * @chinese TTS 发音人；nil 走后端默认
 */
@property (nonatomic, copy, nullable) NSString *speakerId;

/**
 * @brief Convenience constructor with defaults for the remaining fields
 * @chinese 便捷构造，其余字段取默认值
 *
 * @param sourceLanguage
 * EN: Source language or `TSAILanguageAuto`
 * CN: 源语言或 `TSAILanguageAuto`
 *
 * @param targetLanguage
 * EN: Concrete target language
 * CN: 具体的目标语言
 *
 * @param pickup
 * EN: Microphone source
 * CN: 拾音设备
 *
 * @return
 * EN: A request with `enableVoiceOutput = YES` and `voiceOutputChannel = Automatic`
 * CN: `enableVoiceOutput = YES`、`voiceOutputChannel = Automatic` 的请求
 */
+ (instancetype)requestWithSourceLanguage:(TSAILanguage)sourceLanguage
                           targetLanguage:(TSAILanguage)targetLanguage
                                   pickup:(TSAIInterpretationPickup)pickup;

@end

NS_ASSUME_NONNULL_END
