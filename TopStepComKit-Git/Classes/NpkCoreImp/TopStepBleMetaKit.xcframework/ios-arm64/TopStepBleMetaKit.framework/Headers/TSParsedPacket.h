//
//  TSParsedPacket.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 解析后的数据包对象
 * @chinese 用于存储解析后的协议数据包信息
 *
 * @discussion
 * EN: This class represents a parsed protocol data packet with all fields extracted
 *     from the raw packet data. It provides a structured way to access packet information
 *     instead of using dictionary keys.
 * CN: 此类表示解析后的协议数据包，包含从原始数据包中提取的所有字段。
 *     它提供了一种结构化的方式来访问数据包信息，而不是使用字典键。
 *
 * @note
 * EN: This class is immutable once created. All properties are readonly.
 * CN: 此类在创建后是不可变的。所有属性都是只读的。
 */
@interface TSParsedPacket : NSObject

#pragma mark - 基础协议字段

/**
 * @brief 魔数字节
 * @chinese 协议魔数字节，固定为0xAB
 *
 * @discussion
 * EN: Protocol magic byte, fixed value 0xAB for packet validation.
 * CN: 协议魔数字节，固定值0xAB用于数据包验证。
 */
@property (nonatomic, assign, readonly) UInt8 magicByte;

/**
 * @brief 命令字节
 * @chinese 主命令类型标识符
 *
 * @discussion
 * EN: Main command type identifier (0x00-0xFF).
 * CN: 主命令类型标识符 (0x00-0xFF)。
 */
@property (nonatomic, assign, readonly) UInt8 cmd;

/**
 * @brief 功能键
 * @chinese 子命令或功能键标识符
 *
 * @discussion
 * EN: Sub-command or function key identifier (0x00-0xFF).
 * CN: 子命令或功能键标识符 (0x00-0xFF)。
 */
@property (nonatomic, assign, readonly) UInt8 key;

/**
 * @brief 序列号
 * @chinese 数据包序列号，用于请求响应匹配
 *
 * @discussion
 * EN: Packet sequence ID for request-response matching.
 * CN: 数据包序列号，用于请求响应匹配。
 */
@property (nonatomic, assign, readonly) UInt16 sequenceId;

/**
 * @brief 载荷长度
 * @chinese 载荷数据的长度（字节数）
 *
 * @discussion
 * EN: Length of the payload data in bytes.
 * CN: 载荷数据的长度（字节数）。
 *
 * @note
 * EN: For fragmented packets, this includes the fragmentation header (8 bytes).
 * CN: 对于分包数据，此长度包含分包头部（8字节）。
 */
@property (nonatomic, assign, readonly) UInt16 payloadLength;

/**
 * @brief 载荷CRC16校验值
 * @chinese 载荷数据的CRC16校验值
 *
 * @discussion
 * EN: CRC16 checksum of the payload data for integrity verification.
 * CN: 载荷数据的CRC16校验值，用于完整性验证。
 */
@property (nonatomic, assign, readonly) UInt16 payloadCRC;

#pragma mark - 标志位信息

/**
 * @brief 原始标志位字节
 * @chinese 原始的标志位字节值
 *
 * @discussion
 * EN: Raw flags byte value containing all flag bits.
 * CN: 包含所有标志位的原始标志位字节值。
 */
@property (nonatomic, assign, readonly) UInt8 flags;

/**
 * @brief Response flag (deprecated)
 * @chinese 是否为响应包（已废弃）
 *
 * @discussion
 * [EN]: Indicates whether this packet is a response packet.
 *       This property is deprecated and temporarily unavailable.
 *       Please do NOT rely on this flag for routing. Use the upper-layer
 *       dispatcher/manager logic to distinguish response vs notify.
 * [CN]: 标识该数据包是否为响应包。
 *       此属性已废弃，且暂时不可用。
 *       请不要依赖该标志进行路由判断，改为使用上层分发/管理逻辑
 *       来区分响应与通知。
 *
 * @note
 * [EN]: Deprecated. Temporarily unavailable. Subject to removal in future versions.
 * [CN]: 废弃，且暂不可用；后续版本可能移除。
 */
@property (nonatomic, assign, readonly) BOOL isResponse __attribute__((deprecated("TSParsedPacket.isResponse is deprecated and temporarily unavailable. Use upper-layer dispatcher for routing.")));

/**
 * @brief 是否为重传包
 * @chinese 标识该数据包是否为重传包
 *
 * @discussion
 * EN: Indicates whether this packet is a retransmission.
 * CN: 标识该数据包是否为重传包。
 */
@property (nonatomic, assign, readonly) BOOL isRetransmission;

/**
 * @brief 是否为分包
 * @chinese 标识该数据包是否为分包数据
 *
 * @discussion
 * EN: Indicates whether this packet is part of a fragmented transmission.
 * CN: 标识该数据包是否为分包数据。
 */
@property (nonatomic, assign, readonly) BOOL isFragmented;

/**
 * @brief 保留字段
 * @chinese 标志位中的保留字段值
 *
 * @discussion
 * EN: Reserved field value from the flags byte (5 bits).
 * CN: 标志位字节中的保留字段值（5位）。
 */
@property (nonatomic, assign, readonly) UInt8 reserved;

#pragma mark - 载荷数据

/**
 * @brief 原始载荷数据
 * @chinese 原始的载荷数据（包含分包头部）
 *
 * @discussion
 * EN: Raw payload data including fragmentation header if present.
 * CN: 原始载荷数据，如果存在则包含分包头部。
 *
 * @note
 * EN: For fragmented packets, this includes the 8-byte fragmentation header.
 * CN: 对于分包数据，此数据包含8字节的分包头部。
 */
@property (nonatomic, strong, readonly) NSData *payloadData;

/**
 * @brief 实际载荷数据
 * @chinese 去除分包头部后的实际载荷数据
 *
 * @discussion
 * EN: Actual payload data with fragmentation header removed (if any).
 * CN: 去除分包头部后的实际载荷数据（如果有的话）。
 *
 * @note
 * EN: For non-fragmented packets, this is the same as payloadData.
 *     For fragmented packets, this excludes the 8-byte fragmentation header.
 * CN: 对于非分包数据，此数据与payloadData相同。
 *     对于分包数据，此数据不包含8字节的分包头部。
 */
@property (nonatomic, strong, readonly) NSData *actualPayloadData;

#pragma mark - 分包信息

/**
 * @brief 总包数
 * @chinese 分包传输的总包数
 *
 * @discussion
 * EN: Total number of packets in fragmented transmission.
 * CN: 分包传输的总包数。
 *
 * @note
 * EN: Only valid when isFragmented is YES. Value is 0 for non-fragmented packets.
 * CN: 仅当isFragmented为YES时有效。非分包数据的值为0。
 */
@property (nonatomic, assign, readonly) UInt32 totalPackets;

/**
 * @brief 当前包序号
 * @chinese 当前分包在整个传输中的序号
 *
 * @discussion
 * EN: Index of current packet in fragmented transmission (0-based).
 * CN: 当前分包在整个传输中的序号（从0开始）。
 *
 * @note
 * EN: Only valid when isFragmented is YES. Value is 0 for non-fragmented packets.
 * CN: 仅当isFragmented为YES时有效。非分包数据的值为0。
 */
@property (nonatomic, assign, readonly) UInt32 currentPacketIndex;

#pragma mark - 初始化方法

/**
 * @brief 从解析字典创建数据包对象
 * @chinese 从TSCommandDataParser解析的字典创建数据包对象
 *
 * @param parsedDict 解析后的数据字典
 *        EN: Parsed data dictionary from TSCommandDataParser
 *        CN: 来自TSCommandDataParser的解析数据字典
 *
 * @return 解析后的数据包对象，解析失败返回nil
 *         EN: Parsed packet object, nil if parsing fails
 *         CN: 解析后的数据包对象，解析失败返回nil
 */
+ (nullable instancetype)packetWithParsedDictionary:(NSDictionary *)parsedDict;

/**
 * @brief 指定初始化方法
 * @chinese 使用解析字典初始化数据包对象
 *
 * @param parsedDict 解析后的数据字典
 *        EN: Parsed data dictionary from TSCommandDataParser
 *        CN: 来自TSCommandDataParser的解析数据字典
 *
 * @return 初始化的数据包对象，解析失败返回nil
 *         EN: Initialized packet object, nil if parsing fails
 *         CN: 初始化的数据包对象，解析失败返回nil
 */
- (nullable instancetype)initWithParsedDictionary:(NSDictionary *)parsedDict NS_DESIGNATED_INITIALIZER;

// 禁用默认初始化方法
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - 便利方法

/**
 * @brief 验证数据包是否有效
 * @chinese 验证数据包的基本字段是否有效
 *
 * @return 数据包是否有效
 *         EN: Whether the packet is valid
 *         CN: 数据包是否有效
 */
- (BOOL)isValid;

/**
 * @brief 检查是否为指定命令的数据包
 * @chinese 检查数据包是否匹配指定的命令和键
 *
 * @param cmd 命令字节
 *        EN: Command byte to match
 *        CN: 要匹配的命令字节
 *
 * @param key 功能键字节
 *        EN: Key byte to match
 *        CN: 要匹配的功能键字节
 *
 * @return 是否匹配
 *         EN: Whether the packet matches the specified command and key
 *         CN: 数据包是否匹配指定的命令和键
 */
- (BOOL)matchesCommand:(UInt8)cmd key:(UInt8)key;

/**
 * @brief 检查是否为指定序列号的数据包
 * @chinese 检查数据包是否匹配指定的序列号
 *
 * @param sequenceId 序列号
 *        EN: Sequence ID to match
 *        CN: 要匹配的序列号
 *
 * @return 是否匹配
 *         EN: Whether the packet matches the specified sequence ID
 *         CN: 数据包是否匹配指定的序列号
 */
- (BOOL)matchesSequenceId:(UInt16)sequenceId;

/**
 * @brief 获取数据包的描述信息
 * @chinese 获取数据包的详细描述信息，用于调试
 *
 * @return 描述字符串
 *         EN: Description string for debugging
 *         CN: 用于调试的描述字符串
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
