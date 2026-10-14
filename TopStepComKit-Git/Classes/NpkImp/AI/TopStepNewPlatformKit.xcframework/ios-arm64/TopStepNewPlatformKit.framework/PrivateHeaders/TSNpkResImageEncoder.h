//
//  TSNpkResImageEncoder.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkResImageSpec;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Result of encoding one image for res.bin
 * @chinese 一张图片编码后的结果
 *
 * @discussion
 * [EN]: Carries the payload together with every header field that depends on the encoding, so the format label
 *       and the data always come from the same place.
 * [CN]: 同时携带数据和所有取决于编码方式的图片头字段，保证格式标签与数据出自同一处。
 */
@interface TSNpkResEncodedImage : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) uint8_t colorFormat;
@property (nonatomic, assign) uint16_t flags;
@property (nonatomic, assign) uint16_t stride;
@property (nonatomic, assign) uint16_t width;
@property (nonatomic, assign) uint16_t height;
@end

/**
 * @brief Encodes a planned image into the pixel format of one platform/quality
 * @chinese 把计划中的图片编码成某个平台/画质对应的像素格式
 *
 * @discussion
 * [EN]: One implementation per format (W30 TSC now; W30 raw RGB and 579X ParV3 later).
 * [CN]: 一种格式一个实现（当前为 W30 TSC；后续有 W30 无损 RGB、579X ParV3）。
 */
@protocol TSNpkResImageEncoder <NSObject>

/**
 * @brief Encode the image described by a spec
 * @chinese 编码计划项描述的图片
 *
 * @param spec EN: A non-removal spec. CN: 非移除类型的计划项。
 * @param error EN: Failure reason. CN: 失败原因。
 * @return EN: Encoded image, or nil on failure. CN: 编码结果，失败返回 nil。
 */
- (nullable TSNpkResEncodedImage *)encodeImageWithSpec:(TSNpkResImageSpec *)spec
                                                error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
