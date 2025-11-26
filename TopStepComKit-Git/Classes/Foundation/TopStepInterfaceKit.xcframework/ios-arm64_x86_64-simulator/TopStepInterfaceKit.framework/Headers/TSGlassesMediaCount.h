//
//  TSGlassesMediaCount.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/6/19.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Smart glasses media count model
 * @chinese 智能眼镜媒体数量模型
 * 
 * @discussion
 * EN: This model represents the count of different types of media files
 *     stored on the smart glasses device.
 * CN: 此模型表示智能眼镜设备上存储的不同类型媒体文件的数量。
 */
@interface TSGlassesMediaCount : TSKitBaseModel

/**
 * @brief Number of video files on the device
 * @chinese 设备上的视频文件数量
 *
 * @discussion
 * [EN]: Total count of video files (including recorded videos and downloaded videos)
 *       stored on the smart glasses device.
 * [CN]: 智能眼镜设备上存储的视频文件总数（包括录制的视频和下载的视频）。
 *
 * @note
 * [EN]: This count includes all video formats supported by the device.
 * [CN]: 此数量包括设备支持的所有视频格式。
 */
@property (nonatomic, assign) NSInteger videoCount;

/**
 * @brief Number of audio recording files on the device
 * @chinese 设备上的录音文件数量
 *
 * @discussion
 * [EN]: Total count of audio recording files created by the smart glasses device.
 *       This includes voice memos and other audio recordings.
 * [CN]: 智能眼镜设备创建的录音文件总数。包括语音备忘录和其他录音文件。
 *
 * @note
 * [EN]: This count only includes audio files recorded by the device itself.
 * [CN]: 此数量仅包括设备本身录制的音频文件。
 */
@property (nonatomic, assign) NSInteger audioRecordingCount;

/**
 * @brief Number of music files on the device
 * @chinese 设备上的音乐文件数量
 *
 * @discussion
 * [EN]: Total count of music files stored on the smart glasses device.
 *       This includes uploaded music files and system music.
 * [CN]: 智能眼镜设备上存储的音乐文件总数。包括上传的音乐文件和系统音乐。
 *
 * @note
 * [EN]: This count includes all music formats supported by the device.
 * [CN]: 此数量包括设备支持的所有音乐格式。
 */
@property (nonatomic, assign) NSInteger musicCount;

/**
 * @brief Number of photo files on the device
 * @chinese 设备上的照片文件数量
 *
 * @discussion
 * [EN]: Total count of photo files captured by the smart glasses device.
 *       This includes photos taken with the device camera.
 * [CN]: 智能眼镜设备拍摄的照片文件总数。包括使用设备摄像头拍摄的照片。
 *
 * @note
 * [EN]: This count includes all photo formats supported by the device.
 * [CN]: 此数量包括设备支持的所有照片格式。
 */
@property (nonatomic, assign) NSInteger photoCount;

/**
 * @brief Get total count of all media files
 * @chinese 获取所有媒体文件的总数量
 *
 * @return 
 * EN: Total count of all media files (videos + audio recordings + music + photos)
 * CN: 所有媒体文件的总数量（视频 + 录音 + 音乐 + 照片）
 *
 * @discussion
 * EN: This method calculates the sum of all media file counts on the device.
 *     It provides a quick way to check the total media storage usage.
 * CN: 此方法计算设备上所有媒体文件数量的总和。
 *     它提供了一种快速检查总媒体存储使用情况的方法。
 */
- (NSInteger)totalMediaCount;

/**
 * @brief Check if device has any media files
 * @chinese 检查设备是否有任何媒体文件
 *
 * @return 
 * EN: YES if device has at least one media file, NO if no media files exist
 * CN: 如果设备至少有一个媒体文件返回YES，如果没有媒体文件返回NO
 *
 * @discussion
 * EN: This method provides a quick way to determine if the device contains
 *     any media files without needing to check individual counts.
 * CN: 此方法提供了一种快速确定设备是否包含任何媒体文件的方法，
 *     无需检查各个单独的数量。
 *
 * @note
 * EN: This method is equivalent to checking if totalMediaCount > 0.
 * CN: 此方法等同于检查 totalMediaCount > 0。
 */
- (BOOL)hasAnyMedia;

@end

NS_ASSUME_NONNULL_END
