//
//  TSSportBlockParser.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

@class TSSportParseContext;

/// Sport detail binary block types
typedef NS_ENUM(uint8_t, TSSportBlockType) {
    TSSportBlockTypeConfig      = 0x00,  // 配置，2 字节/项
    TSSportBlockTypeHeartRate   = 0x01,  // 心率，1 字节/项
    TSSportBlockTypeSpeed       = 0x02,  // 速度，3 字节/项（米/分钟，暂不处理）
    TSSportBlockTypeAltitude    = 0x03,  // 海拔，暂未定义
    TSSportBlockTypeGPS         = 0x04,  // GPS，暂未定义
    TSSportBlockTypeStepFreq    = 0x05,  // 步频，3 字节/项（步/分钟，暂不处理）
    TSSportBlockTypeStride      = 0x06,  // 步幅，暂未定义
    TSSportBlockTypeStep        = 0x07,  // 步数，3 字节/项
    TSSportBlockTypeDistance    = 0x08,  // 距离，3 字节/项（米）
    TSSportBlockTypeCalorie     = 0x09,  // 卡路里，3 字节/项
    TSSportBlockTypePace        = 0x0A,  // 配速，3 字节/项（秒/公里，暂不处理）
};

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Protocol for sport data block parsers.
 * @chinese 运动数据块解析器协议。
 *
 * @discussion
 * Each parser handles one block type. The file parser reads the block header,
 * populates context.currentBlock* fields, then calls parseBlockWithContext:error:.
 * The parser reads data starting at context.currentOffset and returns the new offset.
 * Returns NSNotFound on error.
 */
@protocol TSSportBlockParser <NSObject>

/// The primary block type this parser handles (used for registration)
- (uint8_t)supportedBlockType;

/**
 * Parse the block data. Header has already been read by TSSportFileParser.
 * context.currentOffset points to the start of the data area (past the header).
 * @return New offset after consuming all block data, or NSNotFound on error.
 */
- (NSUInteger)parseBlockWithContext:(TSSportParseContext *)context
                              error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
