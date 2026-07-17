//
//  UIColor+Tool.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Tool)

/**
 * @brief Extract RGBA values from UIColor and convert to dictionary
 * @chinese 从UIColor提取RGBA值并转换为字典
 *
 * @param color
 * EN: Source UIColor
 * CN: 源UIColor对象
 *
 * @return
 * EN: Dictionary with R, G, B, A keys (0-255 range), nil if color cannot be parsed
 * CN: 包含R、G、B、A键的字典（0-255范围），如果颜色无法解析则返回nil
 *
 * @discussion
 * [EN]: This method extracts RGBA values from UIColor and converts them to a dictionary
 *       with integer values in 0-255 range. Supports various color spaces.
 * [CN]: 此方法从UIColor提取RGBA值并转换为字典，整数值范围为0-255。支持多种颜色空间。
 */
+ (nullable NSDictionary<NSString *, NSNumber *> *)rgbaDictionaryFromColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
