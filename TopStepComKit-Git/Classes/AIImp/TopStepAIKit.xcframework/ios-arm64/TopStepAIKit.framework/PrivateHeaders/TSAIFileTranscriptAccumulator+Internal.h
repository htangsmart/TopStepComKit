#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
/// 将厂商句内修订更新为公开接口要求的全文快照；不通过文本去重推测句界。
@interface TSAIFileTranscriptAccumulator : NSObject
@property (nonatomic, readonly, copy) NSString *text;
@property (nonatomic, readonly) NSInteger sentenceNo;
@property (nonatomic, readonly) NSInteger fragmentNo;
- (BOOL)updateText:(NSString *)text transcriptSequence:(nullable NSNumber *)transcriptSequence responseSequence:(NSInteger)responseSequence isFinal:(BOOL)isFinal;
/// 旁路统计：调用者先按 taskId 校验，首个响应及每 30 秒返回摘要。
- (nullable NSDictionary *)observeDiagnosticResponseAtTime:(NSTimeInterval)time hasText:(BOOL)hasText accepted:(BOOL)accepted;
- (void)markDiagnosticCancellationAtTime:(NSTimeInterval)time;
- (nullable NSDictionary *)finishDiagnosticAtTime:(NSTimeInterval)time;
@end
NS_ASSUME_NONNULL_END
