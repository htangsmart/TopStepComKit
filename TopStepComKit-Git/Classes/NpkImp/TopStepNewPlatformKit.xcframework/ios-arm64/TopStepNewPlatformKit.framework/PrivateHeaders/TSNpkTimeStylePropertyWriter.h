//
//  TSNpkTimeStylePropertyWriter.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSNpkScreenPropertyResolver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Outcome of writing a time position into one "PropertyValues" array
 * @chinese 向一组 "PropertyValues" 写入时间位置的结果
 */
@interface TSNpkTimeStyleWriteResult : NSObject

/** @brief Both X and Y were written into WidgetCoord properties @chinese X、Y 都已写进 WidgetCoord 属性 */
@property (nonatomic, assign, readonly) BOOL wroteCoord;
/** @brief The axis of each coordinate came from the template bindings, not from its order @chinese 坐标的 X/Y 归属来自模板里的绑定关系，而不是靠出现顺序推断 */
@property (nonatomic, assign, readonly) BOOL resolvedByBinding;
/** @brief Widget whose position the written coordinates drive; nil when unknown @chinese 被写入坐标所驱动的控件 Id；无法确定时为 nil */
@property (nonatomic, strong, readonly, nullable) NSNumber *positionWidgetId;

@end

/**
 * @brief Writes the time position and color into one "PropertyValues" array
 * @chinese 把时间位置和颜色写进一组 "PropertyValues"
 *
 * @discussion
 * [EN]: Properties are matched by ValueDataTypeName, never by index. For "WidgetCoord" the axis and the driven widget
 *       are taken from the template bindings (Style.Position.X / Style.Position.Y); only when the template carries
 *       no bindings does it fall back to the convention "first WidgetCoord is X, second is Y".
 *       Every "SerializableColor" receives the color.
 * [CN]: 按 ValueDataTypeName 匹配属性，不依赖下标。"WidgetCoord" 属于 X 还是 Y、驱动哪个控件，
 *       优先取模板里的绑定关系（Style.Position.X / Style.Position.Y）；模板里没有绑定信息时，
 *       才退回"第一个 WidgetCoord 是 X，第二个是 Y"的约定。所有 "SerializableColor" 写入颜色。
 */
@interface TSNpkTimeStylePropertyWriter : NSObject

/**
 * @brief Apply origin and color using the template bindings
 * @chinese 依据模板绑定关系写入位置与颜色
 *
 * @param origin EN: Top-left of the time area in screen pixels. CN: 时间区域左上角的屏幕像素坐标。
 * @param color EN: Tint color, nil keeps the template color. CN: 颜色，nil 表示保留模板颜色。
 * @param propertyValues EN: Mutable array of mutable property dictionaries. CN: 属性字典的可变数组（字典也需可变）。
 * @param resolver EN: Binding resolver; nil means "use the order convention". CN: 绑定解析器；为 nil 时按出现顺序约定处理。
 * @param preferredWidgetId EN: Id of the time container; coordinates driving it win when several widgets are driven.
 *                          CN: 时间容器控件的 Id；当坐标驱动多个控件时，优先写驱动它的那一组。
 * @return EN: What was written. CN: 写入结果。
 */
+ (TSNpkTimeStyleWriteResult *)writeOrigin:(CGPoint)origin
                                     color:(nullable UIColor *)color
                        intoPropertyValues:(NSMutableArray *)propertyValues
                                  resolver:(nullable TSNpkScreenPropertyResolver *)resolver
                         preferredWidgetId:(nullable NSNumber *)preferredWidgetId;

/**
 * @brief Apply origin and color using the order convention only
 * @chinese 只按出现顺序约定写入位置与颜色
 *
 * @return EN: YES when both X and Y were written into WidgetCoord properties. CN: X、Y 都写进了 WidgetCoord 属性时返回 YES。
 */
+ (BOOL)writeOrigin:(CGPoint)origin
              color:(nullable UIColor *)color
 intoPropertyValues:(NSMutableArray *)propertyValues;

@end

NS_ASSUME_NONNULL_END
