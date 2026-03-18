//
//  TSAppLanguageManager.m
//  TopStepComKit_Example
//
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAppLanguageManager.h"

NSString *const TSAppLanguageUserDefaultsKey = @"TSAppPreferredLanguage";

/// 应用支持的语言 code 列表，第一个为未设置时的回退语言
static NSArray<NSString *> *TSSupportedLanguageCodes(void) {
    return @[ @"en", @"zh-Hans", @"hi" ];
}

@implementation TSAppLanguageManager

+ (void)applyStoredLanguageIfNeeded {
    NSString *stored = [[NSUserDefaults standardUserDefaults] stringForKey:TSAppLanguageUserDefaultsKey];
    if (stored.length == 0) {
        // 跟随系统，不修改 AppleLanguages
        return;
    }
    NSArray *supported = TSSupportedLanguageCodes();
    if (![supported containsObject:stored]) {
        return;
    }
    NSMutableArray *preferred = [supported mutableCopy];
    [preferred removeObject:stored];
    [preferred insertObject:stored atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:preferred forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)currentLanguageCode {
    NSString *stored = [[NSUserDefaults standardUserDefaults] stringForKey:TSAppLanguageUserDefaultsKey];
    if (stored.length > 0 && [TSSupportedLanguageCodes() containsObject:stored]) {
        return stored;
    }
    NSString *systemFirst = [NSLocale preferredLanguages].firstObject;
    NSString *lang = systemFirst;
    if ([lang hasPrefix:@"zh"]) {
        lang = @"zh-Hans";
    } else if ([lang hasPrefix:@"hi"]) {
        lang = @"hi";
    } else {
        lang = @"en";
    }
    if (![TSSupportedLanguageCodes() containsObject:lang]) {
        lang = @"en";
    }
    return lang;
}

+ (NSString *)currentLanguageDisplayName {
    NSString *code = [self currentLanguageCode];
    return [self displayNameForLanguageCode:code];
}

+ (NSString *)displayNameForLanguageCode:(NSString *)code {
    if (code.length == 0) {
        return NSLocalizedString(@"mine.follow_system", nil);
    }
    if ([code isEqualToString:@"en"]) return @"English";
    if ([code isEqualToString:@"zh-Hans"]) return @"简体中文";
    if ([code isEqualToString:@"hi"]) return @"हिंदी";
    return @"English";
}

+ (void)savePreferredLanguageCode:(NSString *)code {
    if (code.length == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TSAppLanguageUserDefaultsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:TSAppLanguageUserDefaultsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSArray *supported = TSSupportedLanguageCodes();
    if (code.length > 0 && [supported containsObject:code]) {
        NSMutableArray *preferred = [supported mutableCopy];
        [preferred removeObject:code];
        [preferred insertObject:code atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:preferred forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppleLanguages"];
    }
}

@end
