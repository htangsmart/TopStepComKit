//
//  TSAIInterpreterFormatter.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterFormatter.h"

#import "TSRootVC.h"

@implementation TSAIInterpreterFormatter

+ (NSString *)displayNameForLanguage:(TSAILanguage)language {
    switch (language) {
        case TSAILanguageAuto:               return TSLocalizedString(@"ai_interpreter.lang.auto");
        case TSAILanguageChineseSimplified:  return TSLocalizedString(@"ai_interpreter.lang.zh_cn");
        case TSAILanguageChineseTraditional: return TSLocalizedString(@"ai_interpreter.lang.zh_tw");
        case TSAILanguageEnglishUS:          return TSLocalizedString(@"ai_interpreter.lang.en_us");
        case TSAILanguageEnglishUK:          return TSLocalizedString(@"ai_interpreter.lang.en_gb");
        case TSAILanguageJapanese:           return TSLocalizedString(@"ai_interpreter.lang.ja");
        case TSAILanguageKorean:             return TSLocalizedString(@"ai_interpreter.lang.ko");
        case TSAILanguageFrench:             return TSLocalizedString(@"ai_interpreter.lang.fr");
        case TSAILanguageGerman:             return TSLocalizedString(@"ai_interpreter.lang.de");
        case TSAILanguageSpanish:            return TSLocalizedString(@"ai_interpreter.lang.es");
        case TSAILanguageRussian:            return TSLocalizedString(@"ai_interpreter.lang.ru");
        case TSAILanguageUnknown:
        default:                             return TSLocalizedString(@"ai_interpreter.lang.unset");
    }
}

+ (NSString *)displayNameForEndReason:(TSAIInterpreterEndReason)reason {
    switch (reason) {
        case TSAIInterpreterEndReasonUserStop:    return TSLocalizedString(@"ai_interpreter.endreason.userstop");
        case TSAIInterpreterEndReasonInterrupted: return TSLocalizedString(@"ai_interpreter.endreason.interrupted");
        case TSAIInterpreterEndReasonError:       return TSLocalizedString(@"ai_interpreter.endreason.error");
        case TSAIInterpreterEndReasonUnknown:
        default:                                  return TSLocalizedString(@"general.unknown");
    }
}

+ (NSArray<NSNumber *> *)concreteLanguageList {
    return @[
        @(TSAILanguageChineseSimplified),
        @(TSAILanguageChineseTraditional),
        @(TSAILanguageEnglishUS),
        @(TSAILanguageEnglishUK),
        @(TSAILanguageJapanese),
        @(TSAILanguageKorean),
        @(TSAILanguageFrench),
        @(TSAILanguageGerman),
        @(TSAILanguageSpanish),
        @(TSAILanguageRussian),
    ];
}

+ (NSString *)shortIdForTaskId:(NSString *)taskId {
    if (taskId.length == 0) return @"";
    if (taskId.length <= 8) return taskId;
    return [NSString stringWithFormat:@"%@…%@",
              [taskId substringToIndex:4],
              [taskId substringFromIndex:taskId.length - 4]];
}

@end
