//
//  TSAIBudsInterpreterConfigMapper+Private.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/24.
//

#import <Foundation/Foundation.h>

@class AIBudsSimultaneousInterpretationConfig;
@class TSAIInterpreterConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal mapper for the AIBuds simultaneous-interpretation configuration
 * @chinese AIBuds 同声传译配置内部映射器
 */
@interface TSAIBudsInterpreterConfigMapper : NSObject

/**
 * @brief Convert the vendor-neutral interpreter configuration to an AIBuds configuration
 * @chinese 将厂商无关同传配置转换为 AIBuds 配置
 *
 * @param config
 * EN: Vendor-neutral interpreter configuration
 * CN: 厂商无关同传配置
 * @param sourceLanguageCode
 * EN: AIBuds source-language code
 * CN: AIBuds 源语言代码
 * @param targetLanguageCode
 * EN: AIBuds target-language code
 * CN: AIBuds 目标语言代码
 * @param usesInternalAudioRecording
 * EN: Whether AIBuds owns microphone capture
 * CN: 是否由 AIBuds 持有麦克风采集
 *
 * @return
 * EN: A mapped AIBuds configuration
 * CN: 映射后的 AIBuds 配置
 */
+ (AIBudsSimultaneousInterpretationConfig *)budsConfigFromConfig:(TSAIInterpreterConfig *)config
                                              sourceLanguageCode:(NSString *)sourceLanguageCode
                                              targetLanguageCode:(NSString *)targetLanguageCode
                                      usesInternalAudioRecording:(BOOL)usesInternalAudioRecording;

@end

NS_ASSUME_NONNULL_END
