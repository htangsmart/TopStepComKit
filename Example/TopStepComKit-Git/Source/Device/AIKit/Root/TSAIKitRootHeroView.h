//
//  TSAIKitRootHeroView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Hero header with gradient background and two CTA buttons
 * @chinese 顶部 Hero 区，含渐变背景与两个 CTA 按钮
 *
 * @discussion
 * [EN]: Renders the brand-level intro and exposes two tap callbacks for the
 *       primary (Voice Chat) and secondary (Interpreter) shortcut buttons.
 * [CN]: 展示品牌级介绍信息，并向外暴露两个 CTA（Voice Chat / 同传）的点击回调。
 */
@interface TSAIKitRootHeroView : UIView

/**
 * @brief Tap callback for the primary CTA (Voice Chat)
 * @chinese 主按钮点击回调（Voice Chat）
 */
@property (nonatomic, copy, nullable) void (^onPrimaryTap)(void);

/**
 * @brief Tap callback for the secondary CTA (Interpreter)
 * @chinese 次按钮点击回调（同传）
 */
@property (nonatomic, copy, nullable) void (^onSecondaryTap)(void);

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
 * CN: 需要的高度
 */
+ (CGFloat)heightForWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
