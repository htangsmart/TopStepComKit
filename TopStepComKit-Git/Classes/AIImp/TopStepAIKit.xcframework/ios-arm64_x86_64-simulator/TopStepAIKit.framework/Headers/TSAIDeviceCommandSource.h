#import <Foundation/Foundation.h>

@class TSAIDeviceCommandRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Optional source of neutral device commands
 * @chinese 可选的中立设备指令来源
 */
@protocol TSAIDeviceCommandSource <NSObject>

/**
 * @brief Receives each parsed command on the main thread
 * @chinese 在主线程接收每次解析后的指令
 * @discussion
 * [EN]: Core validates Context and device before execution.
 * [CN]: 执行前由 Core 校验 Context 与设备。
 * @note
 * [EN]: Nil disables forwarding, not the cloud's spoken claims.
 * [CN]: nil 关闭转发，不代表云端停止播报执行声明。
 */
@property (nonatomic, copy, nullable) void (^deviceCommandHandler)(TSAIDeviceCommandRequest *request);

/**
 * @brief Verify the command's source task before device execution
 * @chinese 执行设备动作前检查指令的来源任务
 * @param taskIdentifier
 * EN: Source task to verify.
 * CN: 要校验的来源任务。
 * @return
 * EN: YES only for the active task.
 * CN: 仅活动任务返回 YES。
 */
- (BOOL)isDeviceCommandTaskActive:(NSString *)taskIdentifier;

/**
 * @brief Check an already accepted command's source authorization
 * @chinese 检查已受理指令的来源授权是否仍有效
 * @param taskIdentifier
 * EN: Previously active source task.
 * CN: 接收时活动的来源任务。
 * @return
 * EN: YES while active or normally completed, but not explicitly cancelled.
 * CN: 活动或正常完成且未明确取消时返回 YES。
 */
- (BOOL)isDeviceCommandTaskAuthorized:(NSString *)taskIdentifier;

@end

NS_ASSUME_NONNULL_END
