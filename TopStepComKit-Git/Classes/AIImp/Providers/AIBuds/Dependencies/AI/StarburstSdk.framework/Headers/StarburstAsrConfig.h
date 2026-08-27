//
//  StarburstAsrConfig.h
//  StarburstSdk
//
//  Created by incar on 2024/9/14.
//

#import <Foundation/Foundation.h>

//语言
//简体中文 zh-CN
//四川话 sc
//粤语 cant
//上海话 zh_shanghai
//英文  en-US
//日语 ja-JP
//韩语 ko-KR
//法语 fr-FR
//西班牙语 es-MX
//葡萄牙语 pt-BR
//印尼语 id-ID
//俄语 ru-RU
//马来语 ms-MY

/// voice chat配置
@interface StarburstVoiceChatConfig : NSObject
@property (nonatomic, strong) NSString *role;/// 对话⻆⾊设定；默认为⽆特⾊的智能助⼿
//@property (nonatomic, assign) int channel;/// 默认为1，只⽀持1：单声道、2：双声道
@property (nonatomic, strong) NSString *language;/// 语⾔编码，默认为普通话(zh-CN)
@property (nonatomic, assign) BOOL tts;/// 是否进⾏Tts，默认false
@property (nonatomic, strong) NSString *ttsAudioFormat;/// 默认pcm。⽀持pcm / ogg_opus / mp3
@property (nonatomic, strong) NSString *ttsSpeakerType;/// tts声⾊类型，仅当传"clone"时，ttsSpeaker为单⾊克隆⽣成的speakerId
@property (nonatomic, strong) NSString *ttsSpeakerId;/// tts声⾊设置，默认使⽤“⾃然⼥声”
/// 眼镜对话：YES 使用 multi_start（多模态），NO 使用 start（普通对话）。默认 YES
@property (nonatomic, assign) BOOL useMultiModalDialog;

/// 【能量 VAD】静音检测时长（单位：毫秒）。
/// 仅在 SDK 内部使用能量 VAD（ChatRecorder 能量检测）时生效。
/// 默认：900
@property (nonatomic, assign) NSInteger energyVadSilenceTimeoutMs;

/// 【能量 VAD】灵敏度，范围建议 [0.0, 1.0]，越大越灵敏。
/// 仅在 SDK 内部使用能量 VAD（ChatRecorder 能量检测）时生效。
/// 默认：0.5
@property (nonatomic, assign) float energyVadSensitivity;

/// 【能量 VAD】调试日志开关。打开后会打印每帧判定的关键时间点与阈值信息（日志较多）。
/// 默认：NO
@property (nonatomic, assign) BOOL energyVadDebugLogEnabled;

/// 【能量 VAD】强制使用能量 VAD（不使用外部 VAD / rsvad）。
/// 打开后，即便外部 VAD 已初始化并 ready，录音也只会走能量 VAD 的 start/stop 判定，
/// 从而确保静音超时（energyVadSilenceTimeoutMs）严格生效。
/// 默认：NO
@property (nonatomic, assign) BOOL forceEnergyVad;
@end

/// 手机录音asr配置
@interface StarburstAsrConfig : NSObject
/// 是否翻译，默认 false。如果为 true 翻译源语言和目标语言不能是同一种语言
@property (nonatomic, assign) BOOL isTranslate;
/// 源语言编码，默认为普通话(zh-CN)，auto_lang 自动识别
@property (nonatomic, strong) NSString *fromLanguage;
/// 目标语言编码，默认为英语(en-US)，auto_lang 自动识别
@property (nonatomic, strong) NSString *toLanguage;
/// 左声道源语言编码；如果不设置，则使用 fromLanguage
@property (nonatomic, strong, nullable) NSString *leftFromLanguage;
/// 左声道目标语言编码；如果不设置，则使用 toLanguage
@property (nonatomic, strong, nullable) NSString *leftToLanguage;

/// 右声道源语言编码；如果不设置，则使用 fromLanguage
@property (nonatomic, strong, nullable) NSString *rightFromLanguage;
/// 右声道目标语言编码；如果不设置，则使用 toLanguage
@property (nonatomic, strong, nullable) NSString *rightToLanguage;

/// 是否进行 TTS，默认 false
@property (nonatomic, assign) BOOL isTTs;
/// TTS 输出格式，默认 pcm，支持 pcm / ogg_opus / mp3
@property (nonatomic, strong) NSString *ttsFormat;
/// TTS 类型，默认只支持 "stream"
@property (nonatomic, strong) NSString *ttsType;
/// TTS 声色设置
@property (nonatomic, strong) NSString *ttsSpeaker;
/// TTS 声色类型
@property (nonatomic, strong, nullable) NSString *ttsSpeakerType;
/// TTS 声色 ID
@property (nonatomic, strong, nullable) NSString *ttsSpeakerId;
/// 是否使用 LLM 翻译，默认 NO
@property (nonatomic, assign) BOOL llmTranslate;
/// 音频封装格式（opus 原始流 raw，封装 ogg）
@property (nonatomic, strong) NSString *format;
/// 音频编码格式（opus、raw）
@property (nonatomic, strong) NSString *codec;
/// Opus 输入包大小（字节数）
@property (nonatomic, assign) NSInteger opusInputPackageSize;
/// Opus 输出包大小（字节数）
@property (nonatomic, assign) NSInteger opusOutputPackageSize;
/// 音频采样率，单位 Hz（例如：16000 或 48000）
@property (nonatomic, assign) NSInteger sampleRate;
/// 声道数（1 单声道，2 立体声）
@property (nonatomic, assign) NSInteger channels;
/// 说话人分离
@property (nonatomic, assign) BOOL isSpeakerSeparate;
@end

/// 蓝牙耳机录音asr配置
@interface StarburstBleAsrConfig : NSObject
@property (nonatomic, assign) NSInteger type;/// 0x00实时录音，0x0c通话录音,其他待定
@end

/// 文件/文本asr配置
@interface StarburstAsrFileConfig : NSObject
@property (nonatomic, assign) BOOL isTranslate;/// 是否翻译，默认false
@property (nonatomic, strong) NSString *fromLanguage;/// 语⾔编码
@property (nonatomic, strong) NSString *toLanguage;/// ⽬标语⾔编码
@property (nonatomic, assign) BOOL summary;/// 是否进行总结，默认false
/// 是否区分说话人，默认 NO
@property (nonatomic, assign) BOOL speakerSeparate;
/// 是否启用 ITN（数值/时间等标准化）
@property (nonatomic, assign) BOOL enableItn;
/// 端点检测窗口大小（VAD 终点判定），与服务端约定
//@property (nonatomic, assign) NSInteger endWindowSize; // endWindowSize
/// 翻译增强，默认 NO
@property (nonatomic, assign) BOOL enableTranslateImprove; // enableTranslateImprove
@property (nonatomic, assign) BOOL speakerSplit;/// 是否区分说话人，默认false
/// TTS 声色类型（如 "clone" 时配合 ttsSpeakerId 使用）
@property (nonatomic, strong, nullable) NSString *ttsSpeakerType;
/// TTS 声色 ID
@property (nonatomic, strong, nullable) NSString *ttsSpeakerId;
/// 是否使用 LLM 翻译，默认 NO
@property (nonatomic, assign) BOOL llmTranslate;
@end


/// 翻译配置
@interface StarburstTslConfig : NSObject
@property (nonatomic, strong) NSString *fromLanguage;/// 语⾔编码
@property (nonatomic, strong) NSString *toLanguage;/// ⽬标语⾔编码
/// TTS 声色类型（如 "clone" 时配合 ttsSpeakerId 使用）
@property (nonatomic, strong, nullable) NSString *ttsSpeakerType;
/// TTS 声色 ID
@property (nonatomic, strong, nullable) NSString *ttsSpeakerId;
/// 是否使用 LLM 翻译，默认 NO
@property (nonatomic, assign) BOOL llmTranslate;
@end
