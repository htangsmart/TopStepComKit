//
//  TSFwUgreen.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/10/14.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persimwear implementation of TSUgreenInterface (not supported)
 * @chinese TSUgreenInterface 的 Persimwear 实现（不支持）
 *
 * @discussion
 * [EN]: The UGREEN customization package is FitCloud-only. Every isSupportXxx returns NO and every method
 *       completes on the main thread with TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName) without sending.
 * [CN]: 绿联定制包仅 FitCloud 提供。所有 isSupportXxx 返回 NO，所有方法在主线程回调
 *       TSERROR_NOTSUPPORT(kTSErrorDomainUgreenName)，不发包。
 */
@interface TSFwUgreen : TSFwKitBase <TSUgreenInterface>

@end

NS_ASSUME_NONNULL_END
