//
//  TSNpkECardBag.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/4/1.
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief New Platform Kit implementation of `TSECardBagInterface` (electronic card bag). Feature is not implemented yet; all API calls report not supported.
 * @chinese 新平台电子卡片包（`TSECardBagInterface`）实现类。当前功能未接入，接口均按「不支持」处理。
 *
 * @discussion
 * [EN]: Callers should check `isSupport` before use; completions receive `TSERROR_NOTSUPPORT` with domain `kTSErrorDomainECardBagName` when invoked.
 * [CN]: 调用前请先判断 `isSupport`；在未支持情况下若仍调用接口，完成回调将收到域为 `kTSErrorDomainECardBagName` 的不支持错误。
 */
@interface TSNpkECardBag : TSNpkKitBase<TSECardBagInterface>

@end

NS_ASSUME_NONNULL_END
