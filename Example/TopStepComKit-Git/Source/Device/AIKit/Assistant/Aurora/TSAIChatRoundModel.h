//
//  TSAIChatRoundModel.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSAIChatIntent;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Round state shared by the chat bubbles and the flow transcript
 * @chinese 对话气泡与畅聊记录共用的轮状态
 */
typedef NS_ENUM(NSInteger, TSAIChatRoundState) {
    /// 录音中（按住）
    TSAIChatRoundStateRecording = 0,
    /// 识别中（Question 流式）
    TSAIChatRoundStateRecognizing,
    /// 回答中（Answer 流式）
    TSAIChatRoundStateAnswering,
    /// 播放中
    TSAIChatRoundStateSpeaking,
    /// 已完成
    TSAIChatRoundStateDone,
    /// 出错
    TSAIChatRoundStateError,
};

/**
 * @brief Where the question came from
 * @chinese 问题来源
 */
typedef NS_ENUM(NSInteger, TSAIChatRoundSource) {
    /// 语音（按住 / 耳机唤醒 / 畅聊）
    TSAIChatRoundSourceVoice = 0,
    /// 文字（输入框 / 建议 chip）
    TSAIChatRoundSourceText,
};

/**
 * @brief How the App handled the intents of this round
 * @chinese 本轮意图在 App 侧的处理状态
 */
typedef NS_ENUM(NSInteger, TSAIChatRoundIntentStatus) {
    /// 无需 App 处理 / 仅展示 (Nothing to do, display only)
    TSAIChatRoundIntentStatusNone = 0,
    /// App 正在处理（如获取定位） (App is handling it, e.g. fetching location)
    TSAIChatRoundIntentStatusPending,
    /// 已处理并得到回答 (Handled and answered)
    TSAIChatRoundIntentStatusExecuted,
    /// 处理失败 (Handling failed)
    TSAIChatRoundIntentStatusFailed,
    /// 当前设备 / App 执行不了的指令意图（如播放音乐、调音量、拍照） (Command intent this device / App cannot execute, e.g. play music, volume, photo)
    TSAIChatRoundIntentStatusUnsupported,
};

/**
 * @brief One question / answer round shown on the AI chat screen
 * @chinese AI 对话页展示的一轮问答
 */
@interface TSAIChatRoundModel : NSObject

/** @brief Unique id (also keys the "already popped in" set) @chinese 唯一标识（同时用于记录是否已入场） */
@property (nonatomic, copy, readonly) NSString *roundId;

/** @brief Source @chinese 来源 */
@property (nonatomic, assign) TSAIChatRoundSource source;

/** @brief State @chinese 状态 */
@property (nonatomic, assign) TSAIChatRoundState state;

/** @brief Cumulative question text @chinese 累计问题文本 */
@property (nonatomic, copy, nullable) NSString *question;

/** @brief Whether the question is final @chinese 问题是否定稿 */
@property (nonatomic, assign) BOOL questionFinal;

/** @brief Cumulative answer text @chinese 累计回答文本 */
@property (nonatomic, copy, nullable) NSString *answer;

/** @brief Whether the answer is final @chinese 回答是否定稿 */
@property (nonatomic, assign) BOOL answerFinal;

/** @brief Voice input duration in seconds @chinese 语音输入时长（秒） */
@property (nonatomic, assign) NSTimeInterval inputDuration;

/** @brief Error text for the error state @chinese 出错态的错误原因 */
@property (nonatomic, copy, nullable) NSString *errorText;

/**
 * @brief Original round failure
 * @chinese 本轮原始失败
 * @discussion
 * [EN]: Retains the SDK error including its domain, code and underlying error.
 * [CN]: 保留 SDK 错误对象及其错误域、错误码和底层错误。
 * @note
 * [EN]: Nil until a typed failure is received.
 * [CN]: 收到带类型的失败之前为 nil。
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 * @brief Error bubble body
 * @chinese 出错气泡正文
 * @discussion
 * [EN]: Describes the specific failure and recovery action.
 * [CN]: 说明具体失败原因和恢复操作。
 * @note
 * [EN]: Nil uses a generic request failure message.
 * [CN]: 为 nil 时使用通用请求失败提示。
 */
@property (nonatomic, copy, nullable) NSString *errorBodyText;

/** @brief Intent handling status @chinese 意图处理状态 */
@property (nonatomic, assign) TSAIChatRoundIntentStatus intentStatus;

/** @brief Progress text shown while answering (e.g. "正在获取位置…"); nil shows the default @chinese 回答中显示的进度文案（如「正在获取位置…」）；nil 显示默认 */
@property (nonatomic, copy, nullable) NSString *statusText;

/** @brief Recognized intents @chinese 识别到的意图 */
@property (nonatomic, strong, readonly) NSMutableArray<TSAIChatIntent *> *intents;

/** @brief Cached answer PCM (16k mono 16-bit) for replay @chinese 缓存的回答 PCM（16k 单声道 16bit），供「播放」 */
@property (nonatomic, strong, readonly) NSMutableData *answerPCM;

/** @brief Cached user PCM when available @chinese 可用时缓存的用户录音 PCM */
@property (nonatomic, strong, readonly) NSMutableData *questionPCM;

/** @brief SDK round index this model maps to (-1 when unknown) @chinese 对应的 SDK roundIndex（未知为 -1） */
@property (nonatomic, assign) NSInteger sdkRoundIndex;

/**
 * @brief Create a round
 * @chinese 创建一轮
 * @param source EN: Source. CN: 来源。
 */
+ (instancetype)roundWithSource:(TSAIChatRoundSource)source;

/** @brief Whether the round is still in progress @chinese 该轮是否仍在进行 */
- (BOOL)isInProgress;

/**
 * @brief Mark the round failed while retaining the question and original error
 * @chinese 标记本轮失败，保留原问题和原始错误
 * @param error
 * EN: Original SDK failure.
 * CN: SDK 原始失败。
 */
- (void)failWithError:(NSError *)error;

/**
 * @brief Resolve a user-facing title from the typed error
 * @chinese 根据错误类型生成用户可读的标题
 * @param error
 * EN: Original failure.
 * CN: 原始失败。
 * @return
 * EN: Display title.
 * CN: 展示标题。
 */
+ (NSString *)errorTitleForError:(NSError *)error;

/**
 * @brief Resolve recovery text without treating service failures as missing speech
 * @chinese 生成恢复提示，不把服务失败解释为未识别到语音
 * @param error
 * EN: Original failure.
 * CN: 原始失败。
 * @return
 * EN: Display body.
 * CN: 展示正文。
 */
+ (NSString *)errorBodyForError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
