//
//  TSVolumeInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/28.
//

#import "TSKitBaseInterface.h"
#import "TSVolumeModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Volume type
 * @chinese 音量类型
 */
typedef NS_ENUM(NSUInteger, TSVolumeType) {
    TSVolumeTypeSystemPrompt = 0,   ///< 系统提示音
    TSVolumeTypeMediaPlayback,      ///< 媒体播放音量
    TSVolumeTypeCall                ///< 通话音量
};

/**
 * @brief Get volume callback
 * @chinese 获取音量回调
 *
 * @param volume
 * EN: Current volume, range 0~100, 0 if retrieval fails
 * CN: 当前音量值，范围 0~100，获取失败时为 0
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSVolumeResultBlock)(NSInteger volume, NSError * _Nullable error);

/**
 * @brief Get volume model callback
 * @chinese 获取音量模型回调
 *
 * @param volumeModel
 * EN: Device volume model, nil if retrieval fails
 * CN: 设备音量模型，获取失败时为 nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSVolumeModelResultBlock)(TSVolumeModel * _Nullable volumeModel, NSError * _Nullable error);

/**
 * @brief Device volume management interface
 * @chinese 设备音量管理接口
 *
 * @discussion
 * EN: This interface defines all operations related to device volume, including:
 *     1. Check whether a specified volume type is supported
 *     2. Get all device volume information
 *     3. Set all device volume information
 *     4. Get current volume for a specified type
 *     5. Set volume for a specified type
 *     6. Quickly get or set system prompt, media playback and call volume
 * CN: 该接口定义了与设备音量相关的所有操作，包括：
 *     1. 检查指定音量类型是否支持
 *     2. 获取设备全部音量信息
 *     3. 设置设备全部音量信息
 *     4. 获取指定类型的当前音量
 *     5. 设置指定类型的音量
 *     6. 快速获取或设置系统提示音、媒体播放、通话音量
 */
@protocol TSVolumeInterface <TSKitBaseInterface>

/**
 * @brief Check whether volume type is supported
 * @chinese 检查音量类型是否支持
 *
 * @param volumeType
 * EN: Volume type
 * CN: 音量类型
 *
 * @return
 * EN: YES if supported, otherwise NO
 * CN: 支持返回 YES，否则返回 NO
 *
 * @discussion
 * EN: Use this method before get or set volume when the device capability is uncertain.
 * CN: 当设备能力不明确时，建议在获取或设置音量前先调用该方法判断。
 */
- (BOOL)isVolumeTypeSupported:(TSVolumeType)volumeType;

/**
 * @brief Get all device volume information
 * @chinese 获取设备全部音量信息
 *
 * @param completion
 * EN: Completion callback
 *     - volumeModel: Device volume model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - volumeModel: 设备音量模型，获取失败时为 nil
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Get all current volume information from the device, including system prompt, media playback and call volume.
 * CN: 获取设备当前全部音量信息，包括系统提示音、媒体播放和通话音量。
 */
- (void)getVolumeModel:(nullable TSVolumeModelResultBlock)completion;

/**
 * @brief Set all device volume information
 * @chinese 设置设备全部音量信息
 *
 * @param volumeModel
 * EN: Device volume model to set
 * CN: 要设置的设备音量模型
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Set all device volume information at one time, including system prompt, media playback and call volume.
 * CN: 一次性设置设备全部音量信息，包括系统提示音、媒体播放和通话音量。
 */
- (void)setVolumeModel:(TSVolumeModel *)volumeModel
            completion:(TSCompletionBlock)completion;

/**
 * @brief Get current volume for specified type
 * @chinese 获取指定类型的当前音量
 *
 * @param volumeType
 * EN: Volume type
 * CN: 音量类型
 *
 * @param completion
 * EN: Completion callback
 *     - volume: Current volume, range 0~100, 0 if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - volume: 当前音量值，范围 0~100，获取失败时为 0
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Get the current volume for the specified volume type from the device.
 * CN: 从设备获取指定音量类型的当前音量。
 */
- (void)getVolumeWithType:(TSVolumeType)volumeType
               completion:(nullable TSVolumeResultBlock)completion;

/**
 * @brief Set volume for specified type
 * @chinese 设置指定类型的音量
 *
 * @param volume
 * EN: Volume to set, range 0~100
 * CN: 要设置的音量值，范围 0~100
 *
 * @param volumeType
 * EN: Volume type
 * CN: 音量类型
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Set the volume for the specified volume type on the device.
 *     The volume parameter must be in the range of 0~100.
 * CN: 设置设备指定音量类型的音量。
 *     volume 参数必须在 0~100 范围内。
 */
- (void)setVolume:(NSInteger)volume
             type:(TSVolumeType)volumeType
       completion:(TSCompletionBlock)completion;

/**
 * @brief Get system prompt volume
 * @chinese 获取系统提示音音量
 *
 * @param completion
 * EN: Completion callback
 *     - volume: Current volume, range 0~100, 0 if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - volume: 当前音量值，范围 0~100，获取失败时为 0
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Quickly get the current system prompt volume from the device.
 * CN: 快速获取设备当前系统提示音音量。
 */
- (void)getSystemPromptVolume:(nullable TSVolumeResultBlock)completion;

/**
 * @brief Set system prompt volume
 * @chinese 设置系统提示音音量
 *
 * @param volume
 * EN: Volume to set, range 0~100
 * CN: 要设置的音量值，范围 0~100
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Quickly set the system prompt volume on the device.
 * CN: 快速设置设备系统提示音音量。
 */
- (void)setSystemPromptVolume:(NSInteger)volume
                   completion:(TSCompletionBlock)completion;

/**
 * @brief Get media playback volume
 * @chinese 获取媒体播放音量
 *
 * @param completion
 * EN: Completion callback
 *     - volume: Current volume, range 0~100, 0 if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - volume: 当前音量值，范围 0~100，获取失败时为 0
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Quickly get the current media playback volume from the device.
 * CN: 快速获取设备当前媒体播放音量。
 */
- (void)getMediaPlaybackVolume:(nullable TSVolumeResultBlock)completion;

/**
 * @brief Set media playback volume
 * @chinese 设置媒体播放音量
 *
 * @param volume
 * EN: Volume to set, range 0~100
 * CN: 要设置的音量值，范围 0~100
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Quickly set the media playback volume on the device.
 * CN: 快速设置设备媒体播放音量。
 */
- (void)setMediaPlaybackVolume:(NSInteger)volume
                    completion:(TSCompletionBlock)completion;

/**
 * @brief Get call volume
 * @chinese 获取通话音量
 *
 * @param completion
 * EN: Completion callback
 *     - volume: Current volume, range 0~100, 0 if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - volume: 当前音量值，范围 0~100，获取失败时为 0
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Quickly get the current call volume from the device.
 * CN: 快速获取设备当前通话音量。
 */
- (void)getCallVolume:(nullable TSVolumeResultBlock)completion;

/**
 * @brief Set call volume
 * @chinese 设置通话音量
 *
 * @param volume
 * EN: Volume to set, range 0~100
 * CN: 要设置的音量值，范围 0~100
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: Quickly set the call volume on the device.
 * CN: 快速设置设备通话音量。
 */
- (void)setCallVolume:(NSInteger)volume
           completion:(TSCompletionBlock)completion;

/**
 * @brief Register volume changed notify
 * @chinese 注册音量变化监听
 *
 * @param completion
 * EN: completion invoked when device volume changes
 *     - volumeModel: Latest device volume model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 设备音量变化时回调
 *     - volumeModel: 最新设备音量模型，获取失败时为 nil
 *     - error: 获取失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: After registration, the callback will be invoked whenever the device reports a volume change.
 * CN: 注册后，当设备上报音量变化时会触发回调。
 */
- (void)registerVolumeDidChanged:(nullable TSVolumeModelResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
