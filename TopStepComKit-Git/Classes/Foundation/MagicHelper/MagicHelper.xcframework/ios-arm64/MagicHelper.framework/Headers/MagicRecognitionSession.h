//
//  MagicSpeechSession.h
//  MagicHelper
//
//  Created by ymz on 2025/7/16.
//

#import <Foundation/Foundation.h>
#import "MagicSmartOptionModel.h"
#import "MagicMemoryData.h"
#import "MagicCardEnvelope.h"

NS_ASSUME_NONNULL_BEGIN

@interface MGAgent : NSObject

@property (nonatomic, strong) NSString *agentId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *personality;
@property (nonatomic, strong) NSString *petDescription;
@property (nonatomic, strong) NSString *hobby;
@property (nonatomic, strong) NSString *birthday;

+ (instancetype)agentWithId:(NSString *)petId
                     name:(NSString *)name
              personality:(NSString *)personality
           petDescription:(NSString *)petDescription
                    hobby:(NSString *)hobby
                 birthday:(NSString *)birthday;

@end


/// 音频格式
typedef NS_ENUM(NSInteger, MagicAudioType) {
    MagicAudioTypePcm,
    MagicAudioTypeOpus
};

/// 音频输入模式
typedef NS_ENUM(NSInteger, MGAudioInputMode) {
    /// 手动控制输入开始 / 结束 (对应startSpeech -> sendSpeechAudioData -> endSpeech)
    MGAudioInputModeManual = 0,
    /// 持续输入音频
    MGAudioInputModeContinuous = 1,
};

typedef NS_ENUM(NSInteger, MGVADState) {
    /// 初始状态
    MGVADStateSpeechNone = 0,
    /// VAD 检测到语音开始
    MGVADStateSpeechStart = 1,
    /// VAD 检测到语音结束
    MGVADStateSpeechEnd = 2
};


@protocol MagicRecognitionSessionDelegate<NSObject>

@optional
/// 意图理解回调
- (void)onIntentionAction:(NSString *)type params:(NSDictionary *)params;

/// 情绪回调
- (void)onEmotionAction:(NSString *)emotion ext:(nullable NSDictionary *)ext;

/// 文本回调
- (void)onMessage:(NSDictionary *)message;
/// 文本回调结束
- (void)onMessageFinished:(NSDictionary *)message;

/// 音频数据回调
- (void)onAudioData:(NSData *)audioData;
/// 音频数据回调结束
- (void)onAudioDataFinished:(NSDictionary *)message;

/// VAD识别结束（检测到用户停止说话，建议停止发送音频）
- (void)onVADCompleted;

/// webSocket开启回调
- (void)onOpen;
/// WebSocket关闭回调
- (void)onClosed:(NSString *)reason;
/// WebSocket错误回调
- (void)onFailure:(NSString *)reason;

/// VAD 状态变化回调（开始 / 结束）
/// 该方法只会在MGAudioInputModeContinuous模式有效
- (void)onVADStateChanged:(MGVADState)state
                timestamp:(NSTimeInterval)timestamp;

/**
 * 卡片数据回调（response.card.data）。
 * 同时携带播报文本与卡片结构化数据，收到即可渲染 UI；TTS 音频仍通过 onAudioData 下发。
 * @param card 解析后的卡片信封，含 broadcast.text、card_data、card_group 等
 * @param rawJson 原始事件 JSON 字符串，用于读取尚未建模的扩展字段
 */
- (void)onCardData:(MagicCardEnvelope *)card rawJson:(NSString *)rawJson;

/**
 * 卡片加载中回调（response.card.loading）。
 * MCP/工具调用发起时下发，端上可展示 skeleton；后续必跟随 onCardData 或 onCardError。
 * @param card 含 card_type、display_title、response_id 等加载态字段
 * @param rawJson 原始事件 JSON
 */
- (void)onCardLoading:(MagicCardEnvelope *)card rawJson:(NSString *)rawJson;

/**
 * 卡片错误回调（response.card.error）。
 * 卡片获取失败时的兜底事件，不触发 onFailure；降级纯文本仍走 onMessage（response.text.delta）。
 * @param card 含 error_code、error_message、card_type 等
 * @param rawJson 原始事件 JSON
 */
- (void)onCardError:(MagicCardEnvelope *)card rawJson:(NSString *)rawJson;

/// 定位点的字符串表示
///
/// 格式： "latitude,longitude"
///
/// 说明：
/// - 使用英文逗号 `,` 分隔，不包含空格
/// - 若定位信息不存在或无效，返回 nil
///
/// 示例：
///   "31.230416,121.473701"
///
- (nullable NSString *)locationAction;
/// 经纬度对应的地址
- (nullable NSString *)addressAction;

@end


@interface MagicRecognitionSession : NSObject

@property (nonatomic, weak) id<MagicRecognitionSessionDelegate> delegate;

/// websocket是否连接
@property (nonatomic, assign, readonly) BOOL isConnected;

/// 是否需要vad, 默认YES
@property (nonatomic, assign) BOOL needVAD;

/// 是否开启 Dscrow 降噪，默认 YES
@property (nonatomic, assign) BOOL enableDenoise;

/// 连续静音达到多少毫秒判定结束，默认1500ms
@property (nonatomic, assign) NSInteger silenceTriggerDurationMs;

/// 静默时长，默认10s, needVAD = YES有效
/// 从开始传输音频到超过时长还未检测出声音，则触发vad
@property (nonatomic, assign) NSInteger silenceTimeout;

/// session.created 成功后回显的卡片能力协商结果（card_config），非卡片会话时为 nil
@property (nonatomic, strong, readonly, nullable) MagicCardConfig *cardConfig;

/// 默认1s
@property (nonatomic, assign) NSTimeInterval vadTimeout;

/// 获取支持的configCode
- (NSArray *)getSmartConfigModels;

/// 初始化降噪 SDK，BDMagicHelper 初始化时内部调用
- (void)setupDenoiseWithMac:(NSString *)mac channel:(NSString *)channel productId:(NSString *)productId;

/// 创建会话
- (void)createSession:(nullable NSDictionary *)ext  __attribute__((deprecated("请使用 createSessionWithConfigCode:ext 替代")));

/// 创建会话
/// configCode: 控制模型，不设置使用默认的，可通过getSmartConfigModels获取
/// online_search_bailian： 带意图版本
/// online_search_bailian_no_intent：不带意图
/// ext: "{\"extKey\":\"extValue\"}" // Session级别扩展字段
- (void)createSessionWithConfigCode:(nullable NSString *)configCode ext:(nullable NSDictionary *)ext  __attribute__((deprecated("请使用 createSessionWithConfigCode:model:ext 替代")));

/// 创建会话
- (void)createSessionWithConfigCode:(nullable NSString *)configCode model:(nullable MagicSmartOptionModel *)model ext:(nullable NSDictionary *)ext;


/// 开始语音对话
- (void)startSpeech:(MagicAudioType)type __attribute__((deprecated("请使用 startSpeechWithMode:mode 替代")));

/// 开始语音对话
- (void)startSpeechWithMode:(MGAudioInputMode)mode;

/// 发送音频数据
- (void)sendSpeechAudioData:(NSData *)data;

/// 发送结束帧
- (void)endSpeech;

/// 中断对话
- (void)closeSpeech;

/// 关闭整个会话（WebSocket）
- (void)stopSession;

/// 主动发起图片识图/翻译等文本任务
/// type: 拍照识图、翻译(visual_qa)
/// params : {
///"prompt": "这是什么植物？",
///"images": [
///           {"type":"base64","value":"${image base64}"}
///           ]
///}
///注意： 图片要小于5M
- (void)requestToRespondWithType:(NSString *)intentType
                          params:(NSDictionary *)params;


/// 开始多模态图文输入流程（图文传输起始点）
/// 调用顺序：startMultimodalQAIput -> requestToRespondWithType -> startSpeech -> endSpeech -> commitMultimodalQAIput
- (void)startMultimodalQAIput;

/// 提交多模态图文输入（结束图文传输流程）
- (void)commitMultimodalQAIput;

/// 获取configcode列表
- (NSArray *)queryConfigCodeList;

/// 输入文本开启对话
- (void)commitText:(NSString *)text;

/// 主动发送ping， 会有获取最新位置点的回调
- (void)updateLocationSendPing;
@end

NS_ASSUME_NONNULL_END
