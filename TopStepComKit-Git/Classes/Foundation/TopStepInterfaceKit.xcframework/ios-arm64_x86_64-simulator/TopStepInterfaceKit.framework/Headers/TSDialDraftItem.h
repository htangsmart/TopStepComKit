//
//  TSDialDraftItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/20.
//

#import "TSKitBaseModel.h"
#import "TSDialTime.h"
#import <UIKit/UIKit.h>

@class TSDialDanMuItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Build draft resource item
 * @chinese 造包草稿资源项
 *
 * @discussion
 * [EN]: One ready-made image or video resource in TSDialDraft. Each item owns one
 *       TSDialTime so different backgrounds can use different time styles. DanMu drafts
 *       use an image background with danMuItems and may omit time.
 * [CN]: TSDialDraft 中的一个成品图片或视频资源。每个 item 拥有一个 TSDialTime，
 *       因此不同背景可以使用不同时间样式。弹幕草稿使用图片背景和 danMuItems，允许省略 time。
 */
@interface TSDialDraftItem : TSKitBaseModel <NSCopying>

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
 * [EN]: Required for image items and nil for video items created by the video factory.
 *       Pixel size (UIImage.size multiplied by scale) must match the supplied device
 *       screen size during screen-aware validation. A DanMu item uses this entire
 *       image as its background. Copies share the image without duplicating pixels.
 * [CN]: 图片资源项必填，由视频工厂创建的资源项为 nil。按屏幕校验时，
 *       像素尺寸（UIImage.size 乘 scale）必须与设备屏幕尺寸匹配。
 *       弹幕资源项将整张图片作为背景；复制模型共享图片，不复制像素数据。
 */
@property (nonatomic, strong, nullable, readonly) UIImage *image;

/**
 * @brief Local prepared video file path
 * @chinese 本地成品视频文件路径
 *
 * @discussion
 * [EN]: Required and nonempty for video items; the file must exist. When the Provider
 *       advertises videoRequirementsForQuality:, export a finished video matching that
 *       snapshot before building. Other Providers retain their documented media behavior.
 *       Keep this caller-owned file readable and unchanged until build completes;
 *       copying the model copies its path, without duplicating or deleting the file.
 * [CN]: 视频资源项必填且不能为空，文件必须存在。Provider 提供
 *       videoRequirementsForQuality: 结果时，App 应先按该快照导出成品视频再造包；
 *       其他 Provider 保留其已约定的媒体处理行为。造包完成前应保持调用方文件可读且不变；
 *       复制模型仅复制路径，不复制或删除文件。
 */
@property (nonatomic, copy, nullable, readonly) NSString *videoFilePath;

/**
 * @brief Time element configuration for this resource
 * @chinese 当前资源的时间元素配置
 *
 * @discussion
 * [EN]: Required for single-image, multiple-image, and video drafts; optional for
 *       a DanMu image background with nonempty danMuItems. Copied at construction
 *       and when the item is copied, keeping each background's time configuration
 *       independent. Actual device time support remains Provider/template-specific.
 * [CN]: 单图、多图及视频草稿必填；带非空 danMuItems 的弹幕图片背景可为 nil。
 *       构造和复制资源项时均复制时间模型，使各背景的时间配置独立；
 *       设备实际时间显示仍取决于 Provider 和模板支持。
 */
@property (nonatomic, copy, nullable, readonly) TSDialTime *time;

/**
 * @brief Scrolling items bound to this image background
 * @chinese 当前图片背景关联的弹幕资源项
 *
 * @discussion
 * [EN]: Defaults to an empty array. Only DanMu drafts may provide a nonempty array,
 *       which must contain valid TSDialDanMuItem values and at least one item.
 *       Copying the draft item also copies each DanMu model; immutable images remain shared.
 * [CN]: 默认为空数组。仅弹幕草稿允许提供非空数组，且至少包含一个有效的
 *       TSDialDanMuItem。复制当前资源项时同时复制每个弹幕模型，
 *       不可变图片仍共享持有。
 */
@property (nonatomic, copy) NSArray<TSDialDanMuItem *> *danMuItems;

/**
 * @brief Create an image draft item
 * @chinese 创建图片草稿资源项
 *
 * @param image
 * EN: Ready-made image matching TSPeripheralScreen.screenSize.
 * CN: 像素尺寸等于 TSPeripheralScreen.screenSize 的成品图片。
 *
 * @param time
 * EN: Time configuration for this image. Nil is allowed only in a DanMu draft.
 * CN: 当前图片的时间配置，仅弹幕草稿允许传 nil。
 *
 * @return
 * EN: Configured draft item.
 * CN: 配置好的草稿资源项。
 */
+ (instancetype)itemWithImage:(UIImage *)image time:(nullable TSDialTime *)time;

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
