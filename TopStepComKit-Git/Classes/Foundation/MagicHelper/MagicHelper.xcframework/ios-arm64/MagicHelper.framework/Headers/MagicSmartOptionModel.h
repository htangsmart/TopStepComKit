//
//  MagicSmartOptionModel.h
//  MagicHelper
//
//  Created by ymz on 2025/9/19.
//

#import <Foundation/Foundation.h>
#import "AILanguageCodeUtil.h"

NS_ASSUME_NONNULL_BEGIN

/// 智能体code
typedef NS_ENUM(NSInteger, MagicLLMCode) {
    /// 眼镜
    MagicLLMCodeGlass = 0,
    /// 玩具
    MagicLLMCodeToy,
};

@interface SmartOptionExt: NSObject

///当前经纬度
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

/// 经纬度对应的地址
@property (nonatomic, strong) NSString *address;
@end

@interface MagicSmartOptionModel : NSObject

/// 语言，默认中文（zn-CH）
@property (nonatomic, strong) NSString *language;

///输入音频格式，默认pcm
@property (nonatomic, strong) NSString *input_audio_format;

///输出音频格式，默认pcm
@property (nonatomic, strong) NSString *output_audio_format;

///ASR类型, 默认aliyun
@property (nonatomic, strong) NSString *asr_type;

///是否开启vad, 默认开启YES
@property (nonatomic, strong) NSNumber *enable_vad;

///最大静默时长单位ms, 默认600
@property (nonatomic, strong) NSNumber *max_sentence_silence;

///tts类型, 默认aliyun
@property (nonatomic, strong) NSString *tts_type;

///音色, 默认siyue, 可设置
@property (nonatomic, strong) NSString *voice;

///音量, 默认50, 范围0~100, 可设置
@property (nonatomic, strong) NSNumber *volume;

///音调, 默认0, 范围0~100, 可设置
@property (nonatomic, strong) NSNumber *pitch_rate;

///语速, 默认0, 范围0~100, 可设置
@property (nonatomic, strong) NSNumber *speech_rate;

///是否开启联网搜索, 默认开启YES
@property (nonatomic, strong) NSNumber *enable_search;

///智能体配置code, 默认3, 可设置
@property (nonatomic, strong) NSString *llm_chat_code;

///视觉智能体code, 默认4
@property (nonatomic, strong) NSString *vllm_chat_code;

///是否开启意图识别, 默认开启YES
@property (nonatomic, strong) NSNumber *enable_intent;

///意图版本, 默认v4
@property (nonatomic, strong) NSString *intent_version;

///意图配置code, 默认basic_intent_config
@property (nonatomic, strong) NSString *intentConfigCode;

/**
 * 会话模式（session.create config.session_mode）。
 * 未设置或 MagicCardSessionModeDefault：纯语音对话；MagicCardSessionModeCard：卡片智能体模式。
 */
@property (nonatomic, copy, nullable) NSString *session_mode;
/**
 * 是否启用卡片下发（session.create config.enable_card）。
 * session_mode=card 时建议 YES；设为 NO 可临时禁用卡片、仅保留播报。
 */
@property (nonatomic, strong, nullable) NSNumber *enable_card;
/**
 * 端上支持的 card_type 白名单（session.create config.card_capabilities）。
 * 未传时服务端按全量下发；端上收到不认识的 card_type 可忽略。建议使用 +defaultCardCapabilities。
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *card_capabilities;

/// 额外参数
@property (nonatomic, strong, nullable) SmartOptionExt *ext;

///情绪配置
@property (nonatomic, strong) NSString *emotionIntentConfigCode;

///上下文，默认true (MagicTextSession用到)
@property (nonatomic, strong) NSNumber *enable_conversation;


/// 构建model
/// - Parameters:
///   - language: 语言code
///   - voice: 语言对应的音色，不传会使用默认的
///   - intentConfigCode: 意图配置code, 默认basic_intent_config
///   - llmCode: 智能体code
+ (MagicSmartOptionModel *)generateModelWithLanguage:(AILanguageCode)language
                                               voice:(nullable NSString *)voice
                                    intentConfigCode:(nullable NSString *)intentConfigCode
                                             llmCode:(MagicLLMCode)llmCode;

/**
 * P0 默认 card_capabilities 白名单。
 * @return 与 MagicCardDefaultCapabilities() 相同，包含 7 种 P0 card_type
 */
+ (NSArray<NSString *> *)defaultCardCapabilities;

@end

NS_ASSUME_NONNULL_END
