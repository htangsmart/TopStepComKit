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
 * [EN]: Shows all device watch faces grouped into three sections (built-in / cloud / custom)
 *       using UICollectionView. The active watch face is highlighted with a primary-color border.
 *       Two action buttons at the top allow pushing cloud dials or creating custom dials.
 *       Long-press on cloud or custom cells to delete. Tap any cell to view detail / switch.
 *
 * [CN]: 以 UICollectionView 分三组（内置/云端/自定义）展示设备上所有表盘，当前表盘用主色边框高亮。
 *       顶部两个按钮分别进入推送云端表盘和制作并推送自定义表盘流程。
 *       长按云端/自定义表盘可删除，点击任意表盘进入详情页。
 */
@interface TSPeripheralDialVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
