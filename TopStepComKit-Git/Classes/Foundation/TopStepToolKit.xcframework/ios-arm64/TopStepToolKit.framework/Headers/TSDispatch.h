//
//  TSDispatch.h
//  TopStepToolKit
//
//  Created by 磐石 on 2026/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Run a block on the main thread
 * @chinese 在主线程执行一个 block
 *
 * @param block
 * EN: The block to run. Ignored if nil.
 * CN: 要执行的 block，为 nil 时忽略。
 *
 * @discussion
 * [EN]: If the caller is already on the main thread, the block runs synchronously and immediately;
 *       otherwise it is dispatched asynchronously to the main queue. This avoids an unnecessary
 *       runloop hop when already on the main thread.
 *       NOTE: because it may run synchronously, do NOT rely on it always being asynchronous
 *       (e.g. to defer execution until after the current method returns).
 * [CN]: 若调用方已在主线程，block 同步立即执行；否则异步派发到主队列。已在主线程时可避免多绕一个 runloop。
 *       注意：因为可能同步执行，不要依赖它「总是异步」的行为（例如指望它把执行推迟到当前方法返回之后）。
 */
FOUNDATION_EXPORT void TSDispatchMain(dispatch_block_t _Nullable block);

NS_ASSUME_NONNULL_END
