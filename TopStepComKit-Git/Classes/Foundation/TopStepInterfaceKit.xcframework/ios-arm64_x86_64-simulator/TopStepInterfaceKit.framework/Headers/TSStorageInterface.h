//
//  TSStorageInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/28.
//

#import "TSKitBaseInterface.h"
#import "TSMediaCountMode.h"
#import "TSStorageSpace.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Storage space result callback
 * @chinese 存储空间信息结果回调
 *
 * @param storageSpace
 * EN: Storage space model, nil when retrieval fails
 * CN: 存储空间信息模型，获取失败时为 nil
 *
 * @param error
 * EN: Error info, nil when successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSStorageSpaceResultBlock)(TSStorageSpace * _Nullable storageSpace, NSError * _Nullable error);

/**
 * @brief Media count result callback
 * @chinese 媒体数量结果回调
 *
 * @param mediaCount
 * EN: Media count model, nil when retrieval fails
 * CN: 媒体数量模型，获取失败时为 nil
 *
 * @param error
 * EN: Error info, nil when successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSMediaCountResultBlock)(TSMediaCountMode * _Nullable mediaCount, NSError * _Nullable error);


@protocol TSStorageInterface <TSKitBaseInterface>

/**
 * @brief Get media file count on peripheral
 * @chinese 获取外设上的媒体文件数量
 *
 * @param completion
 * EN: Completion block called when count retrieval finishes
 *     - mediaCount: Media count model containing counts for different file types
 *     - error: Error object if count retrieval failed, nil if successful
 * CN: 数量获取完成时调用的回调块
 *     - mediaCount: 包含不同文件类型数量的媒体数量模型
 *     - error: 数量获取失败时的错误对象，成功时为nil
 *
 * @discussion
 * EN: This method retrieves the count of different types of media files
 *     (videos, audio recordings, music, photos) stored on the device.
 * CN: 此方法获取设备上存储的不同类型媒体文件（视频、录音、音乐、照片）的数量。
 */
- (void)getMediaCount:(nullable TSMediaCountResultBlock)completion;

/**
 * @brief Get storage space information of smart peripheral
 * @chinese 获取外设的存储空间信息
 *
 * @param completion
 * EN: Completion block called when storage space information retrieval finishes
 *     - storageSpace: Storage space information model containing total and available space
 *     - error: Error object if storage space information retrieval failed, nil if successful
 * CN: 存储空间信息获取完成时调用的回调块
 *     - storageSpace: 包含总空间和可用空间的存储空间信息模型
 *     - error: 存储空间信息获取失败时的错误对象，成功时为nil
 *
 * @discussion
 * EN: This method retrieves the storage space information of the peripheral,
 *     including total storage space and available storage space in bytes.
 *     The storage space information can be used to check available space before
 *     recording videos or taking photos.
 * CN: 此方法获取外设的存储空间信息，包括总存储空间和可用存储空间（字节）。
 *     存储空间信息可用于在录制视频或拍照前检查可用空间。
 */
- (void)getStorageSpace:(nullable TSStorageSpaceResultBlock)completion;

/**
 * @brief Register listener for storage space change
 * @chinese 注册外设存储空间信息变化的监听
 *
 * @param completion
 * EN: Callback invoked on the main queue when the device reports storage space change.
 *     Pass nil to unregister.
 * CN: 设备上报存储空间信息变化时在主线程回调，传 nil 可取消监听。
 *
 * @discussion
 * EN: The callback is held strongly by the receiver and only the latest registered value is kept.
 *     The callback only fires when the device pushes a change; it does NOT trigger an
 *     initial query — call -getStorageSpace: explicitly if the current state is needed.
 * CN: 回调由接收者强引用，仅保留最近一次注册值。
 *     仅在设备主动上报变化时回调，不会触发首次查询，需要当前值请显式调用 -getStorageSpace:。
 */
- (void)registerStorageSpaceDidChange:(nullable TSStorageSpaceResultBlock)completion;

/**
 * @brief Register listener for media count change
 * @chinese 注册外设媒体数量变化的监听
 *
 * @param completion
 * EN: Callback invoked on the main queue when the device reports media count change.
 *     Pass nil to unregister.
 * CN: 设备上报媒体数量变化时在主线程回调，传 nil 可取消监听。
 *
 * @discussion
 * EN: The callback is held strongly by the receiver and only the latest registered value is kept.
 *     The callback only fires when the device pushes a change; it does NOT trigger an
 *     initial query — call -getMediaCount: explicitly if the current state is needed.
 * CN: 回调由接收者强引用，仅保留最近一次注册值。
 *     仅在设备主动上报变化时回调，不会触发首次查询，需要当前值请显式调用 -getMediaCount:。
 */
- (void)registerMediaCountDidChanged:(nullable TSMediaCountResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
