//
//  TSEpoInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/9.
//

#import "TSKitBaseInterface.h"
#import "TSEpoDefines.h"
#import "TSEpoSource.h"
#import "TSEpoTimeInfo.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief EPO time info callback
 * @chinese EPO 时间信息回调
 *
 * @param info
 * EN: The EPO time info from device, nil if failed
 * CN: 设备返回的 EPO 时间信息，失败时为 nil
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为 nil
 */
typedef void(^TSEpoTimeInfoBlock)(TSEpoTimeInfo * _Nullable info, NSError * _Nullable error);

/**
 * @brief EPO(GNSS ephemeris) management interface
 * @chinese EPO(GNSS 星历) 管理接口
 *
 * @discussion
 * [EN]: EPO(Extended Prediction Orbit) is predicted satellite orbit data used to speed up the device
 *       GPS cold-start positioning. This interface defines all EPO operations:
 *       1. Capability check
 *       2. Update device EPO(from various sources)
 *       3. Cancel an in-progress update
 *       4. Query / clear device EPO info (debugging)
 *
 *       Design note: the ephemeris source is modeled by [TSEpoSource]. builtinServer/customServer
 *       hide all protocol details; fileURLs/binFile give full control but require the App to follow
 *       the device EPO format.
 *
 * [CN]: EPO(扩展预测轨道) 是预测的卫星轨道数据，用于加速设备 GPS 冷启动定位。
 *       该接口定义了 EPO 的所有操作：
 *       1. 能力检查
 *       2. 更新设备 EPO(支持多种来源)
 *       3. 取消进行中的更新
 *       4. 查询 / 清除设备 EPO 信息(调试用)
 *
 *       设计说明：星历来源由 [TSEpoSource] 建模。builtinServer/customServer 隐藏全部协议细节；
 *       fileURLs/binFile 提供完全控制权，但要求 App 遵循设备 EPO 格式。
 */
@protocol TSEpoInterface <TSKitBaseInterface>

#pragma mark - Capability Check / 能力检查

/**
 * @brief Check if the device supports EPO
 * @chinese 检查设备是否支持 EPO
 *
 * @return
 * [EN]: YES if the device supports EPO(GNSS ephemeris) update, NO otherwise
 * [CN]: 如果设备支持 EPO(GNSS 星历) 更新返回 YES，否则返回 NO
 *
 * @discussion
 * [EN]: Call this before any other method. If NO, other methods return a not-support error.
 * [CN]: 在调用其他任何方法前先检查。若为 NO，其他方法会返回不支持错误。
 */
- (BOOL)isSupportEpo;

#pragma mark - EPO Update / EPO 更新

/**
 * @brief Update the device EPO ephemeris
 * @chinese 更新设备 EPO 星历
 *
 * @param source
 * EN: The ephemeris source. Pass nil to use the built-in server(equivalent to [TSEpoSource builtinServer]).
 * CN: 星历来源。传 nil 等价于使用内置服务器([TSEpoSource builtinServer])。
 *
 * @param forceUpdate
 * EN: NO: if the device was already updated today, the failure callback returns an error with code
 *        eTSErrorNotNecessary. IMPORTANT: this is NOT a real failure — the device EPO is already
 *        fresh, so callers MUST treat eTSErrorNotNecessary as success/already-latest and not show an
 *        error to the user.
 *     YES: force update regardless. Use NO for automatic/timed triggers, YES for a user-tapped action.
 *     Note: the not-necessary check does not apply to the binFile source.
 * CN: NO：若设备当天已更新，failure 回调返回错误码 eTSErrorNotNecessary。重要：这不是真正的失败——
 *     设备星历已是最新，接入方必须把 eTSErrorNotNecessary 当作成功/已是最新处理，不要向用户报错。
 *     YES：无条件强制更新。自动/定时触发用 NO，用户手动点击用 YES。
 *     注意：binFile 来源没有"必要性"概念，该检查不适用。
 *
 * @param progress
 * EN: Progress callback, push progress 0-100(download & merge happen first, landing on device = success)
 * CN: 进度回调，推送进度 0-100(下载与合并在前，落盘即成功)
 *
 * @param success
 * EN: Success callback when the EPO takes effect on device
 * CN: 成功回调，EPO 在设备生效时调用
 *
 * @param failure
 * EN: Failure callback. Distinguish the eTSErrorNotNecessary code(treat as success) from a real failure.
 * CN: 失败回调。需区分 eTSErrorNotNecessary 错误码(应视为成功)与真正的失败。
 */
- (void)updateEpoWithSource:(nullable TSEpoSource *)source
                forceUpdate:(BOOL)forceUpdate
                   progress:(nullable TSFileTransferProgressBlock)progress
                    success:(nullable TSFileTransferSuccessBlock)success
                    failure:(nullable TSFileTransferFailureBlock)failure;

/**
 * @brief Cancel the in-progress EPO update
 * @chinese 取消进行中的 EPO 更新
 *
 * @param completion
 * EN: Completion callback with cancel result
 * CN: 完成回调，返回取消结果
 */
- (void)cancelEpoUpdate:(nullable TSCompletionBlock)completion;

#pragma mark - Debugging / 调试辅助

/**
 * @brief Query the device EPO time info
 * @chinese 查询设备 EPO 时间信息
 *
 * @param completion
 * EN: Completion callback with EPO time info(valid deadline + last update). Mainly for debugging.
 * CN: 完成回调，返回 EPO 时间信息(有效截止 + 上次更新)。主要用于调试。
 */
- (void)fetchEpoTimeInfo:(nonnull TSEpoTimeInfoBlock)completion;

/**
 * @brief Clear the device EPO info
 * @chinese 清除设备 EPO 信息
 *
 * @param completion
 * EN: Completion callback with clear result. Mainly for debugging.
 * CN: 完成回调，返回清除结果。主要用于调试。
 */
- (void)clearEpo:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
