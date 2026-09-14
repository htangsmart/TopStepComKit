//
//  TSFitOfflineMaps.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/7/8.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud offline map implementation (not supported)
 * @chinese FitCloud 离线地图实现（暂不支持）
 *
 * @discussion
 * [EN]: FitCloud platform does not support offline map. All methods return a not-support error.
 * [CN]: FitCloud 平台不支持离线地图，所有方法均返回不支持错误。
 */
@interface TSFitOfflineMaps : TSFitKitBase<TSOfflineMapsInterface>

@end

NS_ASSUME_NONNULL_END
