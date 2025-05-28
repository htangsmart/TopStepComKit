//
//  TSTimeInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import "TSWorldClockModel.h"
#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Time management interface
 * @chinese 时间管理接口
 * 
 * @discussion 
 * EN: This interface defines all operations related to device time, including:
 *     1. System time synchronization
 *     2. Specific time setting
 *     3. World time setting
 * 
 * CN: 该接口定义了与设备时间相关的所有操作，包括：
 *     1. 系统时间同步
 *     2. 指定时间设置
 *     3. 世界时间设置
 */
@protocol TSTimeInterface <TSKitBaseInterface>

/**
 * Set system time to watch
 * @chinese 设置系统时间到手表
 * 
 * @param completion 
 * EN: Setting completion callback
 * CN: 设置完成的回调
 * 
 * @discussion 
 * EN: Synchronize current system time from phone to device.
 *     Time format will be automatically adjusted based on device settings (12/24-hour format).
 * 
 * CN: 将手机当前系统时间同步到设备。
 *     时间格式将根据设备当前设置自动调整（12小时制或24小时制）。
 */
- (void)setSystemTimeWithCompletion:(nullable TSCompletionBlock)completion;

/**
 * Set specific time to watch
 * @chinese 设置指定时间到手表
 * 
 * @param date 
 * EN: Time to set
 * CN: 要设置的时间
 * 
 * @param completion 
 * EN: Setting completion callback
 * CN: 设置完成的回调
 * 
 * @discussion 
 * EN: Set specified time to device.
 *     Time format will be automatically adjusted based on device settings (12/24-hour format).
 * 
 * CN: 将指定的时间设置到设备。
 *     时间格式将根据设备当前设置自动调整（12小时制或24小时制）。
 */
- (void)setSpecificTime:(NSDate *)date
             completion:(nullable TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
