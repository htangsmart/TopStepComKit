//
//  TSNpkResFontTablePatcher.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkResBinLayout;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Rewrites the absolute image addresses stored in the res.bin font table
 * @chinese 修正 res.bin 字体表里保存的图片绝对地址
 *
 * @discussion
 * [EN]: The font table sits between the image table and the first image. It is a sequence of groups:
 *       a 4-byte group header [glyphCount u8][firstImageIndex u8][0][0] followed by glyphCount entries of
 *       [charCode u8][absolute image address u24, little endian]; a header with glyphCount 0 is padding.
 *       This format was inferred from template samples and is pending confirmation by the firmware team.
 *       When no image moved, the table is returned untouched without being parsed at all.
 * [CN]: 字体表位于索引表和第一张图之间，由若干组构成：4 字节组头 [字形数 u8][首图下标 u8][0][0]，
 *       随后是"字形数"个 [字符码 u8][图片绝对地址 u24 小端] 项；字形数为 0 的组头是填充。
 *       该格式由模板样本反推得到，尚待固件组确认。没有任何图片移动时，直接原样返回，不做解析。
 */
@interface TSNpkResFontTablePatcher : NSObject

/**
 * @brief Return the font table with addresses remapped to the new layout
 * @chinese 返回按新布局修正过地址的字体表
 *
 * @param fontTable EN: Font table bytes of the template. CN: 模板里的字体表字节。
 * @param layout EN: New layout providing the address map. CN: 提供地址映射的新布局。
 * @param error EN: Set when the table cannot be parsed or a glyph image was removed.
 *              CN: 字体表无法解析，或字形图片被移除时给出错误。
 * @return EN: Patched table of the same length, or nil on failure. CN: 长度不变的字体表，失败返回 nil。
 */
+ (nullable NSData *)patchedFontTable:(NSData *)fontTable
                           withLayout:(TSNpkResBinLayout *)layout
                                error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
