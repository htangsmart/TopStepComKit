//
//  TSAIInterpreterFormatter.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterFormatter.h"

#import <TopStepAIKit/TSAILanguageMapper.h>

#import "TSRootVC.h"

@implementation TSAIInterpreterFormatter

/// 常用语言沿用本地化 key，其余语言用系统区域设置生成展示名
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
        case TSAILanguageUnknown:            return TSLocalizedString(@"ai_interpreter.lang.unset");
        default:
            break;
    }
    NSString *code = [TSAILanguageMapper bcp47CodeForLanguage:language];
    if (code.length == 0) {
        return [NSString stringWithFormat:@"#%ld", (long)language];
    }
    NSString *name = [[NSLocale currentLocale] localizedStringForLocaleIdentifier:code];
    if (name.length == 0) {
        NSString *languageCode = [code componentsSeparatedByString:@"-"].firstObject;
        name = [[NSLocale currentLocale] localizedStringForLanguageCode:languageCode];
    }
    return name.length > 0 ? name : code;
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

+ (NSString *)displayNameForInterpretationEndReason:(TSAIInterpretationEndReason)reason {
    switch (reason) {
        case TSAIInterpretationEndReasonUserStop:           return TSLocalizedString(@"ai_interpreter.end_reason.user_stop");
        case TSAIInterpretationEndReasonDeviceExit:         return TSLocalizedString(@"ai_interpreter.end_reason.device_exit");
        case TSAIInterpretationEndReasonDeviceDisconnected: return TSLocalizedString(@"ai_interpreter.end_reason.device_disconnected");
        case TSAIInterpretationEndReasonNetworkError:       return TSLocalizedString(@"ai_interpreter.end_reason.network_error");
        case TSAIInterpretationEndReasonAudioInterrupted:   return TSLocalizedString(@"ai_interpreter.end_reason.audio_interrupted");
        case TSAIInterpretationEndReasonContextInactive:    return TSLocalizedString(@"ai_interpreter.end_reason.context_inactive");
        case TSAIInterpretationEndReasonFailure:            return TSLocalizedString(@"ai_interpreter.end_reason.failure");
        case TSAIInterpretationEndReasonNone:
        default:                                            return TSLocalizedString(@"general.unknown");
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
