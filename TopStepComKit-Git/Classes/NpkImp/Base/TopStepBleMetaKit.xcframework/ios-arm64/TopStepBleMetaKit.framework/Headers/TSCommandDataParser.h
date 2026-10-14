//
//  TSCommandDataParser.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import <Foundation/Foundation.h>

@class TSParsedPacket;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 命令数据包解析器
 * @chinese 专门负责解析协议数据包，遵循单一职责原则
 *
 * @discussion
 * EN: This class is dedicated to parsing protocol data packets, following the single responsibility principle.
 * It only handles the parsing of received data packets.
 * CN: 此类专门负责解析协议数据包，遵循单一职责原则。
 * 只处理接收到的数据包的解析工作。
 */
@interface TSCommandDataParser : NSObject

/**
 * @brief 解析数据包（推荐方法）
 * @chinese 从完整数据包中解析出各个字段，返回结构化对象
 *
 * @param packetData 完整的数据包
 *        EN: Complete data packet
 *        CN: 完整的数据包
 *
 * @return 解析后的数据包对象
 *         EN: Parsed packet object containing all fields
 *         CN: 解析后的数据包对象，包含各个字段
 */
+ (nullable TSParsedPacket *)parsePacketToObject:(NSData *)packetData;

/**
 * @brief 验证数据包格式
 * @chinese 验证数据包是否符合协议格式
 *
 * @param packetData 待验证的数据包
 *        EN: Data packet to be validated
 *        CN: 待验证的数据包
 *
 * @return 是否有效
 *         EN: Whether the packet is valid
 *         CN: 数据包是否有效
 */
+ (BOOL)validatePacketFormat:(NSData *)packetData;

/**
 * @brief 提取实际载荷数据
 * @chinese 从解析结果中提取去除分包头的实际数据
 *
 * @param parsedData 解析后的数据字典
 *        EN: Parsed data dictionary
 *        CN: 解析后的数据字典
 *
 * @return 实际载荷数据
 *         EN: Actual payload data
 *         CN: 实际载荷数据
 */
+ (nullable NSData *)extractActualPayloadFromParsedData:(NSDictionary *)parsedData;

/**
 * @brief 提取分包信息
 * @chinese 从解析结果中提取分包相关信息
 *
 * @param parsedData 解析后的数据字典
 *        EN: Parsed data dictionary
 *        CN: 解析后的数据字典
 *
 * @return 分包信息字典
 *         EN: Fragmentation info dictionary
 *         CN: 分包信息字典
 */
+ (nullable NSDictionary *)extractFragmentationInfoFromParsedData:(NSDictionary *)parsedData;

/**
 * @brief 验证分包数据的完整性
 * @chinese 检查分包数据是否完整，包括序号连续性和数据完整性
 *
 * @param packetCache 分包数据缓存字典
 *        EN: Packet cache dictionary with index as key
 *        CN: 以索引为键的分包数据缓存字典
 *
 * @param totalPackets 总包数
 *        EN: Total number of packets
 *        CN: 总包数
 *
 * @return 是否完整
 *         EN: Whether all packets are complete
 *         CN: 所有分包是否完整
 */
+ (BOOL)validateFragmentedDataCompleteness:(NSDictionary<NSNumber *, NSData *> *)packetCache
                               totalPackets:(UInt32)totalPackets;

/**
 * @brief 拼接分包数据
 * @chinese 将多个分包数据按顺序拼接成完整数据
 *
 * @param packetCache 分包数据缓存字典
 *        EN: Packet cache dictionary with index as key
 *        CN: 以索引为键的分包数据缓存字典
 *
 * @param totalPackets 总包数
 *        EN: Total number of packets
 *        CN: 总包数
 *
 * @return 拼接后的完整数据
 *         EN: Assembled complete data
 *         CN: 拼接后的完整数据
 */
+ (nullable NSData *)assembleFragmentedData:(NSDictionary<NSNumber *, NSData *> *)packetCache
                               totalPackets:(UInt32)totalPackets;

@end

NS_ASSUME_NONNULL_END 
