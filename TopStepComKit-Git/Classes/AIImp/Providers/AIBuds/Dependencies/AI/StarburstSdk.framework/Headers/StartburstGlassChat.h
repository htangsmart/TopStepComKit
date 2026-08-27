//
//  StartburstGlassChat.h
//  StarburstSdk
//
//  Created by liangshi on 2025/5/6.
//

#import <Foundation/Foundation.h>
#import <StarburstSdk/StarburstSdkManager.h>
#import <StarburstSdk/StarbaustVoiceChatModel.h>
#import <StarburstSdk/StarbusrtSpeaker.h>


@interface StartburstGlassChat : NSObject
///
/// 对话设置
/// - Parameters:
///   - config: 对话配置
///   - textCallBack: 文本识别回调
///   - voiceCallBack: AI语音回复回调
///   - stateChange: 状态回调
///   - finished：录音地址回调
- (void)setupPhoneChatWith:(StarburstVoiceChatConfig*)config textCallback:(void (^)(StarbaustVoiceChatModel*))textCallBack  responseVoice:(void (^)(NSInteger dialogId,NSData*data,BOOL finish,NSInteger sampleRate))voiceCallBack stateChange:(void(^)(StarburstCode code))stateChange finished:(void(^)(NSString *filePath))path;

/// 开始对话
- (void)start;

/// 结束对话
- (void)stop;

/// 分发数据
/// - Parameter data:音频流
- (void)fireAudioData:(NSData *)data;

/// 通知vad状态变化
/// - Parameter isVadStarted: ture表⽰vad检测到说话开始,false表⽰vad检测到说话结束
- (void)vadStateChange:(BOOL)isVadStarted;

/// 分发数据
/// - Parameter data:图片流
- (void)fireImageData:(NSData *)data;

/// 分发数据
/// - Parameter text:文本
- (void)fireText:(NSString *)text;

- (void)requestSpeakerListWithContextId:(NSString *)contextId
customPrompt:(NSString *)customPrompt
callback:(void (^)(NSArray *list, BOOL success))callback;

@end

