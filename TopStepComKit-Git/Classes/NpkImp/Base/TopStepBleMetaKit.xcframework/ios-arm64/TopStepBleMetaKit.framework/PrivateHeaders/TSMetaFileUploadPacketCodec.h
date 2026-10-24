//
//  TSMetaFileUploadPacketCodec.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Decoded START response fields. @chinese START 成功应答字段，全部已从小端转换。 */
typedef struct {
    uint8_t protocolVersion;
    uint32_t allLength;
    uint32_t allCRC;
    uint32_t offset;
    uint16_t packetSize;
    uint16_t blockSize;
} TSMetaFileUploadStartAcknowledgement;

/** @brief Validated immutable response. @chinese 已通过长度与 ARC 校验的不可变应答。 */
@interface TSMetaFileUploadPacket : NSObject
/**
 * @brief Validated response command
 * @chinese 已校验的应答命令码
 *
 * @discussion
 * [EN]: Decoded unsigned byte: 0x81 for START, 0x82...0x85 for command responses,
 *       or 0xA0 for a device status event. The decoder rejects other command values;
 *       transaction-specific acceptance remains the uploader's responsibility.
 * [CN]: 解码后的无符号字节：0x81 为 START 应答，0x82...0x85 为命令应答，
 *       0xA0 为设备状态事件。解码器拒绝其他值；是否适用于当前事务由上传器判断。
 */
@property (nonatomic, assign, readonly) uint8_t command;

/**
 * @brief Response header offset
 * @chinese 应答帧头中的偏移值
 *
 * @discussion
 * [EN]: Unsigned 32-bit field decoded from little endian and retained as received.
 *       The codec does not validate it against a source file or advance progress
 *       from it. The START resume position is a separate field inside its payload.
 * [CN]: 从小端解码并原样保留的无符号 32 位字段。编解码器不将其与源文件范围比较，
 *       也不据此推进进度；START 的续传偏移是负载中的另一个独立字段。
 */
@property (nonatomic, assign, readonly) uint32_t offset;

/**
 * @brief Immutable response payload
 * @chinese 不可变的应答有效负载
 *
 * @discussion
 * [EN]: Copied payload after exact-length and CRC-16/ARC checks: 20 bytes for 0x81,
 *       one byte for the other accepted responses. It excludes the 12-byte frame
 *       header; START version fields and device status meanings are checked separately.
 * [CN]: 经过准确长度和 CRC-16/ARC 校验后复制保存的负载：0x81 为 20 字节，
 *       其他支持的应答为 1 字节。不含 12 字节帧头；START 版本及设备状态语义另行校验。
 */
@property (nonatomic, copy, readonly) NSData *payload;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/**
 * @brief TOPSTEP command encoder and bounded response stream decoder.
 * @chinese TOPSTEP 命令编码与有界应答流解码；实例仅在任务串行队列使用。
 */
@interface TSMetaFileUploadPacketCodec : NSObject

/**
 * @brief Buffered incomplete response byte count
 * @chinese 尚未组成完整应答的缓冲字节数
 *
 * @discussion
 * [EN]: Current decoder buffer length in bytes, bounded by the 32-byte maximum
 *       response. Initially zero and cleared after a complete frame, reset, or fatal
 *       parse failure. Read on the same task serial queue as appendData: and reset.
 * [CN]: 当前解码缓冲的字节数，上限为最大应答长度 32 字节。初始为零，完整帧解析、
 *       reset 或致命解析错误后清零；须与 appendData:、reset 在同一任务串行队列读取。
 */
@property (nonatomic, assign, readonly) NSUInteger bufferedLength;

/**
 * @brief Encode START with file type in the first reserved byte.
 * @chinese 编码 START，将文件类型写入首个保留字节。
 * @param fileType EN: Derived file type, or zero for mixed items. CN: 推导的文件类型，混合条目使用零。
 * @return EN: Exactly 12 bytes. CN: 恰好 12 字节的帧。
 */
+ (NSData *)startFrameWithFileType:(uint8_t)fileType;

/**
 * @brief Encode one complete outgoing command, not BLE fragments.
 * @chinese 编码完整出站命令帧，不负责 BLE 分片。
 * @param command EN: 1...5. CN: 命令码 1...5。
 * @param offset EN: Absolute transmitted file offset. CN: 含文件头的绝对偏移。
 * @param payload EN: Empty for START/END/ABORT, 1024 for HEAD, 1...65535 for DATA.
 * CN: START/END/ABORT 为空，HEAD 为 1024 字节，DATA 为 1...65535 字节。
 * @param error EN: Encoding error. CN: 编码错误。
 * @return EN: Encoded frame, or nil. CN: 帧字节或 nil。
 */
+ (nullable NSData *)frameWithCommand:(uint8_t)command
                              offset:(uint32_t)offset
                             payload:(NSData *)payload
                               error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Consume split or coalesced notifications with strict ARC verification.
 * @chinese 处理拆包和连包通知，CRC 零值也必须校验；错误后须 reset 才可复用。
 * @param data EN: Notification bytes, at most 65536 per call. CN: 通知字节，每次最多 65536 字节。
 * @param error EN: Fatal framing/checksum error. CN: 不可恢复的帧或校验错误。
 * @return EN: Complete responses, or nil on error. CN: 完整应答数组，错误返回 nil。
 */
- (nullable NSArray<TSMetaFileUploadPacket *> *)appendData:(NSData *)data
                                                  error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Decode the fixed 20-byte START success payload.
 * @chinese 解析固定 20 字节 START 成功负载，拒绝不支持的版本与零传输参数。
 * @param packet EN: CRC-validated response. CN: 已通过 CRC 校验的应答。
 * @param result EN: Output fields. CN: 输出字段。
 * @param error EN: Format or version error. CN: 格式或版本错误。
 * @return EN: Whether decoding succeeded. CN: 是否解析成功。
 */
+ (BOOL)decodeStartAcknowledgement:(TSMetaFileUploadPacket *)packet
                           result:(TSMetaFileUploadStartAcknowledgement *)result
                            error:(NSError * _Nullable * _Nullable)error;

/** @brief Clear partial bytes and failure state. @chinese 清理半帧与失败标记，仅用于已确认的会话边界。 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
