//
//  TSAIEarbudsPickupAvailability.h
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/10/15.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Grace period after the earbuds drop during a session, in seconds
 * @chinese 会话中耳机断开后的等待重连时长（秒）
 *
 * @discussion
 * [EN]: Shared by AI recording and conversation translation: if the earbuds come
 *       back within this period the session continues, otherwise it ends and keeps
 *       what was captured.
 * [CN]: AI 录音与对话翻译共用：期间耳机恢复则继续，超时则结束并保留已有内容。
 */
FOUNDATION_EXTERN const NSTimeInterval TSAIEarbudsReconnectGracePeriod;

/**
 * @brief Earbuds pickup option state shared by AI recording, conversation translation and interpretation
 * @chinese 耳机收音选项状态，AI 录音、对话翻译、同声传译共用
 *
 * @discussion
 * [EN]: Selection only uses signals without audible side effects; whether the
 *       Bluetooth hands-free (HFP) microphone really works is verified when the
 *       session starts. Only CaseRequired makes the option unselectable; the
 *       other states stay tappable and guide the user.
 * [CN]: 选择阶段只使用不会影响用户听音的信号；耳机通话麦克风（HFP）能否真正使用在开始时验证。
 *       只有 CaseRequired 不可选，其余状态均可点击并给出引导。
 */
typedef NS_ENUM(NSInteger, TSAIEarbudsPickupState) {
    /// @brief AI service or charging case is unavailable @chinese AI 服务或充电仓不可用
    TSAIEarbudsPickupStateCaseRequired = 0,
    /// @brief Microphone permission was denied @chinese 麦克风权限已被拒绝
    TSAIEarbudsPickupStatePermissionRequired,
    /// @brief No Bluetooth audio device is connected to the phone @chinese 手机未连接任何蓝牙音频设备
    TSAIEarbudsPickupStateEarbudsNotReady,
    /// @brief Selectable; the HFP microphone is verified on start @chinese 可选择，开始时再验证 HFP 麦克风
    TSAIEarbudsPickupStateAvailable,
};

/**
 * @brief Immutable earbuds pickup status
 * @chinese 不可变的耳机收音状态
 */
@interface TSAIEarbudsPickupStatus : NSObject

/**
 * @brief Option state
 * @chinese 选项状态
 */
@property (nonatomic, assign, readonly) TSAIEarbudsPickupState state;

/**
 * @brief Name of the Bluetooth audio device the system will use, when known
 * @chinese 系统将使用的蓝牙音频设备名称，未知时为 nil
 *
 * @discussion
 * [EN]: Also filled in PermissionRequired, so callers can tell whether earbuds are connected.
 * [CN]: PermissionRequired 状态下同样会填写，便于调用方区分耳机是否已连接。
 */
@property (nonatomic, copy, readonly, nullable) NSString *deviceName;

/**
 * @brief Whether the option can be tapped (every state except CaseRequired)
 * @chinese 选项是否可点击（除 CaseRequired 外均可点击）
 */
@property (nonatomic, assign, readonly, getter=isSelectable) BOOL selectable;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Evaluates and observes whether earbuds can be offered as a pickup source
 * @chinese 判断并监听耳机能否作为收音方式
 */
@interface TSAIEarbudsPickupAvailability : NSObject

/**
 * @brief Evaluate the earbuds pickup status
 * @chinese 计算耳机收音状态
 *
 * @param caseReady
 * EN: Whether the AI service is ready and the charging case is connected
 * CN: AI 服务是否就绪且充电仓已连接
 *
 * @param allowsProbe
 * EN: YES only when the caller knows no capture or playback session is running;
 *     then a category that hides Bluetooth ports is switched briefly (no activation)
 * CN: 仅当调用方确认没有采集或播放会话进行时传 YES；此时若当前类别看不到蓝牙端口，
 *     会在不激活会话的前提下临时切换类别查看，随后恢复
 *
 * @return
 * EN: Status in priority order: case, permission, Bluetooth audio device
 * CN: 按充电仓、权限、蓝牙音频设备的优先级得出的状态
 *
 * @discussion
 * [EN]: Call on the main thread.
 * [CN]: 需在主线程调用。
 */
+ (TSAIEarbudsPickupStatus *)statusWithCaseReady:(BOOL)caseReady allowsProbe:(BOOL)allowsProbe;

/**
 * @brief Name of the connected Bluetooth audio device (A2DP / HFP / LE)
 * @chinese 已连接的蓝牙音频设备（A2DP / HFP / LE）名称
 *
 * @param allowsProbe
 * EN: YES allows a brief category switch (no activation) when the current
 *     category hides Bluetooth ports; pass NO unless the caller knows no
 *     capture or playback session is running
 * CN: YES 表示当前类别看不到蓝牙端口时允许临时切换类别（不激活会话）；
 *     除非调用方确认没有采集或播放会话进行，否则传 NO
 *
 * @return
 * EN: Device name, or nil when none is connected
 * CN: 设备名称，未连接时为 nil
 */
+ (nullable NSString *)connectedBluetoothAudioDeviceNameAllowingProbe:(BOOL)allowsProbe;

/**
 * @brief Whether a route contains a Bluetooth audio port
 * @chinese 路由中是否包含蓝牙音频端口
 *
 * @param route
 * EN: Route to inspect, e.g. the previous route of a route-change notification
 * CN: 待检查的路由，如路由变化通知中的旧路由
 *
 * @return
 * EN: YES when an input or output is A2DP / HFP / LE
 * CN: 输入或输出中存在 A2DP / HFP / LE 时返回 YES
 */
+ (BOOL)routeContainsBluetoothAudio:(nullable AVAudioSessionRouteDescription *)route;

/**
 * @brief Observe events that may change the earbuds status
 * @chinese 监听可能改变耳机状态的事件
 *
 * @param handler
 * EN: Called on the main thread, coalesced, after a Bluetooth audio device is
 *     added or removed, the App becomes active, or the device connection changes
 * CN: 蓝牙音频设备接入或断开、App 回到前台、设备连接状态变化后在主线程合并回调
 *
 * @return
 * EN: Observer token; keep it and pass it to removeChangeObserver:
 * CN: 监听令牌；需持有并在不用时传给 removeChangeObserver:
 */
+ (id<NSObject>)addChangeObserverWithHandler:(void (^)(void))handler;

/**
 * @brief Stop an observer created by addChangeObserverWithHandler:
 * @chinese 停止 addChangeObserverWithHandler: 创建的监听
 *
 * @param observer
 * EN: Observer token, nil is ignored
 * CN: 监听令牌，nil 时忽略
 */
+ (void)removeChangeObserver:(nullable id<NSObject>)observer;

/**
 * @brief Open this App's page in the system Settings
 * @chinese 打开系统设置中的本 App 页面
 */
+ (void)openAppSettings;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
