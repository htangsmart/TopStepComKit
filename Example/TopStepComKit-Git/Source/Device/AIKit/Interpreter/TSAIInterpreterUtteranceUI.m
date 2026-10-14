//
//  TSAIInterpreterUtteranceUI.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterUtteranceUI.h"

@implementation TSAIInterpreterUtteranceUI

- (instancetype)init {
    self = [super init];
    if (self) {
        _audioData = [NSMutableData data];
        _audioFormat = TSAIAudioFormatNone;
    }
    return self;
}

- (NSTimeInterval)latency {
    if (self.originalFinalDate == nil || self.translatedFinalDate == nil) {
        return -1;
    }
    return [self.translatedFinalDate timeIntervalSinceDate:self.originalFinalDate];
}

- (BOOL)isComplete {
    return self.isOriginalFinal && self.isTranslatedFinal;
}

@end
