//
//  TSDialGuiHeader.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief TBUI target platforms. @chinese TBUI 目标平台。 */
typedef NS_ENUM(NSUInteger, TSDialGuiPlatform) {
    TSDialGuiPlatformGUI = 0,
    TSDialGuiPlatformRealtek = 2,
    TSDialGuiPlatformAB568X = 3,
    TSDialGuiPlatformAB579X = 4,
};

/** @brief TBUI screen shapes. @chinese TBUI 屏幕形状。 */
typedef NS_ENUM(NSUInteger, TSDialGuiShape) {
    TSDialGuiShapeRectangle = 1,
    TSDialGuiShapeCircle = 2,
};

/** @brief TBUI header parameters; defaults match Android 3410b969. @chinese TBUI 头参数，默认值对齐 Android 3410b969。 */
@interface TSDialGuiHeader : NSObject <NSCopying>
/**
 * @brief Dial identifier stored in the TBUI header
 * @chinese 写入 TBUI 包头的表盘编号
 *
 * @discussion
 * [EN]: Defaults to 0. The binary encoder accepts 0...0xFFFFFF; business-level
 *       identifier requirements are checked by the caller before packing.
 * [CN]: 默认 0，二进制编码器接受 0...0xFFFFFF；业务层对表盘编号的要求由调用方在造包前校验。
 */
@property (nonatomic, assign) NSUInteger dialID;
/**
 * @brief Dial format version
 * @chinese 表盘格式版本
 *
 * @discussion
 * [EN]: Defaults to 1. Encoding requires a value in 1...100.
 * [CN]: 默认 1，编码时必须在 1...100 范围内。
 */
@property (nonatomic, assign) NSUInteger version;
/**
 * @brief Target platform identifier in the TBUI format
 * @chinese TBUI 格式中的目标平台编号
 *
 * @discussion
 * [EN]: Defaults to 0. Use TSDialGuiPlatform values 0, 2, 3 or 4; AB579X is 4.
 *       This field does not use the device-information TSNpkPlatform numbering.
 * [CN]: 默认 0，使用 TSDialGuiPlatform 的 0、2、3、4，其中 AB579X 为 4。
 *       本字段不使用设备信息 TSNpkPlatform 的编号体系。
 */
@property (nonatomic, assign) NSUInteger platform;
/**
 * @brief LCD identifier stored in the header
 * @chinese 包头中的屏幕编号
 *
 * @discussion
 * [EN]: Defaults to 0. Serialized as an unsigned 16-bit integer in 0...65535.
 * [CN]: 默认 0，以 16 位无符号整数写入，有效范围为 0...65535。
 */
@property (nonatomic, assign) NSUInteger lcd;
/**
 * @brief Logical screen width in pixels
 * @chinese 逻辑屏幕宽度，单位像素
 *
 * @discussion
 * [EN]: Defaults to 0 and must be set to 1...65535 before encoding.
 * [CN]: 默认 0，编码前必须设置为 1...65535。
 */
@property (nonatomic, assign) NSUInteger width;
/**
 * @brief Logical screen height in pixels
 * @chinese 逻辑屏幕高度，单位像素
 *
 * @discussion
 * [EN]: Defaults to 0 and must be set to 1...65535 before encoding.
 * [CN]: 默认 0，编码前必须设置为 1...65535。
 */
@property (nonatomic, assign) NSUInteger height;
/**
 * @brief Screen shape code
 * @chinese 屏幕形状代码
 *
 * @discussion
 * [EN]: Defaults to 0, which is invalid for encoding. Set Rectangle (1) or Circle (2).
 * [CN]: 默认 0，编码时无效；必须设置为矩形 Rectangle（1）或圆形 Circle（2）。
 */
@property (nonatomic, assign) NSUInteger shape;
/**
 * @brief Corner radius stored in the header
 * @chinese 包头中的圆角半径
 *
 * @discussion
 * [EN]: Defaults to 0 and fits in one byte (0...255). TSDialGuiResourcePacker
 *       requires 0 because its input pixels already contain the shape mask.
 * [CN]: 默认 0，有效范围为单字节的 0...255。TSDialGuiResourcePacker 要求为 0，
 *       因为输入像素已包含形状遮罩。
 */
@property (nonatomic, assign) NSUInteger corner;
/**
 * @brief Screen rotation code
 * @chinese 屏幕旋转代码
 *
 * @discussion
 * [EN]: Defaults to 0. Values 0, 1, 2 and 3 represent 0, 90, 180 and 270 degrees.
 * [CN]: 默认 0；0、1、2、3 分别表示 0、90、180、270 度。
 */
@property (nonatomic, assign) NSUInteger rotate;
/**
 * @brief Language bitmap bytes
 * @chinese 语言位图字节
 *
 * @discussion
 * [EN]: Must contain exactly 10 bytes. Defaults to 0A followed by nine zero bytes;
 *       the encoder preserves the supplied bitmap without interpreting its bits.
 * [CN]: 必须恰好为 10 字节，默认首字节为 0A，其余九字节为零；
 *       编码器原样写入位图，不解释其中的语言位。
 */
@property (nonatomic, copy) NSData *language;
/**
 * @brief Tool version bytes
 * @chinese 工具版本字节
 *
 * @discussion
 * [EN]: Must contain exactly four bytes. Defaults to 01 00 00 00 and is written verbatim.
 * [CN]: 必须恰好为四字节，默认 01 00 00 00，编码时原样写入。
 */
@property (nonatomic, copy) NSData *toolVersion;
@end

NS_ASSUME_NONNULL_END
