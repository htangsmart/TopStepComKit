#import <Foundation/Foundation.h>
#import "TSAIDeviceCommandResult.h"

@class TSAIContext;
@protocol TSAIDeviceBridge;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Validates device command ownership before execution
 * @chinese 执行前校验设备指令所有权
 */
@interface TSAIDeviceCommandCoordinator : NSObject

/**
 * @brief Actual command result observer
 * @chinese 指令真实结果观察回调
 * @discussion
 * [EN]: Runs on the main thread.
 * [CN]: 在主线程执行。
 * @note
 * [EN]: Cloud reply text never counts as device success.
 * [CN]: 云端文本不作为设备成功依据。
 */
@property (nonatomic, copy, nullable) void (^onResult)(TSAIDeviceCommandResult *result);

/**
 * @brief Construct a coordinator for one activation
 * @chinese 为一次激活创建协调器
 * @param context
 * EN: Owning Context.
 * CN: 所属 Context。
 * @param deviceBridge
 * EN: Current device bridge.
 * CN: 当前设备桥。
 * @return
 * EN: New coordinator.
 * CN: 新协调器。
 */
- (instancetype)initWithContext:(TSAIContext *)context deviceBridge:(id<TSAIDeviceBridge>)deviceBridge;

/**
 * @brief Validate and execute a command
 * @chinese 校验并执行指令
 * @param request
 * EN: Source command.
 * CN: 来源指令。
 */
- (void)handleCommand:(TSAIDeviceCommandRequest *)request;

@end

NS_ASSUME_NONNULL_END
