//
//  TSAITranslateDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAITranslatePartialResult.h"
#import "TSAITranslateResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAITranslatePartialBlock)(TSAITranslatePartialResult *partial);
typedef void(^TSAITranslateCompletionBlock)(TSAITranslateResult * _Nullable result,
                                            NSError * _Nullable error);

NS_ASSUME_NONNULL_END
