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
- (NSString *)generateCustomDialId;

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

@end

NS_ASSUME_NONNULL_END
