//
//  TSDialEditorAppearance.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief HTML editor colors and shared drawing. @chinese HTML 编辑器的颜色和共用绘制。 */
@interface TSDialEditorAppearance : NSObject
/** @brief Decode RGB. @chinese 转换 RGB 色值。 @param value EN: RGB integer. CN: RGB 整数。 @return EN: Opaque color. CN: 不透明颜色。 */
+ (UIColor *)color:(NSUInteger)value;
/** @brief Decode HEX. @chinese 转换 HEX。 @param hex EN: Six hex digits. CN: 六位色值。 @return EN: Color. CN: 颜色。 */
+ (UIColor *)colorFromHex:(NSString *)hex;
/** @brief Encode color. @chinese 转换颜色为 HEX。 @param color EN: Color. CN: 颜色。 @return EN: Six digits. CN: 六位色值。 */
+ (NSString *)hexFromColor:(UIColor *)color;
/** @brief Create a label. @chinese 创建标签。 @param text EN: Text. CN: 文本。 @param size EN: Points. CN: 字号。 @param color EN: RGB. CN: 色值。 @return EN: Label. CN: 标签。 */
+ (UILabel *)label:(NSString *)text size:(CGFloat)size color:(NSUInteger)color;
/** @brief Create an action button. @chinese 创建操作按钮。 @param title EN: Title. CN: 标题。 @param primary EN: Accent appearance. CN: 主按钮样式。 @return EN: Button. CN: 按钮。 */
+ (UIButton *)button:(NSString *)title primary:(BOOL)primary;
/** @brief Draw section heading. @chinese 创建编号标题。 @param number EN: Section number. CN: 编号。 @param title EN: Title. CN: 标题。 @return EN: Heading. CN: 标题视图。 */
+ (UIView *)heading:(NSInteger)number title:(NSString *)title;
/** @brief Load a prototype icon. @chinese 读取原型图标。 @param name EN: Icon name. CN: 图标名。 @return EN: Template image. CN: 模板图。 */
+ (nullable UIImage *)icon:(NSString *)name;
/** @brief Render the custom color wheel. @chinese 绘制自定义颜色色轮。 @return EN: Wheel image. CN: 色轮图片。 */
+ (UIImage *)colorWheel;
/** @brief Fit an image without distortion. @chinese 等比填充目标像素。 @param image EN: Source. CN: 原图。 @param size EN: Pixels. CN: 像素尺寸。 @return EN: Output. CN: 输出图。 */
+ (UIImage *)fillImage:(UIImage *)image size:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
