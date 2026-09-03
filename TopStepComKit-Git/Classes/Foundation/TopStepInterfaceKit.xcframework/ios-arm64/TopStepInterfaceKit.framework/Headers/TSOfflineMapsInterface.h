//
//  TSOfflineMapsInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/8.
//

#import "TSKitBaseInterface.h"
#import "TSOfflineMapRegion.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Offline map name list callback block type
 * @chinese 离线地图名称列表回调块类型
 *
 * @param mapNames
 * EN: Array of offline map names on the device, empty array if none or retrieval fails
 * CN: 设备上的离线地图名称数组，无地图或获取失败时为空数组
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为nil
 */
typedef void (^TSOfflineMapListBlock)(NSArray<NSString *> *_Nullable mapNames, NSError *_Nullable error);

/**
 * @brief Offline map download completion callback block type
 * @chinese 离线地图下载完成回调块类型
 *
 * @param packagePath
 * EN: Local file path of the downloaded offline map package, nil if download fails
 * CN: 下载好的离线地图包本地文件路径，下载失败时为nil
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 下载失败时的错误信息，成功时为nil
 */
typedef void (^TSOfflineMapDownloadBlock)(NSString *_Nullable packagePath, NSError *_Nullable error);

/**
 * @brief Watch device offline map management interface
 * @chinese 手表设备离线地图管理接口
 *
 * @discussion
 * [EN]: This interface defines all operations related to offline map management on the watch device, including:
 *       1. Fetch offline map name list from the device
 *       2. Delete an offline map on the device by name
 *       3. Download an offline map package to the phone by region
 *       4. Push a local offline map package to the device
 *       5. Download and push an offline map to the device in one step
 * [CN]: 该接口定义了与手表设备离线地图管理相关的所有操作，包括：
 *       1. 从设备获取离线地图名称列表
 *       2. 根据名称删除设备上的离线地图
 *       3. 根据区域参数下载离线地图包到手机
 *       4. 将手机本地离线地图包推送到设备
 *       5. 一步完成下载并推送离线地图到设备
 */
@protocol TSOfflineMapsInterface <TSKitBaseInterface>

#pragma mark - Capability Check / 能力检查

/**
 * @brief Check if the device supports offline map
 * @chinese 检查设备是否支持离线地图
 *
 * @return
 * [EN]: YES if the device supports offline map management, NO otherwise
 * [CN]: 如果设备支持离线地图管理返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Offline map refers to the ability to download a map package on the phone and push it to the
 *       watch device for offline map display. Use this method to check whether the connected device
 *       has this capability before invoking any other method of this interface.
 * [CN]: 离线地图指的是在手机端下载地图包并推送到手表设备以供离线地图显示的能力。
 *       在调用本接口的其他任何方法之前，使用此方法检查连接的设备是否具有该能力。
 */
- (BOOL)isSupportOfflineMap;

#pragma mark - Offline Map Management / 离线地图管理

/**
 * @brief Fetch offline map name list from the device
 * @chinese 从设备获取离线地图名称列表
 *
 * @param completion
 * EN: Completion callback with array of offline map names currently stored on the device
 * CN: 完成回调，返回设备当前存储的离线地图名称数组
 *
 * @discussion
 * [EN]: This method retrieves the names of all offline maps currently stored on the watch device.
 *       The callback will be called on the main thread.
 *       Returns an empty array if retrieval fails or no map is found.
 * [CN]: 此方法获取设备上当前存储的所有离线地图名称。
 *       回调将在主线程执行。
 *       如果获取失败或未找到地图，则返回空数组。
 */
- (void)fetchDeviceOfflineMaps:(nonnull TSOfflineMapListBlock)completion;

/**
 * @brief Delete a specific offline map on the device by name
 * @chinese 根据名称删除设备上的指定离线地图
 *
 * @param mapName
 * EN: The offline map name to delete, obtained from fetchDeviceOfflineMaps:
 * CN: 要删除的离线地图名称，来自fetchDeviceOfflineMaps:
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the deletion was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - success: 删除操作是否成功
 *     - error: 删除失败时的错误信息，成功时为nil
 *
 * @discussion
 * [EN]: This method deletes a specific offline map from the watch device by its name.
 *       The callback will be called on the main thread.
 * [CN]: 此方法根据名称从手表设备删除指定的离线地图。
 *       回调将在主线程执行。
 */
- (void)deleteOfflineMap:(NSString *)mapName completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Download an offline map package to the phone by region
 * @chinese 根据区域参数下载离线地图包到手机
 *
 * @param region
 * EN: The download region defined by center coordinate and radius. See TSOfflineMapRegion.
 * CN: 由中心坐标和半径确定的下载区域。参见TSOfflineMapRegion。
 *
 * @param progress
 * EN: Progress callback, returns current download progress (0-100). May be called multiple times.
 * CN: 进度回调，返回当前下载进度（0-100），会被多次调用。
 *
 * @param completion
 * EN: Completion callback
 *     - packagePath: Local file path of the downloaded offline map package on success
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - packagePath: 下载成功时离线地图包的本地文件路径
 *     - error: 下载失败时的错误信息，成功时为nil
 *
 * @discussion
 * [EN]: This method only downloads the offline map package to the phone; it does NOT push it to the device.
 *       Use pushOfflineMap:name:progress:success:failure: to push the resulting package to the device.
 *       All callbacks will be called on the main thread.
 * [CN]: 此方法仅将离线地图包下载到手机，不会推送到设备。
 *       使用 pushOfflineMap:name:progress:success:failure: 将产出的包推送到设备。
 *       所有回调将在主线程执行。
 */
- (void)downloadOfflineMapWithRegion:(TSOfflineMapRegion *)region
                            progress:(nullable TSFileTransferProgressBlock)progress
                          completion:(nonnull TSOfflineMapDownloadBlock)completion;

/**
 * @brief Push a local offline map package to the device
 * @chinese 将本地离线地图包推送到设备
 *
 * @param packagePath
 * EN: Local file path of the offline map package, usually obtained from downloadOfflineMapWithRegion:progress:completion:
 * CN: 离线地图包的本地文件路径，通常来自 downloadOfflineMapWithRegion:progress:completion:
 *
 * @param mapName
 * EN: The offline map name shown on the device. If nil, the package file name is used.
 *     Note the device may truncate an over-long name.
 * CN: 在设备上显示的离线地图名称。如果为nil，则使用包文件名。
 *     注意设备可能会截断过长的名称。
 *
 * @param progress
 * EN: Progress callback, returns current push progress (0-100). Called multiple times during push.
 *     Uses TSFileTransferStatus to indicate transfer state.
 * CN: 进度回调，返回当前推送进度（0-100），推送过程中会被多次调用。
 *     使用TSFileTransferStatus表示传输状态。
 *
 * @param success
 * EN: Success callback, called when push completes successfully
 * CN: 成功回调，推送成功完成时调用
 *
 * @param failure
 * EN: Failure callback, called when push fails or is canceled
 * CN: 失败回调，推送失败或被取消时调用
 *
 * @discussion
 * [EN]: This method pushes a local offline map package to the watch device.
 *       The file at packagePath must exist and be valid.
 *       All callbacks will be called on the main thread.
 * [CN]: 此方法将本地离线地图包推送到手表设备。
 *       packagePath指向的文件必须存在且有效。
 *       所有回调将在主线程执行。
 */
- (void)pushOfflineMap:(NSString *)packagePath
               mapName:(nullable NSString *)mapName
              progress:(nullable TSFileTransferProgressBlock)progress
               success:(nullable TSFileTransferSuccessBlock)success
               failure:(nullable TSFileTransferFailureBlock)failure;

/**
 * @brief Download and push an offline map to the device in one step
 * @chinese 一步完成下载并推送离线地图到设备
 *
 * @param region
 * EN: The download region defined by center coordinate and radius. See TSOfflineMapRegion.
 * CN: 由中心坐标和半径确定的下载区域。参见TSOfflineMapRegion。
 *
 * @param mapName
 * EN: The offline map name shown on the device. If nil, the downloaded package file name is used.
 * CN: 在设备上显示的离线地图名称。如果为nil，则使用下载包的文件名。
 *
 * @param downloadProgress
 * EN: Download-stage progress callback, returns current download progress (0-100). May be called multiple times.
 *     This block is invoked during the download stage only.
 * CN: 下载阶段进度回调，返回当前下载进度（0-100），会被多次调用。
 *     此回调仅在下载阶段被调用。
 *
 * @param pushProgress
 * EN: Push-stage progress callback, returns current push progress (0-100). May be called multiple times.
 *     This block is invoked during the push stage only, after the download stage completes.
 * CN: 推送阶段进度回调，返回当前推送进度（0-100），会被多次调用。
 *     此回调仅在下载阶段完成后的推送阶段被调用。
 *
 * @param success
 * EN: Success callback, called when the whole download-and-push completes successfully
 * CN: 成功回调，整个下载并推送成功完成时调用
 *
 * @param failure
 * EN: Failure callback, called when download or push fails or is canceled
 * CN: 失败回调，下载或推送失败或被取消时调用
 *
 * @discussion
 * [EN]: This method combines downloadOfflineMapWithRegion:progress:completion: and
 *       pushOfflineMap:name:progress:success:failure:. The SDK automatically downloads the offline map
 *       package for the specified region and then pushes it to the device. The two stages are distinguished
 *       by which progress block is invoked: downloadProgress for the download stage, pushProgress for the
 *       push stage. The success / failure callbacks report the final result of the whole operation.
 *       All callbacks will be called on the main thread.
 * [CN]: 此方法组合了 downloadOfflineMapWithRegion:progress:completion: 与
 *       pushOfflineMap:name:progress:success:failure:。SDK 会自动下载指定区域的离线地图包，
 *       然后推送到设备。两个阶段通过不同的进度回调区分：下载阶段调用 downloadProgress，
 *       推送阶段调用 pushProgress。success / failure 回调上报整个操作的最终结果。
 *       所有回调将在主线程执行。
 */
- (void)downloadAndPushOfflineMapWithRegion:(TSOfflineMapRegion *)region
                                    mapName:(nullable NSString *)mapName
                           downloadProgress:(nullable TSFileTransferProgressBlock)downloadProgress
                               pushProgress:(nullable TSFileTransferProgressBlock)pushProgress
                                    success:(nullable TSFileTransferSuccessBlock)success
                                    failure:(nullable TSFileTransferFailureBlock)failure;

/**
 * @brief Cancel the ongoing offline map download / push operation
 * @chinese 取消正在进行的离线地图下载/推送操作
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the cancellation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - success: 取消操作是否成功
 *     - error: 取消失败时的错误信息，成功时为nil
 *
 * @discussion
 * [EN]: This method cancels the currently ongoing offline map download or push operation and cleans up
 *       any temporary files. If no operation is in progress, calling this method has no effect.
 *       The callback will be called on the main thread.
 * [CN]: 此方法取消当前正在进行的离线地图下载或推送操作，并清理所有临时文件。
 *       如果没有正在进行的操作，调用此方法不会有任何效果。
 *       回调将在主线程执行。
 */
- (void)cancelOfflineMapTransfer:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
