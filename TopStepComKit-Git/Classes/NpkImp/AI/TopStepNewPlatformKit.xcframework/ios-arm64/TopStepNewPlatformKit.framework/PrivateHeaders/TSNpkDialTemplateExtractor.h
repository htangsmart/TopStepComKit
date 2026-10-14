//
//  TSNpkDialTemplateExtractor.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unpacks a dial template into a content directory
 * @chinese 把表盘模板解压成表盘内容目录
 *
 * @discussion
 * [EN]: Two template shapes are supported. (1) The zip directly contains res.bin/config.json/screen.json: its
 *       content is copied. (2) The zip contains per-type sub archives (base/mult/video, optional "_tint" variants,
 *       .tar or .zip): the first existing candidate is unpacked. Does not validate the content.
 * [CN]: 支持两种模板形态。(1) zip 里直接是 res.bin/config.json/screen.json：复制其内容。
 *       (2) zip 里是按类型划分的子包（base/mult/video，可带 "_tint" 变体，.tar 或 .zip）：解压第一个存在的候选。不做内容校验。
 */
@interface TSNpkDialTemplateExtractor : NSObject

/**
 * @brief Sub archive base names to try, in priority order
 * @chinese 按优先级返回要尝试的子包基名
 *
 * @param preferTint EN: Prefer the "_tint" variant (the draft sets a time color). CN: 是否优先 "_tint" 变体（草稿设置了时间颜色）。
 * @return EN: Empty for unsupported draft types. CN: 不支持的草稿类型返回空数组。
 */
+ (NSArray<NSString *> *)subArchiveNamesForDraftType:(TSDialDraftType)draftType preferTint:(BOOL)preferTint;

/**
 * @brief Unpack the template
 * @chinese 解压模板
 *
 * @param archivePath EN: Template zip. CN: 模板 zip。
 * @param templateDirectory EN: Scratch directory for the zip content; recreated. CN: 存放 zip 内容的临时目录，会被重建。
 * @param contentDirectory EN: Destination content directory. CN: 目标内容目录。
 * @param subArchiveNames EN: Candidates from subArchiveNamesForDraftType:preferTint:. CN: 子包候选名。
 */
+ (BOOL)extractArchiveAtPath:(NSString *)archivePath
           templateDirectory:(NSString *)templateDirectory
            contentDirectory:(NSString *)contentDirectory
             subArchiveNames:(NSArray<NSString *> *)subArchiveNames
                       error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
