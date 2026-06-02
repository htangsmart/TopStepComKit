//
//  TSAIKitRootSectionHeaderView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Section header with tint bar, title, protocol name and count badge
 * @chinese Section 头部，含主色竖条、标题、协议名与数量徽章
 */
@interface TSAIKitRootSectionHeaderView : UICollectionReusableView

/**
 * @brief Apply section content
 * @chinese 应用 section 内容
 *
 * @param title
 * EN: Section display name (e.g. "Assistant")
 * CN: section 显示名（例如 "Assistant"）
 *
 * @param protocolName
 * EN: Underlying protocol identifier (e.g. "TSAIAssistantInterface")
 * CN: 对应的协议标识（例如 "TSAIAssistantInterface"）
 *
 * @param count
 * EN: Number of capabilities in this section, used by the badge
 * CN: 当前 section 的能力数量，用于徽章展示
 *
 * @param tintColor
 * EN: Section tint color
 * CN: section 主色
 */
- (void)applyTitle:(NSString *)title
       protocolName:(NSString *)protocolName
              count:(NSInteger)count
          tintColor:(UIColor *)tintColor;

/**
 * @brief Calculate height that fits the given width
 * @chinese 根据宽度计算视图所需高度
 *
 * @param width
 * EN: Available width
 * CN: 可用宽度
 *
 * @return
 * EN: Required height
 * CN: 所需高度
 */
+ (CGFloat)heightForWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
