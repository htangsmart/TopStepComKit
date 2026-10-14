//
//  TSNpkDialPreviewProvider.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSNpkDialBuildRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Produces the dial preview image for a build
 * @chinese 为一次造包提供表盘预览图
 *
 * @discussion
 * [EN]: Order: the preview supplied in the draft; else, for image drafts, the draft's own preview generation;
 *       else, for video drafts, the first video frame composed with the time style image.
 *       The result is not resized here; the image encoder scales it to the preview pixel size.
 * [CN]: 顺序：草稿里已有的预览图；否则图片草稿用草稿自带的预览图生成逻辑；否则视频草稿取视频首帧并叠加时间样式图。
 *       这里不做缩放，图片编码时会缩放到预览图像素尺寸。
 */
@interface TSNpkDialPreviewProvider : NSObject

+ (void)previewImageForRequest:(TSNpkDialBuildRequest *)request
                    completion:(void (^)(UIImage *_Nullable previewImage, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
