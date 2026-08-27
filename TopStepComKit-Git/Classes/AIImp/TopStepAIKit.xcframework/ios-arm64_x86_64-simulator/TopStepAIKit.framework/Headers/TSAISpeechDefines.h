//
//  TSAISpeechDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIASRDeviceMicResult.h"
#import "TSAIASRPartialResult.h"
#import "TSAIASRResult.h"
#import "TSAITTSResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAITTSCompletionBlock)(TSAITTSResult * _Nullable result,
                                      NSError * _Nullable error);
typedef void(^TSAIASRPartialBlock)(TSAIASRPartialResult *partial);
typedef void(^TSAIASRCompletionBlock)(TSAIASRResult * _Nullable result,
                                      NSError * _Nullable error);
typedef void(^TSAIASRDeviceMicCompletionBlock)(TSAIASRDeviceMicResult * _Nullable result,
                                               NSError * _Nullable error);

typedef NS_ENUM(NSInteger, TSAIDeviceMicRecognitionState) {
    TSAIDeviceMicRecognitionStateDeviceStopped = 0,
    TSAIDeviceMicRecognitionStateStarted = 1,
    TSAIDeviceMicRecognitionStateEnded = 2,
    TSAIDeviceMicRecognitionStateFailure = 255,
};

typedef NS_ENUM(NSInteger, TSAISpeechRecognitionMode) {
    TSAISpeechRecognitionModeOff = 0,
    TSAISpeechRecognitionModeOn = 1,
};

typedef void(^TSAIDeviceMicRecognitionStateBlock)(TSAIDeviceMicRecognitionState state);
typedef void(^TSAISpeechBoolResultBlock)(BOOL success, BOOL result, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
