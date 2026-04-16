//
//  NSData+Tool.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/8/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NSData bit utilities
 * @chinese NSData 位操作工具
 */
@interface NSData (Tool)

/**
 * @brief Read a bit value at the given global bit index (LSB-first per byte)
 * @chinese 读取全局位索引处的比特值（每字节按低位在前）
 *
 * @param bitIndex 
 * EN: Global bit index starting from 0 (bit 0 is the LSB of byte 0)
 * CN: 全局位索引，从0开始（第0位为第0字节的最低位）
 *
 * @return 
 * EN: YES if the bit is 1; NO if 0 or index out of bounds
 * CN: 若该位为1则返回YES；为0或越界返回NO
 */
- (BOOL)bitAtIndex:(NSUInteger)bitIndex;

/**
 * @brief Return a mutable copy with the target bit set/cleared; ensures length>=4
 * @chinese 返回设置/清除目标位后的可变副本；会确保长度>=4
 *
 * @param bitIndex 
 * EN: Global bit index starting from 0
 * CN: 全局位索引，从0开始
 *
 * @param on 
 * EN: YES to set 1, NO to clear 0
 * CN: YES 置1，NO 置0
 */
- (NSMutableData *)mutableBySettingBitAtIndex:(NSUInteger)bitIndex value:(BOOL)on;


/**
 * @brief 计算CRC16校验值
 * @chinese 使用 CRC-16/IBM 查表算法（poly 0xA001，init 0x0000）计算校验值
 *
 * @param data 要计算CRC的数据
 *        EN: Data to calculate CRC for
 *        CN: 要计算CRC的数据
 *
 * @return CRC16校验值
 *         EN: CRC16 checksum value
 *         CN: CRC16校验值
 */
+ (UInt16)calculateCRC16:(NSData *)data;

/**
 * @brief 计算CRC32校验值（完整版本）
 * @chinese 使用 CRC-32/IEEE 查表算法（poly 0xedb88320）计算校验值
 *
 * @param data 要计算CRC的数据
 *        EN: Data to calculate CRC for
 *        CN: 要计算CRC的数据
 *
 * @param initialCRC 初始CRC值
 *        EN: Initial CRC value
 *        CN: 初始CRC值
 *
 * @return CRC32校验值
 *         EN: CRC32 checksum value
 *         CN: CRC32校验值
 */
+ (UInt32)calculateCRC32:(NSData *)data withInitialCRC:(UInt32)initialCRC;

/**
 * @brief 计算CRC32校验值（简化版本，初始值为0）
 * @chinese 使用 CRC-32/IEEE 查表算法（poly 0xedb88320）计算校验值
 *
 * @param data 要计算CRC的数据
 *        EN: Data to calculate CRC for
 *        CN: 要计算CRC的数据
 *
 * @return CRC32校验值
 *         EN: CRC32 checksum value
 *         CN: CRC32校验值
 */
+ (UInt32)calculateCRC32:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
