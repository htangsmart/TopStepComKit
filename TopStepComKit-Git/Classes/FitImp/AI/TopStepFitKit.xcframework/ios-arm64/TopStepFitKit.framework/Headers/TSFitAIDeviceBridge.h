//
//  TSFitAIDeviceBridge.h
//  TopStepFitKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import <TopStepAIKit/TSAIAudioRouteDefines.h>
#import <TopStepAIKit/TSAIDeviceAICapabilityProviding.h>
#import <TopStepAIKit/TSAIDeviceAISessionBridge.h>
#import <TopStepAIKit/TSAIDeviceBridge.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device bridge connecting Fit platform capabilities to AIKit
 * @chinese 将 Fit 平台设备能力接入 AIKit 的桥接器
 *
 * @discussion
 * [EN]: Interpreter support permits the AIBuds provider to use the phone's built-in microphone.
 * It does not indicate device-microphone or firmware translation support.
 * [CN]: 同声传译支持仅表示允许 AIBuds Provider 使用手机内置麦克风，
 * 不代表设备麦克风或固件具备翻译能力。
 */
@interface TSFitAIDeviceBridge : NSObject <
    TSAIDeviceBridge,
    TSAIAssistantDeviceBridge,
    TSAIInterpreterDeviceBridge,
    TSAIDeviceQuestionAnswerBridge,
    TSAIDeviceVoiceTranslationBridge,
    TSAISpeechDeviceBridge,
    TSAITranslateDeviceBridge,
    TSAIAudioRecordDeviceBridge,
    TSAIDevicePCMOutputBridge,
    TSAIDeviceAICapabilityProviding,
    TSAIDeviceAISessionBridge
>

/**
 * @brief Output channel used when creating device question-answer requests
 * @chinese 创建设备问答请求时使用的输出通道；Unknown 沿用设备音源映射
 */
@property (nonatomic, assign, readonly) TSAIAudioOutputChannel questionAnswerAudioOutputChannel;

/**
 * @brief Create a bridge with a fixed question-answer output channel
 * @chinese 创建固定问答输出通道的桥接器；仅影响问答，输入仍由设备请求决定
 * @param outputChannel EN: Output channel, or Unknown for the legacy mapping.
 * CN: 输出通道；Unknown 保留原映射，SystemDefault 跟随系统媒体输出且不改变设备输入。
 * @return EN: A configured bridge. CN: 已配置的桥接器，配置在其生命周期内不变。
 */
- (instancetype)initWithQuestionAnswerAudioOutputChannel:(TSAIAudioOutputChannel)outputChannel
    NS_SWIFT_NAME(init(questionAnswerAudioOutputChannel:));

/**
 * @brief Output channel used when creating device chat requests
 * @chinese 创建设备对话请求时使用的输出通道；Unknown 沿用设备音源映射
 */
@property (nonatomic, assign, readonly) TSAIAudioOutputChannel chatAudioOutputChannel;

/**
 * @brief Create a bridge with fixed chat and question-answer output channels
 * @chinese 创建固定对话与问答输出的桥接器；输入仍由设备请求决定，不自动回退
 * @param chatOutputChannel EN: Chat output, or Unknown for the legacy mapping.
 * CN: 对话输出；Unknown 保留原映射，SystemDefault 跟随系统媒体输出。
 * @param questionAnswerOutputChannel EN: Question-answer output, or Unknown for the legacy mapping.
 * CN: 问答输出；Unknown 保留原映射，SystemDefault 跟随系统媒体输出。
 * @return EN: A bridge with immutable output configuration. CN: 输出配置不可变的桥接器。
 */
- (instancetype)initWithChatAudioOutputChannel:(TSAIAudioOutputChannel)chatOutputChannel
               questionAnswerAudioOutputChannel:(TSAIAudioOutputChannel)questionAnswerOutputChannel
    NS_SWIFT_NAME(init(chatAudioOutputChannel:questionAnswerAudioOutputChannel:));

/**
 * @brief Output channel used when creating device translation requests
 * @chinese 创建设备翻译请求时使用的输出通道；Unknown 沿用设备音源映射
 */
@property (nonatomic, assign, readonly) TSAIAudioOutputChannel translationAudioOutputChannel;

/**
 * @brief Create a bridge with fixed chat, question-answer and translation outputs
 * @chinese 创建固定对话、问答和设备翻译输出的桥接器；输入仍由设备请求决定
 * @param chatOutputChannel EN: Chat output, or Unknown for the legacy mapping.
 * CN: 对话输出；Unknown 保留原映射。
 * @param questionAnswerOutputChannel EN: Question-answer output, or Unknown for the legacy mapping.
 * CN: 问答输出；Unknown 保留原映射。
 * @param translationOutputChannel EN: Translation output, or Unknown for the legacy mapping.
 * CN: 设备翻译输出；SystemDefault 跟随系统媒体输出，Unknown 保留原映射。
 * @return EN: A bridge with immutable output configuration. CN: 输出配置不可变的桥接器。
 */
- (instancetype)initWithChatAudioOutputChannel:(TSAIAudioOutputChannel)chatOutputChannel
               questionAnswerAudioOutputChannel:(TSAIAudioOutputChannel)questionAnswerOutputChannel
                  translationAudioOutputChannel:(TSAIAudioOutputChannel)translationOutputChannel
    NS_SWIFT_NAME(init(chatAudioOutputChannel:questionAnswerAudioOutputChannel:translationAudioOutputChannel:));

@end

NS_ASSUME_NONNULL_END
