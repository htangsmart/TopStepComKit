//
//  TSNpkScreenLocator.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkScreenDocument;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Finds the nodes of screen.json that dial building needs
 * @chinese 在 screen.json 中定位造包要用到的节点
 *
 * @discussion
 * [EN]: Looks a node up by its conventional name first; templates made before the naming convention have no such
 *       names, so it then falls back to the node's structural position. All template-generation differences are
 *       contained here. Returned containers are the live mutable nodes of the document.
 * [CN]: 先按约定的名字查找；命名约定出现之前制作的模板没有这些名字，此时退回按结构位置查找。
 *       新旧模板的差异全部收在这个类里。返回的容器就是文档里的可变节点本身。
 */
@interface TSNpkScreenLocator : NSObject

- (instancetype)initWithDocument:(TSNpkScreenDocument *)document NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Background widget: "bg_widget", else the first child whose WidgetType matches
 * @chinese 背景控件：先找 "bg_widget"，找不到取第一个 WidgetType 匹配的子控件
 *
 * @param widgetType EN: "ImageWidget" or "VideoWidget". CN: "ImageWidget" 或 "VideoWidget"。
 */
- (nullable NSMutableDictionary *)backgroundWidgetOfType:(NSString *)widgetType;

/**
 * @brief Time style presets: "time_presets", else the first unnamed preset
 * @chinese 时间样式预设：先找 "time_presets"，找不到取第一个没有名字的预设
 */
- (nullable NSMutableDictionary *)timePresets;

/**
 * @brief Multi-image presets: "multiple_presets" (name only, no fallback)
 * @chinese 多图预设："multiple_presets"（只按名字，不做回退）
 */
- (nullable NSMutableDictionary *)multiplePresets;

/**
 * @brief Container of the time widgets: "time_widget", else the second child
 * @chinese 时间控件容器：先找 "time_widget"，找不到取第二个子控件
 */
- (nullable NSMutableDictionary *)timeContainerWidget;

/**
 * @brief Any widget in the Children tree by its Id (searches nested children too)
 * @chinese 按 Id 在 Children 树里查找控件（包含嵌套的子控件）
 *
 * @param widgetId EN: Value of the widget's "Id". CN: 控件 "Id" 的值。
 */
- (nullable NSMutableDictionary *)widgetWithId:(NSNumber *)widgetId;

/**
 * @brief Timer in Setting.Timers by name (no fallback)
 * @chinese 按名字查找 Setting.Timers 里的计时器（不做回退）
 */
- (nullable NSMutableDictionary *)timerNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
