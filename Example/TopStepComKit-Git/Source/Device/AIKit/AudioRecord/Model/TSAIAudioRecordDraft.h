//
//  TSAIAudioRecordDraft.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TopStepAIKit/TSAIDefines.h>
#import <TopStepAIKit/TSAudioRecordDefines.h>

#import "TSAIAudioRecordSessionState.h"

@class TSAIAudioRecordSessionResult;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One normalized transcript sentence for Demo rendering and persistence
 * @chinese 用于 Demo 展示和保存的一条标准化转写句
 */
@interface TSAIAudioRecordTranscriptItem : NSObject <NSCopying>

/** @brief Sentence index @chinese 句序号 */
@property (nonatomic, assign) NSInteger sentenceIndex;

/** @brief Transcript text @chinese 转写文本 */
@property (nonatomic, copy) NSString *text;

/** @brief Whether the sentence is final @chinese 当前句是否已定稿 */
@property (nonatomic, assign) BOOL isFinal;

/** @brief BCP-47 language code @chinese BCP-47 语言码 */
@property (nonatomic, copy, nullable) NSString *languageCode;

/** @brief Speaker identifier @chinese 说话人标识 */
@property (nonatomic, copy, nullable) NSString *speakerIdentifier;

/** @brief Segment start in milliseconds @chinese 片段开始毫秒数 */
@property (nonatomic, assign) NSInteger startTimeMilliseconds;

/** @brief Segment end in milliseconds @chinese 片段结束毫秒数 */
@property (nonatomic, assign) NSInteger endTimeMilliseconds;

@end

/**
 * @brief One normalized AI recording session event
 * @chinese 一条标准化 AI 录音会话事件
 */
@interface TSAIAudioRecordEventItem : NSObject <NSCopying>

/** @brief Provider-neutral event type @chinese 厂商无关事件类型 */
@property (nonatomic, assign) NSInteger eventType;

/** @brief Seconds since session start @chinese 相对会话开始的秒数 */
@property (nonatomic, assign) NSTimeInterval timeSinceSessionStart;

/** @brief Event evidence @chinese 事件证据 */
@property (nonatomic, copy, nullable) NSString *evidence;

/** @brief Event details @chinese 事件详情 */
@property (nonatomic, copy, nullable) NSString *details;

@end

/**
 * @brief Mutable draft owned by the AI recording coordinator
 * @chinese AI 录音协调器持有的可变会话草稿
 */
@interface TSAIAudioRecordDraft : NSObject <NSCopying>

/** @brief Stable record identifier @chinese 稳定录音标识 */
@property (nonatomic, copy) NSString *recordIdentifier;

/** @brief Suggested display title @chinese 建议展示标题 */
@property (nonatomic, copy) NSString *title;

/** @brief Recording scene @chinese 录音场景 */
@property (nonatomic, assign) TSAIAudioRecordScene scene;

/** @brief Recording language @chinese 录音语言 */
@property (nonatomic, assign) TSAILanguage language;

/** @brief Initiation source @chinese 发起来源 */
@property (nonatomic, assign) TSAIAudioRecordSessionSource source;

/** @brief Session start date @chinese 会话开始时间 */
@property (nonatomic, strong) NSDate *startDate;

/** @brief Duration in milliseconds @chinese 时长，单位毫秒 */
@property (nonatomic, assign) NSInteger durationMilliseconds;

/** @brief Sorted transcript snapshot @chinese 已排序转写快照 */
@property (nonatomic, copy) NSArray<TSAIAudioRecordTranscriptItem *> *transcriptItems;

/** @brief Session-event snapshot @chinese 会话事件快照 */
@property (nonatomic, copy) NSArray<TSAIAudioRecordEventItem *> *eventItems;

/** @brief Provider temporary audio path @chinese Provider 临时音频路径 */
@property (nonatomic, copy, nullable) NSString *rawAudioFilePath;

/** @brief Stored relative audio path @chinese 保存后的相对音频路径 */
@property (nonatomic, copy, nullable) NSString *storedAudioRelativePath;

/** @brief Latest runtime error @chinese 最近一次运行错误 */
@property (nonatomic, strong, nullable) NSError *runtimeError;

/** @brief Whether the result is incomplete @chinese 结果是否不完整 */
@property (nonatomic, assign) BOOL isIncomplete;

/** @brief Whether this was offline recording @chinese 是否离线录音 */
@property (nonatomic, assign) BOOL isOfflineRecording;

/** @brief Whether network disconnected during the session @chinese 会话期间是否断网 */
@property (nonatomic, assign) BOOL hadNetworkDisconnection;

/**
 * @brief Create a draft for a new generation
 * @chinese 为新代次创建会话草稿
 * @param scene EN: Recording scene. CN: 录音场景。
 * @param language EN: Speech language. CN: 语音语言。
 * @param source EN: Initiation source. CN: 发起来源。
 * @param startDate EN: Session start date. CN: 会话开始时间。
 * @return EN: Initialized draft. CN: 初始化后的草稿。
 */
+ (instancetype)draftWithScene:(TSAIAudioRecordScene)scene
                      language:(TSAILanguage)language
                        source:(TSAIAudioRecordSessionSource)source
                     startDate:(NSDate *)startDate;

/**
 * @brief Merge one SDK semantic result into the draft
 * @chinese 将一条 SDK 语义结果合并到草稿
 * @param result EN: Transcript, event, error, or finish result. CN: 转写、事件、错误或最终结果。
 */
- (void)applySessionResult:(TSAIAudioRecordSessionResult *)result;

/**
 * @brief Return a JSON-compatible metadata dictionary
 * @chinese 返回可写入 JSON 的元数据字典
 * @return EN: JSON-compatible dictionary. CN: JSON 兼容字典。
 */
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;

/**
 * @brief Count distinct nonempty speaker identifiers
 * @chinese 统计非空说话人标识数量
 * @return EN: Distinct speaker count. CN: 不重复说话人数。
 */
- (NSUInteger)speakerCount;

@end

NS_ASSUME_NONNULL_END
