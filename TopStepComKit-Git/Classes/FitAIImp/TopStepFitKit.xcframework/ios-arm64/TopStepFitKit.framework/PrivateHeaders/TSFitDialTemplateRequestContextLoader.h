//
//  TSFitDialTemplateRequestContextLoader.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

@class TSFitDialTemplateRequestContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Raw template-parameter completion
 * @chinese 原始模板参数完成回调
 */
typedef void (^TSFitDialTemplateParametersCompletion)(NSDictionary *_Nullable parameters,
                                                       NSError *_Nullable error);

/**
 * @brief Injectable raw template-parameter provider
 * @chinese 可注入的原始模板参数提供器
 */
typedef void (^TSFitDialTemplateParametersProvider)(TSFitDialTemplateParametersCompletion completion);

/**
 * @brief Strong request-context completion
 * @chinese 强类型请求上下文完成回调
 */
typedef void (^TSFitDialTemplateRequestContextCompletion)(
    TSFitDialTemplateRequestContext *_Nullable context,
    NSError *_Nullable error);

/**
 * @brief Loads current device parameters for a template request
 * @chinese 加载当前设备的模板请求参数
 */
@interface TSFitDialTemplateRequestContextLoader : NSObject

/**
 * @brief Initialize with TSDialModel+Fit as the production provider
 * @chinese 使用 TSDialModel+Fit 作为生产参数提供器初始化
 * @return EN: Initialized loader. CN: 初始化后的加载器。
 */
- (instancetype)init;

/**
 * @brief Initialize with an injectable parameter provider
 * @chinese 使用可注入的参数提供器初始化
 * @param parametersProvider EN: Provider of raw device parameters. CN: 原始设备参数提供器。
 * @return EN: Initialized loader. CN: 初始化后的加载器。
 */
- (nullable instancetype)initWithParametersProvider:(TSFitDialTemplateParametersProvider)parametersProvider
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Load and validate the current request context
 * @chinese 加载并校验当前请求上下文
 * @param completion
 * EN: Completion called once on the provider callback thread.
 * CN: 在参数提供器回调线程调用一次。
 */
- (void)loadRequestContextWithCompletion:(TSFitDialTemplateRequestContextCompletion)completion;

@end

NS_ASSUME_NONNULL_END
