//
//  TSDialTime+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/8/30.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK template helpers for dial time configuration
 * @chinese 表盘时间配置的 NPK 模板辅助能力
 */
@interface TSDialTime (Npk)

/**
 * @brief Get the actual time display rectangle
 * @chinese 获取实际的时间显示矩形区域
 *
 * @param dialSize
 * EN: Device dial size.
 * CN: 设备表盘尺寸。
 *
 * @return
 * EN: Explicit timeRect when present, otherwise the NPK default rectangle.
 * CN: timeRect 非空时返回其值，否则返回 NPK 默认矩形区域。
 */
- (CGRect)actualTimeRectWithDialSize:(CGSize)dialSize;

/**
 * @brief Convert the public one-based style to the PB template zero-based index
 * @chinese 将公开的一基样式转换为 PB 模板的零基下标
 *
 * @return
 * EN: Zero-based template style index.
 * CN: 模板零基样式下标。
 */
- (NSInteger)npkTemplateStyleIndex;

@end

NS_ASSUME_NONNULL_END
