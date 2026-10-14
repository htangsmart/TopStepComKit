//
//  TSCommandDataWrapper.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 数据包分包模式枚举
 * @chinese 控制数据包的分包策略
 *
 * @discussion
 * EN: Defines the packet fragmentation strategy for different data types.
 * CN: 定义不同数据类型的数据包分包策略。
 */
typedef NS_ENUM(UInt8, TSPacketMode) {
    /**
     * @brief 对象分包模式
     * @chinese 单个对象数据的分包模式
     *
     * @discussion
     * EN: Single object packet mode. The payload contains only the object data.
     *     Protocol format: Header(10 bytes) + Payload(object data)
     *     Example: 0xAB 06 21 00 00 12 26 99 00 04 / 0A 06 2F 6D 75 73 69 63 10 E1 DE 92 A5 09 18 B0 BA 1F
     * CN: 单个对象数据包模式。载荷只包含对象数据。
     *     协议格式：包头(10字节) + 载荷(对象数据)
     *     示例：0xAB 06 21 00 00 12 26 99 00 04 / 0A 06 2F 6D 75 73 69 63 10 E1 DE 92 A5 09 18 B0 BA 1F
     */
    eTSPacketModeObject = 0,
    
    /**
     * @brief 列表分包模式
     * @chinese 列表数据的分包模式
     *
     * @discussion
     * EN: List packet mode. The payload contains fragmentation info + object data.
     *     Protocol format: Header(10 bytes) + FragmentationInfo(8 bytes) + Payload(object data)
     *     FragmentationInfo: TotalPackets(4 bytes) + CurrentPacketIndex(4 bytes)
     *     Example: 0xAB 06 21 00 00 12 26 99 00 04 / 00 00 00 03 00 00 00 00 / 0A 06 2F 6D 75 73 69 63 10 E1 DE 92 A5 09 18 B0 BA 1F
     * CN: 列表数据包模式。载荷包含分包信息 + 对象数据。
     *     协议格式：包头(10字节) + 分包信息(8字节) + 载荷(对象数据)
     *     分包信息：总包数(4字节) + 当前包索引(4字节)
     *     示例：0xAB 06 21 00 00 12 26 99 00 04 / 00 00 00 03 00 00 00 00 / 0A 06 2F 6D 75 73 69 63 10 E1 DE 92 A5 09 18 B0 BA 1F
     */
    eTSPacketModeList = 1
};

/**
 * @brief 命令数据包装器
 * @chinese 专门负责数据打包和分包，遵循单一职责原则
 *
 * @discussion
 * EN: This class is dedicated to data packaging and fragmentation, following the single responsibility principle.
 * It only handles the encapsulation of raw data into protocol format with optional packet splitting.
 * CN: 此类专门负责数据打包和分包，遵循单一职责原则。
 * 只处理将原始数据封装为协议格式，支持可选的分包功能。
 *
 * @note
 * EN: All methods are class methods. No instance creation needed.
 * CN: 所有方法都是类方法。无需创建实例。
 */
@interface TSCommandDataWrapper : NSObject

#pragma mark - 核心打包方法

/**
 * @brief 将载荷数据打包为可发送的协议数据包
 * @chinese 根据协议格式将原始数据打包，支持自动分包和分包模式控制
 *
 * @param payloadDatas 原始载荷数据数组
 *        EN: Raw payload data array to be wrapped
 *        CN: 要包装的原始载荷数据数组
 *
 * @param command 命令字节 (0x00-0xFF)
 *        EN: Command byte identifier
 *        CN: 命令字节标识符
 *
 * @param key 功能键 (0x00-0xFF)
 *        EN: Function key identifier
 *        CN: 功能键标识符
 *
 * @param sequenceId 序列号
 *        EN: Sequence identifier for request-response matching
 *        CN: 用于请求-响应匹配的序列标识符
 *
 * @param maxPacketSize 单个分包的最大载荷大小（字节），0表示不分包
 *        EN: Maximum payload size per packet in bytes, 0 means no splitting
 *        CN: 单个分包的最大载荷大小（字节），0表示不分包
 *
 * @param packetMode 数据包分包模式
 *        EN: Packet mode for fragmentation strategy
 *        CN: 数据包分包策略模式
 *
 * @return 可发送的数据包数组
 *         EN: Array of ready-to-send protocol packets
 *         CN: 可发送的协议数据包数组
 *
 * @discussion
 * EN: This method wraps payload data into protocol packets with automatic fragmentation support.
 *     - TSPacketModeObject: Single object mode, payload contains only object data
 *     - TSPacketModeList: List mode, payload contains fragmentation info + object data
 * CN: 此方法将载荷数据打包为协议数据包，支持自动分包和分包模式控制。
 *     - TSPacketModeObject：对象模式，载荷只包含对象数据
 *     - TSPacketModeList：列表模式，载荷包含分包信息 + 对象数据
 */
+ (NSArray<NSData *> *)wrapDatas:(nullable NSArray<NSData *> *)payloadDatas
                         command:(UInt8)command
                             key:(UInt8)key
                      sequenceId:(UInt16)sequenceId
                   maxPacketSize:(NSUInteger)maxPacketSize
                      packetMode:(TSPacketMode)packetMode;

@end

NS_ASSUME_NONNULL_END
