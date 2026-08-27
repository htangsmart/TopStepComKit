//
//  TSCompanionWorkoutInterface.h
//  TopStepInterfaceKit
//
//  文件说明:
//  互联运动会话协议，定义运动事件发送、周期数据上报、会话查询和设备数据监听能力

#import "TSCompanionWorkoutAppReportModel.h"
#import "TSCompanionWorkoutCapabilitiesModel.h"
#import "TSCompanionWorkoutDeviceReportModel.h"
#import "TSCompanionWorkoutEventModel.h"
#import "TSCompanionWorkoutInfoModel.h"
#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Companion workout information query callback
 * @chinese 互联运动信息查询回调
 *
 * @param workoutInfo
 * EN: Current workout information, or nil when no session is active
 * CN: 当前运动信息；无活动会话时为 nil
 *
 * @param error
 * EN: Error information, or nil on success
 * CN: 错误信息；成功时为 nil
 */
typedef void (^TSCompanionWorkoutInfoCompletionBlock)(TSCompanionWorkoutInfoModel * _Nullable workoutInfo,
                                                       NSError * _Nullable error);

/**
 * @brief Device companion workout event callback
 * @chinese 设备互联运动事件回调
 *
 * @param event
 * EN: Companion workout event sent by the device
 * CN: 设备发送的互联运动事件
 */
typedef void (^TSCompanionWorkoutEventBlock)(TSCompanionWorkoutEventModel *event);

/**
 * @brief Device periodic report callback
 * @chinese 设备周期运动数据回调
 *
 * @param reportData
 * EN: Periodic workout data sent by the device
 * CN: 设备发送的周期运动数据
 */
typedef void (^TSCompanionWorkoutPeriodicReportBlock)(TSCompanionWorkoutDeviceReportModel *reportData);

/**
 * @brief Companion workout session interface
 * @chinese 互联运动会话接口
 *
 * @discussion
 * EN: This protocol controls a realtime workout session shared by the App and device.
 *     It is independent from workout resource installation and sport history synchronization.
 * CN: 该协议用于控制 App 与设备共享的实时运动会话。
 *     此能力独立于运动资源安装和运动历史同步。
 */
@protocol TSCompanionWorkoutInterface <TSKitBaseInterface>

/**
 * @brief Get companion workout capabilities
 * @chinese 获取互联运动能力
 *
 * @return
 * EN: Companion workout capability model
 * CN: 互联运动能力模型
 *
 * @discussion
 * EN: Returns the companion workout, device GPS, and periodic report capabilities
 *     supported by the currently connected device.
 * CN: 返回当前连接设备支持的互联运动、设备 GPS 和周期数据上报能力。
 */
- (TSCompanionWorkoutCapabilitiesModel *)capabilities;

/**
 * @brief Send a companion workout event to the device
 * @chinese 向设备发送互联运动事件
 *
 * @param event
 * EN: Complete start, pause, resume, or stop event
 * CN: 完整的开始、暂停、继续或结束事件
 *
 * @param completion
 * EN: Optional completion block invoked once on the main thread
 * CN: 可选完成回调，在主线程仅调用一次
 *
 * @discussion
 * EN: Sends the specified companion workout control event to the device.
 * CN: 向设备发送指定的互联运动控制事件。
 */
- (void)sendWorkoutEvent:(TSCompanionWorkoutEventModel *)event
              completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Send periodic workout data from App to device
 * @chinese 从 App 向设备发送周期运动数据
 *
 * @param reportData
 * EN: App-side cumulative workout metrics
 * CN: App 侧累计运动指标
 *
 * @param completion
 * EN: Optional completion block invoked once on the main thread
 * CN: 可选完成回调，在主线程仅调用一次
 *
 * @discussion
 * EN: Sends cumulative workout metrics collected by the App to the device.
 * CN: 将 App 采集的累计运动指标发送到设备。
 */
- (void)sendPeriodicReportData:(TSCompanionWorkoutAppReportModel *)reportData
                    completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Query the current companion workout session
 * @chinese 查询当前互联运动会话
 *
 * @param completion
 * EN: Completion block invoked once on the main thread
 * CN: 完成回调，在主线程仅调用一次
 *
 * @discussion
 * EN: Returns the current companion workout session information.
 *     The workout information is nil when no session is active.
 * CN: 返回当前互联运动会话信息。
 *     无活动会话时，运动信息为 nil。
 */
- (void)queryWorkoutInfoWithCompletion:(TSCompanionWorkoutInfoCompletionBlock)completion;

/**
 * @brief Register the device workout-event listener
 * @chinese 注册设备运动事件监听
 *
 * @param eventBlock
 * EN: Workout-event listener, or nil to unregister
 * CN: 运动事件监听回调；传 nil 解除监听
 *
 * @discussion
 * EN: Registers a listener for companion workout events initiated by the device.
 *     Events are delivered on the main thread.
 * CN: 注册设备发起的互联运动事件监听。
 *     事件在主线程回调。
 */
- (void)registerWorkoutEventDidChanged:(nullable TSCompanionWorkoutEventBlock)eventBlock;

/**
 * @brief Register the device periodic-report listener
 * @chinese 注册设备周期运动数据监听
 *
 * @param reportBlock
 * EN: Periodic-report listener, or nil to unregister
 * CN: 周期数据监听回调；传 nil 解除监听
 *
 * @discussion
 * EN: Registers a listener for periodic workout data reported by the device.
 *     The reporting interval is determined by the device firmware, and callbacks
 *     are delivered on the main thread.
 * CN: 注册设备周期运动数据监听。
 *     上报间隔由设备固件决定，数据在主线程回调。
 */
- (void)registerPeriodicReportDataDidChanged:(nullable TSCompanionWorkoutPeriodicReportBlock)reportBlock;

@end

NS_ASSUME_NONNULL_END
