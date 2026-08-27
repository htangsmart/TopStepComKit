//
//  TSAIDeviceQuestionAnswerCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"
#import "TSAIDeviceQuestionAnswerOutputSink.h"
#import "TSAIQuestionAnswerProvider.h"
#import "TSAISpeechProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal coordinator for device-initiated AI question-answer
 * @chinese 设备发起 AI 问答的内部编排器
 */
@interface TSAIDeviceQuestionAnswerCoordinator : NSObject

/**
 * @brief App-side complete-audio playback sink
 * @chinese App 侧完整音频播放输出对象
 */
@property (nonatomic, weak, nullable) id<TSAIDeviceQuestionAnswerOutputSink> outputSink;

/**
 * @brief Create a coordinator bound to AI providers and one device bridge
 * @chinese 创建绑定 AI Provider 与设备 Bridge 的编排器
 * @param speechProvider EN: Provider for PCM ASR and TTS. CN: PCM ASR 与 TTS Provider。
 * @param questionAnswerProvider EN: Provider for streaming question answering. CN: 流式问答 Provider。
 * @param deviceBridge EN: Device question-answer transport. CN: 设备问答传输 Bridge。
 * @return EN: A coordinator instance. CN: 编排器实例。
 */
- (instancetype)initWithSpeechProvider:(id<TSAISpeechProvider>)speechProvider
                questionAnswerProvider:(id<TSAIQuestionAnswerProvider>)questionAnswerProvider
                          deviceBridge:(id<TSAIDeviceQuestionAnswerBridge>)deviceBridge
    NS_DESIGNATED_INITIALIZER;

/** @brief Enter the device question-answer scene @chinese 进入设备问答场景 */
- (void)handleDeviceQuestionAnswerDidEnter;

/** @brief Exit and cancel the device question-answer scene @chinese 退出并取消设备问答场景 */
- (void)handleDeviceQuestionAnswerDidExit;

/** @brief Begin a new question voice input @chinese 开始新一轮问题语音输入 */
- (void)handleDeviceQuestionAnswerVoiceDidBegin;

/**
 * @brief Append incremental question audio
 * @chinese 追加问题增量音频
 * @param opusData EN: Incremental Opus data, currently ignored. CN: 增量 Opus 数据，当前忽略。
 * @param pcmData EN: Incremental 16 kHz mono Int16LE PCM. CN: 增量 16 kHz 单声道 Int16LE PCM。
 */
- (void)handleDeviceQuestionAnswerOpusData:(nullable NSData *)opusData
                                    pcmData:(nullable NSData *)pcmData;

/** @brief Stop the current voice input and start one-shot ASR @chinese 结束当前语音输入并启动一次性 ASR */
- (void)handleDeviceQuestionAnswerVoiceDidStop;

/**
 * @brief Handle a reserved device confirmation event
 * @chinese 处理预留的设备确认事件
 * @discussion EN: The current no-confirmation flow intentionally ignores it.
 *             CN: 当前免确认流程会主动忽略此事件。
 */
- (void)handleDeviceQuestionAnswerDidConfirm;

/** @brief Cancel all work and invalidate late callbacks @chinese 取消全部任务并使迟到回调失效 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
