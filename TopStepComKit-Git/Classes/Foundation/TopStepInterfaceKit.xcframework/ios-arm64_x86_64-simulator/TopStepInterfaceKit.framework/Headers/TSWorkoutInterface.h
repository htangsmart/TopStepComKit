//
//  TSWorkoutInterface.h
//  TopStepInterfaceKit
//

#import "TSKitBaseInterface.h"
#import "TSFileTransferDefines.h"
#import "TSWorkoutResourceModel.h"
#import "TSWorkoutSlotModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Workout slot query callback
 * @chinese 运动槽位查询回调
 *
 * @param slots
 * EN: Device workout slots, or nil when the query fails.
 * CN: 设备运动槽位；查询失败时为 nil。
 *
 * @param error
 * EN: Error information when the query fails, otherwise nil.
 * CN: 查询失败时的错误信息，成功时为 nil。
 */
typedef void (^TSWorkoutSlotsCompletionBlock)(NSArray<TSWorkoutSlotModel *> * _Nullable slots,
                                               NSError * _Nullable error);

/**
 * @brief Supported workout type query callback
 * @chinese 设备支持的运动类型查询回调
 *
 * @param workoutTypes
 * EN: Unified workout types supported by the device, or nil when the query fails.
 * CN: 设备支持的统一运动类型；查询失败时为 nil。
 *
 * @param error
 * EN: Error information when the query fails, otherwise nil.
 * CN: 查询失败时的错误信息，成功时为 nil。
 */
typedef void (^TSWorkoutTypesCompletionBlock)(NSArray<NSNumber *> * _Nullable workoutTypes,
                                               NSError * _Nullable error);

/**
 * @brief Workout capability interface
 * @chinese 运动功能接口
 *
 * @discussion
 * EN: Manages workout capabilities on the connected device. The current contract
 *     supports slot queries and local workout installation. Cloud resource
 *     retrieval is outside this interface.
 * CN: 管理当前连接设备的运动能力。本期契约支持槽位查询和本地运动安装。
 *     云端资源获取不属于本接口职责。
 */
@protocol TSWorkoutInterface <TSKitBaseInterface>

/**
 * @brief Fetch workout types supported by the connected device
 * @chinese 获取当前连接设备支持的运动类型
 *
 * @param completion
 * EN: Completion callback. Values use TSSportTypeEnum and the callback is invoked once on the main thread.
 * CN: 完成回调，数值使用 TSSportTypeEnum，并在主线程仅调用一次。
 */
- (void)fetchSupportedWorkoutTypes:(TSWorkoutTypesCompletionBlock)completion;

/**
 * @brief Fetch workout slots from the connected device
 * @chinese 获取当前连接设备的运动槽位
 *
 * @param completion
 * EN: Completion callback. It is invoked once on the main thread.
 * CN: 完成回调，在主线程仅调用一次。
 */
- (void)fetchWorkoutSlots:(TSWorkoutSlotsCompletionBlock)completion;

/**
 * @brief Install a local workout resource into a slot
 * @chinese 将本地运动资源安装到指定槽位
 *
 * @param workout
 * EN: Local workout resource. Its path must point to a readable non-empty file.
 * CN: 本地运动资源，路径必须指向可读且非空的文件。
 *
 * @param slot
 * EN: Replaceable slot returned by the current device.
 * CN: 当前设备返回的可替换槽位。
 *
 * @param progress
 * EN: Optional device-transfer progress callback with a value from 0 to 100.
 * CN: 可选的设备传输进度回调，进度范围为 0 到 100。
 *
 * @param completion
 * EN: Final completion callback. It is invoked once on the main thread.
 * CN: 最终完成回调，在主线程仅调用一次。
 */
- (void)installWorkout:(TSWorkoutResourceModel *)workout
                toSlot:(TSWorkoutSlotModel *)slot
              progress:(nullable TSFileTransferProgressBlock)progress
            completion:(TSCompletionBlock)completion;

/**
 * @brief Cancel the current workout installation
 * @chinese 取消当前运动安装
 *
 * @param completion
 * EN: Completion callback. Canceling with no active task is treated as success.
 * CN: 完成回调；没有活动任务时按幂等成功处理。
 */
- (void)cancelWorkoutInstallation:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
