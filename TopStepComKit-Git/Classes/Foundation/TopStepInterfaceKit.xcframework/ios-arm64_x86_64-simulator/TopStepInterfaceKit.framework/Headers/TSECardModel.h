//
//  TSECardModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/21.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Card type enumeration
 * @chinese 卡片类型枚举
 */
typedef NS_ENUM(NSInteger, TSECardType) {
    TSECardTypeUnknow         = 0, // unknow code /未知类型
    // Wallet cards (100-199)
    TSECardTypeWechatPay      = 100, // WeChat payment code / 微信收款码
    TSECardTypeAlipay         = 101,  // Alipay payment code / 支付宝收款码
    TSECardTypePayPal         = 102,  // PayPal payment code / PayPal收款码
    TSECardTypeQQPay          = 103,  // QQ payment code / QQ收款码
    TSECardTypePaytm          = 104,  // Paytm payment code / Paytm收款码
    TSECardTypePhonePe        = 105,  // PhonePe payment code / PhonePe收款码
    TSECardTypeGPay           = 106,  // GPay payment code / GPay收款码
    TSECardTypeBHIM           = 107,  // BHIM payment code / BHIM收款码
    TSECardTypeMomo           = 108,  // Momo payment code / Momo收款码
    TSECardTypeZalo           = 109,  // Zalo payment code / Zalo收款码
    TSECardTypeCustomPay      = 110,  // Custom payment code / 自定义收款码

    // Business cards (1000-1999)
    TSECardTypeWechat         = 1000, // WeChat business card / 微信名片
    TSECardTypeAlipayBusiness = 1001,// Alipay business card / 支付宝名片
    TSECardTypeQQ             = 1002, // QQ business card / QQ名片
    TSECardTypeFacebook       = 1003, // Facebook business card / Facebook名片
    TSECardTypeWhatsApp       = 1004, // WhatsApp business card / WhatsApp名片
    TSECardTypeTwitter        = 1005, // Twitter business card / Twitter名片
    TSECardTypeInstagram      = 1006, // Instagram business card / Instagram名片
    TSECardTypeMessenger      = 1007, // Messenger business card / Messenger名片
    TSECardTypeLINE           = 1008, // LINE business card / LINE名片
    TSECardTypeSnapchat       = 1009, // Snapchat business card / Snapchat名片
    TSECardTypeSkype          = 1010, // Skype business card / Skype名片
    TSECardTypeEmail          = 1011, // Email business card / 邮箱名片
    TSECardTypePhone          = 1012, // Phone business card / 电话名片
    TSECardTypeLinkedIn       = 1013, // LinkedIn business card / LinkedIn名片
    TSECardTypeNucleicAcid    = 1014, // Nucleic acid code / 核酸码
    TSECardTypeZaloBusiness   = 1015, // Zalo business card / Zalo名片
    TSECardTypeCustomBusiness = 1016  // Custom business card / 自定义名片
};

@interface TSECardModel : TSKitBaseModel


/**
 * @brief Type of the card
 * @chinese 卡片类型
 *
 * @discussion
 * [EN]: Defines the type of the card
 * [CN]: 定义卡片的类型
 *
 * @note
 * [EN]: Values 100-199 for wallet cards, 1000-1999 for business cards
 * [CN]: 100-199为钱包卡，1000-1999为名片卡
 */
@property (nonatomic, assign) TSECardType cardType;

/**
 * @brief URL of the card
 * @chinese 卡片URL
 *
 * @discussion
 * [EN]: Content used to generate the card QR code. It is nil when content cannot be restored from local cache.
 * [CN]: 用于生成卡片二维码的内容；无法从本地缓存恢复内容时为 nil。
 *
 * @note
 * [EN]: A nil value means the content must be set again before use.
 * [CN]: nil 表示使用前需要重新设置卡片内容。
 */
@property (nonatomic, copy, nullable) NSString *cardURL;

/**
 * @brief Disable default initializer
 * @chinese 禁用默认初始化方法
 *
 * @discussion
 * [EN]: The default initializer is disabled. Please use designated initializer instead.
 * [CN]: 默认初始化方法已被禁用，请使用指定初始化方法。
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用new方法
 *
 * @discussion
 * [EN]: The new method is disabled. Please use designated initializer instead.
 * [CN]: new方法已被禁用，请使用指定初始化方法。
 */
+ (instancetype)new NS_UNAVAILABLE;


/**
 * @brief Create a card model with all properties
 * @chinese 使用所有属性创建卡片模型
 * @return
 * [EN]: New card model instance, nil if the card type is invalid
 * [CN]: 新的卡片模型实例，卡片类型无效时返回 nil
 *
 * @discussion
 * [EN]: This is the designated initializer for TSECardModel. All other initialization methods
 * should call this method. The card content may be nil when it cannot be restored from local cache.
 * [CN]: 这是TSECardModel的指定初始化方法。所有其他初始化方法都应该调用此方法。
 * 当卡片内容无法从本地缓存恢复时，卡片内容可以为 nil。
 */
+ (instancetype)cardWithType:(TSECardType)cardType
                         url:(nullable NSString *)cardURL;


/**
 * @brief Check if the card is a wallet card
 * @chinese 检查是否为钱包卡
 *
 * @return
 * [EN]: YES if the card is a wallet card, NO otherwise
 * [CN]: 如果是钱包卡返回YES，否则返回NO
 */
- (BOOL)isWalletCard;

/**
 * @brief Check if the card is a business card
 * @chinese 检查是否为名片卡
 *
 * @return
 * [EN]: YES if the card is a business card, NO otherwise
 * [CN]: 如果是名片卡返回YES，否则返回NO
 */
- (BOOL)isBusinessCard;

/**
 * @brief Check if the card is valid
 * @chinese 检查卡片是否有效
 *
 * @return
 * [EN]: YES if the card is valid (has valid type and URL), NO otherwise
 * [CN]: 如果卡片有效（有有效的类型和URL）返回YES，否则返回NO
 */
- (BOOL)isValid;

/**
 * @brief Get all available wallet card types
 * @chinese 获取所有可用的钱包卡类型
 *
 * @return
 * [EN]: Array of wallet card types
 * [CN]: 钱包卡类型数组
 */
+ (NSArray<NSNumber *> *)allWalletCardTypes;

/**
 * @brief Get all available business card types
 * @chinese 获取所有可用的名片卡类型
 *
 * @return
 * [EN]: Array of business card types
 * [CN]: 名片卡类型数组
 */
+ (NSArray<NSNumber *> *)allBusinessCardTypes;

@end

NS_ASSUME_NONNULL_END
