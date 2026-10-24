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

@class TSDialVideoRequirements;

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
 * @brief Supported explicit encoding quality presets
 * @chinese 支持显式选择的编码档位
 *
 * @discussion
 * [EN]: NSNumber values wrapping TSDialQuality, excluding the compatibility value
 *       Default. Defaults to an empty array until configured by the Provider.
 *       An empty array means no explicit preset is advertised, not that custom
 *       building is unavailable. Check supportsCustom separately.
 * [CN]: 元素为包装 TSDialQuality 的 NSNumber，不包含兼容值 Default。
 *       Provider 配置前默认为空数组。空数组表示未声明可显式选择的档位，
 *       不等于不支持自定义造包；自定义能力应另查 supportsCustom。
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *qualityLevels;

/**
 * @brief Look up prepared-video requirements for one quality
 * @chinese 查询指定质量的成品视频要求
 *
 * @discussion
 * [EN]: Synchronous lookup in this captured capability, without media I/O or a
 *       device request. Default must have its own entry; unsupported qualities do
 *       not fall back. A Provider that has not adopted this contract returns nil
 *       while retaining its documented video behavior. Query a new capability
 *       after changing the device, then use the same quality when building.
 * [CN]: 同步查询当前能力快照，不读取媒体或请求设备。Default 必须有独立条目，
 *       不支持的档位不会自动回退。未采用此合同的 Provider 返回 nil，仍保留其
 *       已约定的视频行为。切换设备后应获取新能力，并使用同一质量造包。
 *
 * @param quality
 * EN: Default, Standard or Lossless; unknown values return nil.
 * CN: Default、Standard 或 Lossless；未知值返回 nil。
 * @return
 * EN: Immutable requirements, or nil when video, quality or this query contract is unsupported.
 * CN: 不可变要求快照；不支持视频、该档位或此查询合同时返回 nil。
 */
- (nullable TSDialVideoRequirements *)videoRequirementsForQuality:(TSDialQuality)quality;

/**
 * @brief Whether custom watch face creation is supported
 * @chinese 是否支持自定义表盘制作
 *
 * @discussion
 * [EN]: Supplied by the Provider for the captured device. This is the general build
 *       capability; video, slideshow, DanMu, and explicit quality have separate gates.
 * [CN]: 由 Provider 根据所捕获设备提供。这是通用造包能力；
 *       视频、相册、弹幕和显式质量仍有各自的支持条件。
 */
@property (nonatomic, assign, readonly) BOOL supportsCustom;

/**
 * @brief Whether video background is supported
 * @chinese 是否支持视频背景表盘
 *
 * @discussion
 * [EN]: Supplied by the Provider for the current device and build implementation.
 *       Check maxVideoDuration and videoRequirementsForQuality: separately.
 * [CN]: 由 Provider 结合当前设备及造包实现提供；
 *       时长上限和 videoRequirementsForQuality: 的成品要求需分别检查。
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
 *
 * @discussion
 * [EN]: Supplied by the Provider. YES enables slideshow drafts, subject to
 *       maxSlideshowImages and the Provider's supported playback behavior.
 * [CN]: 由 Provider 提供。YES 表示支持相册草稿，
 *       仍受 maxSlideshowImages 及 Provider 轮播行为约束。
 */
@property (nonatomic, assign, readonly) BOOL supportsSlideshow;

/**
 * @brief Max number of slideshow images
 * @chinese 相册表盘最大图片数量
 *
 * @discussion
 * [EN]: Number of images advertised by the Provider. 0 means no explicit count limit
 *       is advertised; it does not imply slideshow support. Check supportsSlideshow first.
 * [CN]: Provider 声明的图片数量上限。0 表示未声明明确数量上限，
 *       不等于支持相册；应先检查 supportsSlideshow。
 */
@property (nonatomic, assign, readonly) NSInteger maxSlideshowImages;

/**
 * @brief Whether scrolling-overlay watch face creation is supported
 * @chinese 是否支持弹幕表盘制作
 *
 * @discussion
 * [EN]: Combines Provider implementation availability and device capabilities.
 *       Defaults to NO for Providers that do not implement this build path.
 * [CN]: 由 Provider 的生成实现和设备能力共同决定。
 *       尚未实现弹幕生成路径的 Provider 默认为 NO。
 */
@property (nonatomic, assign, readonly) BOOL supportsDanMu;

/**
 * @brief Whether the time/style image can be color-tinted
 * @chinese 时间/样式图是否支持染色
 *
 * @discussion
 * [EN]: Supplied by the Provider for time/style resources. It does not authorize
 *       recoloring background images or guarantee that every template is tintable.
 * [CN]: 由 Provider 针对时间或样式资源提供；
 *       不表示允许修改背景颜色，也不保证所有模板均可染色。
 */
@property (nonatomic, assign, readonly) BOOL colorTintable;

/**
 * @brief Whether dial component is supported
 * @chinese 是否支持表盘组件
 *
 * @discussion
 * [EN]: Supplied by the Provider from device component facts and build support.
 *       This flag is independent of shouldRenderTimeInPreview and does not itself
 *       enable video, slideshow, or DanMu.
 * [CN]: 由 Provider 根据设备组件信息及造包支持情况提供；
 *       与 shouldRenderTimeInPreview 独立，也不直接代表支持视频、相册或弹幕。
 */
@property (nonatomic, assign, readonly) BOOL supportsComponent;

/**
 * @brief Whether to draw the time overlay when composing an installation preview
 * @chinese 合成安装预览图时是否叠加时间
 *
 * @discussion
 * [EN]: Provider-defined preview policy, independent of component support. Requires a time
 *       configuration in the draft. Does not control the live clock or alter supplied previews.
 * [CN]: 由 Provider 决定的预览策略，与组件支持能力独立；仍需草稿提供时间配置。
 *       不控制手表实际时间显示，也不会修改调用方传入的成品预览图。
 */
@property (nonatomic, assign, readonly) BOOL shouldRenderTimeInPreview;

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
 *
 * @discussion
 * [EN]: Supplied by the Provider for built-in faces, not writable custom slots.
 *       A Provider may use -1 for an unlimited count; do not use this value as an
 *       installation slot index or the current number of installed faces.
 * [CN]: 由 Provider 提供，针对内置表盘而非可写自定义槽位。
 *       Provider 可用 -1 表示不设上限；不得作为安装槽位索引或当前已安装数量使用。
 */
@property (nonatomic, assign, readonly) NSInteger maxInnerCount;

/**
 * @brief Screen width in pixels
 * @chinese 屏幕宽度（像素）
 *
 * @discussion
 * [EN]: Device screen width supplied by the Provider. Use with screenHeight for
 *       background image preparation; this is a pixel count, not UIKit points.
 * [CN]: Provider 提供的设备屏幕宽度，与 screenHeight 一起用于准备背景图片；
 *       单位是像素，不是 UIKit 点。
 */
@property (nonatomic, assign, readonly) NSInteger screenWidth;

/**
 * @brief Screen height in pixels
 * @chinese 屏幕高度（像素）
 *
 * @discussion
 * [EN]: Device screen height supplied by the Provider. Use with screenWidth;
 *       preview and encoded video dimensions may differ from the screen dimensions.
 * [CN]: Provider 提供的设备屏幕高度，与 screenWidth 配合使用；
 *       预览图和编码视频的尺寸可能与屏幕尺寸不同。
 */
@property (nonatomic, assign, readonly) NSInteger screenHeight;

/**
 * @brief Device screen physical corner radius in pixels
 * @chinese 设备屏幕物理圆角半径（像素）
 *
 * @discussion
 * [EN]: Radius in screen pixel coordinates supplied by the Provider.
 *       It is separate from previewCornerRadius; do not apply it unchanged
 *       to a preview with different dimensions.
 * [CN]: Provider 提供的屏幕像素坐标系圆角半径，与 previewCornerRadius 分开；
 *       不应直接将该数值用于不同尺寸的预览图。
 */
@property (nonatomic, assign, readonly) CGFloat deviceCornerRadius;

/**
 * @brief Preview thumbnail width in pixels
 * @chinese 预览缩略图宽度（像素）
 *
 * @discussion
 * [EN]: Width required for a supplied TSDialDraft.previewImage.
 *       Use with previewHeight rather than the full-screen dimensions.
 * [CN]: 调用方提供 TSDialDraft.previewImage 时所需的宽度，
 *       应与 previewHeight 配合，不以完整屏幕尺寸替代。
 */
@property (nonatomic, assign, readonly) NSInteger previewWidth;

/**
 * @brief Preview thumbnail height in pixels
 * @chinese 预览缩略图高度（像素）
 *
 * @discussion
 * [EN]: Height required for a supplied TSDialDraft.previewImage.
 *       The Provider supplies this value independently of screenHeight.
 * [CN]: 调用方提供 TSDialDraft.previewImage 时所需的高度，
 *       由 Provider 独立于 screenHeight 提供。
 */
@property (nonatomic, assign, readonly) NSInteger previewHeight;

/**
 * @brief Preview thumbnail corner radius in pixels
 * @chinese 预览缩略图圆角半径（像素）
 *
 * @discussion
 * [EN]: Radius in preview pixel coordinates supplied by the Provider.
 *       Use for preview composition, not as the full-screen or video encoding radius.
 * [CN]: Provider 提供的预览图像素坐标系圆角半径，
 *       用于预览合成，不作为完整屏幕或视频编码圆角使用。
 */
@property (nonatomic, assign, readonly) CGFloat previewCornerRadius;

/**
 * @brief Screen shape
 * @chinese 屏幕形状
 *
 * @discussion
 * [EN]: TSPeriphShape value supplied by the Provider. Interpret it together with
 *       the screen dimensions and corner radius; it does not replace those values.
 * [CN]: Provider 提供的 TSPeriphShape 枚举值，应结合屏幕尺寸和圆角半径解释，
 *       不能替代这些数值。
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
