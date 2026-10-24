//
//  TSDialGuiFont.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief One 384-byte TBUI bitmap font slot, with at most 95 glyphs. @chinese 一套 384 字节 TBUI 位图字体槽，最多 95 个字形。 */
@interface TSDialGuiFont : NSObject <NSCopying>
/**
 * @brief Ordered character codes for this font slot
 * @chinese 当前字体槽中有序排列的字符编码
 *
 * @discussion
 * [EN]: Defaults to an empty array. At most 95 NSNumber integers in 0...65535;
 *       each entry maps to the imageIDs entry at the same position.
 * [CN]: 默认空数组，最多 95 个 NSNumber 包装的 0...65535 整数；
 *       每项与 imageIDs 中同一位置的图片编号对应。
 */
@property (nonatomic, copy) NSArray<NSNumber *> *characterCodes;
/**
 * @brief Image identifiers corresponding to the character codes
 * @chinese 与字符编码对应的图片编号
 *
 * @discussion
 * [EN]: Defaults to an empty array. Must have the same count as characterCodes,
 *       with each NSNumber containing an integer in 0...65535.
 * [CN]: 默认空数组，数量必须与 characterCodes 相等，
 *       每个 NSNumber 必须为 0...65535 范围内的整数。
 */
@property (nonatomic, copy) NSArray<NSNumber *> *imageIDs;
@end

NS_ASSUME_NONNULL_END
