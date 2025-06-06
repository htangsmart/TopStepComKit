//
//  TSECardModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/21.
//

#import <Foundation/Foundation.h>

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
    TSECardTypeNucleicAcid    = 1014 // Nucleic acid code / 核酸码
};

@interface TSECardModel : NSObject


/**
 * @brief Unique identifier of the card
 * @chinese 卡片的唯一标识符
 *
 * @discussion
 * [EN]: A unique identifier for the card, ranging from 0 to 255.
 * This ID is used for card management operations such as sorting and deletion.
 * [CN]: 卡片的唯一标识符，范围从0到255。
 * 此ID用于卡片管理操作，如排序和删除。
 *
 * @note
 * [EN]: Must be between 0 and 255 inclusive.
 * [CN]: 必须在0到255之间（包含0和255）。
 */
@property (nonatomic, assign) NSInteger cardId;

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
 * @brief Name of the card
 * @chinese 卡片名称
 *
 * @discussion
 * [EN]: The display name of the card
 * [CN]: 卡片的显示名称
 *
 * @note
 * [EN]: Cannot be nil
 * [CN]: 不能为空
 */
@property (nonatomic, copy) NSString *cardName;

/**
 * @brief URL of the card
 * @chinese 卡片URL
 *
 * @discussion
 * [EN]: The URL that can be used to generate QR code for the card
 * [CN]: 可用于生成卡片二维码的URL
 *
 * @note
 * [EN]: Should be a valid URL string
 * [CN]: 应该是一个有效的URL字符串
 */
@property (nonatomic, copy) NSString *cardURL;

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
 * [EN]: New card model instance, nil if any parameter is invalid
 * [CN]: 新的卡片模型实例，如果任何参数无效则返回nil
 *
 * @discussion
 * [EN]: This is the designated initializer for TSECardModel. All other initialization methods
 * should call this method. The method will validate all parameters and return nil if any
 * parameter is invalid.
 * [CN]: 这是TSECardModel的指定初始化方法。所有其他初始化方法都应该调用此方法。
 * 该方法将验证所有参数，如果任何参数无效则返回nil。
 */
+ (instancetype)cardWithId:(NSInteger)cardId
                      type:(TSECardType)cardType
                      name:(NSString *)cardName
                       url:(NSString *)cardURL;


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
 * @brief Get the default name for the card type
 * @chinese 获取卡片类型的默认名称
 *
 * @return
 * [EN]: Default name for the card type
 * [CN]: 卡片类型的默认名称
 */
- (NSString *)defaultCardName;

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
 * @brief Check if the card ID is valid
 * @chinese 检查卡片ID是否有效
 *
 * @return
 * [EN]: YES if the card ID is between 0 and 255, NO otherwise
 * [CN]: 如果卡片ID在0到255之间返回YES，否则返回NO
 */
- (BOOL)isValidCardId;

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
