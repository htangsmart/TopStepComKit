//
//  TSAITranslateConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Translate request configuration
 * @chinese 翻译请求配置
 *
 * @discussion
 * [EN]: Configuration for a single translate request. Currently exposes
 *       source / target language only; more options (formality, domain,
 *       glossary, model selection, format preservation, ...) can be added
 *       later without breaking the API.
 *
 *       `sourceLanguage` may be `TSAILanguageAuto` to let the backend
 *       detect the source language. `targetLanguage` must always be a
 *       concrete language.
 *
 * [CN]: 单次翻译请求的配置。当前仅暴露源语言 / 目标语言；
 *       后续可在不破坏接口的前提下扩展正式度、领域、术语表、
 *       模型选择、格式保留等选项。
 *
 *       `sourceLanguage` 可设为 `TSAILanguageAuto`，由后端自动检测；
 *       `targetLanguage` 必须为具体语言。
 */
@interface TSAITranslateConfig : NSObject

/**
 * @brief Source language of the input text
 * @chinese 输入文本的源语言
 *
 * @discussion
 * [EN]: Set to `TSAILanguageAuto` to enable backend auto-detection.
 *       The actually detected language is returned via
 *       `TSAITranslatePartialResult.detectedSourceLanguage` and
 *       `TSAITranslateResult.detectedSourceLanguage`.
 * [CN]: 设为 `TSAILanguageAuto` 时由后端自动检测，
 *       实际检测到的语言通过
 *       `TSAITranslatePartialResult.detectedSourceLanguage` 与
 *       `TSAITranslateResult.detectedSourceLanguage` 回传。
 */
@property (nonatomic, assign) TSAILanguage sourceLanguage;

/**
 * @brief Target language to translate into
 * @chinese 翻译目标语言
 *
 * @discussion
 * [EN]: Must be a concrete language. Assigning `TSAILanguageAuto` is
 *       rejected at the property level — it triggers an `NSAssert` in
 *       Debug builds and is silently dropped in Release builds (the
 *       previous value is kept), so an invalid `Auto` target can never be
 *       observed by downstream code.
 * [CN]: 必须为具体语言。在属性层面拒绝写入 `TSAILanguageAuto` ——
 *       Debug 下触发 `NSAssert`，Release 下静默丢弃（保持原值不变），
 *       下游代码不会观察到非法的 `Auto` 目标语言。
 */
@property (nonatomic, assign) TSAILanguage targetLanguage;

/**
 * @brief Create a config with the given source / target languages
 * @chinese 通过源语言与目标语言创建配置
 *
 * @param sourceLanguage
 * EN: Source language; pass `TSAILanguageAuto` for auto-detect
 * CN: 源语言，传 `TSAILanguageAuto` 表示自动检测
 *
 * @param targetLanguage
 * EN: Target language; must be a concrete language
 * CN: 目标语言，必须为具体语言
 *
 * @return
 * EN: A new config instance
 * CN: 新创建的配置对象
 */
+ (instancetype)configWithSourceLanguage:(TSAILanguage)sourceLanguage
                          targetLanguage:(TSAILanguage)targetLanguage;

@end

NS_ASSUME_NONNULL_END
