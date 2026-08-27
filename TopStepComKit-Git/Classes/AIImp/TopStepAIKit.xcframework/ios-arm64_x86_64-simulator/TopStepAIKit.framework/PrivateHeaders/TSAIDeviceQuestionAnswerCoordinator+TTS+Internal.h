//
//  TSAIDeviceQuestionAnswerCoordinator+TTS+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/23.
//

#import "TSAIDeviceQuestionAnswerCoordinator+Internal.h"

NS_ASSUME_NONNULL_BEGIN

/** @brief Private TTS coordination accessors @chinese TTS 编排私有访问接口 */
@interface TSAIDeviceQuestionAnswerCoordinator (TTSInternal)

@property (nonatomic, strong) id<TSAISpeechProvider> speechProvider;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, assign) NSUInteger generation;
@property (nonatomic, assign) BOOL isSceneActive;
@property (nonatomic, copy, nullable) NSString *ttsTaskId;
@property (nonatomic, copy, nullable) NSString *playbackTaskId;
@property (nonatomic, assign) BOOL isTTSStreaming;
@property (nonatomic, assign) BOOL hasTTSStreamAudio;
@property (nonatomic, assign) BOOL didAttemptTTSFallback;
@property (nonatomic, assign) NSUInteger nextTTSStreamSequenceIndex;
@property (nonatomic, assign) NSUInteger ttsStreamWatchdogToken;
@property (nonatomic, copy, nullable) NSString *ttsFallbackText;

/** 使用流式优先策略合成并播放最终答案 */
- (void)startTTSWithText:(NSString *)text generation:(NSUInteger)generation;
/** 正常结束当前轮次 */
- (void)finishCurrentRoundOnSessionQueue;
/** 在主线程停止 App 播放 */
- (void)stopPlaybackTaskId:(NSString *)taskId;
/** 将空结果任务标识回退到当前任务 */
- (nullable NSString *)resolvedTaskIdFromResultTaskId:(nullable NSString *)resultTaskId
                                        currentTaskId:(nullable NSString *)currentTaskId;
/** 校验任务标识与轮次代次 */
- (BOOL)acceptsTaskId:(nullable NSString *)taskId
        currentTaskId:(nullable NSString *)currentTaskId
           generation:(NSUInteger)generation;

@end

NS_ASSUME_NONNULL_END
