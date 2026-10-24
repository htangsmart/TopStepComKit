//
//  TSNpkDialStyleResource.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Resolved template representation. @chinese 已解析的模板种类。 */
typedef NS_ENUM(NSInteger, TSNpkDialTemplateKind) {
    TSNpkDialTemplateKindLVGLArchive,
    TSNpkDialTemplateKindGuiTemplate,
    TSNpkDialTemplateKindGenerated,
};

/** @brief Parsed NPK custom-dial cloud resource @chinese 解析后的 NPK 自定义表盘云资源 */
@interface TSNpkDialStyleResource : NSObject <NSCopying>
/**
 * @brief Resolved template representation
 * @chinese 已解析的模板种类
 *
 * @discussion
 * [EN]: Distinguishes an LVGL archive, an existing GUI template and a generated
 *       resource with no template. Cloud initialization starts with LVGLArchive.
 * [CN]: 区分 LVGL 归档、既有 GUI 模板、无需模板的代码生成资源；
 *       云资源初始化时为 LVGLArchive，解析层按实际平台设置。
 */
@property (nonatomic, assign) TSNpkDialTemplateKind kind;
/**
 * @brief Resolved local template path
 * @chinese 已解析的本地模板路径
 *
 * @discussion
 * [EN]: Nil until a local source is supplied or downloaded, and normally nil for
 *       generated resources. Referencing a caller's file does not transfer cleanup ownership.
 * [CN]: 提供本地源或下载完成后设置，代码生成资源通常为 nil；
 *       引用调用方文件不代表取得该文件的清理所有权。
 */
@property (nonatomic, copy, nullable) NSString *localPath;
/**
 * @brief Local style image paths in catalog order
 * @chinese 按目录顺序排列的本地样式图片路径
 *
 * @discussion
 * [EN]: Initially empty. After selective download, entries align with styleImageURLs;
 *       unrequested entries use empty strings so style indices remain stable.
 * [CN]: 初始为空数组；按需下载后与 styleImageURLs 顺序对应，
 *       未请求项使用空字符串占位，保持样式索引稳定。
 */
@property (nonatomic, copy) NSArray<NSString *> *localStylePaths;
/** @brief Create an explicit no-template result. @chinese 创建明确无需模板的结果。
 * @return EN: Generated resource. CN: 代码生成资源。 */
+ (instancetype)generatedResource;
/** @brief Create a resource referencing a caller-owned file. @chinese 引用调用方持有的本地文件。
 * @param path EN: Existing source file path. CN: 已存在的源文件路径。
 * @param kind EN: Archive or GUI kind. CN: LVGL 归档或 GUI 模板种类。
 * @return EN: Local resource. CN: 本地资源。 */
+ (instancetype)localResourceWithPath:(NSString *)path kind:(TSNpkDialTemplateKind)kind;

/**
 * @brief Remote URL of the LVGL archive or GUI template
 * @chinese LVGL 归档或 GUI 模板的远程 URL
 *
 * @discussion
 * [EN]: Cloud resources require HTTPS with a nonempty host. Local and generated
 *       resources leave this nil instead of fabricating a download URL.
 * [CN]: 云资源要求 HTTPS 且主机名非空；本地和代码生成资源保持 nil，不伪造下载地址。
 */
@property (nonatomic, strong, readonly) NSURL * _Nullable templateURL;
/**
 * @brief Expected template download size in bytes
 * @chinese 模板预期下载大小，单位字节
 *
 * @discussion
 * [EN]: Taken from metadata. Zero means no known positive size for download validation;
 *       local and generated resources initialize it to zero.
 * [CN]: 来自元数据；零表示没有可用于下载大小校验的已知正数值，
 *       本地和代码生成资源初始为零。
 */
@property (nonatomic, assign, readonly) NSUInteger templateSize;
/**
 * @brief Style image URLs in server order
 * @chinese 按服务端顺序排列的样式图片 URL
 *
 * @discussion
 * [EN]: Each URL must use HTTPS with a host. Empty means no remote style entries;
 *       array order is preserved when resolving the selected style.
 * [CN]: 每个 URL 必须为带主机名的 HTTPS 地址；空数组表示没有远程样式项，
 *       解析选中样式时保留数组顺序。
 */
@property (nonatomic, copy, readonly) NSArray<NSURL *> *styleImageURLs;
/**
 * @brief Style dimensions in device pixels
 * @chinese 设备像素坐标系中的样式尺寸
 *
 * @discussion
 * [EN]: Metadata dimensions used for style placement. Both values must be positive
 *       when styleImageURLs contains entries; local/generated resources default to zero.
 * [CN]: 用于样式布局的元数据尺寸；styleImageURLs 非空时宽高均须为正，
 *       本地和代码生成资源默认零尺寸。
 */
@property (nonatomic, assign, readonly) CGSize styleSize;
/**
 * @brief Horizontal style padding in device pixels
 * @chinese 样式水平边距，单位为设备像素
 *
 * @discussion
 * [EN]: Passed to the style layout mapper. Must be nonnegative when remote styles
 *       exist; local/generated resources default to 0.
 * [CN]: 传给样式布局映射器；存在远程样式时必须非负，本地和代码生成资源默认 0。
 */
@property (nonatomic, assign, readonly) NSInteger paddingX;
/**
 * @brief Vertical style padding in device pixels
 * @chinese 样式垂直边距，单位为设备像素
 *
 * @discussion
 * [EN]: Used to resolve top/bottom placement. Must be nonnegative when remote styles
 *       exist; local/generated resources default to 0.
 * [CN]: 用于解析顶部、底部位置；存在远程样式时必须非负，本地和代码生成资源默认 0。
 */
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
