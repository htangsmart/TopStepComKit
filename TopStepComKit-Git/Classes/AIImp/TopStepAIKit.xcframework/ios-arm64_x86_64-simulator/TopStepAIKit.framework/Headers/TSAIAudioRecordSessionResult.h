//
//  TSAIAudioRecordSessionResult.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/28.
//

#import <Foundation/Foundation.h>
#import "TSAIAudioRecordSpeakerSegment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI audio recording session result type
 * @chinese AI 录音会话结果类型
 */
typedef NS_ENUM(NSUInteger, TSAIAudioRecordSessionResultType) {
    TSAIAudioRecordSessionResultTypeTranscript, ///< Transcript result / 转写结果
    TSAIAudioRecordSessionResultTypeEvent,      ///< Session event / 会话事件
    TSAIAudioRecordSessionResultTypeError,      ///< Runtime error / 运行期错误
    TSAIAudioRecordSessionResultTypeFinish,     ///< Final session report / 会话最终报告
};

/**
 * @brief Vendor-neutral AI audio recording session result
 * @chinese 厂商无关的 AI 录音会话结果
 *
 * @discussion
 * [EN]: This model is the only public semantic-result channel for an AI audio
 *       recording session. Its fields are populated according to `type`, so
 *       InterfaceKit consumers never depend on provider-specific models.
 * [CN]: 该模型是 AI 录音会话唯一的公开语义结果通道。字段会根据 `type` 填充，
 *       从而使 InterfaceKit 使用方不依赖任何厂商专属模型。
 */
@interface TSAIAudioRecordSessionResult : NSObject

/**
 * @brief Result type
 * @chinese 结果类型
 */
@property (nonatomic, assign) TSAIAudioRecordSessionResultType type;

/**
 * @brief Transcript text
 * @chinese 转写文本
 */
@property (nonatomic, copy, nullable) NSString *text;
/**
 * @brief Transcript sentence index
 * @chinese 转写句序号
 */
@property (nonatomic, assign) NSInteger sentenceIndex;
/**
 * @brief Whether the transcript sentence is final
 * @chinese 当前转写句是否结束
 */
@property (nonatomic, assign) BOOL isSentenceFinal;
/**
 * @brief BCP-47 transcript language code
 * @chinese BCP-47 转写语言码
 *
 * @discussion
 * [EN]: This value is nil when the provider does not supply a concrete language.
 * [CN]: 当底层服务未提供明确语言时，该值为 nil。
 */
@property (nonatomic, copy, nullable) NSString *languageCode;

/**
 * @brief Provider response sequence
 * @chinese Provider 响应包序号
 */
@property (nonatomic, assign) NSInteger sequence;
/**
 * @brief Provider request identifier
 * @chinese Provider 请求标识
 */
@property (nonatomic, copy, nullable) NSString *requestId;
/**
 * @brief Speaker diarization segments carried by this response
 * @chinese 当前响应携带的说话人分离片段
 */
@property (nonatomic, copy, nullable) NSArray<TSAIAudioRecordSpeakerSegment *> *speakerSegments;

/**
 * @brief Session event type
 * @chinese 会话事件类型
 */
@property (nonatomic, assign) NSInteger eventType;
/**
 * @brief Event timestamp
 * @chinese 事件发生时间
 */
@property (nonatomic, strong, nullable) NSDate *timestamp;
/**
 * @brief Seconds since session start
 * @chinese 相对会话开始的秒数
 */
@property (nonatomic, assign) NSTimeInterval timeSinceSessionStart;
/**
 * @brief Event evidence
 * @chinese 事件证据
 */
@property (nonatomic, copy, nullable) NSString *evidence;
/**
 * @brief Event details
 * @chinese 事件详情
 */
@property (nonatomic, copy, nullable) NSString *details;

/**
 * @brief Runtime session error
 * @chinese 会话运行期错误
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 * @brief Final transcripts
 * @chinese 最终转写文本
 */
@property (nonatomic, copy, nullable) NSArray<NSString *> *transcripts;
/**
 * @brief Final session events
 * @chinese 最终会话事件
 */
@property (nonatomic, copy, nullable) NSArray<TSAIAudioRecordSessionResult *> *sessionEvents;
/**
 * @brief Full raw audio file path
 * @chinese 原始音频完整路径
 */
@property (nonatomic, copy, nullable) NSString *rawAudioFilePath;
/**
 * @brief Whether interruption stopped the session
 * @chinese 会话是否因中断停止
 */
@property (nonatomic, assign) BOOL isStoppedByInterruption;
/**
 * @brief Whether this was an offline recording
 * @chinese 是否离线录音
 */
@property (nonatomic, assign) BOOL isOfflineRecording;
/**
 * @brief Whether network disconnected during session
 * @chinese 会话期间是否发生网络断连
 */
@property (nonatomic, assign) BOOL hadNetworkDisconnection;

@end

/**
 * @brief AI audio recording session result callback
 * @chinese AI 录音会话结果回调
 *
 * @param result
 * EN: A vendor-neutral transcript, event, error, or final session result
 * CN: 厂商无关的转写、事件、错误或会话最终结果
 */
typedef void(^TSAIAudioRecordSessionResultHandler)(TSAIAudioRecordSessionResult *result);

NS_ASSUME_NONNULL_END
