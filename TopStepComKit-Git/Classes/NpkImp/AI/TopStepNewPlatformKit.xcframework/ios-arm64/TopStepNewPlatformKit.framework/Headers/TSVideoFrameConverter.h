//
//  TSVideoFrameConverter.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Video frame conversion result model
 * @chinese 视频帧转换结果模型
 */
@interface TSVideoFrameConvertResult : NSObject

/**
 * @brief Y plane data (luminance data)
 * @chinese Y平面数据（亮度数据）
 */
@property (nonatomic, strong, nullable) NSData *yData;

/**
 * @brief U plane data (chrominance data)
 * @chinese U平面数据（色度数据）
 */
@property (nonatomic, strong, nullable) NSData *uData;

/**
 * @brief V plane data (chrominance data), can be nil for NV12 format
 * @chinese V平面数据（色度数据），对于NV12格式可以为nil
 */
@property (nonatomic, strong, nullable) NSData *vData;

/**
 * @brief Video frame width in pixels
 * @chinese 视频帧宽度（像素）
 */
@property (nonatomic, assign) NSInteger width;

/**
 * @brief Video frame height in pixels
 * @chinese 视频帧高度（像素）
 */
@property (nonatomic, assign) NSInteger height;

/**
 * @brief Device orientation value in degrees (0, 90, 180, 270)
 * @chinese 设备方向值（角度：0、90、180、270度）
 *
 * @discussion
 * [EN]: Orientation values in degrees (refer to MTWatchVideoH264 implementation):
 *       - 0: Landscape Left (左横屏)
 *       - 90: Portrait (竖屏)
 *       - 180: Landscape Right (右横屏)
 *       - 270: Portrait Upside Down (倒置竖屏)
 *
 * [CN]: 方向值（角度，参照MTWatchVideoH264实现）：
 *       - 0: 左横屏
 *       - 90: 竖屏
 *       - 180: 右横屏
 *       - 270: 倒置竖屏
 */
@property (nonatomic, assign) NSInteger orientation;

@end

/**
 * @brief Video frame converter utility class
 * @chinese 视频帧转换工具类
 *
 * @discussion
 * [EN]: This class provides functionality to convert CMSampleBuffer to YUV data format.
 *       It handles different pixel formats (NV12, I420) and extracts device orientation information.
 *       Follows single responsibility principle for video frame processing.
 *
 * [CN]: 此类提供将CMSampleBuffer转换为YUV数据格式的功能。
 *       处理不同的像素格式（NV12、I420）并提取设备方向信息。
 *       遵循视频帧处理的单一职责原则。
 */
@interface TSVideoFrameConverter : NSObject

/**
 * @brief Convert CMSampleBuffer to YUV data format
 * @chinese 将CMSampleBuffer转换为YUV数据格式
 *
 * @param sampleBuffer
 * EN: CMSampleBuffer containing video frame data from AVFoundation capture session
 * CN: 包含来自AVFoundation捕获会话的视频帧数据的CMSampleBuffer
 *
 * @param error
 * EN: Pointer to NSError object for error information. Can be nil.
 * CN: 指向NSError对象的指针，用于错误信息。可以为nil。
 *
 * @return
 * EN: TSVideoFrameConvertResult object containing YUV data and metadata, nil if conversion fails
 * CN: 包含YUV数据和元数据的TSVideoFrameConvertResult对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: This method extracts YUV data from CMSampleBuffer and determines device orientation.
 *       Supports NV12 and I420 pixel formats commonly used by AVFoundation.
 *       The method handles pixel buffer locking/unlocking automatically.
 *       Note: The isBack parameter should be passed directly to the encoding method, not to this converter.
 *
 * [CN]: 此方法从CMSampleBuffer中提取YUV数据并确定设备方向。
 *       支持AVFoundation常用的NV12和I420像素格式。
 *       该方法自动处理像素缓冲区的锁定/解锁。
 *       注意：isBack参数应该直接传递给编码方法，而不是传递给此转换器。
 */
+ (nullable TSVideoFrameConvertResult *)convertSampleBufferToYUV:(CMSampleBufferRef)sampleBuffer
                                                             error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END

