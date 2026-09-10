//
//  TSPeripheralDialVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/19.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Peripheral dial management view controller
 * @chinese 外设表盘管理主页
 *
 * @discussion
 * [EN]: Matches the approved HTML with a current-face preview, creation/import actions,
 *       device/draft tabs, a three-column grid and a fixed storage footer.
 *       Filters are All, Built-in, Cloud, Custom. Details and deletion use bottom sheets.
 *
 * [CN]: 按已确认 HTML 展示当前预览、创建与导入入口、设备与草稿页签、三列网格和固定空间栏。
 *       筛选顺序为全部、内置、云端、自定义；详情、切换及删除使用底部弹层。
 */
@interface TSPeripheralDialVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
