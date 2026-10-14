//
//  TSNpkECardBag.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/4/1.
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief New Platform Kit implementation of the electronic card bag interface.
 * @chinese 新平台电子卡片包接口实现类。
 *
 * @discussion
 * [EN]: Supports payment and business QR code cards through TopStepBleMetaKit.
 * [CN]: 通过 TopStepBleMetaKit 支持钱包与社交名片二维码卡片。
 */
@interface TSNpkECardBag : TSNpkKitBase<TSECardBagInterface>

@end

NS_ASSUME_NONNULL_END
