//
//  TSMetaLanguage.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "TSBusinessBase.h"
#import "PbConnectParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN



/**
 * @brief Language management class
 * @chinese 语言管理类
 */
@interface TSMetaLanguage : TSBusinessBase

/**
 * @brief Get supported language list
 * @chinese 获取支持的语言列表
 *
 * @param completion 
 * EN: Completion callback with array of supported language codes (NSNumber<UInt8>)
 * CN: 完成回调，返回支持的语言代码数组（NSNumber<UInt8>类型）
 *
 * @discussion
 * [EN]: Returns an array of NSNumber objects containing UInt8 values representing language codes
 * [CN]: 返回一个包含UInt8类型语言代码的NSNumber数组
 */
+ (void)getSupportedLanguages:(void(^)(TSMetaLanguageList * _Nullable languages, NSError * _Nullable error))completion;

/**
 * @brief Get current language
 * @chinese 获取当前语言
 *
 * @param completion 
 * EN: Completion callback with current language and error
 * CN: 完成回调，返回当前语言和错误信息
 */
+ (void)getCurrentLanguage:(void(^)(TSMetaLanguageModel *_Nullable curLanguage, NSError * _Nullable error))completion;

/**
 * @brief Set current language
 * @chinese 设置当前语言
 *
 * @param curLanguage
 * EN: Language model to set
 * CN: 要设置的语言模型
 *
 * @param completion 
 * EN: Completion callback with success status and error
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setCurrentLanguage:(TSMetaLanguageModel *)curLanguage
                completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Register language change notification
 * @chinese 注册语言变更通知
 *
 * @param completion 
 * EN: Completion callback with language model and error when language changes
 * CN: 完成回调，当语言变更时返回语言模型和错误信息
 *
 * @discussion
 * [EN]: Registers a notification to receive language change events from the device.
 *       The completion block will be called whenever the device language changes.
 * [CN]: 注册通知以接收来自设备的语言变更事件。
 *       当设备语言变更时，完成回调将被调用。
 */
+ (void)registerLanguageChangeNotification:(void(^)(TSMetaLanguageModel * _Nullable curLanguage, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
