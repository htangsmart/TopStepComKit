//
//  NSData+Hex.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Hex)

/**
 * 将NSData转换为16进制字符串
 * @return 16进制字符串，格式如："48656C6C6F"
 */
- (NSString *)hexString;

/**
 * 将NSData转换为带空格的16进制字符串
 * @return 带空格的16进制字符串，格式如："48 65 6C 6C 6F"
 */
- (NSString *)hexStringWithSpaces;

/**
 * @brief Convert hex string to NSData
 * @chinese 将十六进制字符串转换为二进制数据
 *
 * @param hexString
 * EN: Hex string. Case-insensitive, whitespaces allowed, optional prefix "0x".
 * CN: 十六进制字符串。不区分大小写，允许空格，支持可选前缀“0x”。
 *
 * @return
 * EN: NSData if the input is valid; returns nil when the string is empty, has odd length, or contains invalid hex characters.
 * CN: 当输入有效时返回NSData；若字符串为空、长度为奇数或包含非法十六进制字符则返回nil。
 *
 * @discussion
 * EN:
 *  - Input examples: "0x0A1B", "0a 1b FF", "0A1BFF".
 *  - Time complexity: O(n), where n is the string length.
 *  - The method trims whitespaces/newlines and removes spaces, then parses every two characters into one byte.
 * CN:
 *  - 输入示例：“0x0A1B”、“0a 1b FF”、“0A1BFF”。
 *  - 时间复杂度：O(n)，n为字符串长度。
 *  - 方法会去除首尾空白并移除中间空格，然后每两位解析成一个字节。
 *
 * @code
 * // Usage 示例
 * NSData *data = [NSData dataFromHexString:@"0801101218A6012037"]; // -> <08 01 10 12 18 A6 01 20 37>
 * @endcode
 */

+ (NSData *)dataFromHexString:(NSString *)hexString ;


@end

NS_ASSUME_NONNULL_END
