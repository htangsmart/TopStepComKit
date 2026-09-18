//
//  TSNpkDialStyleResource.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Parsed NPK custom-dial cloud resource @chinese 解析后的 NPK 自定义表盘云资源 */
@interface TSNpkDialStyleResource : NSObject

/** @brief HTTPS PB template ZIP URL @chinese PB 模板 ZIP 的 HTTPS 地址 */
@property (nonatomic, strong, readonly) NSURL *templateURL;
/** @brief Expected template ZIP size @chinese 模板 ZIP 预期大小 */
@property (nonatomic, assign, readonly) NSUInteger templateSize;
/** @brief Ordered HTTPS style preview URLs @chinese 有序的 HTTPS 样式预览地址 */
@property (nonatomic, copy, readonly) NSArray<NSURL *> *styleImageURLs;
/** @brief Style size in device pixels @chinese 样式在设备像素坐标系中的尺寸 */
@property (nonatomic, assign, readonly) CGSize styleSize;
/** @brief Horizontal style padding @chinese 样式水平边距 */
@property (nonatomic, assign, readonly) NSInteger paddingX;
/** @brief Vertical style padding @chinese 样式垂直边距 */
@property (nonatomic, assign, readonly) NSInteger paddingY;

/**
 * @brief Initialize a parsed NPK resource
 * @chinese 初始化解析后的 NPK 资源
 */
- (nullable instancetype)initWithTemplateURL:(NSURL *)templateURL
                                templateSize:(NSUInteger)templateSize
                              styleImageURLs:(NSArray<NSURL *> *)styleImageURLs
                                   styleSize:(CGSize)styleSize
                                    paddingX:(NSInteger)paddingX
                                    paddingY:(NSInteger)paddingY NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
