//
//  TSOfflineMapCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief List cell for the "My Maps" tabs
 * @chinese 「我的地图」Tab 的列表 cell
 *
 * @discussion
 * [EN]: Renders a single offline map row: a 44x44 blue map icon on the left, the map name and size in
 *       two lines, and a circular checkbox on the right indicating selection.
 * [CN]: 渲染单个离线地图行：左侧 44x44 蓝色地图图标，中间两行展示地图名称与大小，右侧圆形勾选框表示选中状态。
 */
@interface TSOfflineMapCell : UITableViewCell

/**
 * @brief Configure the cell content
 * @chinese 配置 cell 内容
 *
 * @param name
 * EN: Map display name
 * CN: 地图展示名称
 *
 * @param sizeText
 * EN: Human-readable size text, or a placeholder such as "—"
 * CN: 人类可读的大小文案，或占位符如「—」
 *
 * @param checked
 * EN: Whether the row is currently selected
 * CN: 该行当前是否选中
 */
- (void)configureWithName:(NSString *)name sizeText:(NSString *)sizeText checked:(BOOL)checked;

@end

NS_ASSUME_NONNULL_END
