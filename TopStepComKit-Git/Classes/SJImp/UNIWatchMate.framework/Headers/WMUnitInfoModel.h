//
//  WMUnitInfoModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 长度单位 （Unit of length）
typedef NS_ENUM(NSInteger, LengthUnit) {
    /// 公里 （kilometre）
    LengthUnitKM,
    /// 英里 （mile）
    LengthUnitMILE
};
/// 重量单位 （Unit of weight）
typedef NS_ENUM(NSInteger, WeightUnit) {
    /// 千克 （kilogram）
    WeightUnitKG,
    /// 磅 （pounds）
    WeightUnitLB
};
/// 温度单位 （Temperature unit）
typedef NS_ENUM(NSInteger, TemperatureUnit) {
    /// 摄氏度 （Degree Celsius）
    TemperatureUnitCELSIUS,
    /// 华氏度 （Fahrenheit）
    TemperatureUnitFAHRENHEIT
};
/// 时间格式 （Time format）
typedef NS_ENUM(NSInteger, TimeFormat) {
    /// 12小时制 （12-hour system）
    TimeFormatTWELVE_HOUR,
    /// 24小时制 （24-hour system）
    TimeFormatTWENTY_FOUR_HOUR
};


/// 计量单位设置 （Unit setting）
@interface WMUnitInfoModel : NSObject

/// 长度单位（none，表示不设置）（Length unit (none, not set)）
@property (nonatomic, assign) LengthUnit lengthUnit;
/// 重量单位（none，表示不设置）（Weight unit (none, not set)）
@property (nonatomic, assign) WeightUnit weightUnit;
/// 温度单位（none，表示不设置） （Temperature unit (none: not set)）
@property (nonatomic, assign) TemperatureUnit temperatureUnit;
/// 时间格式（none，表示不设置） （Time format (none: not set)）
@property (nonatomic, assign) TimeFormat timeFormat;

@end

NS_ASSUME_NONNULL_END
