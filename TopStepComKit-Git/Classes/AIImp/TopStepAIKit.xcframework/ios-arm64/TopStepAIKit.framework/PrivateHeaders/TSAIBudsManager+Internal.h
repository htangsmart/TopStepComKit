//
//  TSAIBudsManager+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIBudsManager.h"

@class TSAIBudsRuntimeCoordinator;

NS_ASSUME_NONNULL_BEGIN

/** @brief Private manager construction APIs @chinese Manager 私有构造接口 */
@interface TSAIBudsManager ()

/**
 * @brief Create a manager with an isolated runtime coordinator
 * @chinese 使用独立 Runtime 协调器创建管理器
 * @param runtimeCoordinator EN: Runtime coordinator. CN: Runtime 协调器。
 * @return EN: Manager instance. CN: 管理器实例。
 */
- (instancetype)initWithRuntimeCoordinator:(TSAIBudsRuntimeCoordinator *)runtimeCoordinator
    NS_DESIGNATED_INITIALIZER;

@end

/**
 * @brief Internal capability snapshots used by AIBuds adapters
 * @chinese AIBuds 适配器使用的内部能力快照
 */
@interface TSAIBudsManager (Internal)

/**
 * @brief Whether the process-wide AIBuds route matches this manager
 * @chinese 进程级 AIBuds 路由是否与当前管理器一致
 */
- (BOOL)isCurrentVendorRouteAvailable;

/** @brief Whether the active route supports streaming TTS @chinese 当前路由是否支持流式 TTS */
- (BOOL)isStreamingTTSSupported;

/** @brief Whether the AIBuds runtime is authenticated @chinese AIBuds 运行时是否已鉴权 */
- (BOOL)isAIBudsAuthorized;

/** @brief Whether the active AIBuds service exposes AI asking @chinese 当前 AIBuds 服务是否提供 AI 问答 */
- (BOOL)isAIQuestionAnswerSupported;

@end

/**
 * @brief Internal AIGC capability snapshots exposed by the AIBuds facade
 * @chinese AIBuds 统一门面对内提供的 AIGC 能力快照
 */
@interface TSAIBudsManager (AIGC)

/** @brief Whether the AIBuds AIGC runtime is initialized @chinese AIBuds AIGC 运行时是否已初始化 */
- (BOOL)isAIGCRuntimeInitialized;

/** @brief Whether the AIBuds unified facade exposes AIGC @chinese AIBuds 统一门面是否提供 AIGC */
- (BOOL)isAIGCSupported;

/** @brief AIBuds unified AIGC maximum image count @chinese AIBuds 统一 AIGC 最大图片数量 */
- (NSInteger)aigcMaximumImageCount;

@end

NS_ASSUME_NONNULL_END
