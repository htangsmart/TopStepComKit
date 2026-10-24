//
//  TSCustomDialStyleConstraint.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/8/17.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import "TSPeripheralScreen.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Custom watch face time-style option
 * @chinese 自定义表盘时间样式选项
 */
@interface TSCustomDialStyleOption : TSKitBaseModel

/**
 * @brief Semantic time style
 * @chinese 语义化时间样式
 *
 * @discussion
 * [EN]: Provider-supplied identifier to assign to TSDialTime.style. Select from
 *       the returned styles rather than assuming every style enum is available;
 *       the same identifier need not have the same appearance across providers.
 * [CN]: 由 Provider 提供，可赋给 TSDialTime.style。应从返回的 styles 中选择，
 *       不应假定所有样式枚举都可用；同一标识在不同平台上不保证外观相同。
 */
@property (nonatomic, assign, readonly) TSDialTimeStyle style;

/**
 * @brief Preview image URL
 * @chinese 预览图片地址
 *
 * @discussion
 * [EN]: The URL is either an HTTPS resource or a file URL owned by the SDK bundle.
 * [CN]: 地址只能是 HTTPS 资源或 SDK Bundle 持有的本地文件地址。
 */
@property (nonatomic, strong, readonly) NSURL *previewImageURL;

/**
 * @brief Style size in device pixels
 * @chinese 样式在设备像素坐标系中的尺寸
 *
 * @discussion
 * [EN]: Width and height used to lay out this style, independent of UIImage.scale.
 *       Provider-generated options have positive dimensions within the screen.
 *       The initializer stores the supplied size without conversion or validation.
 * [CN]: 用于布局该样式的宽高，不受 UIImage.scale 影响。Provider 返回的选项
 *       具有屏幕范围内的正数尺寸；构造器原样保存传入尺寸，不执行换算或校验。
 */
@property (nonatomic, assign, readonly) CGSize size;

/**
 * @brief Initialize a time-style option
 * @chinese 初始化时间样式选项
 *
 * @param style EN: Semantic time style. CN: 语义化时间样式。
 * @param previewImageURL EN: Preview image URL. CN: 预览图片地址。
 * @param size EN: Style size in device pixels. CN: 样式的设备像素尺寸。
 * @return EN: Initialized option. CN: 初始化后的选项。
 */
- (instancetype)initWithStyle:(TSDialTimeStyle)style
              previewImageURL:(NSURL *)previewImageURL
                         size:(CGSize)size NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * @brief Custom watch face time-position option
 * @chinese 自定义表盘时间位置选项
 */
@interface TSCustomDialPositionOption : TSKitBaseModel

/**
 * @brief Semantic time position
 * @chinese 语义化时间位置
 *
 * @discussion
 * [EN]: Provider-supplied position to assign to TSDialTime.timePosition. Only the
 *       positions present in the constraint are offered for the current resource;
 *       this value is stored as supplied and has no independent default.
 * [CN]: 由 Provider 提供，可赋给 TSDialTime.timePosition。当前资源只提供约束中
 *       列出的位置；该值由构造参数指定，模型不另外设置默认位置。
 */
@property (nonatomic, assign, readonly) TSDialTimePosition position;

/**
 * @brief Preview frame in the watch face screen coordinate system
 * @chinese 表盘屏幕坐标系中的预览区域
 *
 * @discussion
 * [EN]: Origin and size are in device pixels, measured from the screen's top-left
 *       corner. Provider-generated frames lie within screenSize. Convert this
 *       frame when displaying the preview at a different scale.
 * [CN]: 原点和尺寸均为设备像素，以屏幕左上角为坐标原点。Provider 返回的区域
 *       位于 screenSize 范围内；以其他比例显示预览时，应同步换算此区域。
 */
@property (nonatomic, assign, readonly) CGRect frame;

/**
 * @brief Initialize a time-position option
 * @chinese 初始化时间位置选项
 *
 * @param position EN: Semantic time position. CN: 语义化时间位置。
 * @param frame EN: Preview frame in device pixels. CN: 设备像素坐标系中的预览区域。
 * @return EN: Initialized option. CN: 初始化后的选项。
 */
- (instancetype)initWithPosition:(TSDialTimePosition)position
                           frame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * @brief Custom watch face style constraint snapshot
 * @chinese 自定义表盘样式约束快照
 *
 * @discussion
 * [EN]: Contains provider-neutral style and position options for the currently connected device.
 *       Provider request parameters and template resources are intentionally not exposed.
 * [CN]: 包含当前连接设备的 Provider 无关样式与位置选项。
 *       不对外暴露 Provider 请求参数和模板资源。
 */
@interface TSCustomDialStyleConstraint : TSKitBaseModel

/**
 * @brief Watch face screen size in pixels
 * @chinese 表盘屏幕像素尺寸
 *
 * @discussion
 * [EN]: Captured from the device screen when the provider creates this constraint;
 *       it does not update when the connection changes. This is the coordinate
 *       space for style sizes and position frames, not the preview output size.
 * [CN]: Provider 创建约束时记录的设备屏幕尺寸，不随连接变化自动更新。
 *       样式尺寸与位置区域使用此坐标空间，它不是预览输出图片的尺寸。
 */
@property (nonatomic, assign, readonly) CGSize screenSize;

/**
 * @brief Watch face screen shape
 * @chinese 表盘屏幕形状
 *
 * @discussion
 * [EN]: Device shape captured with screenSize and stored as supplied. It identifies
 *       the screen outline category; a rounded rectangle's corner radius is not
 *       included in this property.
 * [CN]: 与 screenSize 同时记录的设备形状，按构造参数保存。该属性只标识屏幕
 *       外形类别，不包含圆角矩形的具体圆角半径。
 */
@property (nonatomic, assign, readonly) TSPeriphShape screenShape;

/**
 * @brief Available time-style options
 * @chinese 可用的时间样式选项
 *
 * @discussion
 * [EN]: Non-nil array whose container is copied during initialization. An empty
 *       array means this resource exposes no selectable time styles; it does not
 *       imply that custom watch face building is unavailable.
 * [CN]: 非 nil 数组，构造时复制数组容器。空数组表示当前资源没有可选时间样式，
 *       不代表设备不能制作自定义表盘。
 *
 * @note
 * [EN]: The array may be empty when the device supports background-only custom watch faces.
 * [CN]: 设备只支持纯背景自定义表盘时，数组可以为空。
 */
@property (nonatomic, copy, readonly) NSArray<TSCustomDialStyleOption *> *styles;

/**
 * @brief Available semantic time-position options
 * @chinese 可用的语义化时间位置选项
 *
 * @discussion
 * [EN]: Non-nil array whose container is copied during initialization. Use its
 *       semantic values and frames together. It may be empty when no time style
 *       is offered; no fallback positions are synthesized by this model.
 * [CN]: 非 nil 数组，构造时复制数组容器；语义位置应与对应区域配套使用。
 *       没有时间样式时可以为空，模型不会自行补充默认位置。
 */
@property (nonatomic, copy, readonly) NSArray<TSCustomDialPositionOption *> *positions;

/**
 * @brief Whether a caller may tint the time style
 * @chinese 是否允许调用方修改时间样式颜色
 *
 * @discussion
 * [EN]: Provider capability for setting TSDialTime.timeColor, not the background
 *       color. Current NPK constraints with style resources enable it; Fit and
 *       NPK background-only constraints disable it. The initializer stores the
 *       supplied value without deriving a capability from the style images.
 * [CN]: 表示是否允许设置 TSDialTime.timeColor，与背景颜色无关。当前 NPK 有样式
 *       资源的约束允许着色；Fit 及 NPK 纯背景约束不允许。构造器原样保存此值，
 *       不会根据样式图片自行推导能力。
 */
@property (nonatomic, assign, readonly) BOOL allowColorTint;

/**
 * @brief Initialize a custom watch face style constraint
 * @chinese 初始化自定义表盘样式约束
 *
 * @param screenSize EN: Watch face screen size in pixels. CN: 表盘屏幕像素尺寸。
 * @param screenShape EN: Watch face screen shape. CN: 表盘屏幕形状。
 * @param styles EN: Available time-style options. CN: 可用时间样式选项。
 * @param positions EN: Available semantic time-position options. CN: 可用语义化时间位置选项。
 * @param allowColorTint EN: Whether time-style tinting is supported. CN: 是否支持时间样式着色。
 * @return EN: Initialized constraint snapshot. CN: 初始化后的约束快照。
 */
- (instancetype)initWithScreenSize:(CGSize)screenSize
                       screenShape:(TSPeriphShape)screenShape
                            styles:(NSArray<TSCustomDialStyleOption *> *)styles
                         positions:(NSArray<TSCustomDialPositionOption *> *)positions
                    allowColorTint:(BOOL)allowColorTint NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
