//
//  TSAIKitRootCapabilityCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSAIKitRootCapability.h"

@class TSAIKitRootCapability;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Card cell for an AI capability entry
 * @chinese AI 能力入口卡片
 *
 * @discussion
 * [EN]: Rounded white card with tint-colored icon, title, subtitle and arrow.
 *       A soft tint glow sits at the top-right corner for an AI feel.
 * [CN]: 圆角白底卡片，含主色图标、标题、副标题与箭头。右上角带主色光晕，
 *       营造 AI 主题感。
 */
@interface TSAIKitRootCapabilityCell : UICollectionViewCell

/**
 * @brief Bind a capability model to the cell
 * @chinese 绑定能力模型到卡片
 *
 * @param capability
 * EN: Capability data model
 * CN: 能力数据模型
 */
- (void)bindCapability:(TSAIKitRootCapability *)capability;

@end

NS_ASSUME_NONNULL_END
