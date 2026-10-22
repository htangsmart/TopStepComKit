#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
NS_ASSUME_NONNULL_BEGIN
/** @brief Legacy bpp8 palette and row indexes. @chinese 旧 bpp8 调色板与行索引。 */
@interface TSNpkDialGuiPalette : NSObject
/**
 * @brief Big-endian RGB565 palette bytes
 * @chinese 大端 RGB565 调色板字节
 *
 * @discussion
 * [EN]: Contains 16...256 entries at two bytes each; unused entries in the minimum-sized table are zero-filled.
 * [CN]: 包含 16...256 个颜色项，每项 2 字节；不足最小项数时以零填充，供旧 GUI bpp8 资源使用。
 */
@property (nonatomic, copy, readonly) NSData *colors;
/**
 * @brief Palette indices in source raster order
 * @chinese 按源光栅顺序排列的调色板索引
 *
 * @discussion
 * [EN]: One unsigned byte per original pixel, length width times height; each value indexes colors.
 * [CN]: 每个原始像素占 1 个无符号字节，总长为宽乘高；每个值指向 colors 中的颜色项。
 */
@property (nonatomic, copy, readonly) NSData *indices;
/** @brief Apply Android Palette maximumColorCount(256).clearFilters rules. @chinese 应用 Android Palette 的 256 色、无过滤规则。
 * @param pixels EN: Straight ARGB display pixels. CN: 非预乘 ARGB 显示像素。
 * @param size EN: Pixel geometry. CN: 像素尺寸。
 * @param error EN: Invalid input or allocation failure. CN: 无效输入或内存失败。
 * @return EN: Encoded palette and indexes. CN: 编码的调色板及索引。 */
+ (nullable instancetype)paletteWithARGB:(NSData *)pixels size:(CGSize)size error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
