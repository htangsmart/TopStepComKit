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

@end

NS_ASSUME_NONNULL_END
