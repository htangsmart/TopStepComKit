//
//  TSMetaMeasure.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbDataParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Measurement action type
 * @chinese 测量动作类型
 */
typedef NS_ENUM(NSInteger, TSMetaMeasureAction) {
    /// 停止测量 (Stop measurement)
    eTSMetaMeasureActionStop = 0,
    /// 开始测量 (Start measurement)
    eTSMetaMeasureActionStart = 1
};

@interface TSMetaMeasure : TSBusinessBase

/**
 * @brief Start health measurement
 * @chinese 开始健康测量
 *
 * @param measureModel
 * [EN]: Measurement parameters including type, action, and duration
 * [CN]: 测量参数，包括类型、动作和持续时间
 *
 * @param completion
 * [EN]: Completion callback that indicates the success or failure of starting measurement
 * [CN]: 完成回调，指示开始测量的成功或失败
 *
 * @discussion
 * [EN]: Initiates a health measurement session based on the provided parameters.
 *     The device will start collecting health data according to the specified
 *     measurement type and duration. Only one measurement type can be active at a time.
 * [CN]: 根据提供的参数启动健康测量会话。
 *     设备将根据指定的测量类型和持续时间开始收集健康数据。
 *     一次只能激活一种测量类型。
 *
 * @note
 * [EN]: Supported measurement types include heart rate (1), blood oxygen (2), 
 *     blood pressure (3), and stress (4). Check device capabilities before starting.
 * [CN]: 支持的测量类型包括心率(1)、血氧(2)、血压(3)和压力(4)。
 *     开始前请检查设备功能。
 */
+ (void)startMeasureWithParam:(TSMetaRealtimeModel *)measureModel 
                   completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Stop health measurement
 * @chinese 停止健康测量
 *
 * @param measureModel
 * [EN]: Measurement parameters including type and action (will be set to stop)
 * [CN]: 测量参数，包括类型和动作（将被设置为停止）
 *
 * @param completion
 * [EN]: Completion callback that indicates the success or failure of stopping measurement
 * [CN]: 完成回调，指示停止测量的成功或失败
 *
 * @discussion
 * [EN]: Stops the currently active health measurement session.
 *     The measureModel.type should specify which measurement type to stop.
 *     The action will be automatically set to 0 (stop) and duration will be ignored.
 *     All ongoing data collection will be terminated immediately.
 * [CN]: 停止当前活跃的健康测量会话。
 *     measureModel.type 应指定要停止的测量类型。
 *     action 将自动设置为 0（停止），duration 将被忽略。
 *     所有正在进行的数据收集将立即终止。
 *
 * @note
 * [EN]: If no measurement is currently active, this method will return success.
 *     Stopping measurement does not affect auto monitor configurations.
 *     The measureModel.type should match the currently active measurement type.
 * [CN]: 如果当前没有活跃的测量，此方法将返回成功。
 *     停止测量不会影响自动监测配置。
 *     measureModel.type 应与当前活跃的测量类型匹配。
 */
+ (void)stopMeasureWithParam:(TSMetaRealtimeModel *)measureModel 
                  completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Register measurement data change notification
 * @chinese 注册测量数据变化通知
 *
 * @param observer 
 * EN: Callback block invoked when measurement data is received
 *     - realtimeData: Real-time measurement data from device, nil if error occurs
 *     - error: Error information if data reception fails, nil if successful
 * CN: 当收到测量数据时触发的回调块
 *     - realtimeData: 设备发送的实时测量数据，发生错误时为nil
 *     - error: 数据接收失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method registers a notification listener for real-time measurement data.
 *     After starting a measurement with startMeasureWithParam:completion:, the device will
 *     periodically send measurement data to the app. This observer will be called
 *     each time new measurement data is received.
 *     
 *     The observer will continue to receive data until:
 *     1. The measurement is stopped with stopMeasureWithParam:completion:
 *     2. The device disconnects
 *     3. The app is terminated
 * CN: 此方法注册实时测量数据的通知监听器。
 *     在调用startMeasureWithParam:completion:开始测量后，设备会定期向App发送测量数据。
 *     每次收到新的测量数据时，此观察者都会被调用。
 *     
 *     观察者将持续接收数据，直到：
 *     1. 调用stopMeasureWithParam:completion:停止测量
 *     2. 设备断开连接
 *     3. App被终止
 *
 * @note
 * EN: 1. Multiple observers can be registered simultaneously
 *     2. The observer callback will be called on the main thread
 *     3. It's recommended to register the observer before starting the measurement
 *     4. The measurement must be started first before data will be received
 *     5. The observer will receive data for all measurement types
 * CN: 1. 可以同时注册多个观察者
 *     2. 观察者回调将在主线程中调用
 *     3. 建议在开始测量之前注册观察者
 *     4. 必须先开始测量才能接收到数据
 *     5. 观察者将接收所有测量类型的数据
 */
+ (void)registerMeasurementDataDidChanged:(void(^)(TSMetaRealtimeData * _Nullable realtimeData, NSError * _Nullable error))observer;

/**
 * @brief Register measurement end notification
 * @chinese 注册测量结束通知
 *
 * @param didFinished
 * EN: Callback block invoked when measurement ends
 *     - success: Whether the measurement ended normally (YES) or was interrupted (NO)
 *     - error: Error information if measurement ended abnormally, nil if normal end
 * CN: 当测量结束时触发的回调块
 *     - success: 测量是否正常结束（YES）或被中断（NO）
 *     - error: 异常结束时的错误信息，正常结束时为nil
 *
 * @discussion
 * EN: This method registers a notification listener for measurement end events.
 *     The observer will be called when:
 *     1. Measurement completes successfully
 *     2. Measurement is interrupted by user
 *     3. Measurement fails due to device error
 *     4. Measurement times out
 *     
 *     The observer will be called on the main thread and provides information
 *     about how the measurement ended.
 * CN: 此方法注册测量结束事件的通知监听器。
 *     观察者将在以下情况下被调用：
 *     1. 测量成功完成
 *     2. 测量被用户中断
 *     3. 测量因设备错误失败
 *     4. 测量超时
 *     
 *     观察者将在主线程中被调用，并提供测量如何结束的信息。
 *
 * @note
 * EN: 1. Multiple observers can be registered simultaneously
 *     2. The observer callback will be called on the main thread
 *     3. It's recommended to register the observer before starting the measurement
 *     4. The observer will be called for all measurement types
 *     5. The observer will be called even if no measurement was active
 * CN: 1. 可以同时注册多个观察者
 *     2. 观察者回调将在主线程中调用
 *     3. 建议在开始测量之前注册观察者
 *     4. 观察者将接收所有测量类型的结束事件
 *     5. 即使没有活跃的测量，观察者也会被调用
 */
+ (void)registerActivityeasureDidFinished:(void(^)(BOOL success, NSError * _Nullable error))didFinished;

@end

NS_ASSUME_NONNULL_END
