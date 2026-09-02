//
//  TSDialDraftItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/20.
//

#import "TSKitBaseModel.h"
#import "TSDialTime.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Build draft resource item
 * @chinese 造包草稿资源项
 *
 * @discussion
 * [EN]: One ready-made image or video resource in TSDialDraft. Each item owns one
 *       TSDialTime so different backgrounds can use different time styles.
 * [CN]: TSDialDraft 中的一个成品图片或视频资源。每个 item 拥有一个 TSDialTime，
 *       因此不同背景可以使用不同时间样式。
 */
@interface TSDialDraftItem : TSKitBaseModel

/**
 * @brief Resource item type
 * @chinese 资源项类型
 *
 * @discussion
 * [EN]: Read-only. Set by the factory method and indicates whether this item is image or video.
 * [CN]: 只读。由工厂方法设置，表示当前 item 是图片还是视频。
 */
@property (nonatomic, assign, readonly) TSDialDraftItemType itemType;

/**
 * @brief Ready-made image resource
 * @chinese 成品图片资源
 *
 * @discussion
 * [EN]: Read-only. Non-nil for image items. Pixel size must equal TSPeripheralScreen.screenSize.
 * [CN]: 只读。图片 item 非空，像素尺寸必须等于 TSPeripheralScreen.screenSize。
 */
@property (nonatomic, strong, nullable, readonly) UIImage *image;

/**
 * @brief Ready-made video file path
 * @chinese 成品视频文件路径
 *
 * @discussion
 * [EN]: Read-only. Non-empty for video items. The file must exist before build starts.
 * [CN]: 只读。视频 item 非空，造包前文件必须存在。
 */
@property (nonatomic, copy, nullable, readonly) NSString *videoFilePath;

/**
 * @brief Time element configuration for this resource
 * @chinese 当前资源的时间元素配置
 *
 * @discussion
 * [EN]: Required. Controls time image, position, rect, color and style for this item.
 * [CN]: 必填。控制当前 item 的时间图片、位置、区域、颜色和样式。
 */
@property (nonatomic, copy, nonnull, readonly) TSDialTime *time;

/**
 * @brief Create an image draft item
 * @chinese 创建图片草稿资源项
 *
 * @param image
 * EN: Ready-made image matching TSPeripheralScreen.screenSize.
 * CN: 像素尺寸等于 TSPeripheralScreen.screenSize 的成品图片。
 *
 * @param time
 * EN: Time configuration for this image.
 * CN: 当前图片的时间配置。
 *
 * @return
 * EN: Configured draft item.
 * CN: 配置好的草稿资源项。
 */
+ (instancetype)itemWithImage:(UIImage *)image time:(TSDialTime *)time;

/**
 * @brief Create a video draft item
 * @chinese 创建视频草稿资源项
 *
 * @param videoFilePath
 * EN: Ready-made local video file path.
 * CN: 成品视频本地文件路径。
 *
 * @param time
 * EN: Time configuration for this video.
 * CN: 当前视频的时间配置。
 *
 * @return
 * EN: Configured draft item.
 * CN: 配置好的草稿资源项。
 */
+ (instancetype)itemWithVideoFilePath:(NSString *)videoFilePath time:(TSDialTime *)time;

/**
 * @brief Whether this item contains an image resource
 * @chinese 是否包含图片资源
 *
 * @return
 * EN: YES when image is provided.
 * CN: image 已提供时返回 YES。
 */
- (BOOL)hasImageResource;

/**
 * @brief Whether this item contains a video resource
 * @chinese 是否包含视频资源
 *
 * @return
 * EN: YES when videoFilePath is provided.
 * CN: videoFilePath 已提供时返回 YES。
 */
- (BOOL)hasVideoResource;

/**
 * @brief Validate this item with device screen size
 * @chinese 根据设备屏幕尺寸校验当前资源项
 *
 * @param screenSize
 * EN: Device screen size in pixels.
 * CN: 设备屏幕像素尺寸。
 *
 * @return
 * EN: NSError if validation fails, nil if valid.
 * CN: 校验失败返回 NSError，校验通过返回 nil。
 *
 * @discussion
 * [EN]: Validates resource presence and image size. Video frame size and cover frame
 *       are handled by the build implementation.
 * [CN]: 校验资源是否存在和图片尺寸。视频帧尺寸与封面帧由造包实现处理。
 */
- (NSError *_Nullable)doesModelHasErrorWithScreenSize:(CGSize)screenSize;

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
