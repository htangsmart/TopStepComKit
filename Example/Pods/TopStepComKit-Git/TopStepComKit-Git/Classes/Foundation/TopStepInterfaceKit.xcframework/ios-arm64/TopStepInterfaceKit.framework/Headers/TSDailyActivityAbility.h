//
//  TSDailyActivityAbility.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/5.
//

#import <Foundation/Foundation.h>
#import "TSDailyActivityInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily activity ability class (fine-grained capability)
 * @chinese 每日活动能力类（细粒度能力）
 *
 * @discussion
 * [EN]: Manages which specific daily activity types (step count, exercise duration, etc.) 
 *       are supported and displayed by the device. This is fine-grained capability 
 *       under the DailyActivity feature module.
 *       
 *       The device typically supports displaying up to 3 activity types in the main 
 *       interface rings. Common types include steps, exercise duration, activity count,
 *       distance, and calories.
 * 
 * [CN]: 管理设备支持并显示哪些具体的每日活动类型（步数、锻炼时长等）。
 *       这是每日活动功能模块下的细粒度能力。
 *       
 *       设备通常支持在主界面三环中显示最多3种活动类型。
 *       常见类型包括步数、锻炼时长、活动次数、距离和卡路里。
 *
 * @note
 * [EN]: This detail is only valid when featureAbility.isSupportDailyActivity is YES.
 *       The first 3 types in the array are typically shown in the main interface rings.
 *       Default configuration is [1, 2, 3] representing steps, exercise duration, and activity count.
 * [CN]: 只有当 featureAbility.isSupportDailyActivity 为 YES 时，此详细信息才有效。
 *       数组中的前3个类型通常在主界面三环中显示。
 *       默认配置为 [1, 2, 3]，分别代表步数、锻炼时长和活动次数。
 */
@interface TSDailyActivityAbility : NSObject

#pragma mark - Initialization

/**
 * @brief Initialize with default activity types (steps, exercise duration, activity count)
 * @chinese 使用默认活动类型初始化（步数、锻炼时长、活动次数）
 */
- (instancetype)init;

/**
 * @brief Initialize with original activity support data from device
 * @chinese 使用从设备获取的原始活动支持数据初始化
 *
 * @param originData 
 * EN: Original activity support data from device (typically 3 bytes, each byte represents an activity type).
 *     The ability will automatically parse this data to determine which activity types are supported.
 * CN: 从设备获取的原始活动支持数据（通常为3字节，每个字节代表一个活动类型）。
 *     能力类将自动解析此数据以确定支持哪些活动类型。
 *
 * @return 
 * EN: Initialized instance with parsed activity type support information
 * CN: 初始化的实例，包含解析后的活动类型支持信息
 *
 * @discussion
 * [EN]: This is the designated initializer. The class will internally parse the raw data
 *       and convert it to an array of activity type IDs. The original data is preserved
 *       for debugging and logging purposes.
 *       For example: data <01 02 03> will be parsed to [1, 2, 3].
 * [CN]: 这是指定的初始化方法。该类将在内部解析原始数据并将其转换为活动类型ID数组。
 *       原始数据会被保留用于调试和日志记录。
 *       例如：数据 <01 02 03> 将被解析为 [1, 2, 3]。
 */
- (instancetype)initWithOriginData:(nullable NSData *)originData NS_DESIGNATED_INITIALIZER;

#pragma mark - Factory Methods

/**
 * @brief Create instance with original activity support data from device
 * @chinese 使用从设备获取的原始活动支持数据创建实例
 *
 * @param originData 
 * EN: Original activity support data from device
 * CN: 从设备获取的原始活动支持数据
 *
 * @return 
 * EN: New instance with parsed activity type support information
 * CN: 新实例，包含解析后的活动类型支持信息
 */
+ (instancetype)abilityWithOriginData:(nullable NSData *)originData;

#pragma mark - Query Methods

/**
 * @brief Check if a specific activity type is supported
 * @chinese 检查是否支持特定的活动类型
 *
 * @param type 
 * EN: The activity type to check
 * CN: 要检查的活动类型
 *
 * @return 
 * EN: YES if the activity type is supported, NO otherwise
 * CN: 如果支持该活动类型返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Checks if the specified activity type is in the supported types array.
 * [CN]: 检查指定的活动类型是否在支持的类型数组中。
 */
- (BOOL)isSupportActivityType:(TSDailyActivityType)type;

/**
 * @brief Get all supported activity types
 * @chinese 获取所有支持的活动类型
 *
 * @return 
 * EN: Array of NSNumber (TSDailyActivityType) values that are supported
 * CN: 支持的 NSNumber (TSDailyActivityType) 值数组
 *
 * @discussion
 * [EN]: Returns an array containing all activity types that are supported by the device.
 *       The array maintains the order as configured on the device.
 * [CN]: 返回包含设备支持的所有活动类型的数组。
 *       数组保持设备上配置的顺序。
 */
- (NSArray<NSNumber *> *)allSupportedActivityTypes;

/**
 * @brief Get the primary activity types shown in main interface rings
 * @chinese 获取主界面三环显示的主要活动类型
 *
 * @return 
 * EN: Array of up to 3 activity types shown in the main interface (typically the first 3)
 * CN: 主界面显示的最多3个活动类型数组（通常是前3个）
 *
 * @discussion
 * [EN]: Returns the first 3 activity types from the supported types array.
 *       These are the types displayed in the main interface activity rings.
 * [CN]: 返回支持的类型数组中的前3个活动类型。
 *       这些是在主界面活动环中显示的类型。
 */
- (NSArray<NSNumber *> *)primaryActivityTypes;

/**
 * @brief Get count of supported activity types
 * @chinese 获取支持的活动类型数量
 *
 * @return 
 * EN: Number of supported activity types (maximum 3)
 * CN: 支持的活动类型数量（最多3个）
 */
- (NSInteger)supportedActivityCount;

/**
 * @brief Check if any activity type is supported
 * @chinese 检查是否支持任何活动类型
 *
 * @return 
 * EN: YES if at least one activity type is supported, NO otherwise
 * CN: 如果至少支持一种活动类型返回YES，否则返回NO
 */
- (BOOL)hasAnyActivitySupport;

/**
 * @brief Get supported activity types as readable string array
 * @chinese 获取支持的活动类型的可读字符串数组
 *
 * @return 
 * EN: Array of activity type names (e.g., "Step Count", "Exercise Duration", "Activity Count")
 * CN: 活动类型名称数组（如 "步数", "锻炼时长", "活动次数"）
 */
- (NSArray<NSString *> *)supportedActivityTypeNames;

@end

NS_ASSUME_NONNULL_END
