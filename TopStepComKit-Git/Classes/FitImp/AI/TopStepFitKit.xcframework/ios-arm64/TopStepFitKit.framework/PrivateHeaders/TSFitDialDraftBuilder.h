//
//  TSFitDialDraftBuilder.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/10.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIImage;
@class TSDialDraft;
@class TSFitDialHeader;
@class TSFitDialShapeOptions;
@class TSFitDialPreviewOptions;
@class TSFitDialBin;
@protocol TSFitDialVideoExecuting;

NS_ASSUME_NONNULL_BEGIN

/** @brief Draft orchestration error domain. @chinese 草稿编排错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSFitDialDraftBuildErrorDomain;

/** @brief Draft preparation failures. @chinese 草稿准备错误码。 */
typedef NS_ERROR_ENUM(TSFitDialDraftBuildErrorDomain, TSFitDialDraftBuildErrorCode) {
    TSFitDialDraftBuildErrorInvalidParameter = 78001,
    TSFitDialDraftBuildErrorFileOperation = 78002,
    TSFitDialDraftBuildErrorMissingVideoExecutor = 78003,
    TSFitDialDraftBuildErrorIndependentTimeBinding = 78004,
    TSFitDialDraftBuildErrorCapacityExceeded = 78005,
};

/**
 * @brief Resolved device parameters and task-owned dependencies for one build.
 * @chinese 一次造包已经解析的设备参数及任务专用依赖。
 */
@interface TSFitDialDraftBuildOptions : NSObject
/** @brief Validated logical header with corner zero. @chinese corner 为零的逻辑头部参数。 */
@property (nonatomic, copy) TSFitDialHeader *header;
/** @brief Logical screen geometry including physical corners. @chinese 含实际圆角的逻辑屏幕形状。 */
@property (nonatomic, strong) TSFitDialShapeOptions *shape;
/** @brief Resolved first-item style; nil means no overlay. @chinese 已解析的首项样式，nil 表示不叠加。 */
@property (nonatomic, strong, nullable) TSFitDialPreviewOptions *previewOptions;
/** @brief Render the time overlay; defaults to YES. @chinese 是否绘制时间，默认 YES。 */
@property (nonatomic, assign) BOOL renderTime;
/** @brief Device preview pixels; zero uses the packing default. @chinese 设备预览尺寸，零值采用造包默认尺寸。 */
@property (nonatomic, assign) CGSize previewSize;
/** @brief Preview corner radius. @chinese 预览圆角。 */
@property (nonatomic, assign) CGFloat previewCornerRadius;
/** @brief Preserve transparent preview corners. @chinese 是否保留透明圆角。 */
@property (nonatomic, assign) BOOL keepTransparentPreviewBackground;
/** @brief Optional complete OTA capacity in bytes, consulted only for video. @chinese 可选的完整 OTA 字节容量，仅视频模式使用。 */
@property (nonatomic, copy, nullable) NSNumber *maximumBytes;
/** @brief Exclusive local task directory; caller owns its cleanup. @chinese 独占的本地任务目录，由调用方清理。 */
@property (nonatomic, strong) NSURL *workingDirectoryURL;
/** @brief Synchronous FFmpeg executor, required only for video. @chinese 同步 FFmpeg 执行器，仅视频模式必需。 */
@property (nonatomic, strong, nullable) id<TSFitDialVideoExecuting> videoExecutor;
@end

/** @brief Completed in-memory package and its logical-orientation preview. @chinese 完成的内存包与逻辑朝向预览图。 */
@interface TSFitDialDraftBuildResult : NSObject
/** @brief Independent binary graph ready for OTA serialization. @chinese 可序列化为 OTA 的独立二进制图。 */
@property (nonatomic, strong, readonly) TSFitDialBin *bin;
/** @brief Generated or caller-supplied preview before device rotation. @chinese 设备旋转前生成或由调用方提供的预览。 */
@property (nonatomic, strong, readonly) UIImage *previewImage;
/** @brief Results are created by the builder. @chinese 结果仅由构建器创建。 */
- (instancetype)init NS_UNAVAILABLE;
@end

/**
 * @brief Private synchronous draft-to-resource orchestration for generated FitCloud dials.
 * @chinese FitCloud 自动生成表盘的私有同步草稿资源编排器。
 * @discussion
 * EN: Run on one worker queue. Copies draft values and local video input; never removes caller files.
 *     Device routing, cancellation, output ownership, and completion delivery belong to its caller.
 * CN: 在工作队列调用。复制草稿值与本地视频输入，不删除调用方文件；设备路由、取消、
 *     输出所有权与完成回调由调用方负责。多图的独立时间绑定未明确时，不静默丢弃差异。
 */
@interface TSFitDialDraftBuilder : NSObject
/**
 * @brief Build BASE, MULT, DANMU, or VIDEO resources without writing the final package.
 * @chinese 构建单图、多图、弹幕或视频资源，不写出最终包文件。
 * @param draft EN: Valid draft; immutable image/file inputs must remain stable during snapshotting. CN: 有效草稿，创建快照期间图片及文件须保持稳定。
 * @param options EN: Resolved device parameters and dependencies, unchanged during the call. CN: 已解析且调用期间不变的设备参数与依赖。
 * @param error EN: Optional preparation, packing, or capacity failure. CN: 可选准备、打包或容量错误。
 * @return EN: Complete result, or nil with an error. CN: 完整产物，失败返回 nil 与错误。
 */
+ (nullable TSFitDialDraftBuildResult *)buildDraft:(TSDialDraft *)draft
                                          options:(TSFitDialDraftBuildOptions *)options
                                            error:(NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
