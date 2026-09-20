//
//  TSFitCustomDialBuildOperation.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSFitCustomDialTemplateResolver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable Fit custom-dial build input
 * @chinese Fit 自定义表盘不可变造包入参
 */
@interface TSFitCustomDialBuildInput : NSObject

/** @brief Resolved numeric watch-face id snapshot @chinese 已解析的数字表盘 id 快照 */
@property (nonatomic, copy, readonly) NSString *resolvedDialId;
/** @brief Optional local template path snapshot @chinese 可选本地模板路径快照 */
@property (nonatomic, copy, readonly, nullable) NSString *templateFilePath;
/** @brief Immutable time configuration snapshot @chinese 不可变时间配置快照 */
@property (nonatomic, copy, readonly) TSDialTime *dialTime;
/** @brief Ready-made background image @chinese 已完成适配的背景图 */
@property (nonatomic, strong, readonly) UIImage *backgroundImage;
/** @brief Ready-made preview image @chinese 已准备的预览图 */
@property (nonatomic, strong, readonly) UIImage *previewImage;
/** @brief Background corner radius in pixels @chinese 背景图圆角半径，单位像素 */
@property (nonatomic, assign, readonly) CGFloat backgroundCornerRadius;
/** @brief Whether the device uses NextGUI @chinese 设备是否使用 NextGUI */
@property (nonatomic, assign, readonly) BOOL isNextGUI;

/**
 * @brief Resolve a numeric Fit watch-face id from an optional draft id
 * @chinese 根据可选草稿 id 解析数字格式的 Fit 表盘 id
 * @param draftDialId EN: Optional caller-provided id. CN: 调用方可选提供的 id。
 * @return
 * EN: Canonical numeric Fit id, or nil when a non-nil id is invalid.
 * CN: 规范化后的数字 Fit id；显式提供的 id 非法时返回 nil。
 */
+ (nullable NSString *)resolvedDialIdForDraftDialId:(nullable NSString *)draftDialId;

/**
 * @brief Initialize an immutable Fit build input
 * @chinese 初始化不可变的 Fit 造包入参
 * @param draft EN: Validated single-image draft. CN: 已校验的单图草稿。
 * @param previewImage EN: Ready-made preview image. CN: 已准备的预览图。
 * @param isNextGUI EN: Whether the device uses NextGUI. CN: 设备是否使用 NextGUI。
 * @param backgroundCornerRadius EN: Background corner radius in pixels. CN: 背景图圆角半径，单位像素。
 * @return EN: Initialized input, or nil. CN: 初始化后的入参，参数无效时为 nil。
 */
- (nullable instancetype)initWithDraft:(TSDialDraft *)draft
                          previewImage:(UIImage *)previewImage
                             isNextGUI:(BOOL)isNextGUI
                backgroundCornerRadius:(CGFloat)backgroundCornerRadius NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * @brief Completion for a Fit custom-dial build
 * @chinese Fit 自定义表盘造包完成回调
 */
typedef void (^TSFitCustomDialBuildCompletion)(NSString *_Nullable filePath,
                                                NSError *_Nullable error);

/**
 * @brief Resolves a template and builds one Fit custom-dial package
 * @chinese 解析模板并构建一个 Fit 自定义表盘包
 */
@interface TSFitCustomDialBuildOperation : NSObject

/**
 * @brief Initialize one build operation
 * @chinese 初始化一次造包操作
 * @param input EN: Immutable build input. CN: 不可变造包入参。
 * @param resolver EN: Fit template resolver. CN: Fit 模板解析器。
 * @param completion EN: Main-thread build completion. CN: 主线程造包完成回调。
 * @return EN: Initialized operation, or nil. CN: 初始化后的操作，参数无效时为 nil。
 */
- (nullable instancetype)initWithInput:(TSFitCustomDialBuildInput *)input
                               resolver:(TSFitCustomDialTemplateResolver *)resolver
                             completion:(TSFitCustomDialBuildCompletion)completion NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/** @brief Start the build once @chinese 启动一次造包 */
- (void)start;
/**
 * @brief Cancel template resolution or suppress an active build result
 * @chinese 取消模板解析或忽略当前造包结果
 */
- (void)cancel;

/**
 * @brief Remove one SDK-managed artifact file
 * @chinese 删除一个由 SDK 管理的表盘产物文件
 * @param filePath EN: Managed artifact path. CN: SDK 管理的表盘产物路径。
 */
+ (void)removeManagedArtifactAtPath:(nullable NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
