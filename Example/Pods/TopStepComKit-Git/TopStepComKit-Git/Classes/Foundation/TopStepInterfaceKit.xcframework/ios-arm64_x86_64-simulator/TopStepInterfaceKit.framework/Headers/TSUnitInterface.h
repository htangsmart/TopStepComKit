//
//  TSUnitInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Unit management interface
 * @chinese 单位管理接口
 *
 * @discussion
 * EN: This interface defines all operations related to unit settings, including:
 *     1. Length unit (metric/imperial)
 *     2. Temperature unit (Celsius/Fahrenheit)
 *     3. Weight unit (KG/LB)
 *     4. Time format (12/24 hour)
 *     5. Overall unit system (metric/imperial)
 * CN: 该接口定义了与单位设置相关的所有操作，包括：
 *     1. 长度单位（公制/英制）
 *     2. 温度单位（摄氏度/华氏度）
 *     3. 重量单位（公斤/磅）
 *     4. 时间格式（12/24小时制）
 *     5. 整体单位系统（公制/英制）
 */
@protocol TSUnitInterface <TSKitBaseInterface>

#pragma mark - Length Unit

/**
 * @brief Set length unit
 * @chinese 设置长度单位
 *
 * @param unit
 * EN: Length unit type (metric/imperial)
 * CN: 长度单位类型（公制/英制）
 *
 * @param completion
 * EN: Completion callback
 * CN: 设置完成回调
 *
 * @discussion
 * EN: Set the length unit for distance display
 *     - Metric: kilometer/meter
 *     - Imperial: mile/foot
 * CN: 设置距离显示的长度单位
 *     - 公制：千米/米
 *     - 英制：英里/英尺
 */
- (void)setLengthUnit:(TSLengthUnit)unit
           completion:(TSCompletionBlock)completion;

/**
 * @brief Get current length unit
 * @chinese 获取当前长度单位
 *
 * @param completion
 * EN: Completion callback with current length unit and error if any
 * CN: 完成回调，返回当前长度单位和错误信息（如果有）
 */
- (void)getCurrentLengthUnit:(void(^)(TSLengthUnit unit, NSError * _Nullable error))completion;

#pragma mark - Temperature Unit

/**
 * @brief Set temperature unit
 * @chinese 设置温度单位
 *
 * @param unit
 * EN: Temperature unit type (Celsius/Fahrenheit)
 * CN: 温度单位类型（摄氏度/华氏度）
 *
 * @param completion
 * EN: Completion callback
 * CN: 设置完成回调
 */
- (void)setTemperatureUnit:(TSTemperatureUnit)unit
                completion:(TSCompletionBlock)completion;

/**
 * @brief Get current temperature unit
 * @chinese 获取当前温度单位
 *
 * @param completion
 * EN: Completion callback with current temperature unit and error if any
 * CN: 完成回调，返回当前温度单位和错误信息（如果有）
 */
- (void)getCurrentTemperatureUnit:(void(^)(TSTemperatureUnit unit, NSError * _Nullable error))completion;

#pragma mark - Weight Unit

/**
 * @brief Set weight unit
 * @chinese 设置重量单位
 *
 * @param unit
 * EN: Weight unit type (KG/LB)
 * CN: 重量单位类型（公斤/磅）
 *
 * @param completion
 * EN: Completion callback
 * CN: 设置完成回调
 */
- (void)setWeightUnit:(TSWeightUnit)unit
           completion:(TSCompletionBlock)completion;

/**
 * @brief Get current weight unit
 * @chinese 获取当前重量单位
 *
 * @param completion
 * EN: Completion callback with current weight unit and error if any
 * CN: 完成回调，返回当前重量单位和错误信息（如果有）
 */
- (void)getCurrentWeightUnit:(void(^)(TSWeightUnit unit, NSError * _Nullable error))completion;

#pragma mark - Time Format

/**
 * @brief Set time format
 * @chinese 设置时间格式
 *
 * @param format
 * EN: Time format type (12/24 hour)
 * CN: 时间格式类型（12/24小时制）
 *
 * @param completion
 * EN: Completion callback
 * CN: 设置完成回调
 */
- (void)setTimeFormat:(TSTimeFormat)format
           completion:(TSCompletionBlock)completion;

/**
 * @brief Get current time format
 * @chinese 获取当前时间格式
 *
 * @param completion
 * EN: Completion callback with current time format and error if any
 * CN: 完成回调，返回当前时间格式和错误信息（如果有）
 */
- (void)getCurrentTimeFormat:(void(^)(TSTimeFormat format, NSError * _Nullable error))completion;

#pragma mark - Unit System

/**
 * @brief Set unit system
 * @chinese 设置单位系统
 *
 * @param system
 * EN: Unit system type (metric/imperial)
 * CN: 单位系统类型（公制/英制）
 *
 * @param completion
 * EN: Completion callback
 * CN: 设置完成回调
 *
 * @note
 * [EN]: This method sets both the length and weight units based on the provided unit system.
 * [CN]: 此方法根据提供的单位系统同时设置长度单位和重量单位。
 *
 * @note
 * [EN]: If using this method, avoid using individual length and weight unit setters/getters to maintain consistency.
 * [CN]: 如果使用此方法，为保持一致性，请避免使用单独的长度和重量单位设置/获取方法。
 */
- (void)setUnitSystem:(TSUnitSystem)system
           completion:(TSCompletionBlock)completion;

/**
 * @brief Get current unit system
 * @chinese 获取当前单位系统
 *
 * @param completion
 * EN: Completion callback with current unit system and error if any.
 * CN: 完成回调，返回当前单位系统和错误信息（如果有）。
 *
 * @note
 * [EN]: If using this method, avoid using individual length and weight unit setters/getters to maintain consistency.
 * [CN]: 如果使用此方法，为保持一致性，请避免使用单独的长度和重量单位设置/获取方法。
 */
- (void)getUnitSystemCompletion:(void(^)(TSUnitSystem system, NSError * _Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
