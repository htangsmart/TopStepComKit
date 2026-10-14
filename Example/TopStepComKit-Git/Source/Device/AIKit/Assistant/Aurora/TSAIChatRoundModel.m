//
//  TSAIChatRoundModel.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatRoundModel.h"

@interface TSAIChatRoundModel ()

@property (nonatomic, copy, readwrite) NSString *roundId;
@property (nonatomic, strong, readwrite) NSMutableArray<TSAIChatIntent *> *intents;
@property (nonatomic, strong, readwrite) NSMutableData *answerPCM;
@property (nonatomic, strong, readwrite) NSMutableData *questionPCM;

@end

@implementation TSAIChatRoundModel

#pragma mark - 公开方法

+ (instancetype)roundWithSource:(TSAIChatRoundSource)source {
    TSAIChatRoundModel *round = [[TSAIChatRoundModel alloc] init];
    round.source = source;
    return round;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _roundId = [NSUUID UUID].UUIDString;
        _state = TSAIChatRoundStateRecording;
        _intents = [NSMutableArray array];
        _answerPCM = [NSMutableData data];
        _questionPCM = [NSMutableData data];
        _sdkRoundIndex = -1;
    }
    return self;
}

- (BOOL)isInProgress {
    return self.state != TSAIChatRoundStateDone && self.state != TSAIChatRoundStateError;
}

@end
