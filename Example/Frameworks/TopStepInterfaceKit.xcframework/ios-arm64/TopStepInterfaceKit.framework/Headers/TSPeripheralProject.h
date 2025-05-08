//
//  TSPeripheralProject.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheralProject : NSObject


/**
 * @brief Project identifier.
 * @chinese 项目标识符
 *
 * @discussion
 * [EN]: Used to identify different project types.
 * [CN]: 用于标识不同的项目类型。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *projectId;

/**
 * @brief Firmware version number.
 * @chinese 固件版本号
 *
 * @discussion
 * [EN]: The firmware version currently running on the device.
 * [CN]: 设备当前运行的固件版本。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *firmVersion;

/**
 * @brief Virtual version number.
 * @chinese 虚拟版本号
 *
 * @discussion
 * [EN]: Used for special version control.
 * [CN]: 用于特殊版本控制。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *virtualVersion;

/**
 * @brief Device serial number.
 * @chinese 设备序列号
 *
 * @discussion
 * [EN]: The unique identifier of the device.
 * [CN]: 设备的唯一标识符。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *deviceSN;

/**
 * @brief Main project number.
 * @chinese 主项目号
 *
 * @discussion
 * [EN]: Only used for FitCloudKit.
 * [CN]: 仅用于 FitCloudKit。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *mainProjNum;

/**
 * @brief Sub project number.
 * @chinese 子项目号
 *
 * @discussion
 * [EN]: Only used for FitCloudKit.
 * [CN]: 仅用于 FitCloudKit。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *subProjNum;


@end

NS_ASSUME_NONNULL_END
