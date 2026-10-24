//
//  TSFitOfflineMaps.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/7/8.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud offline map implementation
 * @chinese FitCloud 离线地图实现
 *
 * @discussion
 * [EN]: Backed by FitCloudKit offline maps APIs (requires FitCloudOfflineMaps.xcframework and firmware.withOfflineMaps).
 * [CN]: 基于 FitCloudKit 离线地图接口实现（依赖 FitCloudOfflineMaps.xcframework 与固件 withOfflineMaps 能力位）。
 */
@interface TSFitOfflineMaps : TSFitKitBase<TSOfflineMapsInterface>

@end

NS_ASSUME_NONNULL_END
