//
//  TSDialVideoRecordVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/6.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Video recording view controller for custom video dial creation
 * @chinese 自定义视频表盘制作流程中的视频录制控制器
 *
 * @discussion
 * [EN]: Full-screen camera preview with recording controls and countdown timer.
 *       Enforces maximum duration limit from SDK.
 * [CN]: 全屏相机预览，带录制控制和倒计时。
 *       强制执行 SDK 的最大时长限制。
 */
@interface TSDialVideoRecordVC : TSRootVC

/**
 * @brief Designated initializer.
 * @chinese 指定初始化方法。
 *
 * @param maxDuration
 * EN: Maximum allowed recording duration in seconds.
 * CN: 允许的最大录制时长（秒）。
 *
 * @return
 * EN: A new TSDialVideoRecordVC instance.
 * CN: 新的 TSDialVideoRecordVC 实例。
 */
- (instancetype)initWithMaxDuration:(NSInteger)maxDuration NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * @brief Called with the recorded video URL when recording completes.
 * @chinese 录制完成后回调录制视频的 URL。
 *
 * @param videoURL
 * EN: File URL of the recorded video.
 * CN: 录制视频的文件 URL。
 */
@property (nonatomic, copy, nullable) void(^onRecordComplete)(NSURL *videoURL);

@end

NS_ASSUME_NONNULL_END
