//
//  TSFitDialArtifact.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/30.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Fit-private installable dial artifact
 * @chinese Fit 私有的可安装表盘产物
 *
 * @discussion
 * [EN]: Keeps provider metadata required after build without exposing Fit details
 *       through the shared TSDialArtifact model.
 * [CN]: 在不污染公共 TSDialArtifact 的前提下，保存安装阶段仍需使用的 Provider 元数据。
 */
@interface TSFitDialArtifact : TSDialArtifact

/** @brief Draft type used during build @chinese 造包时使用的草稿类型 */
@property (nonatomic, assign, readonly) TSDialDraftType draftType;

/**
 * @brief Fit watch-face module styles used when selecting the installed dial
 * @chinese 安装后切换表盘时使用的 Fit 模块样式
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *moduleStyles;

/**
 * @brief Initialize a Fit custom-dial artifact
 * @chinese 初始化 Fit 自定义表盘产物
 * @param dialId EN: Opaque artifact id. CN: 不透明的产物 id。
 * @param filePath EN: Built package path. CN: 已生成的表盘包路径。
 * @param draftType EN: Draft type used during build. CN: 造包时使用的草稿类型。
 * @param moduleStyles
 * EN: Fit module styles for post-install selection.
 * CN: 安装后切换使用的 Fit 模块样式。
 * @return EN: Initialized artifact. CN: 初始化后的产物。
 */
- (instancetype)initWithDialId:(NSString *)dialId
                       filePath:(NSString *)filePath
                      draftType:(TSDialDraftType)draftType
                   moduleStyles:(NSArray<NSNumber *> *)moduleStyles NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDialType:(TSDialType)dialType
                          dialId:(NSString *)dialId
                         filePath:(NSString *)filePath NS_UNAVAILABLE;
- (instancetype)initWithDialId:(NSString *)dialId filePath:(NSString *)filePath NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
