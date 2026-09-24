//
//  TSAIQADeviceRound.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQADeviceRound.h"

@interface TSAIQADeviceRound ()

@property (nonatomic, copy, readwrite) NSString *roundIdentifier;
@property (nonatomic, copy, readwrite) NSString *sessionIdentifier;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) NSInteger sequence;
@property (nonatomic, copy, readwrite) NSString *question;
@property (nonatomic, copy, readwrite) NSString *answer;
@property (nonatomic, assign, readwrite) TSAIDeviceQuestionAnswerPhase phase;
@property (nonatomic, strong, readwrite, nullable) NSError *error;
@property (nonatomic, assign, readwrite) NSTimeInterval startedAt;
@property (nonatomic, assign, readwrite) NSTimeInterval updatedAt;

@end

@implementation TSAIQADeviceRound

#pragma mark - 生命周期

/** 用首个事件创建轮次 */
- (instancetype)initWithEvent:(TSAIDeviceQuestionAnswerEvent *)event index:(NSUInteger)index {
    self = [super init];
    if (self) {
        _roundIdentifier = [event.roundIdentifier copy] ?: @"";
        _sessionIdentifier = [event.sessionIdentifier copy] ?: @"";
        _index = index;
        _sequence = -1;
        _question = @"";
        _answer = @"";
        _phase = TSAIDeviceQuestionAnswerPhaseQuestion;
        _startedAt = event.occurredAt > 0 ? event.occurredAt : [[NSDate date] timeIntervalSince1970];
        _updatedAt = _startedAt;
        [self applyEvent:event];
    }
    return self;
}

#pragma mark - 公开方法

/** 应用一条累计快照，落后或不属于本轮的事件返回 NO */
- (BOOL)applyEvent:(TSAIDeviceQuestionAnswerEvent *)event {
    if (!event || ![event.roundIdentifier isEqualToString:self.roundIdentifier]) {
        return NO;
    }
    if (event.sequence <= self.sequence) {
        return NO;
    }
    // 终态之后不再接受同轮次的后续快照
    if ([self isTerminal]) {
        return NO;
    }
    self.sequence = event.sequence;
    if (event.sessionIdentifier.length > 0) {
        self.sessionIdentifier = event.sessionIdentifier;
    }
    self.question = event.question ?: self.question;
    self.answer = event.answer ?: self.answer;
    self.phase = event.phase;
    self.error = event.error;
    self.updatedAt = event.occurredAt > 0 ? event.occurredAt : [[NSDate date] timeIntervalSince1970];
    return YES;
}

/** 本地标记为已取消 */
- (void)markCancelledWithError:(NSError *)error {
    if ([self isTerminal]) {
        return;
    }
    self.phase = TSAIDeviceQuestionAnswerPhaseCancelled;
    self.error = error;
    self.updatedAt = [[NSDate date] timeIntervalSince1970];
}

/** 是否已到终态 */
- (BOOL)isTerminal {
    return self.phase == TSAIDeviceQuestionAnswerPhaseCompleted ||
           self.phase == TSAIDeviceQuestionAnswerPhaseFailed ||
           self.phase == TSAIDeviceQuestionAnswerPhaseCancelled;
}

@end
