#import "TSAIHistoryInterface.h"
NS_ASSUME_NONNULL_BEGIN
/**
 * @brief Internal history capability
 * @chinese 内部历史记录能力
 */
@protocol TSAIHistoryProvider <TSAIHistoryInterface>
/**
 * @brief Cancel playback owned by this capability
 * @chinese 取消当前能力持有的回放
 */
- (void)cancelAllTasks;
@end
NS_ASSUME_NONNULL_END
