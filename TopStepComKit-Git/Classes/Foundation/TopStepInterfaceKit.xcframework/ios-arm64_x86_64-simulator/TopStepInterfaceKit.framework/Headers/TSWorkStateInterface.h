#import "TSKitBaseInterface.h"
#import "TSWorkStateSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Work-state observation delivered on the main queue.
 * @chinese 在主队列交付的工作状态观测。
 * @param snapshot
 * EN: Latest snapshot, including unknown/disconnected observations.
 * CN: 最新快照，也包括未知或断开的状态。
 */
typedef void(^TSWorkStateChangedBlock)(TSWorkStateSnapshot *snapshot);

/**
 * @brief Work-state read result delivered exactly once on the main queue.
 * @chinese 在主队列恰好回调一次的状态读取结果。
 * @param snapshot
 * EN: Available snapshot; may be cached or nil on error.
 * CN: 可用快照，可能来自缓存；错误时可为 nil。
 * @param error
 * EN: Read or refresh error.
 * CN: 读取或刷新错误。
 */
typedef void(^TSWorkStateResultBlock)(TSWorkStateSnapshot * _Nullable snapshot, NSError * _Nullable error);

/**
 * @brief Read and observe full device work state independently of AI sessions.
 * @chinese 独立于 AI 会话读取和监听完整设备工作状态。
 */
@protocol TSWorkStateInterface <TSKitBaseInterface>
/**
 * @brief Read the latest observation or explicitly identified SDK cache.
 * @chinese 读取最近观测或明确标记的 SDK 缓存，不发送设备查询。
 * @param completion
 * EN: Main-queue result, exactly once.
 * CN: 主队列结果，恰好一次。
 */
- (void)getCurrentWorkState:(TSWorkStateResultBlock)completion;
/**
 * @brief Whether a public device query is available.
 * @chinese 是否存在公开的真实设备查询能力。
 * @return
 * EN: YES only when refresh can send a real device query.
 * CN: 仅能真正向设备查询时返回 YES。
 */
- (BOOL)isSupportWorkStateRefresh;
/**
 * @brief Query the device, or return an explicit unsupported error.
 * @chinese 向设备查询；底层无公开能力时明确返回不支持错误。
 * @param completion
 * EN: Main-queue result; cache must not be reported as a successful refresh.
 * CN: 主队列结果；禁止用缓存冒充刷新成功。
 */
- (void)refreshWorkState:(TSWorkStateResultBlock)completion;
/**
 * @brief Add an observer and replay the current snapshot.
 * @chinese 添加独立观察者并重放当前快照。
 * @param handler
 * EN: Main-queue callback. Multiple observers do not replace each other.
 * CN: 主队列回调；多个观察者互不覆盖。
 * @return
 * EN: Cancellation identifier. Retain until removeWorkStateObserver is called.
 * CN: 取消标识，保留到调用 removeWorkStateObserver。
 */
- (NSUUID *)observeWorkState:(TSWorkStateChangedBlock)handler;
/**
 * @brief Remove a single observer.
 * @chinese 移除单个观察者，不改变设备状态。
 * @param identifier
 * EN: Identifier returned by observeWorkState.
 * CN: observeWorkState 返回的标识。
 */
- (void)removeWorkStateObserver:(NSUUID *)identifier;
@end

NS_ASSUME_NONNULL_END
