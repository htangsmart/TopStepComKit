#import "TSAIMeetingMinutesInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Provider contract for meeting file processing
 * @chinese 会议文件处理的 Provider 协议
 *
 * @discussion
 * [EN]: Each instance belongs to one Context. cancelAllMeetingMinutes only cancels that instance's tasks.
 * [CN]: 每个实例仅属于一个 Context；cancelAllMeetingMinutes 仅取消该实例任务，不调用 SDK 全局取消。
 */
@protocol TSAIMeetingMinutesProvider <TSAIMeetingMinutesInterface>
@end

NS_ASSUME_NONNULL_END
