//
//  TSDialDraft+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/8/30.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK build helpers for dial drafts
 * @chinese 表盘草稿的 NPK 造包辅助能力
 */
@interface TSDialDraft (Npk)

/**
 * @brief Generate an NPK custom dial identifier
 * @chinese 生成 NPK 自定义表盘标识符
 *
 * @param draftType
 * EN: Dial draft type used as the identifier category.
 * CN: 作为标识符分类段的表盘草稿类型。
 *
 * @return
 * EN: Generated 14-digit dial identifier.
 * CN: 生成的 14 位表盘标识符。
 */
+ (NSString *)generateNpkCustomDialIdWithType:(TSDialDraftType)draftType;

/**
 * @brief Generate the preview image when it is absent
 * @chinese 在预览图缺失时自动生成预览图
 *
 * @param completion
 * EN: Completion called exactly once. The generated image is assigned to previewImage.
 * CN: 必定调用一次的完成回调；生成结果会写入 previewImage。
 *
 * @discussion
 * [EN]: An existing previewImage is preserved. Otherwise, the first image item and its
 *       time configuration are composed using the connected device's preview geometry.
 * [CN]: 已有 previewImage 会原样保留；否则使用首个图片 item、其时间配置及已连接
 *       设备的预览尺寸合成预览图。
 */
- (void)generatePreviewImageIfNeededWithCompletion:(void (^)(BOOL isSuccess,
                                                              NSError *_Nullable error))completion;

/**
 * @brief Calculate the time image rectangle in background coordinates
 * @chinese 计算时间图片在背景图坐标系中的矩形区域
 *
 * @param backgroundImageSize
 * EN: Background image size.
 * CN: 背景图片尺寸。
 *
 * @param timeImageSize
 * EN: Time style image size.
 * CN: 时间样式图片尺寸。
 *
 * @param position
 * EN: Requested time position.
 * CN: 指定的时间位置。
 *
 * @return
 * EN: Calculated rectangle in background coordinates.
 * CN: 背景图坐标系中的计算结果。
 */
+ (CGRect)previewTimeRectInBackgroundImageSize:(CGSize)backgroundImageSize
                                 timeImageSize:(CGSize)timeImageSize
                                      position:(TSDialTimePosition)position;

@end

NS_ASSUME_NONNULL_END
