#ifndef TSFitRecordDiagnostics_h
#define TSFitRecordDiagnostics_h

#import <Foundation/Foundation.h>
#import <math.h>

// 测试可替换输出边界，生产始终沿用 SDK 的 TSLog 配置和文件存储。
#ifndef TS_FIT_RECORD_LOG_LINE
#import <TopStepToolKit/TSLogPrinter.h>
#define TS_FIT_RECORD_LOG_LINE(line) TSLog(@"%@", (line))
#endif

/// 不从 UTF-16 代理对中间截断，避免新增诊断无法编码为 JSON。
static inline NSString *TSFitRecordDiagnosticPrefix(NSString *value, NSUInteger limit) {
    NSUInteger length = MIN(value.length, limit);
    if (length < value.length) {
        length = [value rangeOfComposedCharacterSequenceAtIndex:length].location;
    }
    return [value substringToIndex:length];
}

/// 仅保留诊断标量与错误码，不写音频、识别正文、路径或鉴权数据。
static inline NSDictionary *TSFitRecordDiagnosticPayload(NSString *event,
                                                         NSDictionary *fields,
                                                         NSError *error) {
    static NSSet<NSString *> *allowed;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowed = [NSSet setWithArray:@[
            @"requestId", @"diagnosticId", @"generation", @"useCase", @"initiator",
            @"input", @"output", @"scene", @"audioSource", @"reason", @"mappedReason",
            @"success", @"accepted", @"hasResult", @"deviceException", @"retained",
            @"pendingId", @"respondingId", @"inFlightId", @"activeId", @"endingId",
            @"compensationCount", @"recordState", @"retryLevel", @"firstResult",
            @"elapsedMs", @"listenerCount", @"opusBytes", @"pcmBytes", @"firstOpus",
            @"firstPCM", @"fileExists", @"bytes", @"expectedBytes", @"fileExtension",
            @"vendorProgress", @"percentage", @"connected", @"ready", @"syncIdle",
            @"connectionId", @"attempt", @"sinceReadyMs", @"sinceBindMs", @"source",
            @"vendorCallbacks", @"vendorOpusBytes", @"vendorPCMBytes",
            @"publishCallbacks", @"publishOpusBytes", @"publishPCMBytes",
            @"bridgeCallbacks", @"bridgeOpusBytes", @"bridgePCMBytes",
            @"prepared", @"idle", @"notifyState", @"state", @"sinkPresent", @"checkpointMs"
        ]];
    });
    NSMutableDictionary *payload = [@{
        @"schema": @"a08f-record-v1", @"layer": @"fit-sdk", @"event": event,
        @"pid": @(NSProcessInfo.processInfo.processIdentifier),
        @"wallMs": @((long long)(NSDate.date.timeIntervalSince1970 * 1000)),
        @"uptimeMs": @((long long)(NSProcessInfo.processInfo.systemUptime * 1000))
    } mutableCopy];
    [fields enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (![allowed containsObject:key]) { return; }
        if ([value isKindOfClass:NSString.class]) {
            payload[key] = TSFitRecordDiagnosticPrefix(value, 256);
        } else if ([value isKindOfClass:NSNumber.class] && isfinite([value doubleValue])) {
            payload[key] = value;
        }
    }];
    NSMutableArray *errors = [NSMutableArray array];
    NSHashTable *visited = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
    while (error != nil && errors.count < 4 && ![visited containsObject:error]) {
        [visited addObject:error];
        NSString *domain = error.domain ?: @"";
        [errors addObject:@{@"domain": TSFitRecordDiagnosticPrefix(domain, 128),
                            @"code": @(error.code)}];
        id underlying = error.userInfo[NSUnderlyingErrorKey];
        error = [underlying isKindOfClass:NSError.class] ? underlying : nil;
    }
    if (errors.count > 0) { payload[@"errors"] = errors; }
    return payload;
}

/// 旁路输出，不发协议命令，不修改业务状态或重试策略。
static inline void TSFitRecordDiagnostic(NSString *event, NSDictionary *fields, NSError *error) {
    NSMutableDictionary *payload = [TSFitRecordDiagnosticPayload(event, fields, error) mutableCopy];
    // 仅约束 A08F 新诊断；预留 128 字节给现有 TSLog 时间/级别外层格式。
    for (NSString *key in payload.allKeys) {
        id value = payload[key];
        if ([value isKindOfClass:NSString.class]) {
            NSString *text = value;
            NSUInteger stringBudget = [key isEqualToString:@"notifyState"] ? 256 : 64;
            while ([text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > stringBudget) {
                text = [text substringToIndex:[text rangeOfComposedCharacterSequenceAtIndex:text.length - 1].location];
            }
            payload[key] = text;
        }
    }
    NSMutableArray *chain = [NSMutableArray array];
    for (NSDictionary *item in payload[@"errors"]) {
        NSString *domain = item[@"domain"];
        while ([domain lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 32) {
            domain = [domain substringToIndex:[domain rangeOfComposedCharacterSequenceAtIndex:domain.length - 1].location];
        }
        [chain addObject:@{@"domain": domain, @"code": item[@"code"]}];
    }
    if (chain.count) { payload[@"errors"] = chain; }
    NSSet *essential = [NSSet setWithArray:@[@"schema", @"layer", @"event", @"pid", @"wallMs",
        @"uptimeMs", @"requestId", @"diagnosticId", @"connectionId", @"errors", @"success", @"reason"]];
    NSMutableArray *removable = [NSMutableArray array];
    for (NSString *key in [payload.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        if (![essential containsObject:key]) { [removable addObject:key]; }
    }
    // 通道快照中的 AA02 可能在长列表末尾；先缩减其他可选字段。
    if ([removable containsObject:@"notifyState"]) {
        [removable removeObject:@"notifyState"];
        [removable insertObject:@"notifyState" atIndex:0];
    }
    while (YES) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingSortedKeys error:nil];
        if (data == nil) { return; }
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *line = [@"[A08FRecord][FitSDK] " stringByAppendingString:json];
        if ([line lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1 <= 896) {
            TS_FIT_RECORD_LOG_LINE(line);
            return;
        }
        if (!removable.count) { return; }
        [payload removeObjectForKey:removable.lastObject];
        [removable removeLastObject];
    }
}

/// 首包标记只表示观察到数据，不依赖文件写入是否成功。调用方沿用原音频锁。
static inline NSUInteger TSFitRecordObserveFirstAudio(NSUInteger *observedMask,
                                                       NSUInteger opusBytes,
                                                       NSUInteger pcmBytes) {
    NSUInteger incoming = (opusBytes > 0 ? 1 : 0) | (pcmBytes > 0 ? 2 : 0);
    NSUInteger first = incoming & ~(*observedMask);
    *observedMask |= incoming;
    return first;
}

// 诊断状态由 Core 唯一持有；不参与连接或录音控制。
FOUNDATION_EXPORT void TSFitRecordTraceConnection(BOOL connected);
FOUNDATION_EXPORT void TSFitRecordTraceBound(void);
FOUNDATION_EXPORT NSDictionary *TSFitRecordTraceBegin(NSString *requestId, NSString *source);
FOUNDATION_EXPORT NSDictionary *TSFitRecordTraceSnapshot(void);
FOUNDATION_EXPORT void TSFitRecordTraceAudio(NSString *stage, NSUInteger opus, NSUInteger pcm);

#endif
