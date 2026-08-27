//
//  CustomVoiceChatConfig.h
//  IOT
//
//  Created by ByteDance on 2026/1/26.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomVoiceChatConfig : NSObject

@property (nonatomic, copy, nullable) NSString *role;      /// 对话角色
@property (nonatomic, copy, nullable) NSString *language;  /// 如 zh-CN

/// 输入音频（multi_start 字段：format + codec）
@property (nonatomic, copy) NSString *format;        /// default "raw"
@property (nonatomic, copy) NSString *codec;         /// default "raw" / "opus"
@property (nonatomic, assign) NSInteger sampleRate;  /// default 16000
@property (nonatomic, assign) NSInteger channel;     /// default 1

/// 透传：multi_start.extraInfo
@property (nonatomic, strong, nullable) NSDictionary *extraInfo;

/// TTS
@property (nonatomic, assign) BOOL tts;
@property (nonatomic, copy, nullable) NSString *ttsAudioFormat;   /// default "pcm"
@property (nonatomic, copy, nullable) NSString *ttsSpeakerType;   /// "clone" etc
@property (nonatomic, copy, nullable) NSString *ttsSpeakerId;

/// 其它（如你旧类有）
@property (nonatomic, assign) BOOL debugEnable;              /// default YES
@property (nonatomic, assign) NSInteger ttsBinaryBurstSize;  /// default 0
@property (nonatomic, assign) NSInteger ttsBinaryBurstDelay; /// default 0

@property (nonatomic, copy, nullable) NSString *customPrompt;
@property (nonatomic, copy, nullable) NSString *pictureFormat;    /// default "jpg"

@end

NS_ASSUME_NONNULL_END
