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
 * @brief Length unit type
 * @chinese 长度单位类型
 */
typedef NS_ENUM(NSInteger, TSMeasureUnit) {
    /** 公制 */
    TSMeasureUnitMetric = 0,
    /** 英制 */
    TSMeasureUnitImperial
};

/**
 * @brief Length unit type
 * @chinese 长度单位类型
 */
typedef NS_ENUM(NSInteger, TSLengthUnit) {
    /** 公制（千米/米） */
    TSLengthUnitMetric = 0,
    /** 英制（英里/英尺） */
    TSLengthUnitImperial
};

/**
 * @brief Temperature unit type
 * @chinese 温度单位类型
 */
typedef NS_ENUM(NSInteger, TSTemperatureUnit) {
    /** 摄氏度 */
    TSTemperatureUnitCelsius = 0,
    /** 华氏度 */
    TSTemperatureUnitFahrenheit
};

/**
 * @brief Weight unit type
 * @chinese 重量单位类型
 */
typedef NS_ENUM(NSInteger, TSWeightUnit) {
    /** 公斤 */
    TSWeightUnitKG = 0,
    /** 磅 */
    TSWeightUnitLB
};

/**
 * @brief Time format type
 * @chinese 时间格式类型
 */
typedef NS_ENUM(NSInteger, TSTimeFormat) {
    /** 12小时制 */
    TSTimeFormat12Hour = 0,
    /** 24小时制 */
    TSTimeFormat24Hour
};


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
 * CN: 该接口定义了与单位设置相关的所有操作，包括：
 *     1. 长度单位（公制/英制）
 *     2. 温度单位（摄氏度/华氏度）
 *     3. 重量单位（公斤/磅）
 *     4. 时间格式（12/24小时制）
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
           completion:(nullable TSCompletionBlock)completion;

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
                completion:(nullable TSCompletionBlock)completion;

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
           completion:(nullable TSCompletionBlock)completion;

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
           completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Get current time format
 * @chinese 获取当前时间格式
 * 
 * @param completion 
 * EN: Completion callback with current time format and error if any
 * CN: 完成回调，返回当前时间格式和错误信息（如果有）
 */
- (void)getCurrentTimeFormat:(void(^)(TSTimeFormat format, NSError * _Nullable error))completion;

#pragma mark TODO: 须实现
-(void)getMetricImperial:(void(^)(TSMeasureUnit unit , NSError *_Nullable error))completion;

- (void)setUnit:(TSMeasureUnit)unit
           completion:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
