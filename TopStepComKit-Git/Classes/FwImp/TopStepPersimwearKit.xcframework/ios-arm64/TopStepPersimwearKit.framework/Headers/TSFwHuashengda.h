//
//  TSFwHuashengda.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/9/23.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persimwear implementation of TSHuashengdaInterface (not supported)
 * @chinese TSHuashengdaInterface 的 Persimwear 实现（不支持）
 *
 * @discussion
 * [EN]: Persimwear platform does not support the Huashengda customization package. Every isSupportXxx returns NO and
 *       every method completes on the main thread with TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName).
 * [CN]: Persimwear 平台不支持华盛达定制包。所有 isSupportXxx 返回 NO，所有方法在主线程回调
 *       TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName)。
 */
@interface TSFwHuashengda : TSFwKitBase <TSHuashengdaInterface>

@end

NS_ASSUME_NONNULL_END
