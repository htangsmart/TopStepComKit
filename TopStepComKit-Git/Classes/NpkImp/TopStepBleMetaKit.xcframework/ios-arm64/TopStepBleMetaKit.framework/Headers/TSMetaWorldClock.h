//
//  TSMetaWorldClock.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 世界时钟操作完成回调
 * @chinese 世界时钟操作完成时的回调
 *
 * @param worldClockList 世界时钟列表数据，成功时不为nil
 *        EN: World clock list data, not nil when successful
 *        CN: 世界时钟列表数据，成功时不为nil
 *
 * @param error 错误信息，成功时为nil
 *        EN: Error information, nil when successful
 *        CN: 错误信息，成功时为nil
 */
typedef void(^TSWorldClocksCompletionBlock)(TSMetaWorldClockList * _Nullable worldClockList, NSError * _Nullable error);

@interface TSMetaWorldClock : TSBusinessBase

/**
 * @brief 获取所有世界时钟
 * @chinese 从设备获取当前设置的世界时钟列表
 *
 * @param completion 完成回调，返回世界时钟列表或错误信息
 *        EN: Completion callback with world clock list or error information
 *        CN: 完成回调，返回世界时钟列表或错误信息
 *
 * @discussion
 * EN: Retrieves the current world clock list from the connected device.
 *     The callback will return a WorldClockList object containing all configured world clocks on success,
 *     or an error on failure.
 * CN: 从已连接的设备获取当前的世界时钟列表。
 *     成功时回调将返回包含所有已配置世界时钟的WorldClockList对象，失败时返回错误信息。
 */
+ (void)fetchAllWorldClocksCompletion:(TSWorldClocksCompletionBlock _Nullable)completion;

/**
 * @brief 设置世界时钟列表
 * @chinese 向设备设置世界时钟列表
 *
 * @param worldClockList 要设置的世界时钟列表
 *        EN: World clock list to be set
 *        CN: 要设置的世界时钟列表
 *
 * @param completion 完成回调，返回设置结果或错误信息
 *        EN: Completion callback with setting result or error information
 *        CN: 完成回调，返回设置结果或错误信息
 *
 * @discussion
 * EN: Sets the world clock list to the connected device.
 *     The device will replace existing world clocks with the provided list.
 *     Use empty list to clear all world clocks.
 * CN: 向已连接的设备设置世界时钟列表。
 *     设备将用提供的列表替换现有世界时钟。
 *     使用空列表可清除所有世界时钟。
 */
+ (void)pushAllWorldClocks:(TSMetaWorldClockList * _Nullable)worldClockList completion:(TSMetaCompletionBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
