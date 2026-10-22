//
//  TSDialGuiImage.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Encoded image or AVI payload with a 12-byte TBUI index. @chinese 已编码图片或 AVI 载荷及其 12 字节索引。 */
@interface TSDialGuiImage : NSObject <NSCopying>
/**
 * @brief Resource identifier in the TBUI image index
 * @chinese TBUI 图片索引中的资源编号
 *
 * @discussion
 * [EN]: Defaults to 0. Must be in 0...65535 and unique within one encoded TBUI body.
 * [CN]: 默认 0，有效范围为 0...65535，在同一个 TBUI 表盘体内不得重复。
 */
@property (nonatomic, assign) NSUInteger imageID;
/**
 * @brief Pixel family identifier
 * @chinese 像素族编号
 *
 * @discussion
 * [EN]: Defaults to 0. The current binary encoder requires 14 for every resource.
 * [CN]: 默认 0，当前二进制编码器要求每个资源都设置为 14。
 */
@property (nonatomic, assign) NSUInteger colorType;
/**
 * @brief Encoded resource format
 * @chinese 编码资源格式
 *
 * @discussion
 * [EN]: Defaults to 0, which cannot be encoded. Accepted values are opaque PAR (1),
 *       transparent PAR (2), RGB565 BMP (5), and AVI (8); data must match this format.
 * [CN]: 默认 0，不能直接编码。支持不透明 PAR（1）、透明 PAR（2）、
 *       RGB565 BMP（5）、AVI（8）；data 必须与指定格式一致。
 */
@property (nonatomic, assign) NSUInteger compressType;
/**
 * @brief Encoded resource width in pixels
 * @chinese 编码资源的像素宽度
 *
 * @discussion
 * [EN]: Defaults to 0. The index accepts 0...65535; media preparation supplies the
 *       actual dimensions after any rotation or alignment.
 * [CN]: 默认 0，索引字段接受 0...65535；媒体准备层负责填写旋转或对齐后的实际尺寸。
 */
@property (nonatomic, assign) NSUInteger width;
/**
 * @brief Encoded resource height in pixels
 * @chinese 编码资源的像素高度
 *
 * @discussion
 * [EN]: Defaults to 0. The index accepts 0...65535; this is the encoded height,
 *       not necessarily the logical control height.
 * [CN]: 默认 0，索引字段接受 0...65535；这是编码高度，不一定等于控件的逻辑高度。
 */
@property (nonatomic, assign) NSUInteger height;
/**
 * @brief Encoded image or AVI payload
 * @chinese 已编码的图片或 AVI 载荷
 *
 * @discussion
 * [EN]: Defaults to empty data, which encoding rejects. Supply the payload without
 *       a length prefix; TSDialGuiBin adds four-byte alignment padding. Parsed
 *       payloads retain padding because the index stores addresses rather than original lengths.
 * [CN]: 默认空数据，编码时会拒绝。提供不带长度前缀的载荷，由 TSDialGuiBin 补齐四字节对齐。
 *       索引记录地址而非原始长度，因此解析得到的载荷会保留对齐填充。
 */
@property (nonatomic, copy) NSData *data;
@end

NS_ASSUME_NONNULL_END
