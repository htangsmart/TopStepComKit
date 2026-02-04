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

/**
 * @brief Split data into chunks of specified size
 * @chinese 将数据按指定大小拆分成多个数据块
 *
 * @param data
 * EN: The NSData object to be split
 * CN: 要拆分的NSData对象
 *
 * @param chunkSize
 * EN: Maximum size of each chunk in bytes
 * CN: 每个数据块的最大大小（字节）
 *
 * @return
 * EN: Array of NSData objects. If data size is less than chunkSize, returns array with single element containing the original data. Otherwise, returns array of data chunks split by chunkSize.
 * CN: NSData对象数组。如果数据大小小于chunkSize，返回包含原始数据的单元素数组。否则，返回按chunkSize拆分的数据块数组。
 *
 * @discussion
 * EN: This method splits the specified NSData object into multiple chunks of the specified size.
 *     If the data size is less than or equal to chunkSize, a single-element array containing
 *     the original data is returned. Otherwise, the data is split into chunks where each chunk
 *     (except possibly the last one) has exactly chunkSize bytes.
 * CN: 此方法将指定的NSData对象按指定大小拆分成多个数据块。
 *     如果数据大小小于或等于chunkSize，返回包含原始数据的单元素数组。
 *     否则，数据被拆分成多个数据块，每个数据块（可能最后一个除外）的大小正好是chunkSize字节。
 *
 * @note
 * EN: - If data is nil or empty, returns empty array.
 *     - If chunkSize is 0, returns empty array.
 *     - The last chunk may be smaller than chunkSize if data length is not evenly divisible.
 * CN: - 如果data为nil或空，返回空数组。
 *     - 如果chunkSize为0，返回空数组。
 *     - 如果数据长度不能被chunkSize整除，最后一个数据块可能小于chunkSize。
 */
+ (NSArray<NSData *> *)splitData:(NSData *)data chunkSize:(NSUInteger)chunkSize;

@end

NS_ASSUME_NONNULL_END
