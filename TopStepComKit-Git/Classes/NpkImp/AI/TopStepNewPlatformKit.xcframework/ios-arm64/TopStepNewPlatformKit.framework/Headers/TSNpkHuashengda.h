//
//  TSNpkHuashengda.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK implementation of TSHuashengdaInterface
 * @chinese TSHuashengdaInterface 的新平台（NPK）实现
 *
 * @discussion
 * [EN]: Capability gating reads raw ability bits 27–34 (TSNpkHsdAbility); model mapping lives in
 *       TSHsdModels+Npk; transport is TSMetaHuashengda (BleMetaKit). Unsupported features complete on
 *       the main thread with TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName) without sending.
 * [CN]: 能力判定读原始能力位 27–34（TSNpkHsdAbility）；模型映射见 TSHsdModels+Npk；传输走 TSMetaHuashengda。
 *       不支持的能力在主线程回调 TSERROR_NOTSUPPORT(kTSErrorDomainHuashengdaName)，不发包。
 */
@interface TSNpkHuashengda : TSNpkKitBase <TSHuashengdaInterface>

@end

NS_ASSUME_NONNULL_END
