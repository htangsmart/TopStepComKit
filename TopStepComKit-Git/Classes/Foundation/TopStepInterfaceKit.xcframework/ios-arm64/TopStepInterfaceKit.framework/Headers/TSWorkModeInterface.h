#import "TSKitBaseInterface.h"
#import "TSWorkModeDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Read, set and observe device audio work mode independently of AI sessions.
 * @chinese 独立于 AI 会话读取、设置和监听设备音频工作模式。
 */
@protocol TSWorkModeInterface <TSKitBaseInterface>

/**
 * @brief Read the latest device observation or SDK cache without a device query.
 * @chinese 读取最近设备观测或 SDK 缓存，不发送设备查询命令。
 *
 * @param completion
 * EN: Delivered once on the main queue; Unknown with nil error means not yet known.
 * CN: 在主队列回调一次；Unknown 且无错误表示模式尚未获知。
 */
- (void)getWorkMode:(nullable TSWorkModeResultBlock)completion NS_SWIFT_NAME(getWorkMode(completion:));

/**
 * @brief Set normal or game mode for the current ready connection.
 * @chinese 为当前就绪连接设置普通或游戏模式。
 *
 * @param mode
 * EN: Normal or Game; Unknown and out-of-range values are invalid.
 * CN: Normal 或 Game；Unknown 和越界值无效。
 *
 * @param completion
 * EN: Delivered once on the main queue, within ten seconds; success is not a device event.
 * CN: 十秒内在主队列回调一次；设置成功不等同于设备变化事件。
 */
- (void)setWorkMode:(TSWorkMode)mode completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Replace the single work-mode observer.
 * @chinese 替换唯一的工作模式监听者。
 *
 * @param handler
 * EN: Main-queue device observations and connection invalidations; nil removes the observer.
 * CN: 主队列交付设备观测及连接失效；nil 注销监听。
 */
- (void)registerWorkModeDidChanged:(nullable TSWorkModeResultBlock)handler;

@end

NS_ASSUME_NONNULL_END
