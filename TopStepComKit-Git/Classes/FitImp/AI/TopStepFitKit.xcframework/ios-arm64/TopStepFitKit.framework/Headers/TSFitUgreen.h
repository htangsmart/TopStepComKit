//
//  TSFitUgreen.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/10/14.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud implementation of TSUgreenInterface
 * @chinese TSUgreenInterface 的 FitCloud 实现
 *
 * @discussion
 * [EN]: Device configuration maps to FitCloudKit (UGreen) queryUgreenConfigWithCompletion: / setUgreenConfig:completion:.
 *       FitCloudKit has no dedicated flag for the configuration command, so isSupportConfig uses
 *       firmware.withUgreenDanmaku as the UGREEN-firmware marker. Model mapping lives in TSUgreenConfigModel+Fit.
 *       All completions run on the main thread exactly once; unsupported features complete with
 *       TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName) without sending.
 * [CN]: 设备配置对接 FitCloudKit (UGreen) queryUgreenConfigWithCompletion: / setUgreenConfig:completion:。
 *       FitCloudKit 没有配置指令的专用标志位，isSupportConfig 以固件 withUgreenDanmaku 作为绿联固件标识。
 *       模型映射见 TSUgreenConfigModel+Fit。
 *       所有回调在主线程且恰好一次；不支持的能力回调 TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName)，不发包。
 */
@interface TSFitUgreen : TSFitKitBase <TSUgreenInterface>

@end

NS_ASSUME_NONNULL_END
