//
//  TopStepComDefines.h
//  Pods
//
//  Created by 磐石 on 2025/1/2.
//
//  文件说明:
//  该文件定义了TopStepComKit中使用的公共枚举类型，包括SDK类型、连接状态、指令状态和错误码等

#ifndef TopStepComDefines_h
#define TopStepComDefines_h

#import <Foundation/Foundation.h>

/**
 * @brief SDK type enumeration
 * @chinese SDK类型枚举
 *
 * @discussion
 * [EN]: Used to identify different types of SDK modules.
 *      Each type corresponds to a specific hardware platform.
 * [CN]: 用于标识不同类型的SDK模块。
 *      每种类型对应特定的硬件平台。
 */
typedef NS_ENUM(NSUInteger, TSSDKType) {
    /// 未知类型 （Unknown type）
    eTSSDKTypeUnknow = 0,
    /// 瑞昱SDK （Realtek SDK）
    eTSSDKTypeFIT,
    /// 恒玄SDK （BES SDK）
    eTSSDKTypeFW,
    /// 伸聚SDK （SJ SDK）
    eTSSDKTypeSJ,
    /// 魔样SDK （CRP SDK）
    eTSSDKTypeCRP,
    /// 优创意SDK （UTE SDK）
    eTSSDKTypeUTE,
    /// 拓步SDK （TPB SDK）
    eTSSDKTypeTPB
    
};

/**
 * @brief Command execution state
 * @chinese 指令执行状态
 *
 * @discussion
 * [EN]: Defines the possible states of command execution.
 *      Used for tracking command sending and result retrieval.
 * [CN]: 定义指令执行的可能状态。
 *      用于跟踪指令发送和结果获取。
 */
typedef NS_ENUM(NSUInteger, TSCommandState) {
    /// 指令发送成功 （Command sent successfully）
    eTSCommandSendSuccess = 0,
    /// 指令发送失败 （Command sending failed）
    eTSCommandSendFailed,
    /// 指令发送成功并获取结果 （Command sent and result received）
    eTSCommandGetResult
};



/**
 * @brief Unit system type
 * @chinese 单位系统类型
 *
 * @discussion
 * EN: Defines the overall unit system for measurements, primarily affecting length and weight units.
 * CN: 定义测量数据的整体单位系统，主要影响长度和重量单位。
 */
typedef NS_ENUM(NSInteger, TSUnitSystem) {
    /**
     * @brief Metric unit system
     * @chinese 公制单位系统
     */
    TSUnitSystemMetric = 0,
    /**
     * @brief Imperial unit system
     * @chinese 英制单位系统
     */
    TSUnitSystemImperial
};

/**
 * @brief Length unit type
 * @chinese 长度单位类型
 */
typedef NS_ENUM(NSInteger, TSLengthUnit) {
    /**
     * @brief Metric (kilometer/meter)
     * @chinese 公制（千米/米）
     */
    TSLengthUnitMetric = 0,
    /**
     * @brief Imperial (mile/foot)
     * @chinese 英制（英里/英尺）
     */
    TSLengthUnitImperial
};

/**
 * @brief Temperature unit type
 * @chinese 温度单位类型
 */
typedef NS_ENUM(NSInteger, TSTemperatureUnit) {
    /**
     * @brief Celsius
     * @chinese 摄氏度
     */
    TSTemperatureUnitCelsius = 0,
    /**
     * @brief Fahrenheit
     * @chinese 华氏度
     */
    TSTemperatureUnitFahrenheit
};

/**
 * @brief Weight unit type
 * @chinese 重量单位类型
 */
typedef NS_ENUM(NSInteger, TSWeightUnit) {
    /**
     * @brief Kilogram
     * @chinese 千克
     */
    TSWeightUnitKG = 0,
    /**
     * @brief Pound
     * @chinese 磅
     */
    TSWeightUnitLB
};

/**
 * @brief Time format type
 * @chinese 时间格式类型
 */
typedef NS_ENUM(NSInteger, TSTimeFormat) {
    /**
     * @brief 12-hour format
     * @chinese 12小时制
     */
    TSTimeFormat12Hour = 0,
    /**
     * @brief 24-hour format
     * @chinese 24小时制
     */
    TSTimeFormat24Hour
};

#endif /* TopStepComDefines_h */
