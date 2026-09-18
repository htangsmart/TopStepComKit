//
//  TSMetaECardBag.h
//  TopStepBleMetaKit
//
//  Created by Codex on 2026/8/6.
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Maximum UTF-8 byte count accepted by QR code content.
 * @chinese 二维码内容允许的最大 UTF-8 字节数。
 */
FOUNDATION_EXPORT NSUInteger const TSMetaQRCodeContentMaxByteCount;

/**
 * @brief Electronic card category used when requesting a QR code list.
 * @chinese 获取二维码列表时使用的电子卡片分类。
 */
typedef NS_ENUM(NSInteger, TSMetaECardCategory) {
    /** Payment cards. / 钱包卡片。 */
    TSMetaECardCategoryPayment = 0,
    /** Business cards. / 社交名片。 */
    TSMetaECardCategoryBusiness = 1,
};

/**
 * @brief Electronic QR code card bag commands.
 * @chinese 电子二维码卡包指令封装。
 */
@interface TSMetaECardBag : TSBusinessBase

/**
 * @brief Gets QR code status entries for a card category.
 * @chinese 获取指定卡片分类的二维码状态列表。
 *
 * @param category Card category. / 卡片分类。
 * @param completion Completion containing the status list or an error. / 返回状态列表或错误的完成回调。
 */
+ (void)getQRCodeStatusListForCategory:(TSMetaECardCategory)category
                            completion:(void (^ _Nullable)(TSMetaQrCodeStatusList * _Nullable statusList,
                                                            NSError * _Nullable error))completion;

/**
 * @brief Sets one QR code card.
 * @chinese 设置单张二维码卡片。
 *
 * @param qrCode QR code setting data. Content must not exceed TSMetaQRCodeContentMaxByteCount. /
 *               二维码设置数据，内容不得超过 TSMetaQRCodeContentMaxByteCount。
 * @param completion Completion containing the operation result or an error. / 返回操作结果或错误的完成回调。
 */
+ (void)setQRCode:(TSMetaQrCodeSet *)qrCode
        completion:(TSMetaCompletionBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
