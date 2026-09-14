//
//  TSFitDialGIFDecoder.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

/** @brief GIF algorithm error domain. @chinese GIF 算法错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSFitDialGIFErrorDomain;
/** @brief Android's total retained GIF pixel budget. @chinese Android 的 GIF 保留帧总像素预算。 */
FOUNDATION_EXPORT NSUInteger const TSFitDialGIFMaximumPixels;

/** @brief GIF parsing and decoding failures. @chinese GIF 解析与解码错误。 */
typedef NS_ENUM(NSInteger, TSFitDialGIFErrorCode) {
    TSFitDialGIFErrorInvalidInput = 4401,
    TSFitDialGIFErrorMalformedData = 4402,
    TSFitDialGIFErrorMemoryBudget = 4403,
    TSFitDialGIFErrorDecodeFailed = 4404,
};

/** @brief Composed GIF frames with Android decoder durations. @chinese 已完成帧合成的 GIF 帧及 Android 解码时长。 */
@interface TSFitDialDecodedGIF : NSObject
/** @brief Fully composed scale=1 frames in playback order. @chinese 按播放顺序排列的完整画布帧，scale 为 1。 */
@property (nonatomic, copy, readonly) NSArray<UIImage *> *frames;
/** @brief Durations in milliseconds; GIF delays of 0/10ms become 100ms. @chinese 每帧毫秒时长，GIF 的 0/10ms 修正为 100ms。 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *frameDurationsMillis;
/** @brief Logical screen pixel width. @chinese 逻辑画布像素宽度。 */
@property (nonatomic, assign, readonly) NSUInteger width;
/** @brief Logical screen pixel height. @chinese 逻辑画布像素高度。 */
@property (nonatomic, assign, readonly) NSUInteger height;
@end

/** @brief ImageIO decoding with GifDrawable 1.2.25 disposal rules. @chinese 使用 ImageIO 解码并应用 GifDrawable 1.2.25 disposal 规则。 */
@interface TSFitDialGIFDecoder : NSObject
/**
 * @brief Decode GIF frames synchronously without applying dial layout.
 * @chinese 同步解码 GIF，处理局部帧、透明、背景恢复和前帧恢复，不附加表盘布局。
 * @param data EN: GIF87a or GIF89a bytes. CN: GIF87a 或 GIF89a 数据。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Composed frames or nil. CN: 合成帧，失败返回 nil。
 */
+ (nullable TSFitDialDecodedGIF *)decodeData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
/**
 * @brief Decode a local GIF file on the caller's thread.
 * @chinese 在调用线程解码本地 GIF 文件，可在后台线程调用。
 * @param fileURL EN: Local file URL. CN: 本地文件 URL。
 * @param error EN: Read or decode failure details. CN: 读取或解码失败信息。
 * @return EN: Composed frames or nil. CN: 合成帧，失败返回 nil。
 */
+ (nullable TSFitDialDecodedGIF *)decodeFileURL:(NSURL *)fileURL error:(NSError * _Nullable * _Nullable)error;
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
