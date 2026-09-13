//
//  TSAIDevicePCMOutputRouter+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Serializes one AI session's PCM output to the device bridge
 * @chinese 将单个 AI 会话的 PCM 输出串行转发到设备 Bridge
 */
@interface TSAIDevicePCMOutputRouter : NSObject

/**
 * @brief Create a PCM router
 * @chinese 创建 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Create a PCM router with a finish timeout
 * @chinese 使用指定结束超时时间创建 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @param finishTimeout EN: Maximum finish duration in seconds. CN: 最大结束等待秒数。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier
                  finishTimeout:(NSTimeInterval)finishTimeout;

/**
 * @brief Create a PCM router that may defer device playback until resumed
 * @chinese 创建可延迟到恢复后才启动设备播放的 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @param startSuspended EN: Whether PCM should be buffered before resume. CN: 是否在恢复前缓存 PCM。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier
                startSuspended:(BOOL)startSuspended;

/**
 * @brief Create a PCM router that may defer device playback until resumed
 * @chinese 创建可延迟到恢复后才启动设备播放的 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @param finishTimeout EN: Maximum finish duration in seconds. CN: 最大结束等待秒数。
 * @param startSuspended EN: Whether PCM should be buffered before resume. CN: 是否在恢复前缓存 PCM。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier
                  finishTimeout:(NSTimeInterval)finishTimeout
                 startSuspended:(BOOL)startSuspended
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Append a 16 kHz mono signed Int16LE PCM chunk
 * @chinese 追加 16 kHz 单声道有符号 Int16LE PCM 分片
 */
- (void)appendPCMData:(NSData *)pcmData;

/** @brief Resume deferred device playback @chinese 恢复被延迟的设备播放 */
- (void)resumeOutput;

/** @brief Finish queued PCM output @chinese 正常结束已排队的 PCM 输出 */
- (void)finish;

/**
 * @brief Finish queued PCM output and observe the real device terminal state
 * @chinese 正常结束已排队的 PCM 输出并观察设备真实终态
 * @param completion EN: Main-thread terminal callback, invoked exactly once within
 *                    the configured finish timeout. CN: 主线程终态回调，在配置的
 *                    结束超时时间内保证调用一次。
 */
- (void)finishWithCompletion:(nullable TSAICompletionBlock)completion;

/** @brief Cancel queued PCM output @chinese 取消已排队的 PCM 输出 */
- (void)cancel;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
