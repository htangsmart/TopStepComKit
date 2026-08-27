//
//  TSFitAIWatchFaceCoordinator.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

#import "TSFitAIWatchFaceSession.h"

@class TSAIContext;
@class TSPeripheralScreen;
@class TSFitAIEventSource;
@class TSFitAIWatchFaceImageProcessor;
@class TSFitDialTemplateCloudService;
@class TSFitDialTemplateDownloader;
@class TSFitDialTemplateRequestContextLoader;
@protocol TSFitAIWatchFaceDeviceTransporting;
@protocol TSPeripheralDialInterface;

NS_ASSUME_NONNULL_BEGIN

/** @brief Active AI Context provider @chinese 当前 AI Context 提供器 */
typedef TSAIContext *_Nullable (^TSFitAIWatchFaceContextProvider)(void);

/** @brief Connected screen information provider @chinese 当前连接设备屏幕信息提供器 */
typedef TSPeripheralScreen *_Nullable (^TSFitAIWatchFaceScreenProvider)(void);

/**
 * @brief Coordinates the private FitCloud AI watch-face flow
 * @chinese 编排 FitCloud 私有 AI 表盘流程
 */
@interface TSFitAIWatchFaceCoordinator : NSObject

/** @brief Current session state snapshot @chinese 当前会话状态快照 */
@property (atomic, assign, readonly) TSFitAIWatchFaceSessionState sessionState;

/**
 * @brief Shared production coordinator
 * @chinese 生产环境共享协调器
 *
 * @return EN: Process-wide coordinator. CN: 进程内共享协调器。
 */
+ (instancetype)sharedInstance;

/**
 * @brief Create an injectable coordinator
 * @chinese 创建依赖可注入的协调器
 *
 * @param eventSource EN: Raw Fit event source. CN: Fit 原始事件源。
 * @param contextProvider EN: Active AI Context provider. CN: 当前 AI Context 提供器。
 * @param transport EN: FitCloud device command transport. CN: FitCloud 设备命令传输器。
 * @param requestContextLoader EN: Device template-context loader. CN: 设备模板上下文加载器。
 * @param cloudService EN: Template metadata service. CN: 模板元数据服务。
 * @param downloader EN: Template and style downloader. CN: 模板与样式下载器。
 * @param imageProcessor EN: Image derivative processor. CN: 图片派生处理器。
 * @param dialInstaller EN: Custom-dial builder and installer. CN: 自定义表盘制作安装器。
 * @param screenProvider EN: Connected screen provider. CN: 当前屏幕信息提供器。
 * @param stageTimeout EN: Timeout for one waiting stage. CN: 单阶段等待超时。
 * @param overallTimeout EN: Timeout for the complete flow. CN: 整轮流程超时。
 * @return EN: Initialized coordinator, or nil for invalid dependencies. CN: 初始化后的协调器，依赖无效时为 nil。
 */
- (nullable instancetype)initWithEventSource:(TSFitAIEventSource *)eventSource
                             contextProvider:(TSFitAIWatchFaceContextProvider)contextProvider
                                    transport:(id<TSFitAIWatchFaceDeviceTransporting>)transport
                         requestContextLoader:(TSFitDialTemplateRequestContextLoader *)requestContextLoader
                                 cloudService:(TSFitDialTemplateCloudService *)cloudService
                                    downloader:(TSFitDialTemplateDownloader *)downloader
                                imageProcessor:(TSFitAIWatchFaceImageProcessor *)imageProcessor
                                 dialInstaller:(id<TSPeripheralDialInterface>)dialInstaller
                                screenProvider:(TSFitAIWatchFaceScreenProvider)screenProvider
                                  stageTimeout:(NSTimeInterval)stageTimeout
                                overallTimeout:(NSTimeInterval)overallTimeout NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/** @brief Start listening for AI watch-face events @chinese 开始监听 AI 表盘事件 */
- (void)start;

/** @brief Stop listening and cancel client-side work @chinese 停止监听并取消客户端任务 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
