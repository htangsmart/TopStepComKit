//
//  TSRemoteControlVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Remote control view controller
 * @chinese 远程控制页
 *
 * @discussion
 * [EN]: Provides shutdown, restart, and factory reset operations for the connected device.
 *       Each action requires user confirmation before execution.
 * [CN]: 提供对已连接设备的关机、重启、恢复出厂设置操作，每个操作执行前需用户二次确认。
 */
@interface TSRemoteControlVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
