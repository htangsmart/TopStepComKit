//
//  TSAIAudioRecordTranscriptView.h
//  TopStepComKit-Git_Example
//

#import <UIKit/UIKit.h>

@class TSAIAudioRecordTranscriptItem;

NS_ASSUME_NONNULL_BEGIN

/// @brief Visual style of the transcript list.
/// @chinese 转写列表的视觉样式。
typedef NS_ENUM(NSInteger, TSAIAudioRecordTranscriptViewStyle) {
    TSAIAudioRecordTranscriptViewStyleLive = 0,
    TSAIAudioRecordTranscriptViewStyleResult,
};

/// @brief Structured speaker transcript list matching the recording prototype.
/// @chinese 与录音原型一致的结构化说话人转写列表。
@interface TSAIAudioRecordTranscriptView : UIScrollView

/// @brief Creates a transcript list using the specified visual style.
/// @chinese 使用指定视觉样式创建转写列表。
/// @param style Visual style. / 视觉样式。
- (instancetype)initWithStyle:(TSAIAudioRecordTranscriptViewStyle)style;

/// @brief Replaces the rendered transcript items.
/// @chinese 替换当前展示的转写内容。
/// @param items Normalized transcript items. / 标准化转写内容。
/// @param emptyText Text shown when the list is empty. / 列表为空时展示的文案。
- (void)updateWithItems:(NSArray<TSAIAudioRecordTranscriptItem *> *)items
              emptyText:(NSString *)emptyText;

@end

NS_ASSUME_NONNULL_END
