//
//  TSSportBinaryReader.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Type-safe binary data reader for sport detail parsing.
 * @chinese 用于运动详情解析的类型安全二进制数据读取器。
 */
@interface TSSportBinaryReader : NSObject

@property (nonatomic, readonly) const uint8_t *bytes;
@property (nonatomic, readonly) NSUInteger length;

- (instancetype)initWithData:(NSData *)data;

/// Read 1-byte unsigned integer at offset
- (uint8_t)readUInt8AtOffset:(NSUInteger)offset;

/// Read 2-byte little-endian unsigned integer at offset
- (uint16_t)readUInt16LEAtOffset:(NSUInteger)offset;

/// Read 3-byte little-endian unsigned integer at offset
- (uint32_t)readUInt24LEAtOffset:(NSUInteger)offset;

/// Check if data starts with the given UTF-8 string prefix at offset
- (BOOL)hasVersionPrefix:(NSString *)prefix atOffset:(NSUInteger)offset;

/// Check if count bytes can be read starting at offset (bounds check)
- (BOOL)canReadBytes:(NSUInteger)count fromOffset:(NSUInteger)offset;

/// Return hex dump string for debugging
- (NSString *)hexDump;

@end

NS_ASSUME_NONNULL_END
