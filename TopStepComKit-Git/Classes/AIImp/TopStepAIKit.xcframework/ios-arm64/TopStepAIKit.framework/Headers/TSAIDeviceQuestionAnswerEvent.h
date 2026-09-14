#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Device question-answer text phase @chinese 设备问答文字阶段 */
typedef NS_ENUM(NSInteger, TSAIDeviceQuestionAnswerPhase) {
    TSAIDeviceQuestionAnswerPhaseQuestion = 0,
    TSAIDeviceQuestionAnswerPhaseAnswer = 1,
    TSAIDeviceQuestionAnswerPhaseCompleted = 2,
    TSAIDeviceQuestionAnswerPhaseFailed = 3,
    TSAIDeviceQuestionAnswerPhaseCancelled = 4,
};

/** @brief Cumulative device question-answer snapshot @chinese 设备问答累计文字快照 */
@interface TSAIDeviceQuestionAnswerEvent : NSObject
/** @brief Public device session identifier @chinese 对外设备会话标识 */
@property (nonatomic, copy) NSString *sessionIdentifier;
/** @brief Globally unique round identifier @chinese 全局唯一轮次标识 */
@property (nonatomic, copy) NSString *roundIdentifier;
/** @brief Increasing sequence within one round @chinese 同轮递增事件序号 */
@property (nonatomic, assign) NSInteger sequence;
/** @brief Cumulative question @chinese 累计问题 */
@property (nonatomic, copy) NSString *question;
/** @brief Cumulative answer @chinese 累计答案 */
@property (nonatomic, copy) NSString *answer;
/** @brief Text phase independent of playback @chinese 独立于播放的文字阶段 */
@property (nonatomic, assign) TSAIDeviceQuestionAnswerPhase phase;
/** @brief Event time in seconds since Unix epoch @chinese 事件产生时间，Unix 秒 */
@property (nonatomic, assign) NSTimeInterval occurredAt;
/** @brief Optional underlying text failure @chinese 可选的文字链路底层错误 */
@property (nonatomic, strong, nullable) NSError *error;
@end

NS_ASSUME_NONNULL_END
