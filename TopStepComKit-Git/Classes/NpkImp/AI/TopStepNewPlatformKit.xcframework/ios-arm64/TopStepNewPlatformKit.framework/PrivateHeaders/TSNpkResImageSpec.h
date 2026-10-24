//
//  TSNpkResImageSpec.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TopStepInterfaceKit/TSDialDefines.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Resource purpose determines alpha and animation encoding. @chinese 资源用途决定透明通道和动画编码。 */
typedef NS_ENUM(NSUInteger, TSNpkResImagePurpose) {
    TSNpkResImagePurposeBackground,
    TSNpkResImagePurposePreview,
    TSNpkResImagePurposeDanMu,
    TSNpkResImagePurposeAnimationFrame,
};

/**
 * @brief One entry of the res.bin image replacement plan
 * @chinese res.bin 图片替换计划中的一项
 *
 * @discussion
 * [EN]: Pure model. An entry either replaces/adds the image at tableIndex, or removes it.
 * [CN]: 纯数据模型。一项要么替换/新增 tableIndex 处的图片，要么移除它。
 */
@interface TSNpkResImageSpec : NSObject

/**
 * @brief Destination image-table index
 * @chinese 目标图片索引表下标
 *
 * @discussion
 * [EN]: Zero-based resource slot; slot 0 is reserved for the preview. Valid allocation is decided by the resource plan.
 * [CN]: 从 0 起算的资源槽位，0 保留给预览图；可用下标由资源计划决定。
 */
@property (nonatomic, assign, readonly) NSUInteger tableIndex;
/**
 * @brief Image supplied to the encoder
 * @chinese 提供给编码器的图片
 *
 * @discussion
 * [EN]: Returns the retained image first, otherwise loads imageFilePath on demand; nil for removals or failed loading.
 * [CN]: 优先返回持有的图片，否则按需从 imageFilePath 加载；移除项或加载失败时为 nil。
 */
@property (nonatomic, strong, readonly, nullable) UIImage *image;
/**
 * @brief Requested resource size in pixels
 * @chinese 请求的资源尺寸，单位像素
 *
 * @discussion
 * [EN]: Set by the planner for encoding and may differ from UIImage point size; ignored for removal entries.
 * [CN]: 由规划器设置，供编码使用，可不同于 UIImage 的点尺寸；移除项不使用此值。
 */
@property (nonatomic, assign, readonly) CGSize pixelSize;
/**
 * @brief Requested alpha-channel preservation
 * @chinese 是否请求保留透明通道
 *
 * @discussion
 * [EN]: Passed to the selected encoder; affects RGB/TSC format or PAR transparency and is not inferred from image contents.
 * [CN]: 交给选定编码器，影响 RGB/TSC 格式或 PAR 透明参数；不会根据图像内容自动推断。
 */
@property (nonatomic, assign, readonly) BOOL hasAlpha;
/**
 * @brief Resource removal marker
 * @chinese 资源移除标记
 *
 * @discussion
 * [EN]: YES only for removalSpecWithTableIndex:. The writer clears this slot instead of encoding image data.
 * [CN]: removalSpecWithTableIndex: 创建的项为 YES；写入器清空对应槽位，不编码图像数据。
 */
@property (nonatomic, assign, readonly) BOOL isRemoval;
/**
 * @brief Semantic resource purpose
 * @chinese 资源用途
 *
 * @discussion
 * [EN]: Creation defaults to Preview at slot 0 and Background elsewhere; planners override it for text and animation resources.
 * [CN]: 创建时下标 0 默认 Preview，其余默认 Background；规划器为弹幕文字与动画帧另行指定。
 */
@property (nonatomic, assign) TSNpkResImagePurpose purpose;
/**
 * @brief Resource encoding quality
 * @chinese 资源编码质量档位
 *
 * @discussion
 * [EN]: Initially TSDialQualityDefault. The binary stage assigns the draft policy, including the W30 DanMu default-to-standard rule.
 * [CN]: 初始为 TSDialQualityDefault；二进制阶段赋予草稿策略，包括 W30 弹幕 Default 转 Standard 的规则。
 */
@property (nonatomic, assign) TSDialQuality quality;
/**
 * @brief Optional task-owned image cache path
 * @chinese 可选的任务图片缓存路径
 *
 * @discussion
 * [EN]: Used only when no in-memory image was supplied. The image getter decodes it on each access without retaining the decoded image.
 * [CN]: 仅在未提供内存图片时使用；image getter 每次访问按需解码，不持有解码结果，路径由任务统一清理。
 */
@property (nonatomic, copy, nullable) NSString *imageFilePath;

/**
 * @brief Create an entry that replaces or adds an image
 * @chinese 创建"替换或新增图片"的计划项
 */
+ (instancetype)specWithTableIndex:(NSUInteger)tableIndex
                             image:(nullable UIImage *)image
                         pixelSize:(CGSize)pixelSize
                          hasAlpha:(BOOL)hasAlpha;

/**
 * @brief Create an entry that removes an image
 * @chinese 创建"移除图片"的计划项
 */
+ (instancetype)removalSpecWithTableIndex:(NSUInteger)tableIndex;

@end

NS_ASSUME_NONNULL_END
