#import <Foundation/Foundation.h>
#import "TSAIAudioRecordSpeakerSegment.h"

NS_ASSUME_NONNULL_BEGIN

/// 文件声纹按时段独立去重，正文为空的控制包也参与聚合。
@interface TSAIFileSpeakerAccumulator : NSObject
- (void)updateSegments:(NSArray<TSAIAudioRecordSpeakerSegment *> *)segments
      responseSequence:(NSInteger)responseSequence;
/// 按音频时间排序的独立快照；新任务必须使用新的聚合器。
@property (nonatomic, readonly) NSArray<TSAIAudioRecordSpeakerSegment *> *segments;
@end

NS_ASSUME_NONNULL_END
