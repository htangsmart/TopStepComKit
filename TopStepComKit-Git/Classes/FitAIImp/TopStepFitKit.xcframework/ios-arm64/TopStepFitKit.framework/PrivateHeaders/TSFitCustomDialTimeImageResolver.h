//
//  TSFitCustomDialTimeImageResolver.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/19.
//

#import <Foundation/Foundation.h>

@class TSCustomDialStyleConstraint;
@class TSCustomDialTime;
@class TSFitDialTemplateDownloader;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completion for preparing a custom-dial time image
 * @chinese 自定义表盘时间图片准备完成回调
 */
typedef void (^TSFitCustomDialTimeImageCompletion)(NSError *_Nullable error);

/**
 * @brief Resolves and loads the selected custom-dial time image
 * @chinese 解析并加载选中的自定义表盘时间图片
 */
@interface TSFitCustomDialTimeImageResolver : NSObject

/**
 * @brief Initialize with a shared dial-resource downloader
 * @chinese 使用共享表盘资源下载器初始化
 * @param downloader EN: Dial-resource downloader. CN: 表盘资源下载器。
 * @return EN: Initialized resolver, or nil. CN: 初始化后的解析器，依赖无效时为 nil。
 */
- (nullable instancetype)initWithDownloader:(TSFitDialTemplateDownloader *)downloader
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Prepare the selected time image from a device constraint
 * @chinese 根据设备约束准备选中的时间图片
 * @param dialTime EN: Selected time configuration. CN: 选中的时间配置。
 * @param constraint EN: Current device style constraint. CN: 当前设备样式约束。
 * @param completion EN: Completion called on the main thread once. CN: 在主线程调用一次的完成回调。
 */
- (void)prepareTimeImageForDialTime:(TSCustomDialTime *)dialTime
                          constraint:(TSCustomDialStyleConstraint *)constraint
                          completion:(TSFitCustomDialTimeImageCompletion)completion;

@end

NS_ASSUME_NONNULL_END
