//
//  TSDialDraft.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/19.
//
//  文件说明:
//  自定义表盘造包草稿。App 提供模板、成品资源、时间样式和可选预览图，
//  SDK 据此构建可安装的 TSDialArtifact。

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import "TSDialDraftItem.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Custom watch face build draft
 * @chinese 自定义表盘造包草稿
 *
 * @discussion
 * [EN]: Input for buildDialWithDraft:. The App supplies a shared template, ready-made
 *       image/video resources, per-item time configuration, and an optional preview image.
 *       The SDK builds these inputs into a TSDialArtifact.
 * [CN]: buildDialWithDraft: 的入参。App 提供共用模板、成品图片/视频资源、
 *       每个资源项的时间配置以及可选预览图，SDK 据此构建 TSDialArtifact。
 */
@interface TSDialDraft : TSKitBaseModel <NSCopying>

/**
 * @brief Optional watch face id
 * @chinese 可选表盘 id
 *
 * @discussion
 * [EN]: Defaults to nil, allowing the Provider to generate or resolve the final id.
 *       Explicit syntax and range are Provider-specific; do not use this as a task
 *       identity. Use the resulting TSDialArtifact.dialId for the actual package id.
 * [CN]: 默认 nil，由 Provider 生成或确定最终编号。显式编号的格式和范围由 Provider
 *       决定，不应作为任务身份使用；实际包编号以返回的 TSDialArtifact.dialId 为准。
 */
@property (nonatomic, copy, nullable) NSString *dialId;

/**
 * @brief Optional encoding quality preset
 * @chinese 可选的编码画质档位
 *
 * @discussion
 * [EN]: Defaults to TSDialQualityDefault, preserving the Provider's existing output
 *       strategy; newly supported NPK W30 DanMu uses Standard. Explicit presets must
 *       appear in capability.qualityLevels. Unknown values are invalid, and Lossless
 *       names an SDK preset rather than promising mathematically lossless video.
 *       For video, query videoRequirementsForQuality: again after changing this value;
 *       a supported quality can require different prepared input pixels.
 * [CN]: 默认 TSDialQualityDefault，保留 Provider 既有输出策略；
 *       新支持的 NPK W30 弹幕使用 Standard。显式档位必须在 capability.qualityLevels
 *       中声明；未知值无效，Lossless 是 SDK 档位名，不承诺视频数学无损。
 *       视频修改本字段后应重新查询 videoRequirementsForQuality:；
 *       不同支持档位可能要求不同的成品输入像素尺寸。
 */
@property (nonatomic, assign) TSDialQuality quality;

/**
 * @brief Dial draft type
 * @chinese 表盘草稿类型
 *
 * @discussion
 * [EN]: Set by the designated initializer and must be single image, multiple-image,
 *       video, or DanMu. The selected type determines item count and resource kind;
 *       Provider capability is checked separately during build.
 * [CN]: 由指定初始化方法设置，只允许单图、多图、视频或弹幕。
 *       所选类型决定资源数量和类型；造包时还会单独检查 Provider 能力。
 */
@property (nonatomic, assign, readonly) TSDialDraftType draftType;

/**
 * @brief Optional local template package override
 * @chinese 可选的本地模板包覆盖路径
 *
 * @discussion
 * [EN]: Nil delegates template resolution or supported template-free generation to
 *       the Provider. A nonnil value must be nonempty and refer to an existing,
 *       compatible local template. Copying the draft copies the path, not the file.
 * [CN]: nil 表示由 Provider 解析模板，或采用其支持的无模板生成路径。
 *       非 nil 时必须为非空路径，指向已存在且兼容的本地模板。
 *       复制草稿只复制路径，不复制模板文件。
 */
@property (nonatomic, copy, nullable, readonly) NSString *templateFilePath;

/**
 * @brief Ready-made resource items
 * @chinese 成品资源项
 *
 * @discussion
 * [EN]: Required. Single image, video and DanMu drafts require exactly one item; multiple-image
 *       drafts require one or more image items. Each item owns its own TSDialTime; DanMu may omit it.
 *       DanMu requires an image background with nonempty danMuItems. Copies preserve each item's time
 *       independently, retain immutable images and copy paths without duplicating source files.
 * [CN]: 必填。单图、视频及弹幕草稿必须只有一个 item；多图草稿需要一个或多个图片 item。
 *       每个 item 拥有自己的 TSDialTime，弹幕可省略。弹幕要求图片背景及非空 danMuItems。
 *       复制时分别保留各项时间配置，共享持有不可变图片、复制路径，不复制源文件。
 */
@property (nonatomic, copy, nonnull, readonly) NSArray<TSDialDraftItem *> *items;

/**
 * @brief App's WYSIWYG preview image (dialPreviewSize)
 * @chinese App 所见即所得的预览图（尺寸须等于 dialPreviewSize）
 *
 * @discussion
 * [EN]: Defaults to nil. The SDK then composes a preview from the first resource,
 *       adding its time only when the Provider's preview policy permits it.
 *       A supplied image must match TSPeripheralScreen.dialPreviewSize in pixels
 *       and is used as the completed source for both the returned app preview and
 *       the package's embedded preview, without another time overlay. Package
 *       encoding may adapt its dimensions, rotation and pixel format as required.
 * [CN]: 默认 nil，由 SDK 从首个资源合成预览，仅在 Provider 预览策略允许时叠加时间。
 *       提供时像素尺寸必须等于 TSPeripheralScreen.dialPreviewSize，
 *       手机端返回的预览与包内预览均以此图为成品来源，不再次叠加时间。
 *       包内编码可按目标格式要求适配尺寸、旋转与像素格式。
 */
@property (nonatomic, strong, nullable) UIImage *previewImage;

/**
 * @brief Requested multiple-image playback interval in milliseconds
 * @chinese 请求的多图轮播间隔，单位毫秒
 *
 * @discussion
 * [EN]: Defaults to 0 and is used only for multiple-image drafts.
 *       Zero or negative values use the Provider default;
 *       positive values are quantized to the device's supported interval during build.
 * [CN]: 仅多图草稿使用。0 或负数使用 Provider 默认值，正数在造包时按设备支持的时间单位量化。
 */
@property (nonatomic, assign) NSInteger multiplePlayIntervalMillis;

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param draftType
 * EN: Draft type: single image, multiple image, video or DanMu.
 * CN: 草稿类型：单图、多图、视频或弹幕。
 *
 * @param templateFilePath
 * EN: Optional local template package override. Pass nil for Provider resolution.
 * CN: 可选的本地模板包覆盖路径；传 nil 时由 Provider 自动解析。
 *
 * @param items
 * EN: Ready-made resource items matching draftType.
 * CN: 与 draftType 匹配的成品资源项。
 *
 * @return
 * EN: Initialized draft.
 * CN: 初始化完成的草稿。
 */
- (instancetype)initWithDraftType:(TSDialDraftType)draftType
                 templateFilePath:(nullable NSString *)templateFilePath
                            items:(NSArray<TSDialDraftItem *> *)items NS_DESIGNATED_INITIALIZER;

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
