//
//  TSAIQATextRound.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQATextRound.h"

@interface TSAIQATextRound ()

@property (nonatomic, strong, readwrite) NSDate *startedAt;

@end

@implementation TSAIQATextRound

#pragma mark - 公开方法

/** 创建等待回答的轮次 */
+ (instancetype)roundWithQuestion:(NSString *)question taskId:(NSString *)taskId {
    TSAIQATextRound *round = [[self alloc] init];
    round.question = question ?: @"";
    round.taskId = taskId ?: @"";
    round.answer = @"";
    round.state = TSAIQATextRoundStatePending;
    round.source = TSAIQARoundSourceText;
    round.startedAt = [NSDate date];
    return round;
}

/** 创建正在拾音 / 识别的语音轮次 */
+ (instancetype)voiceRoundWithSource:(TSAIQARoundSource)source {
    TSAIQATextRound *round = [[self alloc] init];
    round.question = @"";
    round.taskId = @"";
    round.answer = @"";
    round.state = TSAIQATextRoundStateRecognizing;
    round.source = source;
    round.startedAt = [NSDate date];
    return round;
}

/** 是否已到终态 */
- (BOOL)isTerminal {
    return self.state == TSAIQATextRoundStateCompleted ||
           self.state == TSAIQATextRoundStateFailed ||
           self.state == TSAIQATextRoundStateCancelled;
}

/** 标记终态并记录耗时 */
- (void)finishWithState:(TSAIQATextRoundState)state error:(NSError *)error {
    self.state = state;
    self.error = error;
    self.deltaText = nil;
    self.duration = [[NSDate date] timeIntervalSinceDate:self.startedAt];
}

@end
