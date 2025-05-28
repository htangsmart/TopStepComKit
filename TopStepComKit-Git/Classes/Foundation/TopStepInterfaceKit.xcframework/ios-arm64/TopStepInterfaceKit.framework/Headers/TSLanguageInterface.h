//
//  TSLanguageInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSLanguageModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Get language list callback
 * @chinese 获取语言列表回调
 * 
 * @param languages 
 * EN: Array of supported language models, empty array if retrieval fails
 * CN: 支持的语言模型数组，获取失败时为空数组
 * 
 * @param error 
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void(^TSLanguageListResultBlock)(NSArray<TSLanguageModel *> * _Nonnull languages, NSError * _Nullable error);

/**
 * @brief Get current language callback
 * @chinese 获取当前语言回调
 * 
 * @param language 
 * EN: Current language model, nil if retrieval fails
 * CN: 当前语言模型，获取失败时为nil
 * 
 * @param error 
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void(^TSLanguageResultBlock)(TSLanguageModel * _Nullable language, NSError * _Nullable error);

/**
 * @brief Device language management interface
 * @chinese 设备语言管理接口
 * 
 * @discussion 
 * EN: This interface defines all operations related to device language, including:
 *     1. Get list of supported languages
 *     2. Get current device language
 *     3. Set device language
 * CN: 该接口定义了与设备语言相关的所有操作，包括：
 *     1. 获取设备支持的语言列表
 *     2. 获取设备当前语言
 *     3. 设置设备语言
 */
@protocol TSLanguageInterface <TSKitBaseInterface>

/**
 * @brief Get supported language list
 * @chinese 获取设备支持的语言列表
 * 
 * @param completion 
 * EN: Completion callback
 *     - languages: Array of supported language models, empty array if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - languages: 支持的语言模型数组，获取失败时为空数组
 *     - error: 获取失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Retrieve all supported languages from the device
 * CN: 从设备获取其支持的所有语言列表
 */
- (void)getSupportedLanguagesWithCompletion:(nullable TSLanguageListResultBlock)completion;

/**
 * @brief Get current device language
 * @chinese 获取设备当前语言
 * 
 * @param completion 
 * EN: Completion callback
 *     - language: Current language model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - language: 当前语言模型，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Get the currently set language on the device
 * CN: 获取设备当前设置的语言
 */
- (void)getCurrentLanguageWithCompletion:(nullable TSLanguageResultBlock)completion;

/**
 * @brief Set device language
 * @chinese 设置设备语言
 * 
 * @param language 
 * EN: Language model to set, with code like: @"zh"
 * CN: 要设置的语言代码model，其code如：@"zh"
 * 
 * @param completion 
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Set the display language of the device.
 *     The language parameter must be one from the list returned by getSupportedLanguages,
 *     otherwise it will fail and return a parameter error.
 * CN: 设置设备的显示语言。
 *     language参数必须是getSupportedLanguages返回的语言列表中的一个，
 *     否则会设置失败并返回参数错误。
 */
- (void)setLanguage:(TSLanguageModel *)language
         completion:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
