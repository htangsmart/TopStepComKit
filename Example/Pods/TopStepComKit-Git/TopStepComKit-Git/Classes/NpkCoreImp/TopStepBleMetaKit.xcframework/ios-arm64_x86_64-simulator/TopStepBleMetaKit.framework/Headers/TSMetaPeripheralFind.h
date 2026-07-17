//
//  TSMetaPeripheralFind.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "TSBusinessBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Callback block for peripheral finding phone
 * @chinese 外设查找手机的回调块
 */
typedef void (^TSMetaPeripheralFindPhoneBlock)(void);

/**
 * @brief Peripheral device finding management class
 * @chinese 外设查找管理类
 *
 * @discussion
 * [EN]: Manages peripheral device finding functionality including starting/stopping
 *        device search and handling phone finding features.
 * [CN]: 管理外设设备查找功能，包括开始/停止设备搜索和处理手机查找功能。
 */
@interface TSMetaPeripheralFind : TSBusinessBase

/**
 * @brief Begin finding peripheral device
 * @chinese 开始查找外设设备
 *
 * @param completion
 * [EN]: Completion callback block that returns success status and error information.
 * [CN]: 完成回调块，返回成功状态和错误信息。
 *
 * @discussion
 * [EN]: Initiates the process of finding the connected peripheral device.
 *        The device will start vibrating or making sounds to help locate it.
 * [CN]: 启动查找已连接外设设备的过程。
 *        设备将开始振动或发出声音以帮助定位。
 */
+ (void)beginFindPeripheral:(TSMetaCompletionBlock)completion;

/**
 * @brief Stop finding peripheral device
 * @chinese 停止查找外设设备
 *
 * @param completion
 * [EN]: Completion callback block that returns success status and error information.
 * [CN]: 完成回调块，返回成功状态和错误信息。
 *
 * @discussion
 * [EN]: Stops the peripheral device finding process.
 *        The device will stop vibrating or making sounds.
 * [CN]: 停止外设设备查找过程。
 *        设备将停止振动或发出声音。
 */
+ (void)stopFindPeripheral:(TSMetaCompletionBlock)completion;

/**
 * @brief Register callback for when peripheral has been found
 * @chinese 注册外设已被找到的回调
 *
 * @param peripheralHasBeenFound
 * [EN]: Callback block that will be triggered when the peripheral device is found.
 * [CN]: 当外设设备被找到时将触发的回调块。
 *
 * @discussion
 * [EN]: Registers a callback to be notified when the peripheral device
 *        has been successfully located by the user.
 * [CN]: 注册一个回调，当用户成功找到外设设备时通知。
 */
+ (void)registerPeripheralHasBeenFound:(TSMetaPeripheralFindPhoneBlock)peripheralHasBeenFound;

/**
 * @brief Register callback for peripheral finding phone
 * @chinese 注册外设查找手机的回调
 *
 * @param peripheralFindPhoneBlock
 * [EN]: Callback block that will be triggered when peripheral starts finding phone.
 * [CN]: 当外设开始查找手机时将触发的回调块。
 *
 * @discussion
 * [EN]: Registers a callback to be notified when the peripheral device
 *        starts the process of finding the connected phone.
 * [CN]: 注册一个回调，当外设设备开始查找已连接手机的过程时通知。
 */
+ (void)registerPeripheralFindPhone:(TSMetaPeripheralFindPhoneBlock)peripheralFindPhoneBlock;

/**
 * @brief Register callback for peripheral stopping phone finding
 * @chinese 注册外设停止查找手机的回调
 *
 * @param peripheralStopFindPhoneBlock
 * [EN]: Callback block that will be triggered when peripheral stops finding phone.
 * [CN]: 当外设停止查找手机时将触发的回调块。
 *
 * @discussion
 * [EN]: Registers a callback to be notified when the peripheral device
 *        stops the process of finding the connected phone.
 * [CN]: 注册一个回调，当外设设备停止查找已连接手机的过程时通知。
 */
+ (void)registerPeripheralStopFindPhone:(TSMetaPeripheralFindPhoneBlock)peripheralStopFindPhoneBlock;

/**
 * @brief Notify peripheral that phone has been found
 * @chinese 通知外设手机已被找到
 *
 * @param completion
 * [EN]: Completion callback block that returns success status and error information.
 * [CN]: 完成回调块，返回成功状态和错误信息。
 *
 * @discussion
 * [EN]: Sends a notification to the peripheral device that the phone
 *        has been found, which will stop the device's finding behavior.
 * [CN]: 向外设设备发送手机已被找到的通知，
 *        这将停止设备的查找行为。
 */
+ (void)notifyPeripheralPhoneHasBeenFound:(TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
