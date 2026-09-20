//
//  TSFitDialFont.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief One 384-byte TBUI bitmap font slot, with at most 95 glyphs. @chinese 一套 384 字节 TBUI 位图字体槽，最多 95 个字形。 */
@interface TSFitDialFont : NSObject <NSCopying>
/** @brief Ordered unsigned 16-bit character codes. @chinese 按顺序排列的 16 位无符号字符编码。 */
@property (nonatomic, copy) NSArray<NSNumber *> *characterCodes;
/** @brief Image identifiers in the same order and count as characterCodes. @chinese 与 characterCodes 等长、同顺序的图片编号。 */
@property (nonatomic, copy) NSArray<NSNumber *> *imageIDs;
@end

NS_ASSUME_NONNULL_END
