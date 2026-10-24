//
//  TSDialVideoRequirements.h
//  TopStepInterfaceKit
//
//  Created by Codex on 2026/10/20.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import "TSPeripheralScreen.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable requirements for an app-prepared dial video
 * @chinese App 成品表盘视频的只读要求快照
 *
 * @discussion
 * [EN]: Supplied by Providers that implement the prepared-video contract. The app
 *       completes editing and exports the input; the SDK validates it and performs
 *       device encoding and packaging. This snapshot is not a set of editing options.
 *       Query again after changing the device or quality. Build validates its own
 *       captured device context and does not reserve a device through this model.
 * [CN]: 由实现成品视频合同的 Provider 提供。App 完成编辑并导出输入，SDK 负责
 *       校验、设备编码和造包；此快照不是编辑选项。设备或质量变化后应重新查询。
 *       造包仍按其捕获的设备上下文校验，本模型不预约或锁定设备。
 */
@interface TSDialVideoRequirements : TSKitBaseModel <NSCopying>

/**
 * @brief Quality key associated with these requirements
 * @chinese 当前要求对应的质量查询键
 *
 * @discussion
 * [EN]: Captured from the Provider's supported Default, Standard or Lossless entry.
 *       Default is an explicit lookup key and is not an alias for another entry.
 * [CN]: 取自 Provider 支持的 Default、Standard 或 Lossless 条目。
 *       Default 是独立查询键，不自动作为其他档位的别名。
 */
@property (nonatomic, assign, readonly) TSDialQuality quality;

/**
 * @brief Required input canvas size in pixels
 * @chinese 要求的输入画布尺寸，单位像素
 *
 * @discussion
 * [EN]: Positive integer width and height after source orientation correction and
 *       before device storage rotation. The app exports exactly this size; it need
 *       not equal screen or preview dimensions. Build does not fix a size mismatch
 *       by cropping, scaling or stretching the prepared video.
 * [CN]: 源视频方向修正后、设备存储旋转前的正整数像素宽高。App 应按此尺寸精确导出，
 *       不要求与屏幕或预览尺寸相同。造包不会通过裁剪、缩放或拉伸修复成品视频尺寸不符。
 */
@property (nonatomic, assign, readonly) CGSize inputPixelSize;

/**
 * @brief Maximum complete video duration in seconds
 * @chinese 完整视频的最大时长，单位秒
 *
 * @discussion
 * [EN]: A finite positive duration supplied by the Provider. The prepared video must
 *       have a positive duration no greater than this limit. Exceeding it fails
 *       validation; the SDK does not trim the video to fit.
 * [CN]: Provider 提供的有限正数秒数。成品视频时长须大于零且不超过此上限；
 *       超限时校验失败，SDK 不会自动截短视频。
 */
@property (nonatomic, assign, readonly) NSTimeInterval maxDuration;

/**
 * @brief Shape the app must prepare on the input canvas
 * @chinese App 应在输入画布上准备的外形
 *
 * @discussion
 * [EN]: Describes the prepared pixels, independently of the physical screen shape.
 *       A circle is centered with diameter min(width, height), with black pixels outside it; rectangular
 *       shapes use cornerRadius. The SDK does not apply this mask to video frames.
 *       Metadata validation alone cannot prove every frame's mask is correct.
 * [CN]: 描述成品像素外形，与物理屏幕外形独立。圆形以画布短边为直径居中，圆外预合成为黑色，
 *       矩形使用 cornerRadius。SDK 不再给视频帧添加该遮罩，
 *       仅校验元数据也不能证明每帧的遮罩正确。
 */
@property (nonatomic, assign, readonly) TSPeriphShape inputShape;

/**
 * @brief Prepared rectangular corner radius in input pixels
 * @chinese 成品矩形圆角半径，单位为输入画布像素
 *
 * @discussion
 * [EN]: Finite and nonnegative, interpreted in inputPixelSize coordinates. Zero
 *       requires square corners. Ignored for circular input; the app prepares any
 *       required rounded corners over black without asking the SDK to apply them.
 * [CN]: 有限非负值，使用 inputPixelSize 坐标；零表示直角。圆形输入不使用此字段。
 *       所需圆角由 App 合成到黑色背景，不由 SDK 再次处理。
 */
@property (nonatomic, assign, readonly) CGFloat cornerRadius;

/**
 * @brief Whether the prepared video may contain an audio track
 * @chinese 成品视频是否允许包含音轨
 *
 * @discussion
 * [EN]: NO requires a source without audio tracks; audio is rejected rather than
 *       silently removed. YES permits audio subject to the Provider's track and
 *       codec requirements, and also permits a silent source. Device encoding may
 *       convert the audio format; this flag is not a mute or mixing request.
 * [CN]: NO 要求源文件无音轨，带音轨时明确拒绝而非静默删除。YES 允许符合 Provider
 *       轨道与编码约束的音频，也允许无声源。设备编码可转换音频格式；
 *       此字段不是静音或混音请求。
 */
@property (nonatomic, assign, readonly) BOOL supportsAudio;

/**
 * @brief Disable construction without Provider requirements
 * @chinese 禁止缺少 Provider 要求时直接构造
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable default object creation
 * @chinese 禁止默认创建
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
