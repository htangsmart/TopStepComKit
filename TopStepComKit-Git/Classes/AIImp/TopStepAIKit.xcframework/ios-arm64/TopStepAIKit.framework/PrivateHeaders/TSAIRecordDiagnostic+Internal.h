#import <Foundation/Foundation.h>
#import <math.h>

/// A08F 新诊断专用；不接管历史日志。预留 TSLog 外层格式空间。
static inline NSString *TSAIRecordDiagnosticString(NSString *value) {
    if (value.length > 64) value = [value substringWithRange:[value rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 64)]];
    while ([value lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 64 && value.length > 0) {
        value = [value substringToIndex:[value rangeOfComposedCharacterSequenceAtIndex:value.length - 1].location];
    }
    return value;
}

static inline NSString *TSAIRecordDiagnosticLine(NSString *event, NSDictionary *fields, NSError *error) {
    @try {
        static NSSet *allowed;
        static dispatch_once_t once;
        dispatch_once(&once, ^{ allowed = [NSSet setWithArray:@[@"taskId", @"requestId", @"phase", @"receivedPCM", @"thresholdMs", @"idleMs", @"sinceConfirmMs", @"elapsedMs", @"accepted", @"ignored", @"controls", @"callbacks", @"cancelled", @"cancelWaitMs", @"textLength", @"responseSequence", @"transcriptSequence"]]; });
        NSMutableDictionary *payload = [@{@"schema": @"a08f-record-v1", @"layer": @"ai-sdk", @"event": TSAIRecordDiagnosticString(event)} mutableCopy];
        [fields enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *__unused stop) {
            if (![allowed containsObject:key]) return;
            if ([value isKindOfClass:NSString.class]) payload[key] = TSAIRecordDiagnosticString(value);
            else if ([value isKindOfClass:NSNumber.class] && isfinite([value doubleValue])) payload[key] = value;
        }];
        NSMutableArray *errors = [NSMutableArray array];
        NSHashTable *visited = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
        while (error && errors.count < 4 && ![visited containsObject:error]) {
            [visited addObject:error];
            [errors addObject:@{@"domain": TSAIRecordDiagnosticString(error.domain), @"code": @(error.code)}];
            id next = error.userInfo[NSUnderlyingErrorKey];
            error = [next isKindOfClass:NSError.class] ? next : nil;
        }
        if (errors.count) payload[@"errors"] = errors;
        NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingSortedKeys error:nil];
        // 先缩减可选字段，不截断 JSON；固定身份和事件一直保留。
        NSArray *optional = @[@"transcriptSequence", @"responseSequence", @"controls", @"ignored", @"accepted", @"callbacks", @"textLength", @"sinceConfirmMs", @"elapsedMs"];
        for (NSString *key in optional) {
            if (data.length <= 768) break;
            [payload removeObjectForKey:key];
            data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingSortedKeys error:nil];
        }
        while (data.length > 768 && errors.count) {
            [errors removeLastObject];
            data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingSortedKeys error:nil];
        }
        if (!data || data.length > 768) return nil;
        return [@"[A08FRecord][AISDK] " stringByAppendingString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    } @catch (__unused NSException *exception) { return nil; }
}
