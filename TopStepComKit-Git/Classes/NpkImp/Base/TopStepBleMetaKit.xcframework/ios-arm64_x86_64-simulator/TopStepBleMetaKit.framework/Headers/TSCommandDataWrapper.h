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
 * @brief Immutable identity for one independently scheduled protocol packet
 * @chinese 单个可独立调度协议包的不可变身份
 */
@interface TSCommandPacketContext : NSObject

/**
 * @brief Main command byte
 * @chinese 主命令字节
 * @discussion
 * [EN]: Frozen when this context is created.
 * [CN]: 创建上下文时冻结。
 * @note
 * [EN]: Uses the unchanged wire byte value.
 * [CN]: 使用既有协议字节值。
 */
@property (nonatomic, assign, readonly) UInt8 command;

/**
 * @brief Subcommand key byte
 * @chinese 子命令键字节
 * @discussion
 * [EN]: Frozen with the main command.
 * [CN]: 与主命令一起冻结。
 * @note
 * [EN]: Does not change response matching policy.
 * [CN]: 不改变响应匹配策略。
 */
@property (nonatomic, assign, readonly) UInt8 key;

/**
 * @brief Sequence of this complete protocol packet
 * @chinese 当前完整协议包的序列号
 * @discussion
 * [EN]: Supplied by the existing request scheduler.
 * [CN]: 由既有请求调度器提供。
 * @note
 * [EN]: Multipart snapshot identity does not replace this field.
 * [CN]: 多包快照身份不替代此字段。
 */
@property (nonatomic, assign, readonly) UInt16 sequenceId;

/**
 * @brief Original index of a separately scheduled multipart item
 * @chinese 独立调度多包项的原组内序号
 * @discussion
 * [EN]: Uses the existing four-byte big-endian multipart index.
 * [CN]: 使用既有四字节大端多包序号。
 * @note
 * [EN]: Initially zero; smaller than a nonzero fragmentCount.
 * [CN]: 初始为零；小于非零 fragmentCount。
 */
@property (nonatomic, assign, readonly) UInt32 fragmentIndex;

/**
 * @brief Original count of a separately scheduled multipart group
 * @chinese 独立调度多包组的原总包数
 * @discussion
 * [EN]: Uses the existing four-byte big-endian multipart count.
 * [CN]: 使用既有四字节大端总包数。
 * @note
 * [EN]: Initially zero for object mode; positive values enable the normal multipart header.
 * [CN]: 初始为零，表示对象模式；正值启用原有多包头。
 */
@property (nonatomic, assign, readonly) UInt32 fragmentCount;

/**
 * @brief Freeze the original protocol identity
 * @chinese 冻结原协议身份
 * @param command
 * EN: Main command byte.
 * CN: 主命令字节。
 * @param key
 * EN: Subcommand byte.
 * CN: 子命令字节。
 * @param sequenceId
 * EN: Sequence assigned to this packet.
 * CN: 当前包分配的序列号。
 * @return
 * EN: An object-mode immutable context.
 * CN: 对象模式的不可变上下文。
 */
- (instancetype)initWithCommand:(UInt8)command key:(UInt8)key
                     sequenceId:(UInt16)sequenceId NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Copy this context with verified multipart metadata
 * @chinese 复制上下文并设置已校验的多包元信息
 * @param index
 * EN: Original zero-based group index.
 * CN: 原组内从零开始的序号。
 * @param count
 * EN: Positive group count representable by UInt32.
 * CN: 可由 UInt32 表示的正数组总包数。
 * @return
 * EN: A new multipart context, or nil for invalid metadata.
 * CN: 新多包上下文；元信息无效时为 nil。
 */
- (nullable TSCommandPacketContext *)contextWithFragmentIndex:(NSUInteger)index count:(NSUInteger)count;
@end

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

/**
 * @brief Wrap one complete payload using frozen multipart metadata
 * @chinese 使用冻结多包元信息包装单个完整载荷
 * @param payload
 * EN: Complete message bytes, not a protobuf byte slice.
 * CN: 完整消息字节，不是 protobuf 字节切片。
 * @param context
 * EN: Original packet and optional multipart identity.
 * CN: 原包身份及可选多包身份。
 * @param maxPacketSize
 * EN: Maximum BLE fragment size; zero keeps the complete packet.
 * CN: 最大 BLE 片段长度；零保留完整协议包。
 * @return
 * EN: BLE fragments for exactly one protocol packet.
 * CN: 恰好一个完整协议包对应的 BLE 片段。
 */
+ (NSArray<NSData *> *)wrapPayload:(NSData *)payload context:(TSCommandPacketContext *)context
                   maxPacketSize:(NSUInteger)maxPacketSize;

@end

NS_ASSUME_NONNULL_END
