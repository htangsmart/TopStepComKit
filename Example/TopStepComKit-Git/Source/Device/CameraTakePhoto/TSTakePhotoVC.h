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
 *       Waits for permission, capture and connection readiness before entering camera mode.
 *       Provides photo capture, firmware-gated video recording, lens zoom presets and independent preview streaming.
 *       Consumes coordinator-forwarded camera actions; retains failed media for retry before closing.
 * [CN]: 全屏摄像头预览，支持远程控制。
 *       等待权限、采集和设备就绪后进入相机。
 *       提供拍照、固件能力控制的录像、镜头倍率按钮及独立预览推流。
 *       消费协调器转发的相机动作；退出前完成文件收尾并保留失败媒体供重试。
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
 *
 * @note
 * [EN]: Defaults to NO; set before presenting this page after a device Enter action.
 * [CN]: 默认 NO；设备 Enter 动作打开页面时在展示前设置。
 */
@property (nonatomic, assign) BOOL isTriggeredByDevice;

@end

NS_ASSUME_NONNULL_END
