//
//  TSAIAudioRecordSpeakerSegment.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Vendor-neutral speaker diarization segment
 * @chinese 厂商无关的说话人分离片段
 */
@interface TSAIAudioRecordSpeakerSegment : NSObject

/**
 * @brief Speaker identifier
 * @chinese 说话人标识
 */
@property (nonatomic, copy, nullable) NSString *speakerId;

/**
 * @brief Segment start time in milliseconds
 * @chinese 片段开始时间，单位毫秒
 */
@property (nonatomic, assign) NSInteger startTimeMilliseconds;

/**
 * @brief Segment end time in milliseconds
 * @chinese 片段结束时间，单位毫秒
 */
@property (nonatomic, assign) NSInteger endTimeMilliseconds;

/**
 * @brief Associated transcript sentence sequence
 * @chinese 关联的转写句序号
 */
@property (nonatomic, assign) NSInteger associatedTranscriptSequence;

/**
 * @brief Transcript text for this speaker segment
 * @chinese 当前说话人片段的转写文本
 */
@property (nonatomic, copy, nullable) NSString *text;

@end

NS_ASSUME_NONNULL_END
