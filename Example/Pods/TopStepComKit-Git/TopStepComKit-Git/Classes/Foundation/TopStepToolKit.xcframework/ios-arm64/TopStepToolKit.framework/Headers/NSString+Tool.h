//
//  NSString+Tool.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Tool)

+(NSString*)stringFromHex:(NSString*)hexStr;


+(NSString*)hexStringWithString:(NSString *)string ;


/**
 * @brief 将字典对象转换为JSON字符串
 * @param dic 需要转换的字典对象
 * @return 返回转换后的JSON字符串，如果转换失败则返回nil
 */
+(NSString*)jsonStringFromDict:(NSDictionary*)dic;

/**
 * @brief 根据广播数据获取MAC地址
 * @param advDataManufacturerData 广播数据中的制造商数据
 * @return 返回解析出的MAC地址字符串，如果解析失败则返回nil
 */
+ (NSString *)macAddressWithData:(nonnull NSData *)advDataManufacturerData ;

/**
 * @brief Normalize MAC address and convert to lowercase
 * @chinese 规范化MAC地址并转为小写
 *
 * @param mac
 * EN: Raw MAC address string, such as "AA:BB:CC:DD:EE:FF" or "AA-BB-CC-DD-EE-FF"
 * CN: 原始MAC地址字符串，例如 "AA:BB:CC:DD:EE:FF" 或 "AA-BB-CC-DD-EE-FF"
 *
 * @return
 * EN: Normalized MAC string without separators and in lowercase, e.g. "aabbccddeeff"
 * CN: 规范化后的MAC字符串，去掉分隔符并转为小写，例如 "aabbccddeeff"
 */
+ (NSString *)normalizedMacLowercase:(NSString *)mac;

/**
 * @brief Normalize MAC address and convert to uppercase
 * @chinese 规范化MAC地址并转为大写
 *
 * @param mac
 * EN: Raw MAC address string, such as "AA:BB:CC:DD:EE:FF" or "AA-BB-CC-DD-EE-FF"
 * CN: 原始MAC地址字符串，例如 "AA:BB:CC:DD:EE:FF" 或 "AA-BB-CC-DD-EE-FF"
 *
 * @return
 * EN: Normalized MAC string without separators and in uppercase, e.g. "AABBCCDDEEFF"
 * CN: 规范化后的MAC字符串，去掉分隔符并转为大写，例如 "AABBCCDDEEFF"
 */
+ (NSString *)normalizedMacUppercase:(NSString *)mac;

/**
 * @brief 将十进制数转换为36进制字符串
 * @chinese 将十进制整数转换为36进制表示的字符串（0-9,a-z）
 *
 * @param decimalValue 需要转换的十进制整数
 * @return 36进制字符串，由0-9和a-z组成
 *
 * @discussion
 * 转换规则：
 * 1. 输入范围：正整数
 * 2. 输出字符集：0-9,a-z（共36个字符）
 * 3. 转换方法：除36取余，倒序排列
 *
 * 示例：
 * 输入：12345
 * 输出："9ix"
 */
+ (NSString *)stringByConvertingDecimalToBase36:(int)decimalValue;

/**
 * @brief 将UInt8值转换为16进制字符串
 * @param value UInt8值
 * @return 16进制字符串，如："0A", "FF"
 * 
 * @discussion
 * 这个方法特别适用于打印枚举值的16进制表示
 * 使用%02X格式确保每个值都是两位16进制，不足补0
 * 
 * 示例：
 * 输入：10
 * 输出："0A"
 * 输入：255
 * 输出："FF"
 */
+ (NSString *)hexStringFromUInt8:(UInt8)value;

/**
 * @brief Truncate string to maximum byte length while preserving UTF-8 character integrity
 * @chinese 截取字符串到指定字节长度（保留UTF-8字符完整性）
 *
 * @param maxBytes
 * [EN]: Maximum byte length allowed (UTF-8 encoding)
 * [CN]: 允许的最大字节长度（UTF-8编码）
 *
 * @return
 * [EN]: Truncated string that fits within maxBytes, or original string if already within limit.
 *       Returns empty string if the string is nil or empty.
 * [CN]: 截取后的字符串，符合最大字节长度限制；如果已在限制内则返回原字符串。
 *       如果字符串为nil或空则返回空字符串。
 *
 * @discussion
 * [EN]: This method safely truncates the current string to fit within a specified byte length.
 *       It preserves UTF-8 character boundaries to avoid corrupting multi-byte characters.
 *       The algorithm works by reducing the string length character by character until
 *       a valid UTF-8 string within the byte limit is found.
 * [CN]: 此方法安全地截取当前字符串以适应指定的字节长度。
 *       它保留UTF-8字符边界以避免损坏多字节字符。
 *       算法通过逐字符减少字符串长度，直到找到符合字节限制的有效UTF-8字符串。
 *
 * @note
 * [EN]: This is particularly useful for fields that have byte-length restrictions,
 *       such as device contact names and phone numbers.
 * [CN]: 这对于有字节长度限制的字段特别有用，例如设备联系人姓名和电话号码。
 */
- (NSString *)truncateToMaxBytes:(NSUInteger)maxBytes;

@end

NS_ASSUME_NONNULL_END
