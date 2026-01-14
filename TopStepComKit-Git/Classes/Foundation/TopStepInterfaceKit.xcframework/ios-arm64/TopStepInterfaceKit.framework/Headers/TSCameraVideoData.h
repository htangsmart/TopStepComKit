//
//  TSCameraVideoData.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/1/13.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSCameraVideoData : TSKitBaseModel

/**
 * @brief Video frame data
 * @chinese 视频帧数据
 *
 * @discussion
 * EN: Raw video frame data received from the device.
 * CN: 从设备接收的原始视频帧数据。
 */
@property (nonatomic, strong) NSData *data;

/**
 * @brief Whether this frame is a key frame
 * @chinese 是否为关键帧
 *
 * @discussion
 * EN: YES if this is a key frame (I-frame), NO for non-key frames (P-frame/B-frame).
 *     Key frames contain complete image data and can be decoded independently.
 * CN: 如果是关键帧（I帧）则为YES，非关键帧（P帧/B帧）则为NO。
 *     关键帧包含完整的图像数据，可以独立解码。
 */
@property (nonatomic, assign) BOOL isKeyFrame;

/**
 * @brief Initialize with video data and key frame flag
 * @chinese 使用视频数据和关键帧标志初始化
 *
 * @param data 
 * EN: Video frame data
 * CN: 视频帧数据
 *
 * @param isKeyFrame 
 * EN: Whether this frame is a key frame
 * CN: 是否为关键帧
 *
 * @return 
 * EN: Initialized instance
 * CN: 初始化后的实例
 */
- (instancetype)initWithData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame;

@end

NS_ASSUME_NONNULL_END
