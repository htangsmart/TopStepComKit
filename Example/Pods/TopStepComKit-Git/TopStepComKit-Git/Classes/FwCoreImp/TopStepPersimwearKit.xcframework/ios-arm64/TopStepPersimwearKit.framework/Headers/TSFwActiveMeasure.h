//
//  TSFwActiveMeasure.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/14.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persimwear active measurement entry (singleton). Class methods forward to the shared instance.
 * @chinese Persimwear 主动测量入口（单例）。类方法均转发到共享实例的同名实例方法。
 *
 * @discussion
 * [EN]: After `startMeasureWithParam:completion:` succeeds, a 1-second timer fetches realtime values
 *      from DCM until `stopMeasureWithParam:completion:` or `maxMeasureDuration` (seconds) elapses.
 * [CN]: `startMeasureWithParam:completion:` 成功后，会以 1 秒为周期从 DCM 拉取实时数据，直至调用
 *      `stopMeasureWithParam:completion:` 或达到 `maxMeasureDuration`（秒）。
 */
@interface TSFwActiveMeasure : TSFwKitBase<TSActiveMeasureInterface>

/**
 * @brief Shared singleton instance
 * @chinese 单例实例
 *
 * @return
 * EN: The only `TSFwActiveMeasure` instance.
 * CN: 唯一的 `TSFwActiveMeasure` 实例。
 */
+ (instancetype)sharedInstance;

/**
 * @brief Whether a measurement session is currently active (after successful start, before stop).
 * @chinese 当前是否处于测量中（开始成功之后、停止之前为 YES）。
 *
 * @discussion
 * [EN]: Before calling `startMeasureWithParam:completion:`, this should be NO; if YES, start will fail.
 *      Before calling `stopMeasureWithParam:completion:`, if NO, stop returns success without sending command.
 * [CN]: 调用 `startMeasureWithParam:completion:` 前应为 NO；若为 YES 则开始会失败。
 *      调用 `stopMeasureWithParam:completion:` 时若为 NO，则直接成功且不向设备发停止指令。
 */
@property (nonatomic, assign, readonly) BOOL isMeasuring;

/**
 * @brief Register measurement finished callback (instance API; class method calls this).
 * @chinese 注册测量结束回调（实例方法；类方法内部调用）。
 *
 * @param didFinished
 * EN: Invoked when measurement ends (manual stop, timeout, or device error path as implemented).
 * CN: 测量结束时回调（手动停止、超时或内部实现的设备错误路径）。
 */
- (void)registerActivityeasureDidFinished:(nullable void (^)(BOOL isFinished, NSError * _Nullable error))didFinished;

/**
 * @brief Register realtime data callback (instance API; class method calls this).
 * @chinese 注册实时数据回调（实例方法；类方法内部调用）。
 *
 * @param param
 * EN: Measurement parameters; used to determine value keys / pool when dispatching data.
 * CN: 测量参数；用于在分发数据时确定取值键与 pool。
 *
 * @param dataDidChanged
 * EN: Called about every second with parsed `TSHealthValueItem` while measuring.
 * CN: 测量过程中约每秒回调一次，并带上解析后的 `TSHealthValueItem`。
 */
- (void)registerMeasurement:(nonnull TSActivityMeasureParam *)param
             dataDidChanged:(nonnull void (^)(TSHealthValueItem * _Nullable realtimeData, NSError * _Nullable error))dataDidChanged;

/**
 * @brief Start measurement (instance API; class method calls this).
 * @chinese 开始测量（实例方法；类方法内部调用）。
 */
- (void)startMeasureWithParam:(nonnull TSActivityMeasureParam *)measureParam
                   completion:(nonnull TSCompletionBlock)completion;

/**
 * @brief Stop measurement (instance API; class method calls this).
 * @chinese 停止测量（实例方法；类方法内部调用）。
 */
- (void)stopMeasureWithParam:(nonnull TSActivityMeasureParam *)measureParam
                  completion:(nonnull TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
