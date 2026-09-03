//
//  TSDialCapability.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/19.
//
//  文件说明:
//  表盘静态能力快照模型。将原先散落在协议上的一堆能力查询方法
//  （isSupportXXX / maxXXX）聚合为单一对象，一次性返回，便于跨平台桥接对齐。

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import "TSPeripheralScreen.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face static capability snapshot
 * @chinese 表盘静态能力快照
 *
 * @discussion
 * [EN]: Aggregates all watch-face capability flags and numeric limits of the
 *       connected device into a single object, fetched once. Replaces the
 *       scattered per-capability methods (isSupportVideoDial, maxVideoDialDuration, etc.).
 * [CN]: 将已连接设备的所有表盘能力开关与数值上限聚合为单一对象，一次性获取。
 *       替代原先散落的单项能力方法（isSupportVideoDial、maxVideoDialDuration 等）。
 */
@interface TSDialCapability : TSKitBaseModel

/**
 * @brief Whether custom watch face creation is supported
 * @chinese 是否支持自定义表盘制作
 */
@property (nonatomic, assign, readonly) BOOL supportsCustom;

/**
 * @brief Whether video background is supported
 * @chinese 是否支持视频背景表盘
 */
@property (nonatomic, assign, readonly) BOOL supportsVideo;

/**
 * @brief Max video background duration in seconds
 * @chinese 视频背景最大时长（秒）
 *
 * @discussion
 * [EN]: 0 means video is not supported. Check supportsVideo first.
 * [CN]: 为 0 表示不支持视频，请先判断 supportsVideo。
 */
@property (nonatomic, assign, readonly) NSInteger maxVideoDuration;

/**
 * @brief Whether multi-image (slideshow / album) background is supported
 * @chinese 是否支持多图（相册/幻灯片）背景表盘
 */
@property (nonatomic, assign, readonly) BOOL supportsSlideshow;

/**
 * @brief Max number of slideshow images
 * @chinese 相册表盘最大图片数量
 *
 * @discussion
 * [EN]: 0 means slideshow has no explicit limit.
 * [CN]: 为 0 表示无明确上限。
 */
@property (nonatomic, assign, readonly) NSInteger maxSlideshowImages;

/**
 * @brief Whether the time/style image can be color-tinted
 * @chinese 时间/样式图是否支持染色
 */
@property (nonatomic, assign, readonly) BOOL colorTintable;

/**
 * @brief Whether dial component is supported
 * @chinese 是否支持表盘组件
 */
@property (nonatomic, assign, readonly) BOOL supportsComponent;

/**
 * @brief Max installable watch face count
 * @chinese 可安装表盘数量上限
 *
 * @discussion
 * [EN]: -1 means unlimited, 0 means custom/cloud install is not supported.
 * [CN]: -1 表示无限制，0 表示不支持安装云端/自定义表盘。
 */
@property (nonatomic, assign, readonly) NSInteger maxInstallCount;

/**
 * @brief Max number of built-in watch faces
 * @chinese 内置表盘最大数量
 */
@property (nonatomic, assign, readonly) NSInteger maxInnerCount;

/**
 * @brief Screen width in pixels
 * @chinese 屏幕宽度（像素）
 */
@property (nonatomic, assign, readonly) NSInteger screenWidth;

/**
 * @brief Screen height in pixels
 * @chinese 屏幕高度（像素）
 */
@property (nonatomic, assign, readonly) NSInteger screenHeight;

/**
 * @brief Device screen physical corner radius in pixels
 * @chinese 设备屏幕物理圆角半径（像素）
 */
@property (nonatomic, assign, readonly) CGFloat deviceCornerRadius;

/**
 * @brief Preview thumbnail width in pixels
 * @chinese 预览缩略图宽度（像素）
 */
@property (nonatomic, assign, readonly) NSInteger previewWidth;

/**
 * @brief Preview thumbnail height in pixels
 * @chinese 预览缩略图高度（像素）
 */
@property (nonatomic, assign, readonly) NSInteger previewHeight;

/**
 * @brief Preview thumbnail corner radius in pixels
 * @chinese 预览缩略图圆角半径（像素）
 */
@property (nonatomic, assign, readonly) CGFloat previewCornerRadius;

/**
 * @brief Screen shape
 * @chinese 屏幕形状
 */
@property (nonatomic, assign, readonly) TSPeriphShape shape;

/**
 * @brief Disable default init method
 * @chinese 禁用默认初始化方法
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用 new 方法
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
