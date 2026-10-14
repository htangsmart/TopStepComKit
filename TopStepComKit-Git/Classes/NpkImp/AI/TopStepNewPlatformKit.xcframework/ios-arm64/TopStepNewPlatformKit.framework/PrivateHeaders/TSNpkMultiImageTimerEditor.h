//
//  TSNpkMultiImageTimerEditor.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkScreenLocator;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configures the auto-switch timer of a multi-image dial
 * @chinese 配置多图表盘的自动切换计时器
 */
@interface TSNpkMultiImageTimerEditor : NSObject

/**
 * @brief Enable or disable "multiple_timer"
 * @chinese 开关 "multiple_timer"
 *
 * @param intervalMillis EN: Switch interval in milliseconds; 0 or less disables auto switching.
 *                       CN: 切换间隔（毫秒）；小于等于 0 表示关闭自动切换。
 * @param locator EN: Locator of the screen document being edited. CN: 正在编辑的 screen 文档的定位器。
 *
 * @discussion
 * [EN]: A template without the timer is left unchanged.
 * [CN]: 模板里没有该计时器时不做任何修改。
 */
+ (void)applyIntervalMillis:(NSInteger)intervalMillis locator:(TSNpkScreenLocator *)locator;

@end

NS_ASSUME_NONNULL_END
