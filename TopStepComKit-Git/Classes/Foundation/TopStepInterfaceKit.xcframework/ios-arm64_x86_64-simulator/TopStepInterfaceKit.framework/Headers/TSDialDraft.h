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
@interface TSDialDraft : TSKitBaseModel

/**
 * @brief Optional watch face id
 * @chinese 可选表盘 id
 *
 * @discussion
 * [EN]: Usually nil. When nil, the SDK build flow generates or resolves the final id.
 * [CN]: 通常为空。为空时由 SDK 造包流程生成或确定最终 id。
 */
@property (nonatomic, copy, nullable) NSString *dialId;

/**
 * @brief Dial draft type
 * @chinese 表盘草稿类型
 *
 * @discussion
 * [EN]: Single image, multiple-image, or video draft.
 * [CN]: 单图 / 多图（相册） / 视频。
 */
@property (nonatomic, assign, readonly) TSDialDraftType draftType;

/**
 * @brief Optional local template package override
 * @chinese 可选的本地模板包覆盖路径
 *
 * @discussion
 * [EN]: When nil, the Provider resolves a compatible template automatically.
 *       When provided, the file must exist and be compatible with the Provider.
 * [CN]: 为空时由 Provider 自动解析兼容模板。
 *       提供时文件必须存在，并且格式需与 Provider 兼容。
 */
@property (nonatomic, copy, nullable, readonly) NSString *templateFilePath;

/**
 * @brief Ready-made resource items
 * @chinese 成品资源项
 *
 * @discussion
 * [EN]: Required. Single image and video drafts require exactly one item; multiple-image
 *       drafts require one or more image items. Each item owns its own TSDialTime.
 * [CN]: 必填。单图和视频草稿必须只有一个 item；多图草稿需要一个或多个图片 item。
 *       每个 item 拥有自己的 TSDialTime。
 */
@property (nonatomic, copy, nonnull, readonly) NSArray<TSDialDraftItem *> *items;

/**
 * @brief App's WYSIWYG preview image (dialPreviewSize)
 * @chinese App 所见即所得的预览图（尺寸须等于 dialPreviewSize）
 *
 * @discussion
 * [EN]: Optional. If nil, the SDK composes a preview from the first item and its time.
 *       If provided, its pixel size must equal TSPeripheralScreen.dialPreviewSize.
 * [CN]: 可选。为空时 SDK 使用第一个 item 及其时间配置合成预览图。提供时像素尺寸
 *       必须等于 TSPeripheralScreen.dialPreviewSize。
 */
@property (nonatomic, strong, nullable) UIImage *previewImage;

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param draftType
 * EN: Draft type: single image, multiple image or video.
 * CN: 草稿类型：单图、多图或视频。
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
