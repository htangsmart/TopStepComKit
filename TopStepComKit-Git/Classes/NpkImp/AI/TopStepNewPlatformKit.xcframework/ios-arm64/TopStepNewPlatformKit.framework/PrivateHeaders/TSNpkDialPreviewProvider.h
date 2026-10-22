//
//  TSNpkDialPreviewProvider.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSNpkDialBuildRequest;
@class TSNpkDialBuildState;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Produces the dial preview image for a build
 * @chinese 为一次造包提供表盘预览图
 *
 * @discussion
 * [EN]: Explicit draft previews remain authoritative; generated previews use the frozen profile,
 *       prepared video cover and scrolling material, never the global connection.
 * [CN]: 显式草稿预览优先；生成时使用冻结设备快照、处理后的视频封面和弹幕素材，不读取全局连接。
 */
@interface TSNpkDialPreviewProvider : NSObject

+ (void)previewImageForRequest:(TSNpkDialBuildRequest *)request
                    completion:(void (^)(UIImage *_Nullable previewImage, NSError *_Nullable error))completion;

/**
 * @brief Produce a preview using prepared stage results.
 * @chinese 使用已准备的阶段结果生成预览。
 * @param request EN: Frozen request. CN: 冻结的请求。
 * @param state EN: Prepared media results. CN: 已准备的媒体结果。
 * @param completion EN: Preview or failure. CN: 预览或错误回调。
 */
+ (void)previewImageForRequest:(TSNpkDialBuildRequest *)request state:(nullable TSNpkDialBuildState *)state completion:(void (^)(UIImage *_Nullable previewImage, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
