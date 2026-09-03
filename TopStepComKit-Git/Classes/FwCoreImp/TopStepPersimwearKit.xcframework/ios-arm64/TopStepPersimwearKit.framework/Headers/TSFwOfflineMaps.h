//
//  TSFwOfflineMaps.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/7/8.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persimwear offline map implementation (not supported)
 * @chinese Persimwear 离线地图实现（暂不支持）
 *
 * @discussion
 * [EN]: Persimwear platform does not support offline map. All methods return a not-support error.
 * [CN]: Persimwear 平台不支持离线地图，所有方法均返回不支持错误。
 */
@interface TSFwOfflineMaps : TSFwKitBase<TSOfflineMapsInterface>

@end

NS_ASSUME_NONNULL_END
