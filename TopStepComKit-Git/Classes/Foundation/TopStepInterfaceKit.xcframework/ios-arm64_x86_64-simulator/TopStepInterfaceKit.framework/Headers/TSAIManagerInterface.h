//
//  TSAIManagerInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/12.
//

#import "TSKitBaseInterface.h"
#import "TSAIDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI device status callback block type
 * @chinese AI设备状态回调块类型
 *
 * @param status
 * EN: AI device status type
 * CN: AI设备状态类型
 */
typedef void(^TSAIDeviceStatusBlock)(TSAIChatStatusType status);

/**
 * @brief AI device equalizer callback block type
 * @chinese AI设备均衡器回调块类型
 *
 * @param success
 * EN: Whether the query was successful
 * CN: 查询是否成功
 *
 * @param currentEQ
 * EN: Current equalizer preset
 * CN: 当前均衡器预设
 *
 * @param error
 * EN: Error information if query fails, nil on success
 * CN: 查询失败时的错误信息，成功时为nil
 */
typedef void(^TSAIDeviceEqualizerBlock)(BOOL success, TSAIDevicePresetEQ currentEQ, NSError * _Nullable error);

/**
 * @brief AI device noise reduction mode callback block type
 * @chinese AI设备降噪模式回调块类型
 *
 * @param success
 * EN: Whether the query was successful
 * CN: 查询是否成功
 *
 * @param mode
 * EN: Current noise reduction mode
 * CN: 当前降噪模式
 *
 * @param error
 * EN: Error information if query fails, nil on success
 * CN: 查询失败时的错误信息，成功时为nil
 */
typedef void(^TSAIDeviceNoiseReductionModeBlock)(BOOL success, TSAIDeviceNoiseReductionMode mode, NSError * _Nullable error);

/**
 * @brief AI device low latency mode callback block type
 * @chinese AI设备低延迟模式回调块类型
 *
 * @param success
 * EN: Whether the query was successful
 * CN: 查询是否成功
 *
 * @param mode
 * EN: Current low latency mode
 * CN: 当前低延迟模式
 *
 * @param error
 * EN: Error information if query fails, nil on success
 * CN: 查询失败时的错误信息，成功时为nil
 */
typedef void(^TSAIDeviceLowLatencyModeBlock)(BOOL success, TSAIDeviceLowLatencyMode mode, NSError * _Nullable error);

/**
 * @brief AI device status callback block type
 * @chinese AI设备状态回调块类型
 *
 * @param success
 * EN: Whether the query was successful
 * CN: 查询是否成功
 *
 * @param statusInfo
 * EN: AI device status information model, nil if error
 * CN: AI设备状态信息模型，错误时为nil
 *
 * @param error
 * EN: Error information if query fails, nil on success
 * CN: 查询失败时的错误信息，成功时为nil
 */
typedef void(^TSAIDeviceStatusInfoBlock)(BOOL success, TSAIDeviceStatusInfoModel * _Nullable statusInfo, NSError * _Nullable error);

/**
 * @brief AI device firmware version callback block type
 * @chinese AI设备固件版本回调块类型
 *
 * @param success
 * EN: Whether the query was successful
 * CN: 查询是否成功
 *
 * @param version
 * EN: Firmware version string, nil if error
 * CN: 固件版本字符串，错误时为nil
 *
 * @param error
 * EN: Error information if query fails, nil on success
 * CN: 查询失败时的错误信息，成功时为nil
 */
typedef void(^TSAIDeviceFirmwareVersionBlock)(BOOL success, NSString * _Nullable version, NSError * _Nullable error);

/**
 * @brief AI device find status info callback block type
 * @chinese AI设备查找状态信息回调块类型
 *
 * @param success
 * EN: Whether the query was successful
 * CN: 查询是否成功
 *
 * @param statusInfo
 * EN: AI device find status information model, nil if error
 * CN: AI设备查找状态信息模型，错误时为nil
 *
 * @param error
 * EN: Error information if query fails, nil on success
 * CN: 查询失败时的错误信息，成功时为nil
 */
typedef void(^TSAIDeviceFindStatusInfoBlock)(BOOL success, TSAIDeviceFindStatusInfoModel * _Nullable statusInfo, NSError * _Nullable error);

/**
 * @brief AI device find event callback block type
 * @chinese AI设备查找事件回调块类型
 *
 * @param findEvent
 * EN: Find event type
 * CN: 查找事件类型
 */
typedef void(^TSAIDeviceFindEventBlock)(TSAIDeviceFindEvent findEvent);

/**
 * @brief AI chat management interface protocol
 * @chinese AI聊天管理接口协议
 *
 * @discussion
 * [EN]: This protocol defines the interface for managing AI chat functionality on the device, including:
 * - Checking if device supports AI chat
 * - Sending audio messages to AI
 * - Receiving AI responses (text and audio)
 * - Managing chat sessions and conversations
 *
 * [CN]: 此协议定义了设备上AI聊天功能管理的接口，包括：
 * - 检查设备是否支持AI聊天
 * - 向AI发送音频消息
 * - 接收AI响应（文本和音频）
 * - 管理聊天会话和对话
 */
@protocol TSAIManagerInterface <TSKitBaseInterface>

/**
 * @brief Check if device supports AI chat
 * @chinese 检查设备是否支持AI聊天
 *
 * @return 
 * EN: YES if device supports AI chat, NO otherwise
 * CN: 如果设备支持AI聊天则返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Checks whether the current device supports AI chat functionality:
 * - Different device models may have different capabilities
 * - Use this method before attempting to use AI chat features
 * - Returns NO if device does not support AI chat
 *
 * [CN]: 检查当前设备是否支持AI聊天功能：
 * - 不同的设备型号可能有不同的能力
 * - 在使用AI聊天功能前使用此方法检查
 * - 如果设备不支持AI聊天，则返回NO
 */
- (BOOL)isAIDeviceAPISupported;


#pragma mark - AI Device EQ Mode

/**
 * @brief Query the current equalizer preset of the AI device
 * @chinese 查询AI设备当前均衡器预设
 *
 * @param completion
 * EN: Completion handler called with the query result
 * CN: 查询结果完成回调
 *
 * @discussion
 * [EN]: Queries the current equalizer preset setting of the AI device:
 * - Returns the current EQ preset (SoundEffect1-6)
 * - Used to initialize the EQ setting display in the app
 *
 * [CN]: 查询AI设备当前的均衡器预设设置：
 * - 返回当前EQ预设（音效1-6）
 * - 用于初始化应用中的EQ设置显示
 */
- (void)queryAIDeviceEqualizerWithCompletion:(_Nullable TSAIDeviceEqualizerBlock)completion;

/**
 * @brief Set the equalizer preset for the AI device
 * @chinese 设置AI设备的均衡器预设
 *
 * @param eq
 * EN: The equalizer preset to apply
 * CN: 要应用的均衡器预设
 *
 * @param completion
 * EN: Completion handler called when the operation completes
 * CN: 操作完成回调
 *
 * @discussion
 * [EN]: Sets the equalizer preset for the AI device:
 * - Applies the selected EQ preset (SoundEffect1-6)
 * - Changes take effect immediately
 * - Device will notify app when EQ changes from device side
 *
 * [CN]: 设置AI设备的均衡器预设：
 * - 应用选定的EQ预设（音效1-6）
 * - 更改立即生效
 * - 设备端更改EQ时会通知应用
 */
- (void)setAIDeviceEqualizer:(TSAIDevicePresetEQ)eq
                  completion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Register for AI device equalizer change notifications
 * @chinese 注册AI设备均衡器变化通知
 *
 * @param equalizerBlock
 * EN: Callback block that is triggered when device equalizer preset changes
 * CN: 设备均衡器预设变化时触发的回调块
 *
 * @discussion
 * [EN]: Monitors AI device equalizer preset changes:
 * - Only one listener is allowed at a time
 * - New registration will replace the previous listener
 * - Triggered when equalizer preset changes from device side
 *
 * [CN]: 监控AI设备均衡器预设变化：
 * - 同一时间只允许一个监听者
 * - 新的注册会替换之前的监听者
 * - 当设备端均衡器预设变化时触发
 */
- (void)registerAIDeviceEqualizerDidChanged:(void(^ _Nullable )(TSAIDevicePresetEQ latestEQ))equalizerBlock;

#pragma mark - AI Device Noise Reduction Mode

/**
 * @brief Query the current noise reduction mode of the AI device
 * @chinese 查询AI设备当前降噪模式
 *
 * @param completion
 * EN: Completion handler called with the query result
 * CN: 查询结果完成回调
 *
 * @discussion
 * [EN]: Queries the current noise reduction mode setting of the AI device:
 * - Returns the current mode (Off, On, Transparency)
 * - Used to initialize the noise reduction setting display in the app
 *
 * [CN]: 查询AI设备当前的降噪模式设置：
 * - 返回当前模式（关闭、打开、通透模式）
 * - 用于初始化应用中的降噪设置显示
 */
- (void)queryAIDeviceNoiseReductionModeWithCompletion:(_Nullable TSAIDeviceNoiseReductionModeBlock)completion;

/**
 * @brief Set the noise reduction mode for the AI device
 * @chinese 设置AI设备的降噪模式
 *
 * @param mode
 * EN: The noise reduction mode to apply
 * CN: 要应用的降噪模式
 *
 * @param completion
 * EN: Completion handler called when the operation completes
 * CN: 操作完成回调
 *
 * @discussion
 * [EN]: Sets the noise reduction mode for the AI device:
 * - Applies the selected mode (Off, On, Transparency)
 * - Changes take effect immediately
 * - Device will notify app when noise reduction mode changes from device side
 *
 * [CN]: 设置AI设备的降噪模式：
 * - 应用选定的模式（关闭、打开、通透模式）
 * - 更改立即生效
 * - 设备端更改降噪模式时会通知应用
 */
- (void)setAIDeviceNoiseReductionMode:(TSAIDeviceNoiseReductionMode)mode
                           completion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Register for AI device noise reduction mode change notifications
 * @chinese 注册AI设备降噪模式变化通知
 *
 * @param noiseReductionModeBlock
 * EN: Callback block that is triggered when device noise reduction mode changes
 * CN: 设备降噪模式变化时触发的回调块
 *
 * @discussion
 * [EN]: Monitors AI device noise reduction mode changes:
 * - Only one listener is allowed at a time
 * - New registration will replace the previous listener
 * - Triggered when noise reduction mode changes from device side
 *
 * [CN]: 监控AI设备降噪模式变化：
 * - 同一时间只允许一个监听者
 * - 新的注册会替换之前的监听者
 * - 当设备端降噪模式变化时触发
 */
- (void)registerAIDeviceNoiseReductionModeDidChanged:(void(^ _Nullable )(TSAIDeviceNoiseReductionMode latestMode))noiseReductionModeBlock;

#pragma mark - AI Device Low Latency Mode

/**
 * @brief Query the current low latency mode of the AI device
 * @chinese 查询AI设备当前低延迟模式
 *
 * @param completion
 * EN: Completion handler called with the query result
 * CN: 查询结果完成回调
 *
 * @discussion
 * [EN]: Queries the current low latency mode setting of the AI device:
 * - Returns the current mode (Off, On)
 * - Used to initialize the low latency setting display in the app
 *
 * [CN]: 查询AI设备当前的低延迟模式设置：
 * - 返回当前模式（关闭、开启）
 * - 用于初始化应用中的低延迟设置显示
 */
- (void)queryAIDeviceLowLatencyModeWithCompletion:(_Nullable TSAIDeviceLowLatencyModeBlock)completion;

/**
 * @brief Set the low latency mode for the AI device
 * @chinese 设置AI设备的低延迟模式
 *
 * @param mode
 * EN: The low latency mode to apply
 * CN: 要应用的低延迟模式
 *
 * @param completion
 * EN: Completion handler called when the operation completes
 * CN: 操作完成回调
 *
 * @discussion
 * [EN]: Sets the low latency mode for the AI device:
 * - Applies the selected mode (Off, On)
 * - Changes take effect immediately
 * - Device will notify app when low latency mode changes from device side
 *
 * [CN]: 设置AI设备的低延迟模式：
 * - 应用选定的模式（关闭、开启）
 * - 更改立即生效
 * - 设备端更改低延迟模式时会通知应用
 */
- (void)setAIDeviceLowLatencyMode:(TSAIDeviceLowLatencyMode)mode
                       completion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Register for AI device low latency mode change notifications
 * @chinese 注册AI设备低延迟模式变化通知
 *
 * @param lowLatencyModeBlock
 * EN: Callback block that is triggered when device low latency mode changes
 * CN: 设备低延迟模式变化时触发的回调块
 *
 * @discussion
 * [EN]: Monitors AI device low latency mode changes:
 * - Only one listener is allowed at a time
 * - New registration will replace the previous listener
 * - Triggered when low latency mode changes from device side
 *
 * [CN]: 监控AI设备低延迟模式变化：
 * - 同一时间只允许一个监听者
 * - 新的注册会替换之前的监听者
 * - 当设备端低延迟模式变化时触发
 */
- (void)registerAIDeviceLowLatencyModeDidChanged:(void(^ _Nullable )(TSAIDeviceLowLatencyMode latestMode))lowLatencyModeBlock;

#pragma mark - AI Device Status

/**
 * @brief Query the current status information of the AI device
 * @chinese 查询AI设备当前状态信息
 *
 * @param completion
 * EN: Completion handler called with the query result
 * CN: 查询结果完成回调
 *
 * @discussion
 * [EN]: Queries the current status information of the AI device:
 * - Returns connection status for left and right devices
 * - Returns in-case status for left and right devices
 * - Returns battery information for left and right devices
 * - Used to display real-time device status in the app
 *
 * [CN]: 查询AI设备当前的状态信息：
 * - 返回左右设备的连接状态
 * - 返回左右设备的在仓状态
 * - 返回左右设备的电池信息
 * - 用于在应用中显示实时设备状态
 */
- (void)queryAIDeviceStatusWithCompletion:(_Nullable TSAIDeviceStatusInfoBlock)completion;

#pragma mark - AI Device Firmware Version

/**
 * @brief Query the firmware version of the AI device
 * @chinese 查询AI设备的固件版本
 *
 * @param completion
 * EN: Completion handler called with the query result
 * CN: 查询结果完成回调
 *
 * @discussion
 * [EN]: Queries the firmware version of the AI device:
 * - Returns the firmware version string
 * - Used to display device firmware version in the app
 * - Can be used to check if firmware update is needed
 *
 * [CN]: 查询AI设备的固件版本：
 * - 返回固件版本字符串
 * - 用于在应用中显示设备固件版本
 * - 可用于检查是否需要固件更新
 */
- (void)queryAIDeviceFirmwareVersionWithCompletion:(_Nullable TSAIDeviceFirmwareVersionBlock)completion;

#pragma mark - AI Device Find

/**
 * @brief Query the find status information of the AI device
 * @chinese 查询AI设备的查找状态信息
 *
 * @param completion
 * EN: Completion handler called with the query result
 * CN: 查询结果完成回调
 *
 * @discussion
 * [EN]: Queries the find status information of the AI device:
 * - Returns find status for left and right devices
 * - Used to check if device is currently in finding mode
 *
 * [CN]: 查询AI设备的查找状态信息：
 * - 返回左右设备的查找状态
 * - 用于检查设备是否当前处于查找模式
 */
- (void)queryAIDeviceFindStatusInfoWithCompletion:(_Nullable TSAIDeviceFindStatusInfoBlock)completion;

/**
 * @brief Trigger the find AI device function for the specified side
 * @chinese 触发指定侧的AI设备查找功能
 *
 * @param side
 * EN: The side of the AI device to find (Left or Right)
 * CN: 要查找的AI设备侧（左或右）
 *
 * @param completion
 * EN: Completion handler called when the operation completes
 * CN: 操作完成回调
 *
 * @discussion
 * [EN]: Triggers the find function for the specified side of the AI device:
 * - Device will emit sound to help locate it
 * - Can find left device, right device, or both
 * - Use stopFindAIDeviceWithSide to stop the find function
 *
 * [CN]: 触发指定侧AI设备的查找功能：
 * - 设备会发出声音以帮助定位
 * - 可以查找左设备、右设备或两者
 * - 使用stopFindAIDeviceWithSide停止查找功能
 */
- (void)findAIDeviceWithSide:(TSAIDeviceSide)side
                  completion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Stop the find AI device function for the specified side
 * @chinese 停止指定侧的AI设备查找功能
 *
 * @param side
 * EN: The side of the AI device to stop finding (Left or Right)
 * CN: 要停止查找的AI设备侧（左或右）
 *
 * @param completion
 * EN: Completion handler called when the operation completes
 * CN: 操作完成回调
 *
 * @discussion
 * [EN]: Stops the find function for the specified side of the AI device:
 * - Device will stop emitting sound
 * - Can stop finding left device, right device, or both
 *
 * [CN]: 停止指定侧AI设备的查找功能：
 * - 设备会停止发出声音
 * - 可以停止查找左设备、右设备或两者
 */
- (void)stopFindAIDeviceWithSide:(TSAIDeviceSide)side
                      completion:(_Nullable TSCompletionBlock)completion;

/**
 * @brief Register for AI device find status change notifications
 * @chinese 注册AI设备查找状态变化通知
 *
 * @param findEventBlock
 * EN: Callback block that is triggered when device find status changes
 * CN: 设备查找状态变化时触发的回调块
 *
 * @discussion
 * [EN]: Monitors AI device find status changes:
 * - Only one listener is allowed at a time
 * - New registration will replace the previous listener
 * - Triggered when find status changes due to specific events
 * - Events include: FindLeft, FindRight, StopFindLeft, StopFindRight
 *
 * [CN]: 监控AI设备查找状态变化：
 * - 同一时间只允许一个监听者
 * - 新的注册会替换之前的监听者
 * - 当查找状态因特定事件变化时触发
 * - 事件包括：查找左设备、查找右设备、停止查找左设备、停止查找右设备
 */
- (void)registerAIDeviceFindStatusDidChanged:(_Nullable TSAIDeviceFindEventBlock)findEventBlock;

#pragma mark - AI-Chat Session Event & Delta Voice (Device Callbacks)

/**
 * @brief Notifies the app that the watch requests an AI-chat event.
 * @chinese 通知 App 手表请求了 AI 聊天事件
 *
 * @param event
 * EN: The AI chat session event (terminate / initiate with SCO / initiate with Opus)
 * CN: AI 聊天会话事件（结束 / 通过 SCO 发起 / 通过 Opus 发起）
 */
- (void)onAIChatSessionEvent:(TSAIDeviceChatSessionEvent)event;

/**
 * @brief Notifies that incremental voice data has been received during AI-chat conversation
 * @chinese 通知在 AI 聊天对话期间收到了增量语音数据
 *
 * @param deltaOpusVoiceData
 * EN: The incremental voice data in Opus format, may be nil
 * CN: Opus 格式的增量语音数据，可为 nil
 *
 * @param deltaVoiceData
 * EN: The decoded incremental voice data in PCM format (16000Hz sample rate, mono channel, 16-bit), may be nil
 * CN: 解码后的增量语音数据（PCM，16kHz 单声道 16bit），可为 nil
 */
- (void)onAIChatDeltaOpusVoiceData:(NSData *_Nullable)deltaOpusVoiceData decodedDeltaVoiceData:(NSData *_Nullable)deltaVoiceData;

/**
 * @brief Register for AI-chat session event notifications
 * @chinese 注册 AI 聊天会话事件通知
 *
 * @param block
 * EN: Callback when the watch requests an AI-chat event (terminate / initiate with SCO / Opus)
 * CN: 手表请求 AI 聊天事件时触发的回调
 */
- (void)registerOnAIChatSessionEvent:(void(^_Nullable)(TSAIDeviceChatSessionEvent event))block;

/**
 * @brief Register for incremental AI-chat voice data during conversation
 * @chinese 注册 AI 聊天对话期间的增量语音数据
 *
 * @param block
 * EN: Callback with delta Opus data and decoded PCM data (16000Hz, mono, 16-bit)
 * CN: 回调增量 Opus 数据与解码后的 PCM 数据（16kHz 单声道 16bit）
 */
- (void)registerOnAIChatDeltaOpusVoiceData:(void(^_Nullable)(NSData * _Nullable deltaOpusVoiceData, NSData * _Nullable deltaVoiceData))block;

#pragma mark - AI Bridge

/**
 * @brief Send AI bridge data to the device
 * @chinese 向设备发送 AI 桥接数据
 *
 * @param data
 * EN: The AI bridge data to send
 * CN: 要发送的 AI 桥接数据
 *
 * @discussion
 * [EN]: Sends AI bridge data to the device. The underlying implementation may use StarBurst AI or other AI backends; the interface is encapsulated so that the AI provider can be replaced without changing the API.
 * [CN]: 向设备发送 AI 桥接数据。底层实现可使用 StarBurst AI 或其他 AI 方案，接口已做封装以便更换 AI 提供方而不影响 API。
 */
- (void)sendAIBridgeData:(NSData *)data;

/**
 * @brief Register for AI bridge data received from device
 * @chinese 注册接收设备上报的 AI 桥接数据
 *
 * @param block
 * EN: Callback block when AI bridge data is received from device
 * CN: 从设备收到 AI 桥接数据时触发的回调块
 *
 * @discussion
 * [EN]: SDK callback: when device sends AI bridge data, the registered block will be invoked. Implementation may be StarBurst or other AI; the interface is provider-agnostic.
 * [CN]: SDK 回调：当设备发送 AI 桥接数据时，将调用已注册的回调块。实现可以是 StarBurst 或其他 AI，接口与具体提供方解耦。
 */
- (void)registerOnAIBridgeDataReceived:(void(^ _Nullable)(NSData *data))block;

#pragma mark - WP Auth Bridge

/**
 * @brief Send WP auth bridge data to the device (passthrough)
 * @chinese 向设备透传 WP 认证桥接数据
 *
 * @param data
 * EN: The WP auth bridge data to send (e.g. WeChat Pay auth, offline voice auth passthrough)
 * CN: 要透传的认证桥接数据（如微信支付认证、离线语音鉴权透传等）
 *
 * @discussion
 * [EN]: Passthrough data to the device. Historically used for WeChat Pay authentication; the same channel is also used for offline voice authentication passthrough.
 * [CN]: 透传数据到设备端。原用于微信支付认证；该通道也用于离线语音鉴权透传等。
 */
- (void)sendWPAuthBridgeData:(NSData *)data;

/**
 * @brief Register for WP auth bridge data received from device
 * @chinese 注册接收设备上报的 WP 认证桥接数据
 *
 * @param block
 * EN: Callback when auth bridge data is received from device (e.g. offline voice auth passthrough)
 * CN: 从设备收到认证桥接数据时触发的回调（如离线语音鉴权透传数据）
 *
 * @discussion
 * [EN]: SDK callback: when device sends auth bridge data, the registered block will be invoked. Some devices perform local auth on-device and will not trigger this callback.
 * [CN]: SDK 回调：当设备上报认证桥接数据时，将调用已注册的回调。部分设备在端侧本地鉴权，不会触发此回调。
 */
- (void)registerOnWPAuthBridgeDataReceived:(void(^ _Nullable)(NSData *data))block;

#pragma mark - AI-Chat (Device Request Callbacks)

/**
 * @brief Register for device request to initiate AI-Chat session
 * @chinese 注册设备请求发起 AI 聊天会话的回调
 *
 * @param block
 * EN: Callback block when device requests to initiate AI-Chat
 * CN: 设备请求发起 AI 聊天时触发的回调块
 *
 * @discussion
 * [EN]: SDK callback: when device requests to initiate AI-Chat session, the registered block will be invoked.
 * [CN]: SDK 回调：当设备请求发起 AI 聊天会话时，将调用已注册的回调块。
 */
- (void)registerOnRequestInitiateAIChat:(void(^ _Nullable)(void))block;

/**
 * @brief Register for device request to terminate AI-Chat session
 * @chinese 注册设备请求结束 AI 聊天会话的回调
 *
 * @param block
 * EN: Callback block when device requests to terminate AI-Chat
 * CN: 设备请求结束 AI 聊天时触发的回调块
 *
 * @discussion
 * [EN]: SDK callback: when device requests to terminate current AI-Chat session, the registered block will be invoked.
 * [CN]: SDK 回调：当设备请求结束当前 AI 聊天会话时，将调用已注册的回调块。
 */
- (void)registerOnRequestTerminateAIChat:(void(^ _Nullable)(void))block;

// to notify the device the Al chat session initiate failed or already terminated.
- (void)reportAIChatSessionInitiateFailedOrTerminated:(_Nullable TSCompletionBlock)completion;

// to notify the device the Al chat session initiated success, if the API callback parameter deviceEncounteredException is true, the app must terminate the Al chat.
- (void)reportAIChatSessionInitiateSuccess:(void (^_Nullable) (BOOL success, BOOL deviceEncounteredException, NSError *_Nullable error))completion;

#pragma mark - AI-Chat (语音唤醒)

/// 是否支持设备端语音唤醒
- (BOOL)allowVoiceWakeUpOnDevice;

/// Enable or disable on-device voice wake-up.
/// - Parameters:
///   - enabled: Pass `YES` to enable wake-up, `NO` to disable it.
///   - completion: The closure invoked when the operation finishes.
///     - success: `YES` if the command was accepted, `NO` otherwise.
///     - error: An error object on failure, `nil` on success.
- (void)setOnDeviceVoiceWakeUpEnabled:(BOOL)enabled
                           completion:(TSCompletionBlock _Nullable)completion;

/// Query the current enable state of on-device voice wake-up.
/// - Parameters:
///   - completion: The closure invoked with the query result.
///     - success: `YES` if the query succeeded, `NO` otherwise.
///     - enableState: The current enable state.
///     - error: An error object on failure, `nil` on success.
- (void)queryOnDeviceVoiceWakeUpEnableStateWithCompletion:(void (^_Nullable)(BOOL success,
                                                                             TSAIEnableState enableState,
                                                                             NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
