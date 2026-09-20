//
//  TSFitDialImage.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Encoded image or AVI payload with a 12-byte TBUI index. @chinese 已编码图片或 AVI 载荷及其 12 字节索引。 */
@interface TSFitDialImage : NSObject <NSCopying>
/** @brief Unsigned 16-bit image identifier. @chinese 16 位无符号图片编号。 */
@property (nonatomic, assign) NSUInteger imageID;
/** @brief Pixel family; AB requires 14. @chinese 像素族，AB 使用 14。 */
@property (nonatomic, assign) NSUInteger colorType;
/** @brief Opaque PAR 1, transparent PAR 2, RGB565 BMP 5, AVI 8. @chinese 不透明 PAR 为 1，透明 PAR 为 2，RGB565 BMP 为 5，AVI 为 8。 */
@property (nonatomic, assign) NSUInteger compressType;
/** @brief Unsigned 16-bit encoded pixel width. @chinese 16 位无符号编码像素宽度。 */
@property (nonatomic, assign) NSUInteger width;
/** @brief Unsigned 16-bit encoded pixel height. @chinese 16 位无符号编码像素高度。 */
@property (nonatomic, assign) NSUInteger height;
/** @brief Nonempty encoded payload; no length or padding prefix is added here. @chinese 非空编码载荷，此处不附加长度或填充前缀。 */
@property (nonatomic, copy) NSData *data;
@end

NS_ASSUME_NONNULL_END
