//
//  TSDialGuiBin.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSDialGuiHeader;
@class TSDialGuiControl;
@class TSDialGuiImage;
@class TSDialGuiFont;

NS_ASSUME_NONNULL_BEGIN

/** @brief Binary serialization and validation error domain. @chinese 二进制序列化与校验错误域。 */
FOUNDATION_EXTERN NSErrorDomain const TSDialGuiBinaryErrorDomain;
/** @brief Binary failure codes. @chinese 二进制错误代码。 */
typedef NS_ERROR_ENUM(TSDialGuiBinaryErrorDomain, TSDialGuiBinaryErrorCode) {
    TSDialGuiBinaryErrorInvalidParameter = 74001,
    TSDialGuiBinaryErrorCapacityExceeded = 74002,
    TSDialGuiBinaryErrorInvalidFormat = 74003,
    TSDialGuiBinaryErrorChecksumMismatch = 74004,
};

/** @brief Immutable fixed-layout generated TBUI/OTA builder. @chinese 固定新生成布局的不可变 TBUI/OTA 构建器。
 * @discussion EN: Parsing supports this fixed layout only. Never rebuild an arbitrary legacy template with this class.
 * CN: 解析仅支持本类固定布局。任意旧模板必须按原目录校验并原位保留未知区域，不得用本类重建。
 */
@interface TSDialGuiBin : NSObject
/**
 * @brief Copy of the captured header
 * @chinese 已捕获包头的副本
 *
 * @discussion
 * [EN]: Each access returns a new copy. Mutating it does not change this builder's output.
 * [CN]: 每次读取均返回新副本，修改该副本不会改变当前构建器的输出。
 */
@property (nonatomic, copy, readonly) TSDialGuiHeader *header;
/**
 * @brief Copies of the controls in output slot order
 * @chinese 按输出槽位排列的控件副本
 *
 * @discussion
 * [EN]: Each access copies the array and its models. Encoding accepts at most 100
 *       controls and requires exactly one ICON/PREVIEW control.
 * [CN]: 每次读取都会复制数组及其中的模型；编码最多接受 100 个控件，
 *       且必须恰好包含一个 ICON/PREVIEW 控件。
 */
@property (nonatomic, copy, readonly) NSArray<TSDialGuiControl *> *controls;
/**
 * @brief Copies of the resources in payload order
 * @chinese 按载荷顺序排列的资源副本
 *
 * @discussion
 * [EN]: Each access copies the array and its models. Encoding accepts at most 2048
 *       resources; changes to returned models do not alter the captured payloads.
 * [CN]: 每次读取都会复制数组及其中的模型，编码最多接受 2048 个资源；
 *       修改返回模型不会改变已捕获的载荷。
 */
@property (nonatomic, copy, readonly) NSArray<TSDialGuiImage *> *images;
/**
 * @brief Copies of the fonts in output slot order
 * @chinese 按输出槽位排列的字体副本
 *
 * @discussion
 * [EN]: Each access copies the array and its models. Empty is valid; encoding
 *       accepts at most 32 font slots with at most 95 glyphs each.
 * [CN]: 每次读取都会复制数组及其中的模型；允许空数组，编码最多接受 32 个字体槽，
 *       每槽最多 95 个字形。
 */
@property (nonatomic, copy, readonly) NSArray<TSDialGuiFont *> *fonts;

/**
 * @brief Capture independent model and payload snapshots; validation occurs during encoding.
 * @chinese 捕获独立模型与载荷快照，编码时执行参数校验。
 * @param header EN: Header parameters. CN: 头部参数。
 * @param controls EN: Controls in output slot order. CN: 按输出槽位排列的控件。
 * @param images EN: Resources in payload order. CN: 按载荷顺序排列的资源。
 * @param fonts EN: Font slots in output order. CN: 按输出顺序排列的字体槽。
 * @return EN: Independent builder. CN: 独立构建器。
 */
- (instancetype)initWithHeader:(TSDialGuiHeader *)header
                     controls:(NSArray<TSDialGuiControl *> *)controls
                       images:(NSArray<TSDialGuiImage *> *)images
                        fonts:(NSArray<TSDialGuiFont *> *)fonts NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Encode a pure TBUI body including both TBUI markers, synchronously on the caller's thread.
 * @chinese 在调用线程同步编码纯 TBUI 表盘体，包含首尾 TBUI 标记。
 * @param error EN: Optional failure output. CN: 可选错误输出。
 * @return EN: Body data, or nil on failure. CN: 表盘体数据，失败返回 nil。
 */
- (nullable NSData *)encodedDataWithError:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Encode a TBUI body with a 1024-byte TOPSTEP OTA header.
 * @chinese 编码 TBUI 表盘体并添加 1024 字节 TOPSTEP OTA 头。
 * @param productID EN: Unsigned 32-bit project ID, zero disables device matching. CN: 32 位产品编号，零表示设备不校验匹配。
 * @param error EN: Optional failure output. CN: 可选错误输出。
 * @return EN: Installable file bytes, or nil on failure. CN: 可安装文件字节，失败返回 nil。
 */
- (nullable NSData *)otaDataWithProductID:(NSUInteger)productID error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Decode TBUI; image data retains four-byte padding as Android does.
 * @chinese 解析 TBUI，图片载荷与 Android 一样保留四字节对齐填充。
 * @param data EN: Complete TBUI body. CN: 完整 TBUI 表盘体。
 * @param error EN: Optional failure output. CN: 可选错误输出。
 * @return EN: Parsed builder, or nil on failure. CN: 解析结果，失败返回 nil。
 */
+ (nullable instancetype)binWithTBUIData:(NSData *)data error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Validate TOPSTEP OTA length and CRC, then decode its TBUI body.
 * @chinese 校验 TOPSTEP OTA 长度及 CRC 后解析 TBUI 表盘体。
 * @param data EN: Complete OTA file. CN: 完整 OTA 文件。
 * @param error EN: Optional failure output. CN: 可选错误输出。
 * @return EN: Parsed builder, or nil on failure. CN: 解析结果，失败返回 nil。
 */
+ (nullable instancetype)binWithOTAData:(NSData *)data error:(NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
