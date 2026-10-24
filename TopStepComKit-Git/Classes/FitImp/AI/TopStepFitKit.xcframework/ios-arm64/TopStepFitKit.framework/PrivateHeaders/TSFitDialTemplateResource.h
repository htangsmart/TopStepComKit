//
//  TSFitDialTemplateResource.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Parsed cloud resource for an AI watch-face template
 * @chinese 解析后的 AI 表盘云模板资源
 */
@interface TSFitDialTemplateResource : NSObject

/** @brief Whether the resource uses the new GUI format @chinese 是否使用新 GUI 格式 */
@property (nonatomic, assign, readonly) BOOL isNextGUI;
/** @brief HTTPS URL of the template binary @chinese 模板二进制的 HTTPS 地址 */
@property (nonatomic, strong, readonly) NSURL *templateURL;
/** @brief Expected template size, zero when unspecified @chinese 模板预期大小，未指定时为零 */
@property (nonatomic, assign, readonly) NSUInteger templateSize;
/** @brief Ordered HTTPS time-style image URLs @chinese 有序的 HTTPS 时间样式图片地址 */
@property (nonatomic, copy, readonly) NSArray<NSURL *> *styleImageURLs;
/** @brief Legacy style name, or nil for GUI resources @chinese 旧格式样式名，GUI 资源为 nil */
@property (nonatomic, copy, readonly, nullable) NSString *styleName;
/** @brief Time-style image size @chinese 时间样式图片尺寸 */
@property (nonatomic, assign, readonly) CGSize styleSize;
/**
 * @brief Raw vertical position from the legacy service
 * @chinese 旧接口返回的原始纵向位置
 *
 * @discussion
 * [EN]: Used to derive padding for legacy GUI resources.
 * [CN]: 用于计算旧接口 GUI 资源的边距。
 *
 * @note
 * [EN]: New service resources use stylePadding instead and leave this value at zero.
 * [CN]: 新接口资源使用 stylePadding，此值保持为零。
 */
@property (nonatomic, assign, readonly) NSInteger stylePositionY;

/**
 * @brief Whether the service provides style padding directly
 * @chinese 服务端是否直接提供样式边距
 *
 * @discussion
 * [EN]: Selects direct padding instead of the legacy bottom-position conversion.
 * [CN]: 用于区分直接边距与旧接口底部坐标换算。
 *
 * @note
 * [EN]: NO for resources created with the legacy initializer.
 * [CN]: 使用原初始化方法创建的资源为 NO。
 */
@property (nonatomic, assign, readonly) BOOL hasDirectStylePadding;

/**
 * @brief Horizontal and vertical style padding
 * @chinese 样式的水平和垂直边距
 *
 * @discussion
 * [EN]: Contains the new service positionX and positionY values in pixels.
 * [CN]: 保存新接口 positionX 和 positionY 对应的像素边距。
 *
 * @note
 * [EN]: Used only when hasDirectStylePadding is YES; otherwise CGPointZero.
 * [CN]: 仅在 hasDirectStylePadding 为 YES 时使用，否则为 CGPointZero。
 */
@property (nonatomic, assign, readonly) CGPoint stylePadding;

/**
 * @brief Initialize a parsed template resource
 * @chinese 初始化解析后的模板资源
 * @param isNextGUI EN: Whether this is a GUI resource. CN: 是否为 GUI 资源。
 * @param templateURL EN: Template binary URL. CN: 模板二进制地址。
 * @param templateSize EN: Expected template size. CN: 模板预期大小。
 * @param styleImageURLs EN: Ordered style image URLs. CN: 有序样式图片地址。
 * @param styleName EN: Optional legacy style name. CN: 可选的旧格式样式名。
 * @param styleSize EN: Style image size. CN: 样式图片尺寸。
 * @param stylePositionY EN: Raw vertical position. CN: 原始纵向位置。
 * @return EN: Initialized resource. CN: 初始化后的资源。
 */
- (nullable instancetype)initWithNextGUI:(BOOL)isNextGUI
                    templateURL:(NSURL *)templateURL
                   templateSize:(NSUInteger)templateSize
                 styleImageURLs:(NSArray<NSURL *> *)styleImageURLs
                      styleName:(nullable NSString *)styleName
                      styleSize:(CGSize)styleSize
                 stylePositionY:(NSInteger)stylePositionY NS_DESIGNATED_INITIALIZER;

/**
 * @brief Initialize a GUI resource with direct style padding
 * @chinese 使用直接样式边距初始化 GUI 资源
 *
 * @param templateURL
 * EN: HTTPS template binary URL.
 * CN: 模板二进制的 HTTPS 地址。
 *
 * @param templateSize
 * EN: Expected template size in bytes.
 * CN: 模板预期字节数。
 *
 * @param styleImageURLs
 * EN: Ordered style URLs; empty for a template without styles.
 * CN: 有序样式地址，无样式模板传空数组。
 *
 * @param styleLayout
 * EN: The origin contains padding; the size contains style dimensions. Use CGRectZero without styles.
 * CN: origin 保存边距，size 保存样式尺寸；无样式时传 CGRectZero。
 *
 * @return
 * EN: Initialized resource, or nil for invalid values.
 * CN: 初始化后的资源，参数无效时为 nil。
 */
- (nullable instancetype)initWithTemplateURL:(NSURL *)templateURL
                               templateSize:(NSUInteger)templateSize
                             styleImageURLs:(NSArray<NSURL *> *)styleImageURLs
                                styleLayout:(CGRect)styleLayout;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Return the selected first style image URL
 * @chinese 返回选中的首个样式图片地址
 * @return EN: First style image URL, or nil. CN: 首个样式图片地址，无资源时为 nil。
 */
- (nullable NSURL *)firstStyleImageURL;

@end

NS_ASSUME_NONNULL_END
