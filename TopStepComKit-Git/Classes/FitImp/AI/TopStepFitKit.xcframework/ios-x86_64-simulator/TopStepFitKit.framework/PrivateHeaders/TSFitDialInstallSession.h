//
//  TSFitDialInstallSession.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/30.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Private state machine for one Fit dial installation
 * @chinese 单次 Fit 表盘安装的私有状态机
 */
@interface TSFitDialInstallSession : NSObject

/**
 * @brief Initialize one dial installation session
 * @chinese 初始化一次表盘安装会话
 * @param artifact EN: Stable dial artifact. CN: 稳定的表盘产物。
 * @param progressBlock EN: Optional main-thread progress callback. CN: 可选的主线程进度回调。
 * @param completion EN: Main-thread terminal callback. CN: 主线程终态回调。
 * @return EN: Initialized session, or nil. CN: 初始化后的会话，参数无效时为 nil。
 */
- (nullable instancetype)initWithArtifact:(TSDialArtifact *)artifact
                            progressBlock:(nullable TSDialInstallProgressBlock)progressBlock
                                completion:(TSDialInstallCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/** @brief Start installation once @chinese 启动一次安装 */
- (void)start;

/**
 * @brief Cancel the current installation if possible
 * @chinese 在可取消时取消当前安装
 * @param completion EN: Main-thread cancellation response. CN: 主线程取消响应。
 */
- (void)cancelWithCompletion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
