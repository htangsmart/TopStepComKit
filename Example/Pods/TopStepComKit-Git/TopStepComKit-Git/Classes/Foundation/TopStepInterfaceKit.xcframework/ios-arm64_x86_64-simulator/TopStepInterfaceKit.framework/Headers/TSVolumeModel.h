//
//  TSVolumeModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/28.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device volume model
 * @chinese 设备音量模型
 */
@interface TSVolumeModel : TSKitBaseModel

/**
 * @brief System prompt volume
 * @chinese 系统提示音音量
 *
 * @discussion
 * EN: Current system prompt volume, range 0~100
 * CN: 当前系统提示音音量，范围 0~100
 */
@property (nonatomic, assign) NSInteger systemPromptVolume;

/**
 * @brief Media playback volume
 * @chinese 媒体播放音量
 *
 * @discussion
 * EN: Current media playback volume, range 0~100
 * CN: 当前媒体播放音量，范围 0~100
 */
@property (nonatomic, assign) NSInteger mediaPlaybackVolume;

/**
 * @brief Call volume
 * @chinese 通话音量
 *
 * @discussion
 * EN: Current call volume, range 0~100
 * CN: 当前通话音量，范围 0~100
 */
@property (nonatomic, assign) NSInteger callVolume;

@end

NS_ASSUME_NONNULL_END
