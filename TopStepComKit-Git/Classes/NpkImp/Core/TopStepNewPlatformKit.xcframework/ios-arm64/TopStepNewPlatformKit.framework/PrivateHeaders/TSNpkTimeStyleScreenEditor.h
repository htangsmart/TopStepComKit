//
//  TSNpkTimeStyleScreenEditor.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSDialTime;
@class TSNpkScreenLocator;
@class TSNpkScreenPropertyResolver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Applies one time style (style, position, color) to a single-image or video dial
 * @chinese 给单图或视频表盘应用一个时间样式（样式、位置、颜色）
 */
@interface TSNpkTimeStyleScreenEditor : NSObject

/**
 * @brief Apply the time configuration
 * @chinese 应用时间配置
 *
 * @param time EN: Time configuration; nil means the dial has no time component and nothing is changed.
 *             CN: 时间配置；为 nil 表示没有时间组件，不做任何修改。
 * @param screenSize EN: Screen size in pixels. CN: 屏幕像素尺寸。
 * @param locator EN: Locator of the screen document being edited. CN: 正在编辑的 screen 文档的定位器。
 * @param resolver EN: Binding resolver of the same document; tells which widget a WidgetCoord drives.
 *                 CN: 同一文档的绑定解析器；用来判断 WidgetCoord 驱动的是哪个控件。
 *
 * @discussion
 * [EN]: A template without time presets is not an error: the dial simply has no time component.
 * [CN]: 模板里没有时间预设不算错误，表示该表盘没有时间组件。
 */
+ (void)applyTime:(nullable TSDialTime *)time
       screenSize:(CGSize)screenSize
          locator:(TSNpkScreenLocator *)locator
         resolver:(TSNpkScreenPropertyResolver *)resolver;

@end

NS_ASSUME_NONNULL_END
