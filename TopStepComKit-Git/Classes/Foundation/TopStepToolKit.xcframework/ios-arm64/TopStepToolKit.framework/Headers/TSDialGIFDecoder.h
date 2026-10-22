//
//  TSDialGIFDecoder.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

/** @brief GIF algorithm error domain. @chinese GIF 算法错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSDialGIFErrorDomain;
/** @brief Android's total retained GIF pixel budget. @chinese Android 的 GIF 保留帧总像素预算。 */
FOUNDATION_EXPORT NSUInteger const TSDialGIFMaximumPixels;

/** @brief GIF parsing and decoding failures. @chinese GIF 解析与解码错误。 */
typedef NS_ENUM(NSInteger, TSDialGIFErrorCode) {
    TSDialGIFErrorInvalidInput = 4401,
    TSDialGIFErrorMalformedData = 4402,
    TSDialGIFErrorMemoryBudget = 4403,
    TSDialGIFErrorDecodeFailed = 4404,
    TSDialGIFErrorCancelled = 4405,
};

/** @brief Composed GIF frames with Android decoder durations. @chinese 已完成帧合成的 GIF 帧及 Android 解码时长。 */
@interface TSDialDecodedGIF : NSObject
/**
 * @brief Composed frames in playback order
 * @chinese 按播放顺序排列的合成帧
 *
 * @discussion
 * [EN]: Successful decoding returns full logical-canvas images with scale 1,
 *       after applying GIF transparency and disposal rules. These are not local frame patches.
 * [CN]: 解码成功后提供 scale 为 1 的完整逻辑画布图片，
 *       已应用 GIF 透明和处置规则，不是局部帧补丁。
 */
@property (nonatomic, copy, readonly) NSArray<UIImage *> *frames;
/**
 * @brief Per-frame durations in milliseconds
 * @chinese 每帧播放时长，单位毫秒
 *
 * @discussion
 * [EN]: NSNumber integers correspond one-to-one with frames. GIF delays of 0 or
 *       10 ms become 100 ms; longer delays retain their original value.
 * [CN]: NSNumber 整数与 frames 一一对应；GIF 的 0 或 10 毫秒延迟修正为
 *       100 毫秒，其余较长延迟保留原值。
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *frameDurationsMillis;
/**
 * @brief GIF logical canvas width in pixels
 * @chinese GIF 逻辑画布像素宽度
 *
 * @discussion
 * [EN]: Read from the GIF logical screen descriptor. Every returned frame uses this width.
 * [CN]: 来自 GIF 逻辑屏幕描述符，每个返回帧均使用此宽度。
 */
@property (nonatomic, assign, readonly) NSUInteger width;
/**
 * @brief GIF logical canvas height in pixels
 * @chinese GIF 逻辑画布像素高度
 *
 * @discussion
 * [EN]: Read from the GIF logical screen descriptor. Every returned frame uses this height.
 * [CN]: 来自 GIF 逻辑屏幕描述符，每个返回帧均使用此高度。
 */
@property (nonatomic, assign, readonly) NSUInteger height;
@end

/** @brief ImageIO decoding with GifDrawable 1.2.25 disposal rules. @chinese 使用 ImageIO 解码并应用 GifDrawable 1.2.25 disposal 规则。 */
/** @brief Synchronous full-canvas frame callback; return NO to stop. @chinese 同步完整画布帧回调；返回 NO 取消。
 * @param frame EN: Complete frame, retain only if needed. CN: 完整帧，按需保留。
 * @param index EN: Zero-based index. CN: 从零开始的索引。
 * @param durationMillis EN: Normalized delay. CN: 规范化的毫秒时长。
 * @param totalFrames EN: Parsed frame count. CN: 已解析帧总数。
 * @return EN: Whether decoding should continue. CN: 是否继续解码。
 */
typedef BOOL (^TSDialGIFFrameHandler)(UIImage *frame, NSUInteger index, NSUInteger durationMillis, NSUInteger totalFrames);
@interface TSDialGIFDecoder : NSObject
/** @brief Stream complete frames with bounded decoded-frame retention. @chinese 逐帧返回完整画布，不累计保留解码帧。
 * @param data EN: GIF data. CN: GIF 数据。
 * @param frameHandler EN: Synchronous frame callback; NO cancels. CN: 同步逐帧回调，NO 表示取消。
 * @param error EN: Decode or cancellation failure. CN: 解码或取消错误。
 * @return EN: YES only if every frame was delivered. CN: 所有帧处理完成才返回 YES。
 */
+ (BOOL)enumerateData:(NSData *)data frameHandler:(TSDialGIFFrameHandler)frameHandler error:(NSError *_Nullable *_Nullable)error;
/** @brief Stream a local GIF file. @chinese 逐帧处理本地 GIF 文件。
 * @param fileURL EN: Local GIF file. CN: 本地 GIF 文件。
 * @param frameHandler EN: Synchronous frame callback. CN: 同步逐帧回调。
 * @param error EN: Read, decode or cancellation error. CN: 读取、解码或取消错误。
 * @return EN: Whether all frames completed. CN: 是否完成全部帧。
 */
+ (BOOL)enumerateFileURL:(NSURL *)fileURL frameHandler:(TSDialGIFFrameHandler)frameHandler error:(NSError *_Nullable *_Nullable)error;
/**
 * @brief Decode GIF frames synchronously without applying dial layout.
 * @chinese 同步解码 GIF，处理局部帧、透明、背景恢复和前帧恢复，不附加表盘布局。
 * @param data EN: GIF87a or GIF89a bytes. CN: GIF87a 或 GIF89a 数据。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Composed frames or nil. CN: 合成帧，失败返回 nil。
 */
+ (nullable TSDialDecodedGIF *)decodeData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Decode a local GIF file on the caller's thread.
 * @chinese 在调用线程解码本地 GIF 文件，可在后台线程调用。
 * @param fileURL EN: Local file URL. CN: 本地文件 URL。
 * @param error EN: Read or decode failure details. CN: 读取或解码失败信息。
 * @return EN: Composed frames or nil. CN: 合成帧，失败返回 nil。
 */
+ (nullable TSDialDecodedGIF *)decodeFileURL:(NSURL *)fileURL error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Validate retained-frame memory before decoding or expanding onto a screen.
 * @chinese 在解码或铺满屏幕前检查所有保留帧的总像素预算。
 * @param frameCount EN: Number of frames. CN: 帧数。
 * @param pixelSize EN: Pixel width and height. CN: 像素宽高。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: YES when width*height*count is at most 16,000,000. CN: 总像素不超过 1600 万时返回 YES。
 */
+ (BOOL)validateFrameCount:(NSUInteger)frameCount pixelSize:(CGSize)pixelSize
                    error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
