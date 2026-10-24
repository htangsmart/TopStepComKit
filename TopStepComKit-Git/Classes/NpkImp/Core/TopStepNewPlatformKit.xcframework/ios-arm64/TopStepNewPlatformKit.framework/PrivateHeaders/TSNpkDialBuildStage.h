//
//  TSNpkDialBuildStage.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkDialBuildRequest;
@class TSNpkDialBuildState;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One step of the dial package pipeline
 * @chinese 造包流水线中的一步
 *
 * @discussion
 * [EN]: A stage reads the request and earlier results from the state, does one thing, stores its result in the
 *       state and calls completion exactly once. It may complete asynchronously and on any queue.
 * [CN]: 阶段从 request 和 state 读取输入，只做一件事，把结果存进 state，并且恰好调用一次 completion。
 *       可以异步完成，回调所在队列不限。
 */
@protocol TSNpkDialBuildStage <NSObject>

/**
 * @brief Stage name used in pipeline diagnostics
 * @chinese 流水线诊断使用的阶段名称
 *
 * @discussion
 * [EN]: Implementations return their short stage name for start and failure logs; it does not determine execution order.
 * [CN]: 各实现返回自己的简短名称，用于开始及失败日志；该名称不决定执行顺序。
 */
@property (nonatomic, copy, readonly) NSString *stageName;

/**
 * @brief Run the stage
 * @chinese 执行该阶段
 *
 * @param completion EN: nil error means success. CN: error 为 nil 表示成功。
 */
- (void)runWithRequest:(TSNpkDialBuildRequest *)request
                 state:(TSNpkDialBuildState *)state
            completion:(void (^)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
