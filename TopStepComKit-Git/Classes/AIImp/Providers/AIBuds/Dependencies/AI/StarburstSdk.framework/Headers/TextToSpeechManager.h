#import <Foundation/Foundation.h>
#import <StarburstSdk/TextToSpeechCallback.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 文本转语音管理器
 *
 * 封装了调用云端 TTS（Text To Speech）接口的过程，
 * 支持设置语速、音色等参数，将文本合成成语音数据。
 */
@interface TextToSpeechManager : NSObject

/**
 * 获取单例对象
 *
 * @return TextToSpeechManager 单例实例
 *
 * @discussion 建议全局共享此管理器实例，避免重复创建和释放网络资源。
 */
+ (instancetype)sharedInstance;

/**
 * 调用文本转语音服务
 *
 * @param companyId  企业或应用 ID（由服务方分配，用于鉴权）
 * @param text       待合成的文本内容
 * @param reqId      请求唯一标识，用于排查日志或防重复请求
 * @param speedRatio 合成语音的语速倍率（1.0 为正常语速，>1.0 为加快，<1.0 为减慢）
 * @param voiceType  音色类型标识（例如 "zh_female_qingchezizi_moon_bigtts"）
 * @param encoding wav / pcm / ogg_opus / mp3，默认为 pcm
 * @param callback   回调对象，须实现 TextToSpeechCallback 协议，用于接收结果或错误
 *
 */
- (void)textToSpeech:(NSString *)companyId
                text:(NSString *)text
               reqId:(NSString *)reqId
          speedRatio:(float)speedRatio
           voiceType:(NSString *)voiceType
            encoding:(nullable NSString *)encoding
            callback:(id<TextToSpeechCallback>)callback
NS_SWIFT_NAME(textToSpeech(companyId:text:reqId:speedRatio:voiceType:encoding:callback:));

@end

NS_ASSUME_NONNULL_END
