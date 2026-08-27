//
//  TSAIInterpreterDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIInterpreterContent.h"
#import "TSAIInterpreterEvent.h"
#import "TSAIInterpreterReport.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAIInterpreterContentBlock)(TSAIInterpreterContent *content);
typedef void(^TSAIInterpreterEventBlock)(TSAIInterpreterEvent *event);
typedef void(^TSAIInterpreterCompletionBlock)(TSAIInterpreterReport * _Nullable report,
                                              NSError * _Nullable error);

typedef NS_ENUM(NSInteger, TSAIInterpreterState) {
    TSAIInterpreterStateIdle = 0,
    TSAIInterpreterStateStarted = 1,
    TSAIInterpreterStateProcessing = 2,
    TSAIInterpreterStateEnded = 3,
    TSAIInterpreterStateFailure = 255,
};

typedef void(^TSAIInterpreterStateBlock)(TSAIInterpreterState state);

NS_ASSUME_NONNULL_END
