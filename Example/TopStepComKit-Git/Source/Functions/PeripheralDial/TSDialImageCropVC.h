//
//  TSDialImageCropVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Image cropping view controller for custom dial creation
 * @chinese 自定义表盘制作流程中的图片裁剪控制器
 *
 * @discussion
 * [EN]: Presents the source image in a scrollable/zoomable viewport
 *       locked to the device dial aspect ratio. The user pans and pinches
 *       to frame the desired region, then taps "使用" to confirm.
 * [CN]: 将原始图片展示在可滚动/可缩放的裁剪框中，
 *       裁剪框比例锁定为设备表盘比例（宽高比）。
 *       用户平移/捏合构图后点击「使用」确认。
 */
@interface TSDialImageCropVC : UIViewController

/**
 * @brief Designated initializer.
 * @chinese 指定初始化方法。
 *
 * @param image
 * EN: Source image to be cropped.
 * CN: 待裁剪的原始图片。
 *
 * @param aspectRatio
 * EN: Target height-to-width ratio (e.g. 280/240 ≈ 1.167).
 * CN: 目标高宽比（如 280/240 ≈ 1.167）。
 *
 * @return
 * EN: A new TSDialImageCropVC instance.
 * CN: 新的 TSDialImageCropVC 实例。
 */
- (instancetype)initWithImage:(UIImage *)image
                  aspectRatio:(CGFloat)aspectRatio NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * @brief Called with the cropped UIImage when the user taps "使用".
 * @chinese 用户点击「使用」后回调裁剪后的图片。
 *
 * @param croppedImage
 * EN: The cropped image matching the dial aspect ratio.
 * CN: 裁剪后符合表盘比例的图片。
 */
@property (nonatomic, copy, nullable) void(^onCropComplete)(UIImage *croppedImage);

@end

NS_ASSUME_NONNULL_END
