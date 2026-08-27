//
//  StarburstSdk.h
//  VoiceDemo
//
//  Created by incar on 2024/9/12.
//

#import <Foundation/Foundation.h>
#import <StarburstSdk/StarburstAsrConfig.h>
#import <StarburstSdk/StarburstAsrModel.h>
#import <StarburstSdk/StarbaustVoiceChatModel.h>
#import <StarburstSdk/StarburstFileAsrModel.h>
#import <StarburstSdk/StarburstOffLineFile.h>
#import <StarburstSdk/StarburstStreamModel.h>
#import <StarburstSdk/StarbusrtSpeaker.h>
#import <StarburstSdk/StartburstDecoderConfig.h>
#import <StarburstSdk/StarburstVoiceChatRecorder.h>
#import <AVFoundation/AVFoundation.h>
@class TcFeatureConfig;

typedef NS_OPTIONS(NSInteger,StarburstCode) {
    StarburstCode_Start_Record = 20001,///开始录音
    StarburstCode_Stop_Record = 20002,///停止录音
    StarburstCode_Record_Error = 20003,///录音出错
    StarburstCode_Ble_Disconected = 20004,///蓝牙断开
    StarburstCode_Websocket_Connected = 30001,///socket连上
    StarburstCode_Websocket_Disconnected = 30002,///socket断开连接
    StarburstCode_Websocket_Connecting = 30003,///socket连接中...
    StarburstCode_Websocket_pingTimeOut = 30004,///ping超时
    StarburstCode_Net_Error = 50000,///网络错误
    StarburstCode_UnAuth = 60000,///未鉴权
};

typedef void (^AudioIntensityInputCallback)(NSArray<NSNumber*> *left,
                                            NSArray<NSNumber*> *right,
                                            NSTimeInterval timestampMs);

/// 与安卓 `AuthInfoRes` 字段风格一致的鉴权信息返回结构
@interface StarburstAuthInfoRes : NSObject

/// 云端 token（鉴权凭证）
@property (nonatomic, copy, nullable) NSString *token;

/// token 过期时间（ms 时间戳）
@property (nonatomic, assign) long long expireTime;

@property (nonatomic, copy, nullable) NSString *productKey;
@property (nonatomic, copy, nullable) NSString *deviceName;

/// 业务签名（BLE 鉴权下为设备侧返回的 `sign`）
@property (nonatomic, copy, nullable) NSString *businessSign;

/// token 签名时间戳（ms）
@property (nonatomic, copy, nullable) NSString *timestamp;

/// 签名算法，例如 hmacsha256
@property (nonatomic, copy, nullable) NSString *signMethod;

@end

typedef void (^StarburstAuthInfoCallback)(int code, NSString *msg, StarburstAuthInfoRes * _Nullable authInfo);

@interface StarburstSdk : NSObject
//@property (nonatomic, strong)void (^authSuccessCallback)(void);/// 鉴权成功回调
@property (nonatomic, strong)void (^authCallback)(int code,NSString *msg);/// 鉴权结果回调，code200代表成功，其他为失败
@property (nonatomic, readonly)BOOL didAuth;// 是否已经鉴权
@property (nonatomic, strong)void (^websocketStateCallback)(BOOL connected);/// websocket状态回调,true为已连接，false未链接
@property (nonatomic, strong)void (^bleRecordStateCallback)(int state);/// 耳机录音状态回调,1录音，2结束录音
@property (nonatomic, strong)void (^sendToBleCallback)(NSData *data);/// 发送给蓝牙设备

/// 单例
+ (instancetype)shared;

/// 鉴权用时间戳（毫秒），与服务器对齐的 NTP 时间，供 BLE 设备鉴权等使用
+ (long)authTimestampMs;

/// 收到蓝牙设备传过来的数据，交给sdk处理
/// - Parameter data:数据
- (void)receiveBleData:(NSData *)data;

/// 蓝牙设备已经连上（蓝牙连接和断开都需要通知sdk）
- (void)bleConnected;

/// 蓝牙断开连接（在监听到蓝牙断开的时候，调用该方法通知sdk结束当前任务）
- (void)bleDisConnected;

/// 获取当前 BLE 鉴权信息：
/// - 若 `didAuth == YES`，立即回调成功；
/// - 否则挂起，待下一次鉴权成功（200）后再回调。
- (void)getAuthInfoWithCallback:(StarburstAuthInfoCallback)callback;

/// 强制刷新 BLE 鉴权信息：
/// - 内部清缓存 + logout，并复用原有重登流程重新走一次设备鉴权；
/// - 鉴权完成后通过 callback 返回最新的 `StarburstAuthInfoRes`。
- (void)refreshAuthInfoWithCallback:(StarburstAuthInfoCallback)callback;

///// 【文本摘要】
///// - Parameters:
/////   - text: 识别的文本
/////   - recognize: 识别结果回调
/////   - error: 错误回调
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
///   - interrupt:打断回调（接听电话等打断）
- (void)startRecordAsr:(StarburstAsrConfig*)config voiceRecord:(void (^)(NSData*))voiceData recognizeText:(void (^)(StarburstAsrModel*))recognize stateChange:(void(^)(StarburstCode code))stateChange interruption:(void(^)(void))interrupt;

/// 【同声传译】结束手机拾音
/// - Parameter fileCallback: 录音文件回调
- (void)stopRecordAsr:(void(^)(NSString *filePath))callback;

/// 设置手机拾音录音文件保存路径，nil或空字符串时使用SDK临时目录；文件格式为wav
- (void)setPhoneRecordPath:(NSString * _Nullable)recordPath;

/// 设置手机拾音是否保存录音文件，默认YES；NO时stopRecordAsr回调filePath为空字符串
- (void)setPhoneRecordFileSaveEnabled:(BOOL)enabled;

/// 【自定义音频流识别】开始
/// - Parameters:
///   - config: ASR识别配置（和手机拾音配置一致）
///   - recognize: 文本识别结果回调
///   - stateChange: 状态变化回调
- (void)startCustomAsr:(StarburstAsrConfig*)config
          recognizeText:(void (^)(StarburstAsrModel *model))recognize
            stateChange:(void(^)(StarburstCode code))stateChange;

/// 【自定义音频流识别】按实例 ID 开始（支持多实例，如双路识别）
/// - Parameters:
///   - streamerId: 实例标识，如 @"default"、@"secondary"、@"left"、@"right" 等，nil 或空表示默认实例
///   - config: ASR识别配置
///   - recognize: 文本识别结果回调
///   - stateChange: 状态变化回调
- (void)startCustomAsrWithId:(NSString *)streamerId
                      config:(StarburstAsrConfig *)config
               recognizeText:(void (^)(StarburstAsrModel *model))recognize
                 stateChange:(void(^)(StarburstCode code))stateChange;

/// 【自定义音频流识别】发送音频数据
/// - Parameter data: 外部采集的音频 PCM 或其他格式（根据 config 设定）
- (void)sendCustomAudioData:(NSData *)data;

/// 【自定义音频流识别】向指定实例发送音频数据
/// - Parameters:
///   - data: 音频数据
///   - streamerId: 实例标识，nil 或空表示默认实例
- (void)sendCustomAudioData:(NSData *)data toStreamerId:(NSString *)streamerId;

/// 【自定义音频流识别】结束
- (void)stopCustomAsr;

/// 【自定义音频流识别】结束指定实例
/// - Parameter streamerId: 实例标识，nil 或空表示默认实例
- (void)stopCustomAsrForId:(NSString *)streamerId;

/// 开始耳机拾音
/// - Parameters:
///   - config: 识别配置
- (void)startDeviceRecord:(StarburstBleAsrConfig*)config;

/// 结束耳机拾音
- (void)stopDeviceRecord;

/// 设置耳机拾音是否保存录音文件，默认YES；NO时finished回调filePath为空字符串
- (void)setDeviceRecordFileSaveEnabled:(BOOL)enabled;

/// 设置对话录音是否保存文件，默认YES；NO时对话结束finished回调filePath为空字符串（手机对话与BLE对话均生效）
- (void)setChatRecordFileSaveEnabled:(BOOL)enabled;

/// 设置耳机拾音回调
/// - Parameters:
///   - recordPath: 录音文件保存的路径。如果文件已经存在，则音频数据会追加到尾部；如果不存在，则创建新文件；传nil则会按之前时间格式创建新文件
///   - asrConfig: 识别配置
///   - bleConfig: 耳机录音类型回调
///   - recognize: 识别回调
///   - stateChange: 状态回调
///   - path: 录音结束，录音文件地址回调
- (void)setupDeviceRecordWith:(NSString *)recordPath asrConfig:(StarburstAsrConfig*)asrConfig bleConfig:(void (^)(StarburstBleAsrConfig*))bleConfig recognizeText:(void (^)(StarburstAsrModel*))recognize stateChange:(void(^)(StarburstCode code))stateChange finished:(void(^)(NSString *filePath))path;


/// opus输出给app，app解码后将数据通过inputPcmData传回给sdk
- (void)outputOpusData:(void (^)(StartburstDecoderConfig *copusConfig,NSData*opusData))recordCallBack;

/// opus解码后传给sdk
- (void)inputPcmData:(NSData *)pcmData;





/// 获取音色列表
/// - Parameter callBack: 结果回调
- (void)getVcSpeekerList:(void (^)(NSArray <StarbusrtSpeaker*> *list,BOOL success))callBack;

///  设置voice chat回调,目前只支持蓝牙设备发起对话
/// - Parameters:
///   - config: 对话配置
///   - startCallBack: 开始回调
///   - textCallBack: 文本识别回调
///   - voiceCallBack: AI语音回复回调
///   - stateChange: 状态回调
///   - finished：录音地址回调
- (void)setupVoiceChatWith:(StarburstVoiceChatConfig*)config start:(void (^)(NSInteger dialogId))startCallback textCallback:(void (^)(StarbaustVoiceChatModel*))textCallBack  responseVoice:(void (^)(NSInteger dialogId,NSData*data,BOOL finish, NSInteger sampleRate))voiceCallBack stateChange:(void(^)(StarburstCode code))stateChange finished:(void(^)(NSString *filePath))path;

/// 主动请求蓝牙设备开始 BLE voice chat，对齐 Android BLE startVoiceChat()
- (void)startBleVoiceChat;

/// 终止voice chat对话
- (void)stopVoiceChat:(NSInteger)dialogId;

/// 打断当前对话内容下发（仅发送 interrupt 给服务端，不结束会话），对齐 Android interrupt()
- (void)interruptVoiceChat;

/// 开始播放tts
- (void)startPlayTtsAudio:(NSInteger)dialogId;

/// 结束播放tts
- (void)stopPlayTtsAudio:(NSInteger)dialogId;

///  发送文字对话
/// - Parameters:
///   - text: 对话的文字
///   - isTts: 是否tts
- (void)sendVoiceChat:(NSString *)text tts:(BOOL)isTts;


/// 手机拾音 voice chat（支持自定义 recorder）
/// - Parameters:
///   - config: 对话配置
///   - recorder: 外部录音器（实现 StarburstVoiceChatRecorder 协议）
///   - startCallback: 开始回调
///   - textCallBack: 文本回调
///   - voiceCallBack: AI 语音回调
///   - stateChange: 状态回调
///   - path: 录音文件路径回调
///
- (void)setupPhoneChatWith:(StarburstVoiceChatConfig*)config start:(void (^)(NSInteger dialogId))startCallback textCallback:(void (^)(StarbaustVoiceChatModel*))textCallBack  responseVoice:(void (^)(NSInteger dialogId,NSData*data,BOOL finish,NSInteger sampleRate))voiceCallBack stateChange:(void(^)(StarburstCode code))stateChange finished:(void(^)(NSString *filePath))path;

/// 配置并绑定“手机通话/语音对话”能力（支持自定义录音机）。
///
/// 调用流程建议：
/// 1) 先调用本方法完成配置与回调绑定；
/// 2) 再调用 startPhoneChat / stopPhoneChat 控制开始/结束
///
/// 注意：
/// - recorder 需要被外部强持有（或 SDK 内部会强持有），否则可能出现 start 不触发/回调不走。
/// - recorder 负责通过 setUpStart:stop:data:finished: 将音频数据（NSData）持续回传给 SDK。
///
/// @param config        语音对话配置（如鉴权、场景、VAD/ASR/TTS 相关策略等）。
/// @param recorder      自定义录音机（实现 StarburstVoiceChatRecorder 协议）。
/// @param startCallback 对话启动回调：SDK 成功创建/开启一次对话后回调，返回 dialogId。
/// @param textCallBack  文本回调：服务端返回的识别/对话文本模型（字段以 StarbaustVoiceChatModel 实际定义为准）。
/// @param voiceCallBack 语音回调：服务端返回的语音数据流（TTS）。
///                      - dialogId: 对应对话 ID
///                      - data:     音频数据（通常为 opus/pcm，取决于 config）
///                      - finish:   是否为最后一包
///                      - sampleRate: 音频采样率（Hz）
/// @param stateChange   状态回调：SDK 内部状态变化（连接/鉴权/开始/结束/错误等，取决于 StarburstCode 定义）。
/// @param path          结束回调：本次对话/录音结束后回调文件路径（由 recorder 或 SDK 生成；没有则可能为空字符串）。
- (void)setupPhoneChatWith:(StarburstVoiceChatConfig*)config
                  recorder:(id<StarburstVoiceChatRecorder>)recorder
                     start:(void (^)(NSInteger dialogId))startCallback
              textCallback:(void (^)(StarbaustVoiceChatModel *model))textCallBack
             responseVoice:(void (^)(NSInteger dialogId, NSData *data, BOOL finish, NSInteger sampleRate))voiceCallBack
               stateChange:(void(^)(StarburstCode code))stateChange
                  finished:(void(^)(NSString *filePath))path;

- (void)startPhoneChat:(int)vadType;

- (void)startPhoneChat:(int)vadType
audioSessionCategoryOptions:(AVAudioSessionCategoryOptions)audioSessionCategoryOptions;

- (void)stopPhoneChat;

/// 将默认手机对话录音器切换到蓝牙 SCO 输入。
/// 仅对 SDK 内置默认录音器生效；如果当前使用的是自定义 recorder，则不会强制接管其路由。
- (void)switchToSco;

/// 将默认手机对话录音器切换到手机麦输入。
/// 仅对 SDK 内置默认录音器生效；如果当前使用的是自定义 recorder，则不会强制接管其路由。
- (void)switchToPhone;

//不可用
- (void)registerWithProductKey:(NSString *)productKey productSecret:(NSString *)productSecret deviceName:(NSString *)deviceName random:(NSString *)random finished:(void (^)(NSString *deviceSecret,NSError *error))finished;
//不可用
- (void)connectWithProductKey:(NSString *)productKey  deviceName:(NSString *)deviceName deviceSecret:(NSString *)deviceSecret finished:(void (^)(BOOL isSuccess,NSError *error))finished;
- (void)setInputAudioIntensityCallback:(AudioIntensityInputCallback)callback;
- (void)setPhoneInputAudioIntensityCallback:(void(^)(NSArray<NSNumber*> *left, NSArray<NSNumber*> *right, NSTimeInterval frameTimestampMs))callback;
-(NSString *)getDeviceName;

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
