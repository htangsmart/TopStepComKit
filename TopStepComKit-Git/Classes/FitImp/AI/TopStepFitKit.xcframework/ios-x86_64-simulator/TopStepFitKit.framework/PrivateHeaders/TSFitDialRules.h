#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Scalar packing rule errors. @chinese 打包数值规则错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSFitDialRulesErrorDomain;
/** @brief Invalid scalar arguments. @chinese 数值参数错误。 */
typedef NS_ERROR_ENUM(TSFitDialRulesErrorDomain, TSFitDialRulesErrorCode) {
    TSFitDialRulesErrorInvalidParameter = 75001,
};
/** @brief Packed coordinate anchors. @chinese 编码坐标的锚点。 */
typedef NS_ENUM(NSInteger, TSFitDialCoordinateAnchor) {
    TSFitDialCoordinateAnchorStart = 1,
    TSFitDialCoordinateAnchorEnd = 2,
    TSFitDialCoordinateAnchorCenter = 3,
};

/** @brief Android 3410b969 scalar rules, independent of device APIs. @chinese 独立于设备接口的 Android 3410b969 数值规则。 */
@interface TSFitDialRules : NSObject
/**
 * @brief Resolve a custom signed decimal ID, falling back to the platform/LCD default.
 * @chinese 解析自定义十进制编号，无效时采用平台及 LCD 默认编号。
 * @param customID EN: Optional decimal string; no whitespace allowed. CN: 可选十进制字符串，不允许空白。
 * @param platform EN: 3 for 568X, 4 for 579X. CN: 568X 为 3，579X 为 4。
 * @param lcd EN: Unsigned 16-bit LCD number. CN: 16 位无符号 LCD 编号。
 * @param error EN: Optional invalid-platform/LCD error. CN: 可选平台或 LCD 错误。
 * @return EN: Resolved ID, or nil for invalid arguments. CN: 表盘编号，参数无效返回 nil。
 */
+ (nullable NSNumber *)dialIDWithCustomID:(nullable NSString *)customID
                                platform:(NSUInteger)platform
                                     lcd:(NSUInteger)lcd
                                   error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Encode the 50ms carousel interval; nonpositive values become 20.
 * @chinese 编码单位为 50ms 的轮播间隔，非正数按 20 处理。
 * @param milliseconds EN: Android signed 32-bit millisecond interval. CN: Android 32 位有符号毫秒间隔。
 * @return EN: Interval byte. CN: 间隔字节。
 */
+ (uint8_t)intervalCodeForMilliseconds:(int32_t)milliseconds;
/**
 * @brief Round float pixels/second divided by 20 to nearest even, then clamp to 1...20.
 * @chinese 单精度像素每秒除以 20 后按最接近偶数舍入，再限制为 1～20。
 * @param walkSpeed EN: Float pixels per second, including Kotlin-compatible NaN/infinity handling. CN: 单精度像素每秒，兼容 Kotlin 的 NaN 与无穷值处理。
 * @return EN: Firmware speed byte. CN: 固件速度字节。
 */
+ (uint8_t)danMuSpeedCodeForWalkSpeed:(float)walkSpeed;
/**
 * @brief Encode an anchor and signed 20-bit offset.
 * @chinese 编码锚点和 20 位有符号偏移。
 * @param anchor EN: Start, end, or center. CN: 起始、末尾或居中。
 * @param offset EN: -524288...524287 pixels. CN: -524288～524287 像素。
 * @param error EN: Optional argument error. CN: 可选参数错误。
 * @return EN: Android coordinate specification, or nil. CN: Android 坐标编码，失败返回 nil。
 */
+ (nullable NSNumber *)coordinateWithAnchor:(TSFitDialCoordinateAnchor)anchor
                                     offset:(int32_t)offset
                                      error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Resolve either raw absolute pixels or an Android packed coordinate.
 * @chinese 解析原始绝对像素或 Android 编码坐标，居中除法向零截断。
 * @param specification EN: Signed 32-bit Android coordinate. CN: Android 32 位有符号坐标。
 * @param containerSize EN: Positive axis length. CN: 该轴容器正数长度。
 * @param contentSize EN: Positive content length. CN: 该轴内容正数长度。
 * @param error EN: Optional argument error. CN: 可选参数错误。
 * @return EN: Signed top-left pixel coordinate, or nil. CN: 有符号左上像素坐标，失败返回 nil。
 */
+ (nullable NSNumber *)resolveCoordinate:(int32_t)specification
                           containerSize:(int32_t)containerSize
                             contentSize:(int32_t)contentSize
                                   error:(NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
