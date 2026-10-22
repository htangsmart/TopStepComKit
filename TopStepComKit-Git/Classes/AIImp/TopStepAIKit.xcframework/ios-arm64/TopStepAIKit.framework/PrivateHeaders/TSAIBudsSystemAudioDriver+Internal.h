//
//  TSAIBudsSystemAudioDriver+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAISystemAudioDriver+Internal.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIBuds adapter for the shared system audio path (phone microphone / system playback)
 * @chinese AIBuds 共享系统音频链路适配器（手机麦 / 系统播放）
 *
 * @discussion
 * EN: Two paths, chosen once per instance:
 *     - executor path (default): prefersAsynchronousStart == YES. Session writes and vendor engine
 *       start / stop run only on the process-wide audio session executor; callers use the lease API.
 *     - legacy inline path (NSUserDefaults TSAISystemAudioSyncStartFallback = YES): the previous
 *       synchronous behaviour on the calling thread, without the executor.
 * CN: 两条路径，每个实例创建时确定：
 *     - 执行器路径（默认）：prefersAsynchronousStart == YES。会话写操作与厂商引擎启停只在进程级音频会话
 *       执行器上执行，调用方使用租约 API；
 *     - 旧的内联路径（NSUserDefaults TSAISystemAudioSyncStartFallback = YES）：在调用方线程上同步执行，
 *       不经执行器，行为与改造前一致。
 */
@interface TSAIBudsSystemAudioDriver : NSObject <TSAISystemAudioDriver>

/**
 * @brief Driver on the path given by the process fallback switch
 * @chinese 按进程回退开关选择路径
 */
- (instancetype)init;

/**
 * @brief Driver on an explicit path (unit tests)
 * @chinese 指定路径（单测用）：YES 时走旧的内联路径，不经执行器
 */
- (instancetype)initWithSynchronousStartFallback:(BOOL)usesSynchronousFallback NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
