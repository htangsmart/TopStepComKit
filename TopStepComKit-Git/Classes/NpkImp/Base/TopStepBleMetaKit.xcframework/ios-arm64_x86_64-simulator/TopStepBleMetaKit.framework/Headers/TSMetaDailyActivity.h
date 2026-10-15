//
//  TSMetaDailyActivity.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/4.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"
#import "PbDataParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaDailyActivity : TSBusinessBase

/**
 * @brief Fetch daily exercise configs
 * @chinese 获取每日活动目标配置
 *
 * @param completion
 * [EN]: Completion callback returning TSMetaDailyConfig or error
 * [CN]: 返回 TSMetaGoalsModel 或错误的完成回调
 */
+ (void)fetchDailyActivityConfigsWithCompletion:(void(^)(TSMetaDailyConfig *_Nullable config, NSError *_Nullable error))completion;

/**
 * @brief Push daily exercise configs
 * @chinese 设置每日活动目标配置
 *
 * @param config
 * [EN]: Goals configuration to push (TSMetaDailyConfig)
 * [CN]: 需要推送的目标配置（TSMetaGoalsModel）
 *
 * @param completion
 * [EN]: Completion callback indicating success or error
 * [CN]: 指示成功或错误的完成回调
 */
+ (void)pushDailyActivityConfigs:(TSMetaDailyConfig *)config
            completion:(void(^)(BOOL success, NSError *_Nullable error))completion;

/**
 * @brief Register daily exercise config change notification
 * @chinese 注册每日活动目标变更通知
 *
 * @param completion
 * [EN]: Completion callback returning updated TSMetaDailyConfig or error
 * [CN]: 返回变更后的 TSMetaDailyConfig 或错误
 */
 + (void)registerDailyActivityConfigsDidChange:(void(^)(TSMetaDailyConfig *_Nullable config, NSError *_Nullable error))completion;

/**
 * @brief Register listener for current activity data reported by device (0x05-0x40)
 * @chinese 注册设备主动上报当前活动数据的监听（0x05-0x40）
 *
 * @param completion
 * [EN]: Invoked every time the device reports _ActivityCurrent (today's totals), or with an error.
 *       Passing nil is ignored; use unregisterCurrentActivityDidChanged to remove the listener.
 * [CN]: 设备每次上报 _ActivityCurrent（当天累计值）时回调，或回调错误。
 *       传 nil 将被忽略；移除监听请调用 unregisterCurrentActivityDidChanged。
 *
 * @discussion
 * [EN]: The device only reports while the App is in foreground and when steps/calories etc. change.
 *       The listener is keyed by this class: registering again replaces the previous block,
 *       and it is NOT removed on disconnect. The callback is invoked on the main thread.
 * [CN]: 设备仅在 App 处于前台、且步数/卡路里等发生变化时上报。
 *       监听以本类为标识：重复注册会覆盖旧回调，断开连接不会自动移除。回调在主线程执行。
 */
+ (void)registerCurrentActivityDidChanged:(nullable void(^)(TSMetaActivityCurrent *_Nullable currentActivity, NSError *_Nullable error))completion;

/**
 * @brief Remove listener for current activity data report
 * @chinese 移除当前活动数据上报监听
 *
 * @discussion
 * [EN]: Safe to call even if no listener was registered.
 * [CN]: 未注册过监听时调用也是安全的。
 */
+ (void)unregisterCurrentActivityDidChanged;

/**
 * @brief Parse the payload of a 0x05-0x40 report
 * @chinese 解析 0x05-0x40 上报的负载
 *
 * @param payload
 * [EN]: Raw payload. nil or empty is valid: proto3 encodes an all-zero message as zero bytes.
 * [CN]: 原始负载。nil 或空数据合法：proto3 中全 0 的消息编码后长度为 0。
 *
 * @param error
 * [EN]: Set when the payload is not a valid _ActivityCurrent message.
 * [CN]: 负载不是合法的 _ActivityCurrent 消息时返回错误。
 *
 * @return
 * [EN]: Parsed message, or nil on failure.
 * [CN]: 解析后的消息，失败返回 nil。
 */
+ (nullable TSMetaActivityCurrent *)currentActivityFromPayload:(nullable NSData *)payload error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
