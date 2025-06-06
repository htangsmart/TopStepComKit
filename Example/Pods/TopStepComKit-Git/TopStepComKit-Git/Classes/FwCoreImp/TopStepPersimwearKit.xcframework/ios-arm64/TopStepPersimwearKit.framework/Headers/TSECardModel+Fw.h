//
//  TSECardModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/5/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Category for converting between dictionary and TSECardModel
 * @chinese 字典和TSECardModel之间的转换分类
 */
@interface TSECardModel (Fw)

/**
 * @brief Convert wallet dictionary to array of TSECardModel
 * @chinese 将钱包字典转换为TSECardModel数组
 *
 * @param dict 
 * [EN]: Dictionary containing wallet card information, where keys are app names in PascalCase
 * and values are card URLs
 * [CN]: 包含钱包卡片信息的字典，其中键是使用大驼峰命名法的应用名称，值是卡片URL
 *
 * @return 
 * [EN]: Array of TSECardModel objects, empty array if conversion fails
 * [CN]: TSECardModel对象数组，转换失败时返回空数组
 *
 * @discussion
 * [EN]: The dictionary should have the following structure:
 * {
 *     "QQ": "url1",
 *     "Alipay": "url2",
 *     "Wechat": "url3",
 *     "Paypal": "url4",
 *     "Paytm": "url5",
 *     "PhonePe": "url6",
 *     "Gpay": "url7",
 *     "BHIM": "url8",
 *     "Custom": "url9",
 *     "OtherApp": "url10"  // Keys should use PascalCase
 * }
 * [CN]: 字典应具有以下结构：
 * {
 *     "QQ": "url1",
 *     "Alipay": "url2",
 *     "Wechat": "url3",
 *     "Paypal": "url4",
 *     "Paytm": "url5",
 *     "PhonePe": "url6",
 *     "Gpay": "url7",
 *     "BHIM": "url8",
 *     "Custom": "url9",
 *     "OtherApp": "url10"  // 键名应使用大驼峰命名法
 * }
 */
+ (NSArray<TSECardModel *> *)walletModelsWithDictionary:(NSDictionary<NSString *, NSString *> *)dict;

/**
 * @brief Convert business card dictionary to array of TSECardModel
 * @chinese 将名片字典转换为TSECardModel数组
 *
 * @param dict 
 * [EN]: Dictionary containing business card information, where keys are app names in PascalCase
 * and values are QR code strings
 * [CN]: 包含名片信息的字典，其中键是使用大驼峰命名法的应用名称，值是二维码字符串
 *
 * @return 
 * [EN]: Array of TSECardModel objects, empty array if conversion fails
 * [CN]: TSECardModel对象数组，转换失败时返回空数组
 *
 * @discussion
 * [EN]: The dictionary should have the following structure:
 * {
 *     "QQ": "qr1",
 *     "Wechat": "qr2",
 *     "Facebook": "qr3",
 *     "WhatsApp": "qr4",
 *     "Twitter": "qr5",
 *     "Instagram": "qr6",
 *     "Line": "qr7",
 *     "Skype": "qr8",
 *     "OtherApp": "qr9"  // Keys should use PascalCase
 * }
 * [CN]: 字典应具有以下结构：
 * {
 *     "QQ": "qr1",
 *     "Wechat": "qr2",
 *     "Facebook": "qr3",
 *     "WhatsApp": "qr4",
 *     "Twitter": "qr5",
 *     "Instagram": "qr6",
 *     "Line": "qr7",
 *     "Skype": "qr8",
 *     "OtherApp": "qr9"  // 键名应使用大驼峰命名法
 * }
 */
+ (NSArray<TSECardModel *> *)businessCardModelsWithDictionary:(NSDictionary<NSString *, NSString *> *)dict;

@end

NS_ASSUME_NONNULL_END
