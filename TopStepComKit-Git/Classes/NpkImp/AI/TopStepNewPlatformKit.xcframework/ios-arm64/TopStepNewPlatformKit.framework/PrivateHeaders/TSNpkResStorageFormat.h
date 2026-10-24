#import <Foundation/Foundation.h>

@class TSNpkResEncodedImage;
@class TSNpkW30ImageHeader;

NS_ASSUME_NONNULL_BEGIN

/** @brief Platform-specific LVGL resource storage rules. @chinese 平台特有的 LVGL 资源存储规则。 */
@protocol TSNpkResStorageFormat <NSObject>
/**
 * @brief Six-byte platform marker
 * @chinese 六字节平台标记
 *
 * @discussion
 * [EN]: Shenju for W30 and AB579X for LVGL 579X; identifies the resource format independently of the device enum.
 * [CN]: W30 返回 Shenju，LVGL 579X 返回 AB579X；标识资源文件格式，与设备平台枚举分别使用。
 */
@property (nonatomic, copy, readonly) NSString *platformMarker;
/**
 * @brief Selection of W30 header and glyph-reference rules
 * @chinese 是否采用 W30 图片头与字形引用规则
 *
 * @discussion
 * [EN]: YES for W30 and NO for 579X; controls W30 record parsing and font-table patching, not the presence of arbitrary preserved bytes.
 * [CN]: W30 为 YES、579X 为 NO；控制 W30 记录解析及字体表修补，不代表是否存在任意保留字节。
 */
@property (nonatomic, assign, readonly) BOOL usesW30FontTable;
/** @brief Stored byte count for a newly encoded payload. @chinese 新编码数据的实际存储长度。
 * @param payloadLength EN: Encoded payload bytes. CN: 编码数据字节数。
 * @return EN: Stored length, including the platform header. CN: 包含平台图片头的长度。
 */
- (uint64_t)storedLengthForPayloadLength:(uint64_t)payloadLength;
/** @brief Value written into the second index field. @chinese 图片索引第二字段的值。
 * @param payloadLength EN: Encoded byte count. CN: 编码字节数。
 * @return EN: Payload size on W30, zero on 579X. CN: W30 为数据长度，579X 为零。
 */
- (uint32_t)indexSizeForPayloadLength:(uint32_t)payloadLength;
/** @brief Serialize an encoded image. @chinese 将编码结果序列化为存储内容。
 * @param image EN: Encoded pixels and format metadata. CN: 编码数据及格式元数据。
 * @param header EN: Original W30 header, if present. CN: 可选原 W30 图片头。
 * @param error EN: Serialization error. CN: 序列化错误。
 * @return EN: Stored bytes or nil. CN: 存储字节，失败返回 nil。
 */
- (nullable NSData *)storedDataForImage:(TSNpkResEncodedImage *)image
                        existingHeader:(nullable TSNpkW30ImageHeader *)header
                                 error:(NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
