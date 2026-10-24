//
//  TSGamePushInterface.h
//  TopStepInterfaceKit
//

#import "TSKitBaseInterface.h"
#import "TSGamePushDefines.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class TSGamePushRequest;

/**
 * @brief Public game query and installation interface.
 * @chinese 公版游戏查询与安装接口。
 *
 * @discussion
 * [EN]: All callbacks are delivered asynchronously on the main thread. Query
 *       failures return nil and an error; a successful empty list is nonnil.
 *       isSupport requires an active provider session, an authenticated device
 *       and an implemented installation path, not just a raw capability bit.
 *       Queries are bound to the device and connection generation at invocation.
 * [CN]: 所有回调均异步交付至主线程。查询失败返回 nil 和错误，成功空列表非 nil。
 *       isSupport 同时检查有效 Provider 会话、设备认证及已实现安装路径，
 *       不能只依据设备原始能力位。查询绑定调用时的设备及连接代次。
 */
@protocol TSGamePushInterface <TSKitBaseInterface>

/**
 * @brief Check whether this supported device exposes fixed game slots.
 * @chinese 检查当前支持设备是否提供固定游戏槽位。
 *
 * @return
 * EN: YES only when fixed slots are usable.
 * CN: 固定槽位可用时返回 YES。
 */
- (BOOL)isSupportGameSlots;

/**
 * @brief Query current game storage.
 * @chinese 查询当前游戏空间。
 *
 * @param completion
 * EN: One storage result or error.
 * CN: 一次空间结果或错误。
 *
 * @discussion
 * [EN]: On slot-based platforms, total/available describe total slot capacity
 *       and empty slot capacity, not actual game file usage. The aggregate is
 *       for display and must not replace the capacity check for a single target slot.
 * [CN]: 槽位平台 total/available 表示槽位总容量及空槽容量，不表示文件实际已用空间；
 *       汇总仅供展示，不能替代单个目标槽位的容量校验。
 */
- (void)fetchGameStorage:(TSGameStorageCompletionBlock)completion;

/**
 * @brief Query fixed game slots in device order.
 * @chinese 按设备顺序查询固定游戏槽位。
 *
 * @param completion
 * EN: One ordered slot list or error.
 * CN: 一次有序槽位列表或错误。
 *
 * @discussion
 * [EN]: Platforms without fixed game slots return an unsupported error.
 * [CN]: 非固定游戏槽位平台返回不支持错误。
 */
- (void)fetchGameSlots:(TSGameSlotsCompletionBlock)completion;

/**
 * @brief Query all game types supported by the device.
 * @chinese 查询设备支持的全部游戏类型。
 *
 * @param completion
 * EN: One integer type list or error.
 * CN: 一次整数类型列表或错误。
 *
 * @discussion
 * [EN]: Unnamed identifiers are preserved. Type 0 is a valid game type.
 * [CN]: 保留未命名类型的原始数值，类型 0 是合法游戏类型。
 */
- (void)fetchSupportedGameTypes:(TSGameTypesCompletionBlock)completion;

/**
 * @brief Query installed games with skin and built-in information.
 * @chinese 查询已有游戏及皮肤和内置标记。
 *
 * @param completion
 * EN: One game list or error.
 * CN: 一次游戏列表或错误。
 *
 * @discussion
 * [EN]: The device's entry order and duplicate entries are preserved.
 * [CN]: 保留设备返回的条目顺序及重复项。
 */
- (void)fetchInstalledGames:(TSInstalledGamesCompletionBlock)completion;

/**
 * @brief Push one local game package to a target slot.
 * @chinese 将一个本地游戏包推送至目标槽位。
 *
 * @param request
 * EN: Required local package path and optional target slot; nil selects an empty slot.
 * CN: 必填本地包路径和可选目标槽位；nil 自动选择空槽。
 *
 * @param progress
 * EN: Optional Start/Progress events from 0 to 100.
 * CN: 可选的 Start/Progress 事件，范围为 0–100。
 *
 * @param completion
 * EN: YES and nil after the device acknowledges successful transfer; this does not verify game launch.
 * CN: 设备确认传输完成后返回 YES 和 nil；此结果不表示已验证游戏可运行。
 *
 * @discussion
 * [EN]: One operation may be active, including preparation and transfer.
 *       Another push fails busy without replacing it. Progress
 *       is monotonic, stays below 100 until success, and stops after completion.
 *       Failures, including cancellation, return NO with a game-domain error.
 *       NPK completes on a valid successful END_ACK. Refreshing the game list is
 *       independent and cannot revoke an accepted success.
 *       An unconfirmed result after submission does not mean the device did not
 *       install the game; it must not trigger an automatic retry or imply rollback.
 * [CN]: 准备和传输共占一个操作；后到请求报忙，不覆盖原任务。
 *       进度单调且成功前不达 100，终态后停止。失败及取消均返回 NO 和游戏错误域错误。
 *       NPK 在收到有效成功 END_ACK 后完成；游戏列表刷新独立于推送，不能撤销已接受的成功。
 *       提交后结果未确认不等于设备未安装，调用方不能据此自动重推或认定回滚。
 */
- (void)pushGame:(TSGamePushRequest *)request
        progress:(nullable TSFileTransferProgressBlock)progress
      completion:(TSCompletionBlock)completion;

/**
 * @brief Cancel this interface's current game operation.
 * @chinese 取消此接口当前活动游戏操作。
 *
 * @param completion
 * EN: Result of this cancellation request.
 * CN: 本次取消请求的结果。
 *
 * @discussion
 * [EN]: Cancellation targets the current operation, not a historical request or
 *       a particular caller. YES/nil means the local operation ended, not that
 *       the device rolled back. The original push completes with NO and
 *       eTSErrorUserCancelled. No active operation returns eTSErrorTaskNotStarted.
 *       Once END is sent, cancellation is
 *       refused with eTSErrorPreTaskExecuting and the original operation continues.
 *       Repeated cancellation requests each receive one completion.
 * [CN]: 取消针对当前操作，不按历史请求或调用方定向取消。YES/nil 仅表示本地操作结束，
 *       不代表设备回滚；原推送回调为 NO 及 eTSErrorUserCancelled。
 *       无任务返回 eTSErrorTaskNotStarted；END 已提交后返回
 *       eTSErrorPreTaskExecuting，原任务继续。重复取消请求各回调一次。
 */
- (void)cancelGamePush:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
