//
//  TSPeripheralDialVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/19.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Peripheral dial management view controller
 * @chinese 外设表盘管理视图控制器
 *
 * @discussion
 * EN: This controller provides functionality for managing watch faces on peripheral devices.
 *     Supports operations like getting current dial, pushing cloud/custom dials,
 *     deleting dials, and switching between dials.
 *     Also includes file selection functionality for custom dial files.
 *
 * CN: 此控制器提供管理外设设备表盘的功能。
 *     支持获取当前表盘、推送云端/自定义表盘、
 *     删除表盘和切换表盘等操作。
 *     还包含用于自定义表盘文件的文件选择功能。
 */
@interface TSPeripheralDialVC : TSBaseVC <UIDocumentPickerDelegate>

@end

NS_ASSUME_NONNULL_END
