//
//  TSAIQATextRound.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Lifecycle state of one text question-answer task
 * @chinese 单次文字问答任务的生命周期状态
 */
typedef NS_ENUM(NSInteger, TSAIQATextRoundState) {
    /// 已提交，等待 onStartAnswering
    TSAIQATextRoundStatePending = 0,
    /// 语音轮次：正在采集 / 识别问题，尚未提交 askQuestion
    TSAIQATextRoundStateRecognizing = 10,
    /// 服务开始回答，流式更新中
    TSAIQATextRoundStateAnswering,
    /// completion(result) 成功终态
    TSAIQATextRoundStateCompleted,
    /// completion(error) 失败终态
    TSAIQATextRoundStateFailed,
    /// 本地逻辑取消终态
    TSAIQATextRoundStateCancelled,
};

/**
 * @brief View model of one text question and its streaming answer
 * @chinese 一次文字提问及其流式答案的视图模型
 *
 * @discussion
 * [EN]: Mirrors the callbacks of `askQuestion:config:onStartAnswering:onPartialResult:completion:`.
 * [CN]: 与 `askQuestion:config:onStartAnswering:onPartialResult:completion:` 的回调一一对应。
 */
/**
 * @brief Where the question came from
 * @chinese 问题的来源（拾音方式）
 */
typedef NS_ENUM(NSInteger, TSAIQARoundSource) {
    /// 文字输入
    TSAIQARoundSourceText = 0,
    /// 手机麦克风
    TSAIQARoundSourcePhoneMic,
    /// 蓝牙耳机（HFP）麦克风
    TSAIQARoundSourceHeadset,
};

@interface TSAIQATextRound : NSObject

/**
 * @brief Question text; for voice rounds it is the cumulative recognized text
 * @chinese 问题文本；语音轮次为累计识别文本
 */
@property (nonatomic, copy) NSString *question;

/**
 * @brief Where the question came from
 * @chinese 问题来源
 */
@property (nonatomic, assign) TSAIQARoundSource source;

/**
 * @brief Recorded voice duration in seconds for voice rounds
 * @chinese 语音轮次的录音时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval voiceDuration;

/**
 * @brief TTS playback state text shown under the answer, if any
 * @chinese 答案下方显示的播报状态文本，可为空
 */
@property (nonatomic, copy, nullable) NSString *playbackText;

/**
 * @brief Client task identifier returned by askQuestion
 * @chinese askQuestion 返回的客户端任务标识
 *
 * @note
 * [EN]: Assigned right after `askQuestion` returns.
 * [CN]: 在 `askQuestion` 返回后立即赋值。
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Opaque question identifier assigned by the AI service
 * @chinese AI 服务分配的问题标识
 */
@property (nonatomic, copy, nullable) NSString *questionId;

/**
 * @brief Cumulative answer text
 * @chinese 累计答案文本
 */
@property (nonatomic, copy) NSString *answer;

/**
 * @brief Text appended by the latest partial update
 * @chinese 最近一次流式更新新增的文本
 */
@property (nonatomic, copy, nullable) NSString *deltaText;

/**
 * @brief Current lifecycle state
 * @chinese 当前生命周期状态
 */
@property (nonatomic, assign) TSAIQATextRoundState state;

/**
 * @brief Terminal error, when failed or cancelled
 * @chinese 失败或取消时的终态错误
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 * @brief Number of partial updates received
 * @chinese 已收到的流式更新次数
 */
@property (nonatomic, assign) NSUInteger partialCount;

/**
 * @brief Submission time
 * @chinese 提交时间
 */
@property (nonatomic, strong, readonly) NSDate *startedAt;

/**
 * @brief Seconds from submission to the terminal callback; 0 while running
 * @chinese 从提交到终态回调的秒数；进行中为 0
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * @brief Create a pending round
 * @chinese 创建一个等待回答的轮次
 *
 * @param question
 * EN: Question text
 * CN: 问题文本
 *
 * @param taskId
 * EN: Client task identifier
 * CN: 客户端任务标识
 *
 * @return
 * EN: A round in the pending state
 * CN: 处于等待状态的轮次
 */
+ (instancetype)roundWithQuestion:(NSString *)question taskId:(NSString *)taskId;

/**
 * @brief Create a voice round that is still capturing or recognizing
 * @chinese 创建仍在拾音 / 识别中的语音轮次
 *
 * @param source
 * EN: Microphone the question comes from
 * CN: 问题来自哪个麦克风
 *
 * @return
 * EN: A round in the Recognizing state with an empty question
 * CN: 处于 Recognizing 状态、问题为空的轮次
 */
+ (instancetype)voiceRoundWithSource:(TSAIQARoundSource)source;

/**
 * @brief Whether the round reached a terminal state
 * @chinese 轮次是否已到达终态
 *
 * @return
 * EN: YES for completed, failed or cancelled
 * CN: 已完成、失败或已取消时返回 YES
 */
- (BOOL)isTerminal;

/**
 * @brief Mark the terminal state and record the duration
 * @chinese 标记终态并记录耗时
 *
 * @param state
 * EN: Terminal state
 * CN: 终态
 *
 * @param error
 * EN: Terminal error, if any
 * CN: 终态错误，可为空
 */
- (void)finishWithState:(TSAIQATextRoundState)state error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
