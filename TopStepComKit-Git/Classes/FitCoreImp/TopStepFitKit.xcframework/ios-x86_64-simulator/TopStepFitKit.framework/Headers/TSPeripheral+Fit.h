//
//  TSPeripheral+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudPeripheral;
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud specific extension for TSPeripheral
 * @chinese TSPeripheral的FitCloud特定扩展
 *
 * @discussion
 * [EN]: This category extends TSPeripheral with FitCloud specific functionality:
 * - Requesting and synchronizing device information from FitCloud
 * - Determining device capabilities and limitations
 * - Setting up device parameters and settings
 *
 * [CN]: 此分类使用FitCloud特定功能扩展TSPeripheral：
 * - 从FitCloud请求和同步设备信息
 * - 确定设备能力和限制
 * - 设置设备参数和配置
 */
@interface TSPeripheral (Fit)


+ (TSPeripheral *)peripheralWithFitPeriperal:(FitCloudPeripheral *)fitPeripheral ;


/**
 * @brief Request all FitCloud peripheral information and settings
 * @chinese 请求所有FitCloud外设信息和设置
 *
 * @param completion 
 * EN: Callback that returns the updated peripheral with FitCloud information
 * CN: 返回更新了FitCloud信息的外设对象的回调
 *
 * @discussion
 * [EN]: This method performs a complete information request from FitCloud:
 * - System information (firmware version, device SN)
 * - Device limitations (maximum counts for various features)
 * - Device capabilities (supported features)
 * - Display information (screen size, shape)
 * The method is asynchronous and will call completion when all data is retrieved.
 *
 * [CN]: 此方法从FitCloud执行完整的信息请求：
 * - 系统信息（固件版本，设备SN）
 * - 设备限制（各种功能的最大数量）
 * - 设备能力（支持的功能）
 * - 显示信息（屏幕尺寸，形状）
 * 该方法是异步的，当所有数据检索完成时将调用completion。
 */
- (void)requestFitPeripheralInfoCompletion:(void (^)(TSPeripheral *))completion;

/**
 * @brief Request system information from FitCloud
 * @chinese 从FitCloud请求系统信息
 *
 * @discussion
 * [EN]: Updates peripheral's system information:
 * - Project ID
 * - Device SN
 * - Firmware version
 * - MAC address
 * This method is synchronous and modifies the peripheral directly.
 *
 * [CN]: 更新外设的系统信息：
 * - 项目ID
 * - 设备SN
 * - 固件版本
 * - MAC地址
 * 此方法是同步的，直接修改外设对象。
 */
- (void)requestSystemInfo;

/**
 * @brief Request device limitation information from FitCloud
 * @chinese 从FitCloud请求设备限制信息
 *
 * @discussion
 * [EN]: Updates peripheral's limitation information:
 * - Maximum alarm count
 * - Maximum contact count
 * - Maximum reminder count
 * This method is synchronous and updates the limitation object directly.
 *
 * [CN]: 更新外设的限制信息：
 * - 最大闹钟数量
 * - 最大联系人数量
 * - 最大提醒数量
 * 此方法是同步的，直接更新limitation对象。
 */
- (void)requestPeripheralLimitInfo;

/**
 * @brief Request device capability information from FitCloud
 * @chinese 从FitCloud请求设备能力信息
 *
 * @discussion
 * [EN]: Determines and sets peripheral's capabilities based on FitCloud firmware information:
 * - Health features (heart rate, blood pressure, sleep tracking, etc.)
 * - Smart features (notifications, music control, etc.)
 * - System features (language settings, time settings, etc.)
 * This method is synchronous and updates the capability object directly.
 *
 * [CN]: 根据FitCloud固件信息确定并设置外设的能力:
 * - 健康功能（心率、血压、睡眠追踪等）
 * - 智能功能（通知、音乐控制等）
 * - 系统功能（语言设置、时间设置等）
 * 此方法是同步的，直接更新capability对象。
 */
- (void)requestPeripheralCapability;

/**
 * @brief Request watch face and display information from FitCloud
 * @chinese 从FitCloud请求表盘和显示信息
 *
 * @param completion 
 * EN: Callback that is called when information retrieval is complete
 * CN: 信息检索完成时调用的回调
 *
 * @discussion
 * [EN]: Updates peripheral's display and watch face information:
 * - Screen width and height
 * - Screen shape (round or rectangle)
 * - Corner radius
 * - Maximum push dial count
 * - Inner dial count
 * This method is asynchronous and will call completion when all data is retrieved.
 *
 * [CN]: 更新外设的显示和表盘信息：
 * - 屏幕宽度和高度
 * - 屏幕形状（圆形或矩形）
 * - 圆角半径
 * - 最大可推送表盘数量
 * - 内置表盘数量
 * 该方法是异步的，当所有数据检索完成时将调用completion。
 */
- (void)requestPeripheralDialInfoCompletion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
