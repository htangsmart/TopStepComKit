//
//  TSAIKitRootIconView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSAIKitRootCapability.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Vector icon view drawn with CAShapeLayer paths
 * @chinese 用 CAShapeLayer 路径绘制的矢量图标
 *
 * @discussion
 * [EN]: Each `iconType` maps to a deterministic 24x24 path set, scaled into the
 *       view bounds. Uses `tintColor` for strokes; no external image resources.
 * [CN]: 每个 `iconType` 对应一组固定的 24x24 路径，按视图尺寸缩放绘制。
 *       使用 `tintColor` 作为描边色，无外部图片资源依赖。
 */
@interface TSAIKitRootIconView : UIView

/**
 * @brief Icon variant to render
 * @chinese 当前要绘制的图标类型
 */
@property (nonatomic, assign) TSAIKitRootCapabilityIcon iconType;

@end

NS_ASSUME_NONNULL_END
