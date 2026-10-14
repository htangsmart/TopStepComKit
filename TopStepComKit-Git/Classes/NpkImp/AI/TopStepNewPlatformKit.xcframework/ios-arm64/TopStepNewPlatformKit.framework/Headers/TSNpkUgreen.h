//
//  TSNpkUgreen.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/10/14.
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NewPlatform implementation of TSUgreenInterface (not supported)
 * @chinese TSUgreenInterface 的 NewPlatform 实现（不支持）
 *
 * @discussion
 * [EN]: The UGREEN customization package is FitCloud-only. Every isSupportXxx returns NO and every method
 *       completes on the main thread with TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName) without sending.
 * [CN]: 绿联定制包仅 FitCloud 提供。所有 isSupportXxx 返回 NO，所有方法在主线程回调
 *       TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName)，不发包。
 */
@interface TSNpkUgreen : TSNpkKitBase <TSUgreenInterface>

@end

NS_ASSUME_NONNULL_END
