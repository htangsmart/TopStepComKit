//
//  TSLanguageModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 语言模型
 *
 * @discussion 用于表示设备支持的语言信息，包括语言代码、本地名称和中文名称
 */
@interface TSLanguageModel : NSObject

/**
 * 语言代码
 * 格式：语言代码，如：
 * - zh：中文
 * - en：英语
 * - de：德语
 * - es：西班牙语
 * - fr：法语
 * - it：意大利语
 * - pt：葡萄牙语
 * - ar：阿拉伯语
 * - ru：俄语
 * - vi：越南语
 * - th：泰语
 * - fa：波斯语
 */
@property (nonatomic, copy) NSString *languageCode;

/**
 * 语言的本地名称（该语言使用者称呼该语言的名称）
 * 例如：
 * - 中文
 * - English（英语）
 * - Deutsch（德语）
 * - Español（西班牙语）
 * - Français（法语）
 * - Italiano（意大利语）
 * - Português（葡萄牙语）
 * - العربية（阿拉伯语）
 * - Русский（俄语）
 * - Tiếng Việt（越南语）
 * - ภาษาไทย（泰语）
 * - فارسی（波斯语）
 */
@property (nonatomic, copy) NSString *nativeName;

/**
 * 语言的中文名称
 * 用于在中文环境下显示各种语言的名称
 * 例如：
 * - 简体中文
 * - 英语
 * - 德语
 * - 西班牙语
 * - 法语
 * - 意大利语
 * - 葡萄牙语
 * - 阿拉伯语
 * - 俄语
 * - 越南语
 * - 泰语
 * - 波斯语
 */
@property (nonatomic, copy) NSString *chineseName;

/**
 * 便利构造方法
 * @param languageCode 语言代码
 * @param nativeName 语言的本地名称
 * @param chineseName 语言的中文名称
 * @return TSLanguageModel实例
 */
+ (instancetype)modelWithLanguageCode:(NSString *)languageCode 
                         nativeName:(NSString *)nativeName
                       chineseName:(NSString *)chineseName;

- (instancetype)initWithCode:(NSString *)code;
@end

NS_ASSUME_NONNULL_END
