//
//  TSMetaFileUploadSource.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMetaFileUploadRequest;

/**
 * @brief Stable private file snapshot with a bounded upload view.
 * @chinese 稳定的 SDK 私有文件快照，按传输绝对偏移有界读取；不修改调用方文件。
 */
@interface TSMetaFileUploadSource : NSObject

/**
 * @brief Total transmitted file length
 * @chinese 待传输文件的总长度
 *
 * @discussion
 * [EN]: Byte count including the 1024-byte TOPSTEP header, in 1025...UINT32_MAX
 *       after successful preparation. Raw input adds the virtual header; Container
 *       input already includes it. This value defines absolute DATA offsets and EOF.
 * [CN]: 包含 1024 字节 TOPSTEP 头的字节数，准备成功后范围为 1025...UINT32_MAX。
 *       Raw 输入加上虚拟头，Container 输入自身已含头；该值定义 DATA 绝对偏移和文件末尾。
 */
@property (nonatomic, assign, readonly) uint32_t length;

/**
 * @brief Immutable transmission header
 * @chinese 不可变的传输头
 *
 * @discussion
 * [EN]: Exactly 1024 copied bytes after successful preparation. Raw creates a virtual
 *       header; Container preserves the validated header except for an explicitly
 *       requested WATCHFACE or game item index override. Header bytes are excluded from allCRC.
 * [CN]: 准备成功后为复制保存的 1024 字节。Raw 生成虚拟头；Container 保留校验后的原头，
 *       仅在显式请求时覆盖 WATCHFACE 或游戏条目索引。头字节不参与 allCRC。
 *
 * @note
 * [EN]: Game index overrides require storage_addr == 0; other container paths are unchanged.
 * [CN]: 游戏索引覆盖要求 storage_addr 为 0；其他容器入口行为保持不变。
 */
@property (nonatomic, copy, readonly) NSData *header;

/**
 * @brief Checksum of the complete transmitted body
 * @chinese 完整传输正文的校验值
 *
 * @discussion
 * [EN]: Unsigned 16-bit CRC excluding the 1024-byte header. Raw input uses CRC-16/ARC;
 *       existing Container input uses CRC-16/BUYPASS and must match its stored checksum.
 *       Zero is a valid checksum, not an indication that validation was skipped.
 * [CN]: 不含 1024 字节头的无符号 16 位 CRC。Raw 输入使用 CRC-16/ARC；已有 Container
 *       使用 CRC-16/BUYPASS，且须与头内值一致。零是有效校验值，不表示跳过校验。
 */
@property (nonatomic, assign, readonly) uint16_t allCRC;

/**
 * @brief Effective type advertised in START
 * @chinese START 命令上报的实际文件类型
 *
 * @discussion
 * [EN]: Raw uses the validated request type (17, 23, or 25). Container uses the common
 *       type of all validated items (1...26), or zero when item types differ.
 *       A zero value here does not imply an empty body or an invalid source.
 * [CN]: Raw 使用校验后的请求类型（17、23 或 25）；Container 的所有条目同类型时
 *       使用共同类型（1...26），混合类型时为零。此处零不表示正文为空或数据源无效。
 */
@property (nonatomic, assign, readonly) uint8_t fileType;

/**
 * @brief Prepare a stable snapshot synchronously on a background queue.
 * @chinese 在后台队列同步创建快照、验证容器或生成原始文件虚拟头；逐块检查取消。
 * @param request EN: Immutable upload intent. CN: 不可变上传请求。
 * @param cancelled EN: Thread-safe cancellation predicate; nil disables cancellation.
 * CN: 线程安全的取消判断，nil 表示不检查取消。
 * @param error EN: File, format, checksum, or cancellation error. CN: 文件、格式、校验或取消错误。
 * @return EN: Prepared source, or nil after temporary-file cleanup. CN: 已准备数据源，失败清理临时文件后返回 nil。
 */
+ (nullable instancetype)sourceWithRequest:(TSMetaFileUploadRequest *)request
                               cancelled:(BOOL (^ _Nullable)(void))cancelled
                                   error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Read a bounded slice using absolute transmission offsets.
 * @chinese 按包含虚拟头的传输绝对偏移读取，可跨头与正文边界；与 close 互斥。
 * @param offset EN: Absolute offset no greater than length. CN: 不超过总长度的绝对偏移。
 * @param length EN: 0...65535, without reading beyond EOF. CN: 0...65535 字节，不得越过文件末尾。
 * @param error EN: Range, closed-source, or IO error. CN: 范围、已关闭或读写错误。
 * @return EN: Exactly the requested bytes, or nil. CN: 完整指定长度的字节或 nil。
 */
- (nullable NSData *)readDataAtOffset:(uint32_t)offset
                             length:(NSUInteger)length
                              error:(NSError * _Nullable * _Nullable)error;

/** @brief Idempotently close and remove only the private snapshot. @chinese 幂等关闭并删除本任务私有快照。 */
- (void)close;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
