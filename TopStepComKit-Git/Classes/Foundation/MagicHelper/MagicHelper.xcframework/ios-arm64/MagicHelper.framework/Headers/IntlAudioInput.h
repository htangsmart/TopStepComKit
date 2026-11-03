


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IntlAudioInput : NSObject

/// 请求id，跟ASRIntlRequestBody.qid相对应
@property (nonatomic, strong, readonly) NSString *qid;

/// 是否已结束输入监听
@property (nonatomic, assign, readonly) BOOL isFinished;

/// 传输音频数据
- (void)sendAudioData:(NSData *)data;

/// 运行中切换云端 TTS 合成；仅 V5 同传任务会处理。
- (void)setTtsEnabled:(BOOL)enabled;

/// 运行中调整云端 TTS 合成语速；仅 V5 同传任务会处理，合法范围 0.5～2.0。
- (void)setTtsSpeechRate:(float)rate;

/// 运行中调整云端 TTS 音色；仅 V5 同传任务会处理，从后续未合成段落生效。
- (void)setTtsVoiceId:(NSString *)voiceId;

/// 录音结束调用
- (void)sendFinish;

@end

NS_ASSUME_NONNULL_END
