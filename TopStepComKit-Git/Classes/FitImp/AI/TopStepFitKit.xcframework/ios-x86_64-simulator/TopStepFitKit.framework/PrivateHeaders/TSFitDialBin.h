//
//  TSFitDialBin.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSFitDialHeader;
@class TSFitDialControl;
@class TSFitDialImage;
@class TSFitDialFont;

NS_ASSUME_NONNULL_BEGIN

/** @brief Binary serialization and validation error domain. @chinese 二进制序列化与校验错误域。 */
FOUNDATION_EXTERN NSErrorDomain const TSFitDialBinaryErrorDomain;
/** @brief Binary failure codes. @chinese 二进制错误代码。 */
typedef NS_ERROR_ENUM(TSFitDialBinaryErrorDomain, TSFitDialBinaryErrorCode) {
    TSFitDialBinaryErrorInvalidParameter = 74001,
    TSFitDialBinaryErrorCapacityExceeded = 74002,
    TSFitDialBinaryErrorInvalidFormat = 74003,
    TSFitDialBinaryErrorChecksumMismatch = 74004,
};

/** @brief Immutable TBUI/OTA builder using Android 3410b969 wire rules. @chinese 按 Android 3410b969 协议实现的不可变 TBUI/OTA 构建器。 */
@interface TSFitDialBin : NSObject
/** @brief Defensive copy of the header snapshot. @chinese 头部快照的防御性副本。 */
@property (nonatomic, copy, readonly) TSFitDialHeader *header;
/** @brief Defensive copies of the ordered control snapshots. @chinese 有序控件快照的防御性副本。 */
@property (nonatomic, copy, readonly) NSArray<TSFitDialControl *> *controls;
/** @brief Defensive copies of the ordered image snapshots. @chinese 有序图片快照的防御性副本。 */
@property (nonatomic, copy, readonly) NSArray<TSFitDialImage *> *images;
/** @brief Defensive copies of the ordered font snapshots. @chinese 有序字体快照的防御性副本。 */
@property (nonatomic, copy, readonly) NSArray<TSFitDialFont *> *fonts;

/**
 * @brief Capture independent model and payload snapshots; validation occurs during encoding.
 * @chinese 捕获独立模型与载荷快照，编码时执行参数校验。
 * @param header EN: Header parameters. CN: 头部参数。
 * @param controls EN: Controls in output slot order. CN: 按输出槽位排列的控件。
 * @param images EN: Resources in payload order. CN: 按载荷顺序排列的资源。
 * @param fonts EN: Font slots in output order. CN: 按输出顺序排列的字体槽。
 * @return EN: Independent builder. CN: 独立构建器。
 */
- (instancetype)initWithHeader:(TSFitDialHeader *)header
                     controls:(NSArray<TSFitDialControl *> *)controls
                       images:(NSArray<TSFitDialImage *> *)images
                        fonts:(NSArray<TSFitDialFont *> *)fonts NS_DESIGNATED_INITIALIZER;
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
