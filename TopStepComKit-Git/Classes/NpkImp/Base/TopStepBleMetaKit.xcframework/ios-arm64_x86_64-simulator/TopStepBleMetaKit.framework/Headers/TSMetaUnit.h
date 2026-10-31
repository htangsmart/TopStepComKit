//
//  TSMetaUnit.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/28.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"

@class TSBleWriteContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Complete unit configuration result
 * @chinese 完整单位配置结果
 *
 * @param config
 * EN: Configuration including raw flags and protocol update time, or nil on failure.
 * CN: 包含原始 flags 和协议更新时间的配置；失败时为 nil。
 *
 * @param error
 * EN: Error information, or nil on success.
 * CN: 错误信息；成功时为 nil。
 */
typedef void (^TSMetaUnitModelResultBlock)(TSMetaUnitModel * _Nullable config, NSError * _Nullable error);

/**
 * @brief Unit configuration manager
 * @chinese 单位配置管理类
 */
@interface TSMetaUnit : TSBusinessBase

/**
 * @brief Set unit configuration
 * @chinese 设置单位配置信息
 *
 * @param config
 * EN: Protocol configuration. A copy is sent with current seconds since 2000; the input remains unchanged.
 * CN: 协议配置；发送副本时填入距2000年的当前整秒，调用方模型保持不变。
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setUnitConfig:(TSMetaUnitModel *)config completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Set unit configuration on the captured physical connection
 * @chinese 在捕获的物理连接上设置单位配置
 *
 * @param config
 * EN: Configuration copied before adding the current protocol update time.
 * CN: 添加当前协议更新时间前复制的配置，调用方模型保持不变。
 *
 * @param context
 * EN: Original physical target; nil preserves the legacy command path.
 * CN: 原始物理目标；nil 沿用旧命令路径。
 *
 * @param completion
 * EN: Completion at most once. Parameter errors may be synchronous; context-bound transport results use main.
 * CN: 完成回调最多一次；参数错误可能同步返回，绑定上下文的传输结果在主队列交付。
 */
+ (void)setUnitConfig:(TSMetaUnitModel *)config
               context:(nullable TSBleWriteContext *)context
            completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get unit configuration flags
 * @chinese 获取单位配置的 flags 原始字节
 *
 * @param completion 
 * EN: Completion callback with flags bytes and error
 * CN: 完成回调，返回 flags 原始字节与错误信息
 */
+ (void)getUnitConfig:(void(^)(NSData * _Nullable flags, NSError * _Nullable error))completion;

/**
 * @brief Get the complete unit configuration
 * @chinese 获取完整单位配置
 *
 * @param completion
 * EN: Completion with the parsed protocol model or an error, on the command callback queue.
 * CN: 在命令回调队列返回解析后的协议模型或错误。
 */
+ (void)getUnitConfigModel:(TSMetaUnitModelResultBlock)completion;

/**
 * @brief Get complete unit configuration from the captured physical connection
 * @chinese 从捕获的物理连接读取完整单位配置
 *
 * @param context
 * EN: Original physical target; stale contexts fail instead of selecting another device. Nil keeps legacy behavior.
 * CN: 原始物理目标；过期上下文返回错误，不改选其他设备。nil 保持旧行为。
 *
 * @param completion
 * EN: Completion at most once with a model or error; context-bound results arrive on main.
 * CN: 最多一次返回模型或错误；绑定上下文时在主队列交付。
 */
+ (void)getUnitConfigModelWithContext:(nullable TSBleWriteContext *)context
                          completion:(TSMetaUnitModelResultBlock)completion;

/**
 * @brief Register unit configuration change notification
 * @chinese 注册单位配置变更通知（返回 flags 原始字节）
 *
 * @param completion 
 * EN: Latest flags callback on the command callback queue. Nil removes this callback only.
 * CN: 在命令回调队列返回最新 flags；nil 仅注销此回调。
 *
 * @discussion
 * [EN]: Replaces the previous flags callback and coexists with the complete-model callback.
 * [CN]: 替换原 flags 回调，可与完整模型回调同时使用。
 */
+ (void)registerUnitConfigDidChanged:(void(^ _Nullable)(NSData * _Nullable flags, NSError * _Nullable error))completion;

/**
 * @brief Register complete unit configuration changes
 * @chinese 注册完整单位配置变更通知
 *
 * @param completion
 * EN: Latest complete-model callback on the command callback queue. Nil removes this callback only.
 * CN: 在命令回调队列返回最新完整模型；nil 仅注销此回调。
 *
 * @discussion
 * [EN]: Replaces the previous complete-model callback and shares one subscription with the flags callback.
 * [CN]: 替换原完整模型回调，与 flags 回调共用一个底层订阅。
 */
+ (void)registerUnitConfigModelDidChanged:(nullable TSMetaUnitModelResultBlock)completion;

@end

NS_ASSUME_NONNULL_END


