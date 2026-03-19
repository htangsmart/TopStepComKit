//
//  TSPeripheralLockVC.h
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Peripheral lock management view controller
 * @chinese 外设锁管理页
 *
 * @discussion
 * [EN]: Displays screen lock and game lock sections based on device capability.
 *       Each section has an enable switch and configuration rows (password / time range).
 * [CN]: 根据设备能力展示屏幕锁和游戏锁两个分区，每个分区包含开关和配置项（密码/时间段）。
 */
@interface TSPeripheralLockVC : TSRootVC

@end

NS_ASSUME_NONNULL_END
