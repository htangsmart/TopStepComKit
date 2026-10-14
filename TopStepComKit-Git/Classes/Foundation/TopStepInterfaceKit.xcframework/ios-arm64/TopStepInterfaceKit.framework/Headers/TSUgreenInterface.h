//
//  TSUgreenInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/10/14.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSUgreenDefines.h"
#import "TSUgreenConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Get UGREEN configuration callback
 * @chinese 获取绿联设备配置回调
 *
 * @param config
 * EN: Configuration returned by the device, nil if retrieval fails
 * CN: 设备返回的配置，获取失败时为nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void (^TSUgreenConfigResultBlock)(TSUgreenConfigModel *_Nullable config, NSError *_Nullable error);

/**
 * @brief UGREEN customer-specific features interface
 * @chinese 绿联客户定制能力接口
 *
 * @discussion
 * EN: Customer-specific, not part of the public SDK features. Currently groups:
 *     1. Device configuration (desktop-stand mode, triple-press function, always-on pages, lyrics theme / color)
 *     Each feature has its own isSupportXxx; isSupport is YES when any feature is supported.
 *     Only the FitCloud SDK implements it; other SDK types report every feature as unsupported.
 *     All completions run on the main thread exactly once. Unsupported features complete with
 *     TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName) without sending anything to the device.
 * CN: 客户定制能力，不属于公版能力。当前包括：
 *     1. 设备配置（桌搭模式、按键三击功能、常亮页面、歌词主题 / 颜色）
 *     每个能力自带 isSupportXxx；任一能力支持时 isSupport 为YES。
 *     仅 FitCloud 提供实现，其他 SDK 类型各能力均返回不支持。
 *     所有回调在主线程且恰好一次；不支持的能力直接回调 TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName)，不发送蓝牙包。
 */
@protocol TSUgreenInterface <TSKitBaseInterface>

#pragma mark - Capabilities 能力

/**
 * @brief Whether UGREEN device configuration is supported
 * @chinese 是否支持绿联设备配置
 *
 * @return
 * EN: YES if the connected device supports fetchConfig: / setConfig:completion:, otherwise NO.
 * CN: 当前设备支持 fetchConfig: / setConfig:completion: 时返回YES，否则返回NO。
 *
 * @discussion
 * EN: FitCloudKit has no dedicated firmware flag for this command yet. FitCloud treats a firmware
 *     that reports withUgreenDanmaku as UGREEN firmware and returns YES for it.
 * CN: FitCloudKit 目前没有该指令的专用固件标志位。FitCloud 以固件 withUgreenDanmaku 判定为绿联固件并返回YES。
 */
- (BOOL)isSupportConfig;

#pragma mark - Device Configuration 设备配置

/**
 * @brief Get UGREEN device configuration
 * @chinese 获取绿联设备配置
 *
 * @param completion
 * EN: Completion callback
 *     - config: Configuration returned by the device, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - config: 设备返回的配置，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Requires isSupportConfig.
 * CN: 需 isSupportConfig 为YES。
 */
- (void)fetchConfig:(TSUgreenConfigResultBlock)completion;

/**
 * @brief Set UGREEN device configuration
 * @chinese 设置绿联设备配置
 *
 * @param config
 * EN: The complete configuration to apply; every field is written to the device
 * CN: 要下发的完整配置，所有字段都会写入设备
 *
 * @param completion
 * EN: Completion callback
 *     - isSuccess: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - isSuccess: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Requires isSupportConfig. The device has no partial update: fields you do not set are
 *     overwritten with the model's values (defaults for a new model). Call fetchConfig: first,
 *     change the fields you need, then pass that model here.
 *     Model validation failures complete with a parameter error before sending.
 * CN: 需 isSupportConfig 为YES。设备不支持局部更新：未赋值的字段会被模型当前值覆盖（新建模型即为默认值）。
 *     请先调用 fetchConfig:，修改需要的字段后再传入此方法。
 *     模型校验失败时，在发送前回调参数错误。
 */
- (void)setConfig:(TSUgreenConfigModel *)config completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
