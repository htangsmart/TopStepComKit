//
//  BtUtils.h
//  JuPlus
//
//  Created by 孙强 on 2022/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BtUtils : NSObject
+(NSString *)encryptString:(NSString *)string key:(NSString *)key;
+(bool)verificationCmd:(NSString *)cmd oldData:(NSString *)oldData old2Data:(NSString *)old2Data keyOri:(NSString *)keyOri;
+(NSString *)crc:(NSData*)data;
+(long long)crcLong:(NSData*)data;
+(NSString *)crc8maxim:(NSData*)data;
+(NSData *)watchCrc16:(NSData*)data result:(uint16_t)result;
+(uint16_t)watchCrc16Uint:(NSData*)data result:(uint16_t)result;
/**
 * 计算大数据量的 CRC16 并返回 NSData
 *
 * @param data 要计算 CRC16 的大数据
 * @param result CRC16 计算的初始值
 * @return CRC16 结果 NSData，如果输入数据为空或内存分配失败则返回 nil
 */
+ (nullable NSData *)watchCrc16BigData:(NSData *)data result:(uint16_t)result;

@end

NS_ASSUME_NONNULL_END
