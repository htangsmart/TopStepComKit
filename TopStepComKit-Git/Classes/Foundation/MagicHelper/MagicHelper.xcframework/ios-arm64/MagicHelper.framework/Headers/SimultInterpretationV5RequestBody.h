//
//  SimultInterpretationV5RequestBody.h
//  MagicHelper
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const SIV5TTSVoiceAuto;
FOUNDATION_EXPORT NSString * const SIV5TTSVoiceStandardFemale;
FOUNDATION_EXPORT NSString * const SIV5TTSVoiceStandardMale;
FOUNDATION_EXPORT NSString * const SIV5AzureTTSVoicePrefix;

/// MLuo cloud pure-WSS simultaneous interpretation request.
@interface SimultInterpretationV5RequestBody : NSObject

/// SDK-generated request id. It is returned by callbacks for correlation.
@property (nonatomic, copy, readonly) NSString *qid;
/// Source language, for example zh-CN.
@property (nonatomic, copy, nullable) NSString *sourceLanguage;
/// Target language, for example en-US.
@property (nonatomic, copy) NSString *targetLanguage;
/// Enable TTS output. Default NO to avoid unnecessary cloud synthesis cost.
@property (nonatomic, assign) BOOL enableTts;
/// Cloud TTS synthesis speed. Valid range is 0.5 to 2.0; default is 1.0.
@property (nonatomic, assign) float ttsSpeechRate;
/// Provider-independent cloud TTS voice preference. Default is SIV5TTSVoiceAuto.
@property (nonatomic, copy) NSString *ttsVoiceId;

+ (BOOL)isSupportedTtsVoiceId:(NSString *)voiceId;
+ (nullable NSString *)normalizedTtsVoiceId:(NSString *)voiceId;

@end

NS_ASSUME_NONNULL_END
