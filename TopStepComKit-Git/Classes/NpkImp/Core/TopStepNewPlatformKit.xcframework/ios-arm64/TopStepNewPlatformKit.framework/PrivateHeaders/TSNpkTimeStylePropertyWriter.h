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

/**
 * @brief Whether both coordinate axes were written
 * @chinese 是否已写入两个坐标轴
 *
 * @discussion
 * [EN]: YES only after both X and Y WidgetCoord values were updated; color-only changes do not make it YES.
 * [CN]: 仅在 X、Y 两个 WidgetCoord 值均被更新后为 YES；单独改色不设置此标记。
 */
@property (nonatomic, assign, readonly) BOOL wroteCoord;
/**
 * @brief Whether template bindings determined coordinate axes
 * @chinese 坐标轴是否由模板绑定确定
 *
 * @discussion
 * [EN]: YES when the binding-based path ran; NO for order fallback. It may be YES even when wroteCoord is NO.
 * [CN]: 采用绑定路径时为 YES，按顺序回退时为 NO；即使 wroteCoord 为 NO，此值仍可能为 YES。
 */
@property (nonatomic, assign, readonly) BOOL resolvedByBinding;
/**
 * @brief Widget selected for coordinate updates
 * @chinese 选定进行坐标更新的控件
 *
 * @discussion
 * [EN]: Set by binding resolution to the chosen target; nil for order fallback. Its presence does not guarantee both axes were found.
 * [CN]: 绑定解析时设置为选定目标；按顺序回退时为 nil，非空不保证已找到两个坐标轴。
 */
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
