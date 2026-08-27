//
//  StarburstPhoneSdk.h
//  StarburstSdk
//
//  Created by liangshi on 2025/3/11.
//

#import <Foundation/Foundation.h>
#import <StarburstSdk/StarburstSdkManager.h>
#import <StarburstSdk/StarburstAsrConfig.h>
#import <StarburstSdk/StarburstAsrModel.h>
#import <StarburstSdk/StarbaustVoiceChatModel.h>
#import <StarburstSdk/StarburstFileAsrModel.h>
#import <StarburstSdk/StarburstOffLineFile.h>
#import <StarburstSdk/StarburstStreamModel.h>
#import <StarburstSdk/StarbusrtSpeaker.h>

@class TcFeatureConfig;

@interface StarburstPhoneSdk : NSObject
@property (nonatomic, readonly)BOOL didAuth;/// 是否已经鉴权
@property (nonatomic, strong)void (^websocketStateCallback)(BOOL connected);/// websocket状态回调,true为已连接，false未链接


/// 单利
+ (instancetype)shared;

///  注册
/// - Parameters:
///   - productKey: 产品key
///   - productSecret:  产品秘钥，经过aes/cbc/7Padding加密后的data
///   - deviceName:  设备名称
///   - random:  加密随机数
///   - finished: 结果回调
- (void)registerWithProductKey:(NSString *)productKey productSecret:(NSData *)productSecret deviceName:(NSString *)deviceName random:(NSString *)random finished:(void (^)(NSString *deviceSecret,NSError *error))finished;

///  登录
/// - Parameters:
///   - productKey: 产品key
///   - deviceName:  设备名称
///   - deviceSecret:  设备密码
///   - finished: 结果回调
- (void)connectWithProductKey:(NSString *)productKey deviceName:(NSString *)deviceName deviceSecret:(NSString *)deviceSecret finished:(void (^)(BOOL isSuccess,NSError *error))finished;

///// 【文件摘要】
///// - Parameters:
/////   - path: 文件路径
/////   - recognize: 识别结果回调
/////   - error: 错误回调
//- (void)asrByFile:(NSURL *)filePath config:(StarburstAsrFileConfig*)config recognizeText:(void (^)(StarburstFileAsrModel*))recognize error:(void (^)(NSError *err))error;

/// 【文本摘要】
/// - Parameters:
///   - text: 识别的文本
///   - recognize: 识别结果回调
///   - error: 错误回调
- (void)summaryByText:(NSString *)text config:(StarburstAsrFileConfig*)config recognizeText:(void (^)(StarburstFileAsrModel*))recognize error:(void (^)(NSError *err))error;

/// 【文本摘要】--流式
/// - Parameters:
///   - text: 摘要的文字
///   - recognize: 结果回调
///   - error: 错误回调
- (void)summaryByTextWithSplit:(NSString *)text recognizeText:(void (^)(StarburstStreamModel*))recognize error:(void (^)(NSError *err))error;

/// 取消 【文本摘要】--流式
-(void)cancelSummaryByTextWithSplit;

/// 【文本翻译】
/// - Parameters:
///   - text: 翻译的文字
///   - config: 翻译配置
///   - recognize: 识别结果回调
///   - error: 错误回调
- (void)translateByText:(NSString *)text config:(StarburstAsrFileConfig*)config recognizeText:(void (^)(StarburstFileAsrModel*))recognize error:(void (^)(NSError *err))error;

/// 【文本翻译】--流式
/// - Parameters:
///   - text: 翻译的文字
///   - config: 翻译配置
///   - recognize: 结果回调
///   - error: 错误回调
- (void)translateByTextWithSplit:(NSString *)text config:(StarburstTslConfig*)config recognizeText:(void (^)(StarburstStreamModel*))recognize error:(void (^)(NSError *err))error;

/// 取消 【文本翻译】--流式
-(void)cancelTranslateByTextWithSplit;

/// 【同声传译】开始手机拾音
/// - Parameters:
///   - config: 识别配置
///   - voiceRecordData: 录音音频流回调
///   - recognizeText: 识别回调
///   - stateChange: 状态回调
- (void)startRecordAsr:(StarburstAsrConfig*)config voiceRecord:(void (^)(NSData*))voiceData recognizeText:(void (^)(StarburstAsrModel*))recognize stateChange:(void(^)(StarburstCode code))stateChange interruption:(void(^)(void))interrupt;

/// 【同声传译】结束手机拾音
/// - Parameter fileCallback: 录音文件回调
- (void)stopRecordAsr:(void(^)(NSString *filePath))fileCallback;

/// 设置手机拾音录音文件保存路径，nil或空字符串时使用SDK临时目录；文件格式为wav
- (void)setPhoneRecordPath:(NSString * _Nullable)recordPath;

/// 设置手机拾音是否保存录音文件，默认YES；NO时stopRecordAsr回调filePath为空字符串
- (void)setPhoneRecordFileSaveEnabled:(BOOL)enabled;

/// 设置对话录音是否保存文件，默认YES；NO时对话结束finished回调filePath为空字符串
- (void)setChatRecordFileSaveEnabled:(BOOL)enabled;

/// 切换到蓝牙 SCO 输入（对默认对话录音器和默认手机录音 ASR 录音器生效）
- (void)switchToSco;

/// 切换到手机麦输入（对默认对话录音器和默认手机录音 ASR 录音器生效）
- (void)switchToPhone;

/// 手机拾音对话设置
/// - Parameters:
///   - config: 对话配置
///   - startCallBack: 开始回调
///   - textCallBack: 文本识别回调
///   - voiceCallBack: AI语音回复回调
///   - stateChange: 状态回调
///   - finished：录音地址回调
- (void)setupPhoneChatWith:(StarburstVoiceChatConfig*)config start:(void (^)(NSInteger dialogId))startCallback textCallback:(void (^)(StarbaustVoiceChatModel*))textCallBack  responseVoice:(void (^)(NSInteger dialogId,NSData*data,BOOL finish,NSInteger sampleRate))voiceCallBack stateChange:(void(^)(StarburstCode code))stateChange finished:(void(^)(NSString *filePath))path;

/// 手机拾音，开始对话
/// - Parameter vadType: 0 vad检测，1不启用vad（手动控制开始/结束讲话）
- (void)startPhoneChat:(int)vadType;

/// 结束手机拾音对话
- (void)stopPhoneChat;

/// 打断当前对话内容下发（仅发送 interrupt 给服务端，不结束会话），对齐 Android interrupt()
- (void)interruptVoiceChat;

/// 获取音色列表
/// - Parameter callBack: 结果回调
- (void)getVcSpeekerList:(void (^)(NSArray <StarbusrtSpeaker*> *list,BOOL success))callBack;

#pragma mark - TcFeature (套餐功能配置)

/// 获取设备套餐功能配置（强制从云端拉取），featureList 为空代表全功能可用
- (void)getTcFeatureList:(void(^)(NSString * _Nullable tcId, NSString * _Nullable tcName, NSArray<TcFeatureConfig *> * _Nullable featureList, NSError * _Nullable error))callback;

/// 判断当前套餐是否支持某个功能
- (BOOL)isTcFeatureEnabled:(NSString *)featureId;

/// 判断当前套餐是否支持某个功能下的指定语种
- (BOOL)isTcFeatureEnabledForFeature:(NSString *)featureId language:(NSString *)languageTag;

/// 当前套餐 ID，未知时返回空串
- (NSString *)currentTcId;

@end
