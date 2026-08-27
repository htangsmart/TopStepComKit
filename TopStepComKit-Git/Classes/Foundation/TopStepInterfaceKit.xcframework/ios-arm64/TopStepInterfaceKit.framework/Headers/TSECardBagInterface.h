//
//  TSECardBagInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/20.
//

#import "TSKitBaseInterface.h"
#import "TSECardModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Card bag interface protocol
 * @chinese 电子卡包接口协议
 */
@protocol TSECardBagInterface <TSKitBaseInterface>

/**
 * @brief Check whether payment cards are supported
 * @chinese 检查是否支持钱包/支付类卡片
 *
 * @return
 * [EN]: YES when the provider and connected device support payment cards.
 * [CN]: Provider 与已连接设备均支持钱包/支付类卡片时返回 YES。
 */
- (BOOL)isSupportPaymentCard;

/**
 * @brief Check whether business cards are supported
 * @chinese 检查是否支持名片/社交类卡片
 *
 * @return
 * [EN]: YES when the provider and connected device support business cards.
 * [CN]: Provider 与已连接设备均支持名片/社交类卡片时返回 YES。
 */
- (BOOL)isSupportBusinessCard;


/**
 * @brief Get the maximum UTF-8 byte count of card URL content
 * @chinese 获取卡片 URL 内容允许的最大 UTF-8 字节数
 *
 * @return
 * [EN]: Maximum UTF-8 byte count; 0 means unsupported or unavailable.
 * [CN]: 最大 UTF-8 字节数；0 表示不支持或不可用。
 */
- (NSInteger)supportMaxCardURLByteCount;

/**
 * @brief Gets all payment cards.
 * @chinese 获取所有钱包卡片。
 *
 * @param completion
 * [EN]: Completion callback containing payment cards or an error.
 * [CN]: 完成回调，包含钱包卡片或错误信息。
 */
- (void)getAllPaymentCardsCompletion:(void (^)(NSArray<TSECardModel *> * _Nullable paymentCards, NSError * _Nullable error))completion;

/**
 * @brief Sets a payment card.
 * @chinese 设置钱包卡片。
 *
 * @param paymentCard
 * [EN]: Payment card to set.
 * [CN]: 要设置的钱包卡片。
 * @param completion
 * [EN]: Completion callback containing the operation result and an error.
 * [CN]: 完成回调，包含操作结果或错误信息。
 */
- (void)setPaymentCard:(TSECardModel *)paymentCard
            completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Gets all business cards.
 * @chinese 获取所有社交名片。
 *
 * @param completion
 * [EN]: Completion callback containing business cards or an error.
 * [CN]: 完成回调，包含社交名片或错误信息。
 */
- (void)getAllBusinessCardsCompletion:(void (^)(NSArray<TSECardModel *> * _Nullable businessCards, NSError * _Nullable error))completion;

/**
 * @brief Sets a business card.
 * @chinese 设置单张社交名片。
 *
 * @param businessCard
 * [EN]: Business card to set.
 * [CN]: 要设置的社交名片。
 * @param completion
 * [EN]: Completion callback containing the operation result and an error.
 * [CN]: 完成回调，包含操作结果或错误信息。
 */
- (void)setBusinessCard:(TSECardModel *)businessCard
             completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
