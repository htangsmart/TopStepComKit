//
//  StartburstGlassesSdk.h
//  StarburstSdk
//
//  Created by liangshi on 2025/4/29.
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
#import <StarburstSdk/StartburstGlassChat.h>

@class TcFeatureConfig;

@interface StartburstGlassesSdk : NSObject
@property (nonatomic, strong)void (^sendToBleCallback)(NSData *data);/// 发送给蓝牙设备
@property (nonatomic, strong)void (^authCallback)(int code,NSString *msg);/// 鉴权结果回调，code200代表成功，其他为失败
@property (nonatomic, readonly)BOOL didAuth;/// 是否已经鉴权
@property (nonatomic, strong)StartburstGlassChat *chat;/// 对话对象

/// 单利
+ (instancetype)shared;

/// 收到蓝牙设备传过来的数据，交给sdk处理
/// - Parameter data:数据
- (void)receiveBleData:(NSData *)data;

/// 蓝牙设备已经连上
- (void)bleConnected;

/// 蓝牙断开连接（在监听到蓝牙断开的时候，调用该方法通知sdk结束当前任务）
- (void)bleDisConnected;

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

/// 切换到蓝牙 SCO 输入（对默认对话录音器和默认手机录音 ASR 录音器生效）
- (void)switchToSco;

/// 切换到手机麦输入（对默认对话录音器和默认手机录音 ASR 录音器生效）
- (void)switchToPhone;


/// 开始自定义音频流识别
- (void)startCustomAsr:(StarburstAsrConfig*)config
          recognizeText:(void (^)(StarburstAsrModel *model))recognize
            stateChange:(void(^)(StarburstCode code))stateChange;

/// 开始自定义音频流识别（支持多实例，streamerId 如 @"left"、@"right"，nil 为默认实例）
- (void)startCustomAsrWithId:(NSString *)streamerId
                      config:(StarburstAsrConfig *)config
               recognizeText:(void (^)(StarburstAsrModel *model))recognize
                 stateChange:(void(^)(StarburstCode code))stateChange;

/// 发送一段自定义音频数据（采样率、格式需匹配 config 设定）
- (void)sendCustomAudioData:(NSData *)data;

/// 向指定实例发送自定义音频数据
- (void)sendCustomAudioData:(NSData *)data toStreamerId:(NSString *)streamerId;

/// 停止自定义音频流识别
- (void)stopCustomAsr;

/// 停止指定实例的自定义音频流识别
- (void)stopCustomAsrForId:(NSString *)streamerId;

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

