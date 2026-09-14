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
/** @brief Raw vertical position returned by the service @chinese 服务端返回的原始纵向位置 */
@property (nonatomic, assign, readonly) NSInteger stylePositionY;

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

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Return the selected first style image URL
 * @chinese 返回选中的首个样式图片地址
 * @return EN: First style image URL, or nil. CN: 首个样式图片地址，无资源时为 nil。
 */
- (nullable NSURL *)firstStyleImageURL;

@end

NS_ASSUME_NONNULL_END
