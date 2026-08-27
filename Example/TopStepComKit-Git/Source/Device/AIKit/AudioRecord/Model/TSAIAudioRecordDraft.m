//
//  TSAIAudioRecordDraft.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIAudioRecordDraft.h"

#import <TopStepAIKit/TSAIAudioRecordSessionResult.h>
#import <TopStepAIKit/TSAIAudioRecordSpeakerSegment.h>

@implementation TSAIAudioRecordTranscriptItem

/** 复制转写条目 */
- (id)copyWithZone:(NSZone *)zone {
    TSAIAudioRecordTranscriptItem *copy = [[[self class] allocWithZone:zone] init];
    copy.sentenceIndex = self.sentenceIndex;
    copy.text = self.text;
    copy.isFinal = self.isFinal;
    copy.languageCode = self.languageCode;
    copy.speakerIdentifier = self.speakerIdentifier;
    copy.startTimeMilliseconds = self.startTimeMilliseconds;
    copy.endTimeMilliseconds = self.endTimeMilliseconds;
    return copy;
}

@end

@implementation TSAIAudioRecordEventItem

/** 复制事件条目 */
- (id)copyWithZone:(NSZone *)zone {
    TSAIAudioRecordEventItem *copy = [[[self class] allocWithZone:zone] init];
    copy.eventType = self.eventType;
    copy.timeSinceSessionStart = self.timeSinceSessionStart;
    copy.evidence = self.evidence;
    copy.details = self.details;
    return copy;
}

@end

@interface TSAIAudioRecordDraft ()

// 按句序号索引的转写缓存
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, TSAIAudioRecordTranscriptItem *> *transcriptMap;
// 当前事件缓存
@property (nonatomic, strong) NSMutableArray<TSAIAudioRecordEventItem *> *mutableEventItems;

@end

@implementation TSAIAudioRecordDraft

#pragma mark - 生命周期

/** 初始化空录音草稿 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _recordIdentifier = NSUUID.UUID.UUIDString;
        _title = @"AI Recording";
        _startDate = [NSDate date];
        _transcriptMap = [NSMutableDictionary dictionary];
        _mutableEventItems = [NSMutableArray array];
        _transcriptItems = @[];
        _eventItems = @[];
    }
    return self;
}

#pragma mark - 公开方法

/** 创建新会话草稿 */
+ (instancetype)draftWithScene:(TSAIAudioRecordScene)scene
                      language:(TSAILanguage)language
                        source:(TSAIAudioRecordSessionSource)source
                     startDate:(NSDate *)startDate {
    TSAIAudioRecordDraft *draft = [[self alloc] init];
    draft.scene = scene;
    draft.language = language;
    draft.source = source;
    draft.startDate = startDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    draft.title = [NSString stringWithFormat:@"AI Recording %@", [formatter stringFromDate:startDate]];
    return draft;
}

/** 合并一条会话语义结果 */
- (void)applySessionResult:(TSAIAudioRecordSessionResult *)result {
    if (!result) {
        return;
    }
    switch (result.type) {
        case TSAIAudioRecordSessionResultTypeTranscript:
            [self applyTranscriptResult:result];
            break;
        case TSAIAudioRecordSessionResultTypeEvent:
            [self applyEventResult:result];
            break;
        case TSAIAudioRecordSessionResultTypeError:
            self.runtimeError = result.error;
            self.isIncomplete = YES;
            break;
        case TSAIAudioRecordSessionResultTypeFinish:
            [self applyFinishResult:result];
            break;
    }
}

/** 生成 JSON 兼容元数据 */
- (NSDictionary<NSString *, id> *)dictionaryRepresentation {
    NSMutableArray *transcripts = [NSMutableArray array];
    for (TSAIAudioRecordTranscriptItem *item in self.transcriptItems) {
        [transcripts addObject:@{
            @"sentenceIndex": @(item.sentenceIndex), @"text": item.text ?: @"",
            @"isFinal": @(item.isFinal), @"languageCode": item.languageCode ?: @"",
            @"speakerIdentifier": item.speakerIdentifier ?: @"",
            @"startTimeMilliseconds": @(item.startTimeMilliseconds),
            @"endTimeMilliseconds": @(item.endTimeMilliseconds),
        }];
    }
    NSMutableArray *events = [NSMutableArray array];
    for (TSAIAudioRecordEventItem *item in self.eventItems) {
        [events addObject:@{
            @"eventType": @(item.eventType), @"timeSinceSessionStart": @(item.timeSinceSessionStart),
            @"evidence": item.evidence ?: @"", @"details": item.details ?: @"",
        }];
    }
    return @{
        @"recordIdentifier": self.recordIdentifier, @"title": self.title,
        @"scene": @(self.scene), @"language": @(self.language), @"source": @(self.source),
        @"startTimestamp": @([self.startDate timeIntervalSince1970]),
        @"durationMilliseconds": @(self.durationMilliseconds),
        @"transcripts": transcripts, @"events": events,
        @"audioRelativePath": self.storedAudioRelativePath ?: @"",
        @"runtimeError": self.runtimeError.localizedDescription ?: @"",
        @"isIncomplete": @(self.isIncomplete), @"isOfflineRecording": @(self.isOfflineRecording),
        @"hadNetworkDisconnection": @(self.hadNetworkDisconnection),
    };
}

/** 统计不重复说话人数量 */
- (NSUInteger)speakerCount {
    NSMutableSet<NSString *> *speakers = [NSMutableSet set];
    for (TSAIAudioRecordTranscriptItem *item in self.transcriptItems) {
        if (item.speakerIdentifier.length > 0) {
            [speakers addObject:item.speakerIdentifier];
        }
    }
    return speakers.count;
}

/** 复制录音草稿快照 */
- (id)copyWithZone:(NSZone *)zone {
    TSAIAudioRecordDraft *copy = [[[self class] allocWithZone:zone] init];
    copy.recordIdentifier = self.recordIdentifier;
    copy.title = self.title;
    copy.scene = self.scene;
    copy.language = self.language;
    copy.source = self.source;
    copy.startDate = self.startDate;
    copy.durationMilliseconds = self.durationMilliseconds;
    copy.transcriptItems = [[NSArray alloc] initWithArray:self.transcriptItems copyItems:YES];
    copy.eventItems = [[NSArray alloc] initWithArray:self.eventItems copyItems:YES];
    copy.rawAudioFilePath = self.rawAudioFilePath;
    copy.storedAudioRelativePath = self.storedAudioRelativePath;
    copy.runtimeError = self.runtimeError;
    copy.isIncomplete = self.isIncomplete;
    copy.isOfflineRecording = self.isOfflineRecording;
    copy.hadNetworkDisconnection = self.hadNetworkDisconnection;
    return copy;
}

#pragma mark - 私有方法

/** 合并流式转写结果 */
- (void)applyTranscriptResult:(TSAIAudioRecordSessionResult *)result {
    NSNumber *key = @(result.sentenceIndex);
    TSAIAudioRecordTranscriptItem *item = self.transcriptMap[key];
    if (!item) {
        item = [[TSAIAudioRecordTranscriptItem alloc] init];
        item.sentenceIndex = result.sentenceIndex;
        self.transcriptMap[key] = item;
    }
    item.text = result.text ?: item.text ?: @"";
    item.isFinal = result.isSentenceFinal;
    item.languageCode = result.languageCode;
    [self applySpeakerSegments:result.speakerSegments toTranscript:item sequence:result.sequence];
    [self refreshTranscriptSnapshot];
}

/** 追加会话事件 */
- (void)applyEventResult:(TSAIAudioRecordSessionResult *)result {
    TSAIAudioRecordEventItem *item = [[TSAIAudioRecordEventItem alloc] init];
    item.eventType = result.eventType;
    item.timeSinceSessionStart = result.timeSinceSessionStart;
    item.evidence = result.evidence;
    item.details = result.details;
    [self.mutableEventItems addObject:item];
    self.eventItems = [self.mutableEventItems copy];
}

/** 合并最终会话报告 */
- (void)applyFinishResult:(TSAIAudioRecordSessionResult *)result {
    if (result.transcripts.count > 0 && self.transcriptMap.count == 0) {
        [result.transcripts enumerateObjectsUsingBlock:^(NSString *text, NSUInteger index, BOOL *stop) {
            TSAIAudioRecordTranscriptItem *item = [[TSAIAudioRecordTranscriptItem alloc] init];
            item.sentenceIndex = (NSInteger)index;
            item.text = text ?: @"";
            item.isFinal = YES;
            self.transcriptMap[@(index)] = item;
        }];
        [self refreshTranscriptSnapshot];
    }
    for (TSAIAudioRecordSessionResult *event in result.sessionEvents) {
        [self applyEventResult:event];
    }
    self.rawAudioFilePath = result.rawAudioFilePath;
    self.isOfflineRecording = result.isOfflineRecording;
    self.hadNetworkDisconnection = result.hadNetworkDisconnection;
    self.isIncomplete = self.isIncomplete || result.isStoppedByInterruption ||
                        result.hadNetworkDisconnection;
}

/** 将说话人片段映射到当前转写 */
- (void)applySpeakerSegments:(NSArray<TSAIAudioRecordSpeakerSegment *> *)segments
                toTranscript:(TSAIAudioRecordTranscriptItem *)item
                    sequence:(NSInteger)sequence {
    for (TSAIAudioRecordSpeakerSegment *segment in segments) {
        BOOL isMatching = segment.associatedTranscriptSequence == item.sentenceIndex ||
                          segment.associatedTranscriptSequence == sequence;
        if (!isMatching) {
            continue;
        }
        item.speakerIdentifier = segment.speakerId;
        item.startTimeMilliseconds = segment.startTimeMilliseconds;
        item.endTimeMilliseconds = segment.endTimeMilliseconds;
        if (segment.text.length > 0) {
            item.text = segment.text;
        }
        break;
    }
}

/** 刷新已排序转写快照 */
- (void)refreshTranscriptSnapshot {
    NSArray<NSNumber *> *keys = [self.transcriptMap.allKeys
        sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray<TSAIAudioRecordTranscriptItem *> *items = [NSMutableArray array];
    for (NSNumber *key in keys) {
        TSAIAudioRecordTranscriptItem *item = self.transcriptMap[key];
        if (item) {
            [items addObject:item];
        }
    }
    self.transcriptItems = [items copy];
}

@end
