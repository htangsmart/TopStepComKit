#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 每个公开 task 独立持有，所有调用均限定在 chatQueue；只识别已成功恢复的单句错误。
@interface TSAIBudsChatErrorRecovery : NSObject

- (void)recordError:(NSError *)error
       recoverable:(BOOL)recoverable
    nextRoundIndex:(NSInteger)nextRoundIndex;
- (void)beginSpeechWithNextRoundIndex:(NSInteger)nextRoundIndex;
/// 停止、断连或其他终止事件后，本 task 永不再尝试恢复。
- (void)invalidate;
/// 返回可解除的原错误；缺少请求、轮次或定稿证据时返回 nil。
- (nullable NSError *)observeQuestionIdentifier:(NSString *)questionIdentifier
                            requestIdentifier:(nullable NSString *)requestIdentifier
                                     sequence:(NSInteger)sequence
                                   roundIndex:(NSInteger)roundIndex
                                questionFinal:(BOOL)questionFinal
                                  answerFinal:(BOOL)answerFinal;

@end

NS_ASSUME_NONNULL_END
