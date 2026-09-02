//
//  TSComposePreviewInput.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/19.
//
//  文件说明:
//  表盘预览图合成入参。将背景图、时间样式和输出参数收敛为单一只读对象，
//  作为 composeDialPreview:completion: 的唯一入参。

#import "TSKitBaseModel.h"
#import "TSDialTime.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Input for watch face preview composition
 * @chinese 表盘预览图合成入参
 *
 * @discussion
 * [EN]: Immutable input for composeDialPreview:completion:. It contains the background
 *       image, optional time configuration and output options.
 * [CN]: composeDialPreview:completion: 的不可变入参，包含背景图、可选时间配置和输出选项。
 */
@interface TSComposePreviewInput : TSKitBaseModel

/**
 * @brief Background image (base layer)
 * @chinese 背景图（底图）
 */
@property (nonatomic, strong, readonly) UIImage *backgroundImage;

/**
 * @brief Time configuration composited onto the background
 * @chinese 合成到背景上的时间配置
 *
 * @discussion
 * [EN]: Optional. nil means no time layer is composited.
 * [CN]: 为 nil 表示不合成时间图层。
 */
@property (nonatomic, copy, nullable, readonly) TSDialTime *time;

/**
 * @brief Max output size in KB
 * @chinese 输出最大大小（KB）
 *
 * @discussion
 * [EN]: <= 0 falls back to the implementation default (300 KB).
 * [CN]: <= 0 时回退到实现默认值（300 KB）。
 */
@property (nonatomic, assign, readonly) CGFloat maxKBSize;

/**
 * @brief Whether to keep transparent background
 * @chinese 是否保留透明背景
 */
@property (nonatomic, assign, readonly) BOOL keepTransparentBackground;

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param backgroundImage
 * EN: Background image used as the base layer.
 * CN: 作为底图的背景图。
 *
 * @param time
 * EN: Optional time configuration; nil means no time layer.
 * CN: 可选时间配置；nil 表示不合成时间图层。
 *
 * @param maxKBSize
 * EN: Max output size in KB. <= 0 falls back to implementation default.
 * CN: 输出最大大小（KB）；<= 0 时回退到实现默认值。
 *
 * @param keepTransparentBackground
 * EN: Whether to keep transparent background.
 * CN: 是否保留透明背景。
 *
 * @return
 * EN: Initialized preview input.
 * CN: 初始化完成的预览入参。
 */
- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage
                                   time:(nullable TSDialTime *)time
                              maxKBSize:(CGFloat)maxKBSize
              keepTransparentBackground:(BOOL)keepTransparentBackground NS_DESIGNATED_INITIALIZER;

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

/**
 * @brief Debug description
 * @chinese 调试描述
 *
 * @return
 * EN: Human-readable preview composition input information for logs.
 * CN: 用于日志的人类可读预览合成入参信息。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
