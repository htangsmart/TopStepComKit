//
//  TSECardModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/6.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Conversion between unified card models and NPK QR code models.
 * @chinese 统一卡片模型与 NPK 二维码模型之间的转换。
 */
@interface TSECardModel (Npk)

/**
 * @brief Converts a unified card model to NPK QR code setting data.
 * @chinese 将统一卡片模型转换为 NPK 二维码设置数据。
 *
 * @param card Card model to convert. / 要转换的卡片模型。
 * @return NPK setting data, or nil when the card type is unsupported. / NPK 设置数据，类型不支持时返回 nil。
 */
+ (nullable TSMetaQrCodeSet *)npkQRCodeSetWithCard:(TSECardModel *)card;

/**
 * @brief Builds unified card models from NPK status entries and cached content.
 * @chinese 根据 NPK 状态列表和缓存内容构建统一卡片模型。
 *
 * @param statuses Status entries returned by the device. / 设备返回的状态列表。
 * @param cachedContents Cached content keyed by unified card type. / 以统一卡片类型为 key 的缓存内容。
 * @param cachedHashValues Cached hash values keyed by unified card type. / 以统一卡片类型为 key 的缓存哈希值。
 * @param paymentCards YES for payment cards; NO for business cards. / YES 表示钱包卡片，NO 表示社交名片。
 * @return
 * [EN]: Card models. The content is nil when cache is unavailable or its hash does not match.
 * [CN]: 卡片模型；缓存不可用或哈希不一致时内容为 nil。
 */
+ (NSArray<TSECardModel *> *)cardModelsWithNpkStatuses:(NSArray<TSMetaQrCodeStatus *> *)statuses
                                        cachedContents:(NSDictionary<NSNumber *, NSString *> *)cachedContents
                                      cachedHashValues:(NSDictionary<NSNumber *, NSNumber *> *)cachedHashValues
                                          paymentCards:(BOOL)paymentCards;

@end

NS_ASSUME_NONNULL_END
