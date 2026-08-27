//
//  TSAIBudsSpeakerDiarizationMapper+Private.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/5.
//

#import <Foundation/Foundation.h>

@class AIBudsSpeakerSegment;
@class TSAIAudioRecordSpeakerSegment;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal mapper for AIBuds speaker diarization results
 * @chinese AIBuds 说话人分离结果内部映射器
 */
@interface TSAIBudsSpeakerDiarizationMapper : NSObject

/**
 * @brief Convert AIBuds speaker segments to vendor-neutral models
 * @chinese 将 AIBuds 说话人片段转换为厂商无关模型
 *
 * @param speakerSegments
 * EN: AIBuds speaker segments; nil is treated as an empty array
 * CN: AIBuds 说话人片段，nil 按空数组处理
 *
 * @return
 * EN: Converted vendor-neutral speaker segments
 * CN: 转换后的厂商无关说话人片段
 */
+ (NSArray<TSAIAudioRecordSpeakerSegment *> *)speakerSegmentsFromAIBudsSegments:
    (nullable NSArray<AIBudsSpeakerSegment *> *)speakerSegments;

@end

NS_ASSUME_NONNULL_END
