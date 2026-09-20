//
//  TSFitEpo.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/7/10.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud EPO(GNSS ephemeris) implementation
 * @chinese FitCloud 端 EPO(GNSS 星历) 实现
 *
 * @discussion
 * [EN]: Implements TSEpoInterface on FitCloud. Capability check / query-expire-time / clear map to
 *       FitCloudKit's GPS file APIs. The update pipeline is delegated to FitCloudGPSAccelerate, which
 *       downloads the vendor(Airoha/ICOE) EPO files and uploads them to the watch internally; it
 *       requires a location service to pick the EPO region. Cancel is not supported by the SDK.
 * [CN]: 在 FitCloud 上实现 TSEpoInterface。能力检查 / 查询有效期 / 清除分别映射到 FitCloudKit 的
 *       GPS 文件接口。更新流程交给 FitCloudGPSAccelerate：由它内部下载厂商(洛达/芯与物) EPO 文件并上传到
 *       设备，需提供定位服务以选择 EPO 区域。SDK 不支持取消。
 */
@interface TSFitEpo : TSFitKitBase<TSEpoInterface>

@end

NS_ASSUME_NONNULL_END
