//
//  TSAIBudsSpeechProvider+Private.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import "TSAIBudsSpeechProvider.h"

@class TSAIBudsSessionStore;
@class TSAIBudsManager;
@class TSAIBudsPCMRecognitionTask;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TSAIBudsSpeechErrorDomain;

@interface TSAIBudsSpeechProvider ()

/** @brief Current TTS task identifier
 * @chinese 当前 TTS 任务标识 */
@property (nonatomic, copy, nullable) NSString *currentTTSTaskId;
/** @brief Current TTS completion callback
 * @chinese 当前 TTS 完成回调 */
@property (nonatomic, copy, nullable) TSAITTSCompletionBlock currentTTSCompletionBlock;
/** @brief Whether current TTS is logically cancelled
 * @chinese 当前 TTS 是否已请求逻辑取消 */
@property (nonatomic, assign) BOOL currentTTSCancellationRequested;
/** @brief Whether current TTS uses streaming synthesis @chinese 当前 TTS 是否使用流式合成 */
@property (nonatomic, assign) BOOL currentTTSIsStreaming;
/** @brief Current streaming TTS chunk callback @chinese 当前流式 TTS 分片回调 */
@property (nonatomic, copy, nullable) TSAITTSStreamChunkBlock currentTTSStreamChunkBlock;
/** @brief Current streaming TTS terminal callback @chinese 当前流式 TTS 终态回调 */
@property (nonatomic, copy, nullable) TSAITTSStreamCompletionBlock currentTTSStreamCompletionBlock;
/** @brief Next streaming TTS sequence @chinese 下一个流式 TTS 分片序号 */
@property (nonatomic, assign) NSUInteger currentTTSStreamSequenceIndex;
/** @brief Whether current streaming TTS emitted audio @chinese 当前流式 TTS 是否已输出音频 */
@property (nonatomic, assign) BOOL currentTTSStreamDidEmitAudio;

/** @brief Current file ASR task identifier
 * @chinese 当前文件 ASR 任务标识 */
@property (nonatomic, copy, nullable) NSString *currentASRFileTaskId;
/** @brief Current file ASR partial callback
 * @chinese 当前文件 ASR 中间结果回调 */
@property (nonatomic, copy, nullable) TSAIASRPartialBlock currentASRFilePartialBlock;
/** @brief Current file ASR completion callback
 * @chinese 当前文件 ASR 完成回调 */
@property (nonatomic, copy, nullable) TSAIASRCompletionBlock currentASRFileCompletionBlock;
/** @brief Current cumulative file ASR text
 * @chinese 当前文件 ASR 累积文本 */
@property (nonatomic, copy) NSString *currentASRFileCumulativeText;
/** @brief Current file ASR sentence number
 * @chinese 当前文件 ASR 句子序号 */
@property (nonatomic, assign) NSInteger currentASRFileSentenceNo;
/** @brief Current file ASR fragment number
 * @chinese 当前文件 ASR 分片序号 */
@property (nonatomic, assign) NSInteger currentASRFileFragmentNo;
/** @brief Whether the previous file ASR sentence was final
 * @chinese 上一个文件 ASR 句子是否已稳定 */
@property (nonatomic, assign) BOOL currentASRFileLastSentenceFinal;
/** @brief Whether current file ASR is logically cancelled
 * @chinese 当前文件 ASR 是否已请求逻辑取消 */
@property (nonatomic, assign) BOOL currentASRFileCancellationRequested;

/** @brief Current device-microphone ASR task identifier
 * @chinese 当前设备麦克风 ASR 任务标识 */
@property (nonatomic, copy, nullable) NSString *currentASRDeviceMicTaskId;
/** @brief Current device-microphone ASR partial callback
 * @chinese 当前设备麦克风 ASR 中间结果回调 */
@property (nonatomic, copy, nullable) TSAIASRPartialBlock currentASRDeviceMicPartialBlock;
/** @brief Current device-microphone ASR completion callback
 * @chinese 当前设备麦克风 ASR 完成回调 */
@property (nonatomic, copy, nullable) TSAIASRDeviceMicCompletionBlock currentASRDeviceMicCompletionBlock;
/** @brief Current device-microphone ASR configuration
 * @chinese 当前设备麦克风 ASR 配置 */
@property (nonatomic, strong, nullable) TSAIASRDeviceMicConfig *currentASRDeviceMicConfig;
/** @brief Finalized device-microphone ASR text
 * @chinese 已封板的设备麦克风 ASR 文本 */
@property (nonatomic, copy) NSString *currentASRDeviceMicFinalizedText;
/** @brief Last device-microphone ASR question identifier
 * @chinese 上一个设备麦克风 ASR 问句标识 */
@property (nonatomic, copy, nullable) NSString *currentASRDeviceMicLastQuestionId;
/** @brief Current device-microphone ASR sentence number
 * @chinese 当前设备麦克风 ASR 句子序号 */
@property (nonatomic, assign) NSInteger currentASRDeviceMicSentenceNo;
/** @brief Current device-microphone ASR fragment number
 * @chinese 当前设备麦克风 ASR 分片序号 */
@property (nonatomic, assign) NSInteger currentASRDeviceMicFragmentNo;
/** @brief Current cumulative device-microphone ASR text
 * @chinese 当前设备麦克风 ASR 累积文本 */
@property (nonatomic, copy) NSString *currentASRDeviceMicCumulativeText;
/** @brief Current device-microphone ASR start time
 * @chinese 当前设备麦克风 ASR 开始时间 */
@property (nonatomic, copy, nullable) NSDate *currentASRDeviceMicStartTime;
/** @brief Current device-microphone ASR pending error
 * @chinese 当前设备麦克风 ASR 待处理错误 */
@property (nonatomic, strong, nullable) NSError *currentASRDeviceMicPendingError;
/** @brief Device-microphone recognition state callback
 * @chinese 设备麦克风识别状态回调 */
@property (nonatomic, copy, nullable) TSAIDeviceMicRecognitionStateBlock deviceMicRecognitionStateBlock;
/** @brief Context-owned session store
 * @chinese Context 持有的会话存储 */
@property (nonatomic, strong) TSAIBudsSessionStore *sessionStore;
/** @brief Context-owned AIBuds manager
 * @chinese Context 持有的 AIBuds 管理器 */
@property (nonatomic, strong) TSAIBudsManager *manager;
/** @brief Shared one-shot ASR task slot
 * @chinese 文件与 PCM 共用的一次性 ASR 任务槽 */
@property (nonatomic, copy, nullable) NSString *currentOneShotASRTaskId;
/** @brief Current PCM recognition task
 * @chinese 当前 PCM 识别任务 */
@property (nonatomic, strong, nullable) TSAIBudsPCMRecognitionTask *currentPCMRecognitionTask;
/** @brief Current PCM recognition task identifier
 * @chinese 当前 PCM 识别任务标识 */
@property (atomic, copy, nullable) NSString *currentASRPCMTaskId;
/** @brief Serialized PCM recognition state
 * @chinese PCM 识别状态串行队列 */
@property (nonatomic, strong) dispatch_queue_t pcmStateQueue;

/** @brief Acquire the shared one-shot ASR slot @chinese 获取一次性 ASR 共享任务槽 */
- (BOOL)tsai_acquireOneShotASRTaskId:(NSString *)taskId;
/** @brief Release the shared one-shot ASR slot @chinese 释放一次性 ASR 共享任务槽 */
- (void)tsai_releaseOneShotASRTaskId:(NSString *)taskId;

@end

@interface TSAIBudsSpeechProvider (PCMASR)

/**
 * @brief Execute one-shot PCM ASR
 * @chinese 执行一次性 PCM 识别
 */
- (NSString *)tsai_recognizeSpeechWithPCMData:(NSData *)pcmData
                                       config:(TSAIASRPCMConfig *)config
                              onPartialResult:(nullable TSAIASRPartialBlock)onPartialResult
                                   completion:(nullable TSAIASRCompletionBlock)completion;

/** @brief Cancel one-shot PCM ASR @chinese 取消一次性 PCM 识别 */
- (void)tsai_cancelPCMRecognitionWithTaskId:(NSString *)taskId;

@end

@interface TSAIBudsSpeechProvider (TTS)

/** @brief Return whether streaming TTS is supported @chinese 返回是否支持流式 TTS */
- (BOOL)tsai_isStreamingSynthesisSupportedForConfig:(TSAITTSConfig *)config;

/**
 * @brief Execute streaming TTS synthesis
 * @chinese 执行流式 TTS 合成
 * @param text EN: Source text. CN: 源文本。
 * @param config EN: TTS configuration. CN: TTS 配置。
 * @param onAudioChunk EN: Ordered chunk callback. CN: 有序分片回调。
 * @param completion EN: Terminal callback. CN: 终态回调。
 * @return EN: Client task identifier. CN: 客户端任务标识。
 */
- (NSString *)tsai_synthesizeSpeechStreamWithText:(NSString *)text
                                           config:(TSAITTSConfig *)config
                                     onAudioChunk:(nullable TSAITTSStreamChunkBlock)onAudioChunk
                                       completion:(nullable TSAITTSStreamCompletionBlock)completion;

/**
 * @brief Execute TTS synthesis
 * @chinese 执行 TTS 合成
 * @param text EN: Source text / CN: 源文本
 * @param config EN: TTS configuration / CN: TTS 配置
 * @param completion EN: Completion callback / CN: 完成回调
 * @return EN: Client task identifier / CN: 客户端任务标识
 */
- (NSString *)tsai_synthesizeSpeechWithText:(NSString *)text
                                     config:(TSAITTSConfig *)config
                                 completion:(nullable TSAITTSCompletionBlock)completion;

/**
 * @brief Cancel TTS synthesis
 * @chinese 取消 TTS 合成
 * @param taskId EN: Client task identifier / CN: 客户端任务标识
 */
- (void)tsai_cancelSynthesisWithTaskId:(NSString *)taskId;

@end

@interface TSAIBudsSpeechProvider (FileASR)

/**
 * @brief Execute file ASR
 * @chinese 执行文件 ASR
 * @param audioFileURL EN: Local audio URL / CN: 本地音频地址
 * @param config EN: File ASR configuration / CN: 文件 ASR 配置
 * @param onPartialResult EN: Partial callback / CN: 中间结果回调
 * @param completion EN: Completion callback / CN: 完成回调
 * @return EN: Client task identifier / CN: 客户端任务标识
 */
- (NSString *)tsai_recognizeSpeechWithFileURL:(NSURL *)audioFileURL
                                       config:(TSAIASRFileConfig *)config
                              onPartialResult:(nullable TSAIASRPartialBlock)onPartialResult
                                   completion:(nullable TSAIASRCompletionBlock)completion;

/**
 * @brief Cancel the current file ASR task
 * @chinese 取消当前文件 ASR 任务
 * @param taskId EN: Client task identifier / CN: 客户端任务标识
 */
- (void)tsai_cancelFileRecognitionWithTaskId:(NSString *)taskId;

@end

@interface TSAIBudsSpeechProvider (DeviceMicASR)

/**
 * @brief Execute device-microphone ASR
 * @chinese 执行设备麦克风 ASR
 * @param config EN: Device-microphone configuration / CN: 设备麦克风配置
 * @param onPartialResult EN: Partial callback / CN: 中间结果回调
 * @param completion EN: Completion callback / CN: 完成回调
 * @return EN: Client task identifier / CN: 客户端任务标识
 */
- (NSString *)tsai_recognizeSpeechWithDeviceMicConfig:(TSAIASRDeviceMicConfig *)config
                                      onPartialResult:(nullable TSAIASRPartialBlock)onPartialResult
                                           completion:(nullable TSAIASRDeviceMicCompletionBlock)completion;

/**
 * @brief Stop device-microphone ASR
 * @chinese 停止设备麦克风 ASR
 * @param taskId EN: Client task identifier / CN: 客户端任务标识
 */
- (void)tsai_stopDeviceMicRecognitionWithTaskId:(NSString *)taskId;

/**
 * @brief Cancel device-microphone ASR
 * @chinese 取消设备麦克风 ASR
 * @param taskId EN: Client task identifier / CN: 客户端任务标识
 */
- (void)tsai_cancelDeviceMicRecognitionWithTaskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
