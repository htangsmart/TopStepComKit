//
//  TSMessageAbility.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/5.
//

#import <Foundation/Foundation.h>
#import "TSMessageDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Message notification ability class (fine-grained capability)
 * @chinese 消息通知能力类（细粒度能力）
 *
 * @discussion
 * [EN]: Manages which specific message types (SMS, QQ, WeChat, etc.) 
 *       are supported by the device. This is fine-grained capability 
 *       under the AppNotifications feature module.
 *       
 *       This class provides a clean interface for checking message type support
 *       without exposing internal implementation details. All internal data
 *       (bit flags, raw data) are encapsulated and accessed through methods.
 * 
 * [CN]: 管理设备支持哪些具体的消息类型（SMS、QQ、微信等）。
 *       这是应用通知功能模块下的细粒度能力。
 *       
 *       此类提供了一个简洁的接口来检查消息类型支持情况，
 *       而不暴露内部实现细节。所有内部数据（位标志、原始数据）
 *       都被封装，并通过方法访问。
 *
 * @note
 * [EN]: This detail is only valid when featureAbility.isSupportAppNotifications is YES.
 *       Not all device platforms provide detailed message type support information.
 *       For debugging, use debugDescription property to view internal details.
 * [CN]: 只有当 featureAbility.isSupportAppNotifications 为 YES 时，此详细信息才有效。
 *       并非所有设备平台都提供详细的消息类型支持信息。
 *       调试时，使用 debugDescription 属性查看内部细节。
 */
@interface TSMessageAbility : NSObject

#pragma mark - Initialization

/**
 * @brief Unavailable - use factory method instead
 * @chinese 不可用 - 请使用工厂方法
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Unavailable - use factory method instead
 * @chinese 不可用 - 请使用工厂方法
 */
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - Factory Methods

/**
 * @brief Create instance with converted message types (for platforms that need mapping)
 * @chinese 使用转换后的消息类型创建实例（用于需要映射的平台）
 *
 * @param originData 
 * EN: Original message support data from device (for debugging/logging)
 * CN: 从设备获取的原始消息支持数据（用于调试/日志）
 *
 * @param convertedTypes 
 * EN: Converted message type index set (already mapped to TSMessageType enum values)
 * CN: 转换后的消息类型索引集合（已映射到TSMessageType枚举值）
 *
 * @return 
 * EN: New instance with specified message type support
 * CN: 新实例，包含指定的消息类型支持
 *
 * @discussion
 * [EN]: This method is used for platforms where the device protocol's bit mapping
 *       differs from TSMessageType enum values. The platform adapter should handle
 *       the conversion and pass the converted index set directly.
 * [CN]: 此方法用于设备协议的位映射与TSMessageType枚举值不同的平台。
 *       平台适配器应处理转换并直接传递转换后的索引集合。
 */
+ (instancetype)abilityWithOriginData:(nullable NSData *)originData 
                       convertedTypes:(NSIndexSet *)convertedTypes;

#pragma mark - Query Methods

/**
 * @brief Check if a specific message type is supported
 * @chinese 检查是否支持特定的消息类型
 *
 * @param type 
 * EN: The message type to check
 * CN: 要检查的消息类型
 *
 * @return 
 * EN: YES if the message type is supported, NO otherwise
 * CN: 如果支持该消息类型返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Checks the supportedMessageTypes flags to determine if the specific
 *       message type is supported by the device.
 * [CN]: 检查 supportedMessageTypes 标志以确定设备是否支持该特定消息类型。
 */
- (BOOL)isSupportMessageType:(TSMessageType)type;

/**
 * @brief Get all supported message types
 * @chinese 获取所有支持的消息类型
 *
 * @return 
 * EN: Array of NSNumber (TSMessageType) values that are supported
 * CN: 支持的 NSNumber (TSMessageType) 值数组
 *
 * @discussion
 * [EN]: Returns an array containing all message types that are supported
 *       by the device according to the capability flags.
 *       The array is sorted by message type value.
 * [CN]: 返回包含所有根据能力标志设备支持的消息类型的数组。
 *       数组按消息类型值排序。
 */
- (NSArray<NSNumber *> *)allSupportedMessageTypes;

/**
 * @brief Get count of supported message types
 * @chinese 获取支持的消息类型数量
 *
 * @return 
 * EN: Number of supported message types
 * CN: 支持的消息类型数量
 */
- (NSInteger)supportedMessageCount;

/**
 * @brief Check if any message type is supported
 * @chinese 检查是否支持任何消息类型
 *
 * @return 
 * EN: YES if at least one message type is supported, NO otherwise
 * CN: 如果至少支持一种消息类型返回YES，否则返回NO
 */
- (BOOL)hasAnyMessageSupport;

/**
 * @brief Get supported message types as readable string array
 * @chinese 获取支持的消息类型的可读字符串数组
 *
 * @return 
 * EN: Array of message type names (e.g., "SMS", "WeChat", "QQ")
 * CN: 消息类型名称数组（如 "SMS", "WeChat", "QQ"）
 */
- (NSArray<NSString *> *)supportedMessageTypeNames;

@end

NS_ASSUME_NONNULL_END
