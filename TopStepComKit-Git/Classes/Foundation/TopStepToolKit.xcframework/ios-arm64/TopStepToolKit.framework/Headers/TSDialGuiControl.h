//
//  TSDialGuiControl.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief A 32-byte TBUI control record. @chinese 32 字节 TBUI 控件记录。 */
@interface TSDialGuiControl : NSObject <NSCopying>
/**
 * @brief Control slot read from the binary record
 * @chinese 从二进制记录读出的控件槽位
 *
 * @discussion
 * [EN]: Defaults to 0. Parsing preserves the stored slot; encoding uses the control's
 *       position in the controls array instead of this value.
 * [CN]: 默认 0；解析时保留原始槽位，编码时使用控件在 controls 数组中的位置，不使用本值。
 */
@property (nonatomic, assign) NSUInteger index;
/**
 * @brief Control family code
 * @chinese 控件大类代码
 *
 * @discussion
 * [EN]: Defaults to 0 and accepts 0...255. Generated dials use image (0), icon (6)
 *       and animation (7); subType further identifies each control.
 * [CN]: 默认 0，有效范围为 0...255。生成表盘使用图片（0）、图标（6）和动画（7），
 *       具体控件含义由 subType 进一步确定。
 */
@property (nonatomic, assign) NSUInteger controlType;
/**
 * @brief Control enable byte
 * @chinese 控件启用字节
 *
 * @discussion
 * [EN]: Defaults to 1. Encoding accepts 0...255 and preserves the byte without Boolean normalization.
 * [CN]: 默认 1，编码接受 0...255，原样保留字节，不将其归一为布尔值。
 */
@property (nonatomic, assign) NSUInteger enable;
/**
 * @brief Control subtype code
 * @chinese 控件子类型代码
 *
 * @discussion
 * [EN]: Defaults to 0 and accepts 0...255. Its meaning depends on controlType;
 *       an icon (6) with subtype 1 identifies the preview control.
 * [CN]: 默认 0，有效范围为 0...255，含义取决于 controlType；
 *       图标（6）的子类型 1 表示预览控件。
 */
@property (nonatomic, assign) NSUInteger subType;
/**
 * @brief Horizontal control position
 * @chinese 控件横坐标
 *
 * @discussion
 * [EN]: Defaults to 0. Unsigned pixel coordinate in 0...65535.
 * [CN]: 默认 0，单位为像素，有效范围为 0...65535，不支持负坐标。
 */
@property (nonatomic, assign) NSUInteger x;
/**
 * @brief Vertical control position
 * @chinese 控件纵坐标
 *
 * @discussion
 * [EN]: Defaults to 0. Unsigned pixel coordinate in 0...65535.
 * [CN]: 默认 0，单位为像素，有效范围为 0...65535，不支持负坐标。
 */
@property (nonatomic, assign) NSUInteger y;
/**
 * @brief Control width field
 * @chinese 控件宽度字段
 *
 * @discussion
 * [EN]: Defaults to 0. Stored as an unsigned 16-bit value; interpretation depends on the control subtype.
 * [CN]: 默认 0，以 16 位无符号值写入，具体解释取决于控件子类型。
 */
@property (nonatomic, assign) NSUInteger width;
/**
 * @brief Control height field
 * @chinese 控件高度字段
 *
 * @discussion
 * [EN]: Defaults to 0. Stored as an unsigned 16-bit value; interpretation depends on the control subtype.
 * [CN]: 默认 0，以 16 位无符号值写入，具体解释取决于控件子类型。
 */
@property (nonatomic, assign) NSUInteger height;
/**
 * @brief Primary resource identifier
 * @chinese 主资源编号
 *
 * @discussion
 * [EN]: Defaults to 0 and accepts 0...65535. The preview control must refer to an existing imageID.
 * [CN]: 默认 0，有效范围为 0...65535；预览控件必须引用实际存在的 imageID。
 */
@property (nonatomic, assign) NSUInteger resourceID;
/**
 * @brief Alignment or mode field
 * @chinese 对齐或模式字段
 *
 * @discussion
 * [EN]: Defaults to 0. Meaning depends on the subtype; serialization retains only the low eight bits.
 * [CN]: 默认 0，含义取决于子类型；序列化仅保留低八位，与 Android 一致。
 */
@property (nonatomic, assign) NSUInteger align;
/**
 * @brief Encoded interval or speed field
 * @chinese 编码后的间隔或速度字段
 *
 * @discussion
 * [EN]: Defaults to 0. The caller converts media timing into the subtype's protocol unit;
 *       serialization retains only the low eight bits.
 * [CN]: 默认 0，由调用方将媒体时序换算为相应子类型的协议单位；序列化仅保留低八位。
 */
@property (nonatomic, assign) NSUInteger speed;
/**
 * @brief Subtype-specific count field
 * @chinese 子类型相关的数量字段
 *
 * @discussion
 * [EN]: Defaults to 0. Serialization retains only the low eight bits, matching Android.
 * [CN]: 默认 0；序列化仅保留低八位，与 Android 一致。
 */
@property (nonatomic, assign) NSUInteger number;
/**
 * @brief Module field
 * @chinese 模块字段
 *
 * @discussion
 * [EN]: Defaults to 0. Serialization retains only the low eight bits, matching Android.
 * [CN]: 默认 0；序列化仅保留低八位，与 Android 一致。
 */
@property (nonatomic, assign) NSUInteger module;
/**
 * @brief Style field
 * @chinese 样式字段
 *
 * @discussion
 * [EN]: Defaults to 0. Serialization retains only the low eight bits, matching Android.
 * [CN]: 默认 0；序列化仅保留低八位，与 Android 一致。
 */
@property (nonatomic, assign) NSUInteger style;
/**
 * @brief Reserved control byte
 * @chinese 控件保留字节
 *
 * @discussion
 * [EN]: Defaults to 0. Serialization preserves its low eight bits without assigning business meaning.
 * [CN]: 默认 0，序列化保留低八位，不赋予额外业务含义。
 */
@property (nonatomic, assign) NSUInteger reservedC;
/**
 * @brief Additional resource identifiers
 * @chinese 附加资源编号
 *
 * @discussion
 * [EN]: Defaults to an empty array. Supply at most six NSNumber integers in 0...65535;
 *       unused slots are written as zero.
 * [CN]: 默认空数组，最多提供六个 NSNumber 包装的 0...65535 整数；未使用的槽位写零。
 */
@property (nonatomic, copy) NSArray<NSNumber *> *extraIDs;
@end

NS_ASSUME_NONNULL_END
