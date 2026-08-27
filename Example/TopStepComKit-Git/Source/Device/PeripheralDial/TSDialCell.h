//
//  TSDialCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/8/25.
//

#import <UIKit/UIKit.h>

@class TSDialModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face collection view cell
 * @chinese 表盘集合视图单元格
 */
@interface TSDialCell : UICollectionViewCell

/**
 * @brief Configure the cell with a watch face
 * @chinese 使用表盘模型配置单元格
 *
 * @param dial
 * EN: Watch face model to display
 * CN: 需要展示的表盘模型
 *
 * @param isCurrent
 * EN: Whether this is the current watch face
 * CN: 是否为当前表盘
 */
- (void)configureWithDial:(TSDialModel *)dial isCurrent:(BOOL)isCurrent;

@end

NS_ASSUME_NONNULL_END
