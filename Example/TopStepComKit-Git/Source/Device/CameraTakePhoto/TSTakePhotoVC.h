//
//  TSTakePhotoVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/12.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

/**
 * @brief Remote camera control view controller
 * @chinese 远程拍照控制页
 *
 * @discussion
 * [EN]: Full-screen camera preview with remote control support.
 *       Automatically enters camera mode on appear and exits on disappear.
 *       If the device supports video preview, streams live frames to the device.
 *       Also listens for device-initiated camera actions and syncs them locally.
 * [CN]: 全屏摄像头预览，支持远程控制。
 *       进入页面自动发送进入相机指令，离开页面自动退出。
 *       若设备支持视频预览，则实时推流给设备。
 *       同时监听设备主动触发的相机动作并同步到本地。
 */

#import <UIKit/UIKit.h>
#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSTakePhotoVC : TSRootVC

/**
 * @brief Whether this VC was triggered by device entering camera mode
 * @chinese 是否由设备主动触发进入相机
 *
 * @discussion
 * [EN]: When YES, viewWillAppear will NOT send the enter camera command to the device,
 *       because the device has already entered camera mode.
 * [CN]: 为 YES 时，viewWillAppear 不会再向设备发送进入相机指令，
 *       因为设备已经主动进入了相机模式。
 */
@property (nonatomic, assign) BOOL isTriggeredByDevice;

@end

NS_ASSUME_NONNULL_END
