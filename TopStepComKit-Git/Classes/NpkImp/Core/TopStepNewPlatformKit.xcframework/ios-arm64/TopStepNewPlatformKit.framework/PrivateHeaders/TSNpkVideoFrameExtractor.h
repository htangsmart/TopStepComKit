//
//  TSNpkVideoFrameExtractor.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Extracts the first frame of a video file
 * @chinese 提取视频文件的第一帧
 */
@interface TSNpkVideoFrameExtractor : NSObject

/**
 * @brief First frame with the track's preferred transform applied
 * @chinese 取第一帧，已应用视频轨道的方向变换
 */
+ (nullable UIImage *)firstFrameOfVideoAtPath:(NSString *)videoFilePath
                                        error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
