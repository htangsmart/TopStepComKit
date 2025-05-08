//
//  TSPeripheralFindInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/10.
//

#import "TSKitBaseInterface.h"



/**
 * @brief Callback when device initiates finding iPhone
 * @chinese 设备查找iPhone的回调
 * 
 * @discussion 
 * EN: This callback is triggered when the device initiates a request to find iPhone
 * CN: 当设备发起查找iPhone的请求时，此回调会被触发
 */
typedef void (^PeripheralFindPhoneBlock)(void);

/**
 * @brief Device finding interface protocol
 * @chinese 设备查找接口协议
 * 
 * @discussion 
 * EN: This protocol defines all methods for mutual finding between iPhone and peripheral devices
 * CN: 该协议定义了iPhone与外围设备之间互相查找的所有方法
 */
@protocol TSPeripheralFindInterface <TSKitBaseInterface>

/**
 * @brief iPhone starts finding peripheral device
 * @chinese iPhone开始查找外围设备
 * 
 * @param completion 
 * EN: Callback when command sending is completed
 * CN: 指令发送完成的回调
 * 
 * @discussion 
 * EN: When iPhone initiates a find device request, completion is called immediately after sending the command.
 *     To receive device response notifications, you need to register a callback using registerPeripheralHasBeenFoundBlock.
 * CN: 当iPhone发起查找设备请求时，completion会在指令发送后立即回调。
 *     如需接收设备响应通知，需要使用registerPeripheralHasBeenFoundBlock注册回调。
 */
- (void)beginFindPeripheralCompletion:(TSCompletionBlock)completion;

/**
 * @brief iPhone stops finding peripheral device
 * @chinese iPhone停止查找外围设备
 * 
 * @param completion 
 * EN: Callback when stop finding operation is completed
 * CN: 停止查找操作完成的回调
 * 
 * @discussion 
 * EN: Actively end iPhone's device finding operation
 * CN: 主动结束iPhone对设备的查找操作
 */
- (void)stopFindPeripheralCompletion:(TSCompletionBlock)completion;

/**
 * @brief Register callback for when peripheral device has been found
 * @chinese 注册外围设备已被找到的回调
 * 
 * @param peripheralHasBeenFound 
 * EN: Callback triggered when device responds to find request
 * CN: 设备响应查找请求时的回调
 * 
 * @discussion 
 * EN: This callback will be triggered when the device receives and responds to the find request initiated by beginFindPeripheralCompletion.
 *     The callback should be registered before calling beginFindPeripheralCompletion.
 * CN: 当设备收到并响应由beginFindPeripheralCompletion发起的查找请求时，此回调会被触发。
 *     应在调用beginFindPeripheralCompletion之前注册此回调。
 */
- (void)registerPeripheralHasBeenFoundBlock:(TSCompletionBlock)peripheralHasBeenFound;

/**
 * @brief Notify device that iPhone has been found
 * @chinese 通知设备iPhone已被找到
 * 
 * @param completion 
 * EN: Callback when notification operation is completed
 * CN: 通知操作完成的回调
 * 
 * @discussion 
 * EN: When device is finding iPhone, use this method to notify device that iPhone has been found
 * CN: 当设备在查找iPhone时，通过此方法通知设备iPhone已经被找到
 */
- (void)notifyPeripheralPhoneHasBeenFoundCompletion:(TSCompletionBlock)completion;

/**
 * @brief Register listener for device finding iPhone
 * @chinese 注册设备查找iPhone的监听
 * 
 * @param peripheralFindPhoneBlock 
 * EN: Callback when device initiates finding iPhone
 * CN: 设备发起查找iPhone时的回调
 * 
 * @discussion 
 * EN: When device initiates a request to find iPhone, peripheralFindPhoneBlock will be called
 * CN: 当设备发起查找iPhone的请求时，peripheralFindPhoneBlock会被调用
 */
- (void)registerPeripheralFindPhone:(PeripheralFindPhoneBlock)peripheralFindPhoneBlock;

/**
 * @brief Register listener for device stopping to find iPhone
 * @chinese 注册设备停止查找iPhone的监听
 * 
 * @param peripheralStopFindPhoneBlock 
 * EN: Callback when device stops finding iPhone
 * CN: 设备停止查找iPhone时的回调
 * 
 * @discussion 
 * EN: When device actively stops finding iPhone, peripheralStopFindPhoneBlock will be called
 * CN: 当设备主动停止查找iPhone时，peripheralStopFindPhoneBlock会被调用
 */
- (void)registerPeripheralStopFindPhone:(PeripheralFindPhoneBlock)peripheralStopFindPhoneBlock;

@end

