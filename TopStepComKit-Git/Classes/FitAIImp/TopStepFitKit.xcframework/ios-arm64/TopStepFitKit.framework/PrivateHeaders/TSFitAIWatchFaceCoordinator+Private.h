//
//  TSFitAIWatchFaceCoordinator+Private.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSFitAIWatchFaceCoordinator.h"

#import <TopStepAIKit/TopStepAIKitCore.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

#import "TSFitAIWatchFaceImageProcessor.h"
#import "../../Core/AIWatchFace/Template/TSFitDialTemplateDownloader.h"
#import "../../Core/TSFitPeripheralDial/CustomDialTemplate/TSFitCustomDialTemplateResolver.h"
#import "../../Core/AIWatchFace/Transport/TSFitAIWatchFaceDeviceTransport.h"

@class TSFitDialTemplateResource;

NS_ASSUME_NONNULL_BEGIN

@interface TSFitAIWatchFaceCoordinator ()

/** @brief Mutable session-state snapshot @chinese 可写会话状态快照 */
@property (atomic, assign, readwrite) TSFitAIWatchFaceSessionState sessionState;
/** @brief Serial state queue @chinese 状态串行队列 */
@property (nonatomic, strong) dispatch_queue_t stateQueue;
/** @brief Whether event listening has started @chinese 是否已开始事件监听 */
@property (nonatomic, assign) BOOL isStarted;
/** @brief Whether the underlying dial installation is still running @chinese 底层表盘安装是否仍在进行 */
@property (nonatomic, assign) BOOL isDialInstallationInProgress;
/** @brief Raw Fit event source @chinese Fit 原始事件源 */
@property (nonatomic, strong) TSFitAIEventSource *eventSource;
/** @brief Active AI Context provider @chinese 当前 AI Context 提供器 */
@property (nonatomic, copy) TSFitAIWatchFaceContextProvider contextProvider;
/** @brief Device command transport @chinese 设备命令传输器 */
@property (nonatomic, strong) id<TSFitAIWatchFaceDeviceTransporting> transport;
/** @brief Shared template resolver @chinese 共享模板解析器 */
@property (nonatomic, strong) TSFitCustomDialTemplateResolver *templateResolver;
/** @brief Template and style downloader @chinese 模板与样式下载器 */
@property (nonatomic, strong) TSFitDialTemplateDownloader *downloader;
/** @brief Image processor @chinese 图片处理器 */
@property (nonatomic, strong) TSFitAIWatchFaceImageProcessor *imageProcessor;
/** @brief Dial installer @chinese 表盘安装器 */
@property (nonatomic, strong) id<TSPeripheralDialInterface> dialInstaller;
/** @brief Connected screen provider @chinese 当前屏幕提供器 */
@property (nonatomic, copy) TSFitAIWatchFaceScreenProvider screenProvider;
/** @brief Current state-machine session @chinese 当前状态机会话 */
@property (nonatomic, strong) TSFitAIWatchFaceSession *session;
/** @brief Active speech facade @chinese 当前语音门面 */
@property (nonatomic, strong, nullable) id<TSAISpeechInterface> activeSpeech;
/** @brief Active image-generation facade @chinese 当前图片生成门面 */
@property (nonatomic, strong, nullable) id<TSAIImageGenerationInterface> activeImageGeneration;
/** @brief Current speech task identifier @chinese 当前语音任务标识 */
@property (nonatomic, copy, nullable) NSString *speechTaskIdentifier;
/** @brief Current image task identifier @chinese 当前图片任务标识 */
@property (nonatomic, copy, nullable) NSString *imageTaskIdentifier;
/** @brief Current template resolution task @chinese 当前模板解析任务 */
@property (nonatomic, strong, nullable) TSFitCustomDialTemplateResolutionTask *templateResolutionTask;
/** @brief Current style download task @chinese 当前样式下载任务 */
@property (nonatomic, strong, nullable) NSURLSessionTask *styleDownloadTask;
/** @brief Processed images retained through installation @chinese 安装完成前持有的派生图片 */
@property (nonatomic, strong, nullable) TSFitAIWatchFaceProcessedImages *processedImages;
/** @brief Resolved template resource @chinese 已解析的模板资源 */
@property (nonatomic, strong, nullable) TSFitDialTemplateResource *templateResource;
/** @brief Downloaded template file @chinese 已下载模板文件 */
@property (nonatomic, strong, nullable) NSURL *templateFileURL;
/** @brief SDK-owned template resolution @chinese SDK 持有的模板解析结果 */
@property (nonatomic, strong, nullable) TSFitResolvedDialTemplate *templateResolution;
/** @brief Downloaded first-style image file @chinese 已下载首样式图片文件 */
@property (nonatomic, strong, nullable) NSURL *styleImageFileURL;
/** @brief Current stage timer @chinese 当前阶段计时器 */
@property (nonatomic, strong, nullable) dispatch_source_t stageTimer;
/** @brief Complete-flow timer @chinese 整轮计时器 */
@property (nonatomic, strong, nullable) dispatch_source_t overallTimer;
/** @brief Stage timeout interval @chinese 阶段超时时间 */
@property (nonatomic, assign) NSTimeInterval stageTimeout;
/** @brief Complete-flow timeout interval @chinese 整轮超时时间 */
@property (nonatomic, assign) NSTimeInterval overallTimeout;

/**
 * @brief Execute work asynchronously on the state queue
 * @chinese 在状态队列异步执行任务
 * @param block EN: Work to execute. CN: 待执行任务。
 */
- (void)executeStateBlock:(dispatch_block_t)block;

/**
 * @brief Check the current token and state
 * @chinese 检查当前令牌与状态
 * @param token EN: Session token. CN: 会话令牌。
 * @param state EN: Required state. CN: 要求的状态。
 * @return EN: YES when both match. CN: 两者均匹配时返回 YES。
 */
- (BOOL)isCurrentToken:(NSString *)token state:(TSFitAIWatchFaceSessionState)state;

/**
 * @brief Advance the state machine and restart the stage timer
 * @chinese 推进状态机并重启阶段计时器
 * @param state EN: Destination state. CN: 目标状态。
 * @param token EN: Session token. CN: 会话令牌。
 * @return EN: YES on success. CN: 成功时返回 YES。
 */
- (BOOL)transitionToState:(TSFitAIWatchFaceSessionState)state token:(NSString *)token;

/**
 * @brief Finish and reset a session
 * @chinese 结束并重置会话
 * @param state EN: Terminal state. CN: 终态。
 * @param token EN: Session token. CN: 会话令牌。
 */
- (void)finishSessionWithState:(TSFitAIWatchFaceSessionState)state token:(NSString *)token;

/**
 * @brief Fail and optionally report image-generation failure
 * @chinese 失败收口并按需回报图片生成失败
 * @param error EN: Source error. CN: 原始错误。
 * @param token EN: Session token. CN: 会话令牌。
 * @param shouldReportPhoto EN: Whether to send a photo result. CN: 是否发送图片结果。
 */
- (void)failWithError:(NSError *)error
                token:(NSString *)token
    shouldReportPhoto:(BOOL)shouldReportPhoto;

/**
 * @brief Remove downloaded files held by this flow
 * @chinese 删除当前流程持有的下载文件
 */
- (void)removeDownloadedFiles;

@end

@interface TSFitAIWatchFaceCoordinator (Dial)

/**
 * @brief Resolve and install the confirmed watch face
 * @chinese 解析并安装已确认的表盘
 * @param token EN: Session token. CN: 会话令牌。
 */
- (void)resolveAndInstallDialForToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
