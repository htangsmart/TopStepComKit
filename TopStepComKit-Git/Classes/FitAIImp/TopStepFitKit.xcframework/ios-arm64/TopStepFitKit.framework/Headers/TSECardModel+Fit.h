//
//  TSECardModel+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Category for converting between TSECardModel and FitCloudECard
 * @chinese TSECardModel和FitCloudECard之间的转换分类
 */
@interface TSECardModel (Fit)

/**
 * @brief Convert FitCloudECard to TSECardModel
 * @chinese 将FitCloudECard转换为TSECardModel
 *
 * @param fitCard 
 * [EN]: FitCloudECard object to be converted
 * [CN]: 需要转换的FitCloudECard对象
 *
 * @return 
 * [EN]: Converted TSECardModel object, nil if conversion fails
 * [CN]: 转换后的TSECardModel对象，转换失败时返回nil
 */
+ (nullable TSECardModel *)modelWithFitCloudECard:(nullable FitCloudECard *)fitCard;

/**
 * @brief Convert array of FitCloudECard to array of TSECardModel
 * @chinese 将FitCloudECard数组转换为TSECardModel数组
 *
 * @param fitCards 
 * [EN]: Array of FitCloudECard objects to be converted
 * [CN]: 需要转换的FitCloudECard对象数组
 *
 * @return 
 * [EN]: Array of converted TSECardModel objects
 * [CN]: 转换后的TSECardModel对象数组
 */
+ (NSArray<TSECardModel *> *)modelsWithFitCloudECards:(NSArray<FitCloudECard *> *)fitCards;

/**
 * @brief Convert unified card types to FitCloud card identifiers
 * @chinese 将统一卡片类型转换为 FitCloud 卡片标识
 *
 * @param cardTypes
 * [EN]: Unified card type values
 * [CN]: 统一卡片类型值
 *
 * @return
 * [EN]: FitCloud identifiers, or nil when any type is unsupported
 * [CN]: FitCloud 标识数组；任一类型不支持时返回 nil
 */
+ (nullable NSArray<NSNumber *> *)fitCloudIdentifiersWithCardTypes:(NSArray<NSNumber *> *)cardTypes;

/**
 * @brief Builds payment card models from FitCloud identifiers and cached contents.
 * @chinese 根据 FitCloud 标识和缓存内容构建钱包卡片模型。
 *
 * @param identifiers
 * [EN]: FitCloud QR code identifiers supported by the device.
 * [CN]: 设备支持的 FitCloud 二维码标识。
 * @param cachedContents
 * [EN]: Cached contents keyed by unified card type values.
 * [CN]: 以统一卡片类型值为 key 的内容缓存。
 *
 * @return
 * [EN]: Payment card models supported by the device. cardURL is nil when cached content is unavailable.
 * [CN]: 设备支持的钱包卡片模型；无可用缓存内容时 cardURL 为 nil。
 */
+ (NSArray<TSECardModel *> *)paymentCardModelsWithFitCloudIdentifiers:(NSArray<NSNumber *> *)identifiers
                                                       cachedContents:(NSDictionary<NSNumber *, NSString *> *)cachedContents;

/**
 * @brief Builds business card models from FitCloud identifiers and cached contents.
 * @chinese 根据 FitCloud 标识和缓存内容构建社交名片模型。
 *
 * @param identifiers
 * [EN]: FitCloud QR code identifiers supported by the device.
 * [CN]: 设备支持的 FitCloud 二维码标识。
 * @param cachedContents
 * [EN]: Cached contents keyed by unified card type values.
 * [CN]: 以统一卡片类型值为 key 的内容缓存。
 *
 * @return
 * [EN]: Business card models supported by the device. cardURL is nil when cached content is unavailable.
 * [CN]: 设备支持的社交名片模型；无可用缓存内容时 cardURL 为 nil。
 */
+ (NSArray<TSECardModel *> *)businessCardModelsWithFitCloudIdentifiers:(NSArray<NSNumber *> *)identifiers
                                                        cachedContents:(NSDictionary<NSNumber *, NSString *> *)cachedContents;

@end

NS_ASSUME_NONNULL_END
