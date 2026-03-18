//
//  TSDialVideoEditVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Video editing view controller for custom video dial creation
 * @chinese 自定义视频表盘制作流程中的视频编辑控制器
 *
 * @discussion
 * [EN]: Plays the source video with a crop overlay matching the device dial aspect ratio.
 *       Provides a timeline with two draggable handles to trim start/end time.
 *       On confirmation, exports a trimmed video via AVAssetExportSession.
 * [CN]: 将源视频以设备表盘比例的裁剪框叠加显示，
 *       提供时间轴双滑块进行首尾裁剪，
 *       确认后使用 AVAssetExportSession 导出裁剪后的视频。
 */
@interface TSDialVideoEditVC : TSRootVC

/**
 * @brief Designated initializer.
 * @chinese 指定初始化方法。
 *
 * @param videoURL
 * EN: URL of the source video to edit.
 * CN: 待编辑的原始视频 URL。
 *
 * @param dialSize
 * EN: Target dial size in pixels (e.g. 240x280).
 * CN: 目标表盘像素尺寸（如 240x280）。
 *
 * @param maxDuration
 * EN: Maximum allowed video duration in seconds.
 * CN: 视频允许的最大时长（秒）。
 *
 * @return
 * EN: A new TSDialVideoEditVC instance.
 * CN: 新的 TSDialVideoEditVC 实例。
 */
- (instancetype)initWithVideoURL:(NSURL *)videoURL
                        dialSize:(CGSize)dialSize
                     maxDuration:(NSInteger)maxDuration NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * @brief Called with the exported video URL when the user taps "完成".
 * @chinese 用户点击「完成」后回调导出视频的 URL。
 *
 * @param processedURL
 * EN: File URL of the exported (trimmed) video.
 * CN: 导出（裁剪）后视频的文件 URL。
 */
@property (nonatomic, copy, nullable) void(^onEditComplete)(NSURL *processedURL);

@end

NS_ASSUME_NONNULL_END
