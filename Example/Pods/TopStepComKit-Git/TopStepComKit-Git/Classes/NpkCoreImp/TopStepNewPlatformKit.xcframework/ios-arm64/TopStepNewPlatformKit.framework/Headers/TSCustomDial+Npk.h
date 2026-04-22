//
//  TSCustomDial+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/5.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSCustomDial (Npk)

/**
 * @brief Generate dial ID
 * @chinese 生成表盘ID
 */
+ (NSString *)generateNpkCustomDialIdWithType:(TSCustomDialType)dialType;

/**
 * @brief Generate preview image item automatically if not set
 * @chinese 如果未设置预览图项，则自动生成
 *
 * @param completion
 * EN: Completion callback, returns YES if previewImageItem was generated or already exists, NO if generation failed
 * CN: 完成回调，如果previewImageItem已生成或已存在返回YES，生成失败返回NO
 *
 * @discussion
 * [EN]: If previewImageItem is not set, this method will automatically generate it based on the first item in resourceItems.
 *       The generation process includes:
 *       1. Get resourceImage from the first resourceItem
 *       2. Crop the image if needed
 *       3. Get timePosition and other parameters
 *       4. Call UIImage+Tool's previewImageWith method to generate preview image
 *       5. Create previewImageItem
 * [CN]: 如果previewImageItem未设置，此方法将根据resourceItems的第一个项自动生成。
 *       生成过程包括：
 *       1. 从第一个resourceItem获取resourceImage
 *       2. 如果需要，对图片进行裁切
 *       3. 获取timePosition等参数
 *       4. 调用UIImage+Tool的previewImageWith方法生成预览图
 *       5. 创建previewImageItem
 */
- (void)generatePreviewImageItemIfNeededWithCompletion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;


/**
 * @brief Calculate time image rect in background image coordinate system
 * @chinese 计算时间图片在背景图上的位置和尺寸
 *
 * @param originImageSize
 * EN: Background image size (the size of the background image where time image will be placed)
 * CN: 背景图图片尺寸（时间图片将被放置的背景图尺寸）
 *
 * @param timeImageSize
 * EN: Time image size (the size of the time image)
 * CN: 时间原始图片尺寸（时间图片的尺寸）
 *
 * @param position
 * EN: Time position (top, bottom, left, right)
 * CN: 时间位置（上、下、左、右）
 *
 * @return
 * EN: Calculated time rect in background image coordinate system (originImageSize). Returns CGRectZero if position is invalid
 * CN: 计算出的时间图片在背景图上的CGRect（基于originImageSize坐标系），位置参数无效时返回CGRectZero
 *
 * @discussion
 * [EN]: This method calculates where the time image should be placed on the background image.
 *       It directly calculates the position based on originImageSize, timeImageSize and position parameter.
 *       The time image will be centered horizontally when position is top or bottom,
 *       and centered vertically when position is left or right.
 * [CN]: 此方法计算时间图片在背景图上应该放置的位置。
 *       直接基于originImageSize、timeImageSize和position参数计算位置。
 *       当position为top或bottom时，时间图片水平居中；
 *       当position为left或right时，时间图片垂直居中。
 */
+ (CGRect)previewTimeRectInBackgroundImageSize:(CGSize)originImageSize timeImageSize:(CGSize)timeImageSize position:(TSDialTimePosition)position;

@end

NS_ASSUME_NONNULL_END
