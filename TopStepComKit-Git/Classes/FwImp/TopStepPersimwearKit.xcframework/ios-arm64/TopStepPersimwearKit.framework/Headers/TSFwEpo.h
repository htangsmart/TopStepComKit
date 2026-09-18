//
//  TSFwEpo.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/7/10.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persimwear EPO(GNSS ephemeris) implementation (not supported)
 * @chinese Persimwear EPO(GNSS 星历) 实现（暂不支持）
 *
 * @discussion
 * [EN]: Persimwear platform does not support EPO. All methods return a not-support error.
 * [CN]: Persimwear 平台不支持 EPO，所有方法均返回不支持错误。
 */
@interface TSFwEpo : TSFwKitBase<TSEpoInterface>

@end

NS_ASSUME_NONNULL_END
