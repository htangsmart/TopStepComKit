#import "TSAIVoiceTranslationInterface.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * @brief Internal phone translation capability
 * @chinese 内部手机翻译能力
 */
@protocol TSAIVoiceTranslationProvider <TSAIVoiceTranslationInterface>
/**
 * @brief Cancel all operations owned by this capability
 * @chinese 取消当前能力持有的全部操作
 */
- (void)cancelAllTasks;
@end
NS_ASSUME_NONNULL_END
