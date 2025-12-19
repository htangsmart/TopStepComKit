//
//  TSMusicInterface.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/2.
//

#import "TSKitBaseInterface.h"
#import "TSMusicModel.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Music list callback block type
 * @chinese 音乐列表回调块类型
 *
 * @param musics
 * EN: Array of music models, empty array if retrieval fails
 * CN: 音乐模型数组，获取失败时为空数组
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为nil
 */
typedef void (^TSMusicListBlock)(NSArray<TSMusicModel *> *_Nullable musics, NSError *_Nullable error);

/**
 * @brief Watch device music management interface
 * @chinese 手表设备音乐管理接口
 *
 * @discussion
 * [EN]: This interface defines all operations related to music management on the watch device, including:
 *       1. Fetch music list
 *       2. Push music to device
 *       3. Delete music from device
 *       4. Cancel music push operation
 * [CN]: 该接口定义了与手表设备音乐管理相关的所有操作，包括：
 *       1. 获取音乐列表
 *       2. 向设备推送音乐
 *       3. 从设备删除音乐
 *       4. 取消音乐推送操作
 */
@protocol TSMusicInterface <TSKitBaseInterface>

/**
 * @brief Fetch all music list from the device
 * @chinese 获取设备上所有音乐列表
 *
 * @param completion
 * EN: Completion callback with array of all music models
 * CN: 完成回调，返回所有音乐模型数组
 *
 * @discussion
 * [EN]: This method retrieves information about all music tracks that are currently stored on the watch device.
 *       The callback will be called on the main thread.
 *       Returns an empty array if retrieval fails or no music is found.
 * [CN]: 此方法获取设备上所有当前存储的音乐曲目信息。
 *       回调将在主线程执行。
 *       如果获取失败或未找到音乐，则返回空数组。
 */
- (void)fetchAllMusics:(nonnull TSMusicListBlock)completion;

/**
 * @brief Delete a specific music from the device
 * @chinese 从设备删除指定音乐
 *
 * @param music
 * EN: Music model to delete. Must contain musicId for identification.
 * CN: 要删除的音乐模型。必须包含musicId用于识别。
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
 * [EN]: This method deletes a specific music track from the watch device.
 *       The music is identified by musicId from the provided TSMusicModel.
 *       The callback will be called on the main thread.
 * [CN]: 此方法从手表设备删除指定的音乐曲目。
 *       音乐通过提供的TSMusicModel中的musicId进行识别。
 *       回调将在主线程执行。
 *
 * @note
 * [EN]: - The music parameter must contain a valid musicId
 *       - If the music is not found on the device, the operation will fail with an appropriate error
 * [CN]: - music参数必须包含有效的musicId
 *       - 如果设备上未找到该音乐，操作将失败并返回相应错误
 */
- (void)deleteMusic:(TSMusicModel *)music completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Push a music track to the device
 * @chinese 向设备推送一首音乐
 *
 * @param music
 * EN: Music model to push. Must contain filePath pointing to a valid music file.
 * CN: 要推送的音乐模型。必须包含指向有效音乐文件的filePath。
 *
 * @param progress
 * EN: Progress callback, returns current push progress (0-100)
 *     Called multiple times during the push process.
 *     Uses TSFileTransferStatus to indicate transfer state:
 *     - eTSFileTransferStatusStart: Transfer starting
 *     - eTSFileTransferStatusProgress: Transferring
 * CN: 进度回调，返回当前推送进度（0-100）
 *     在推送过程中会被多次调用。
 *     使用TSFileTransferStatus表示传输状态：
 *     - eTSFileTransferStatusStart: 开始传输
 *     - eTSFileTransferStatusProgress: 传输中
 *
 * @param success
 * EN: Success callback, called when push completes successfully
 *     Uses TSFileTransferStatusSuccess to indicate success
 * CN: 成功回调，推送成功完成时调用
 *     使用TSFileTransferStatusSuccess表示成功
 *
 * @param failure
 * EN: Failure callback, called when push fails or is canceled
 *     Uses TSFileTransferStatusFailed or TSFileTransferStatusCanceled to indicate failure
 * CN: 失败回调，推送失败或被取消时调用
 *     使用TSFileTransferStatusFailed或TSFileTransferStatusCanceled表示失败
 *
 * @discussion
 * [EN]: This method pushes a music track to the watch device.
 *       The music file at filePath must exist and be valid.
 *       Progress callback will be called multiple times during the push process.
 *       All callbacks will be called on the main thread.
 * [CN]: 此方法将音乐曲目推送到手表设备。
 *       filePath指向的音乐文件必须存在且有效。
 *       在推送过程中进度回调会被多次调用。
 *       所有回调将在主线程执行。
 *
 * @note
 * [EN]: - The music parameter must contain a valid filePath
 *       - The file at filePath must exist and be readable
 *       - Use cancelPushMusic:completion: to cancel an ongoing push operation
 * [CN]: - music参数必须包含有效的filePath
 *       - filePath指向的文件必须存在且可读
 *       - 使用cancelPushMusic:completion:取消正在进行的推送操作
 */
- (void)pushMusic:(TSMusicModel *)music
         progress:(nullable TSFileTransferProgressBlock)progress
          success:(nullable TSFileTransferSuccessBlock)success
          failure:(nullable TSFileTransferFailureBlock)failure;

/**
 * @brief Cancel ongoing music push operation
 * @chinese 取消正在推送的音乐
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
 * [EN]: This method cancels the currently ongoing music push operation.
 *       Features:
 *       1. Cancels the current music push operation in progress
 *       2. Can be called at any time during push
 *       3. Will clean up any temporary files
 *       4. May take a moment to complete cancellation
 *       The callback will be called on the main thread.
 * [CN]: 此方法取消当前正在进行的音乐推送操作。
 *       特点：
 *       1. 取消当前正在进行的音乐推送操作
 *       2. 可以在推送过程中任何时候调用
 *       3. 会清理所有临时文件
 *       4. 取消操作可能需要一定时间完成
 *       回调将在主线程执行。
 *
 * @note
 * [EN]: - If no push operation is in progress, calling this method has no effect
 *       - Only one music push operation can be active at a time
 * [CN]: - 如果没有正在进行的推送操作，调用此方法不会有任何效果
 *       - 同时只能有一个音乐推送操作处于活动状态
 */
- (void)cancelPushMusic:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
