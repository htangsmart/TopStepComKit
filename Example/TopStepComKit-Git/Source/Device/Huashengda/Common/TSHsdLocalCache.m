//
//  TSHsdLocalCache.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdLocalCache.h"

static NSString *const kTSHsdCachePrefix = @"TSHsdLocalCache";

@implementation TSHsdLocalCache

+ (NSString *)peripheralKey {
    TSPeripheralSystem *system = [TopStepComKit sharedInstance].connectedPeripheral.systemInfo;
    if (system.mac.length) { return system.mac; }
    if (system.uuid.length) { return system.uuid; }
    return @"unknown";
}

+ (NSString *)ts_keyForField:(NSString *)field {
    return [NSString stringWithFormat:@"%@.%@.%@", kTSHsdCachePrefix, [self peripheralKey], field];
}

+ (nullable NSDate *)ts_dateForField:(NSString *)field {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:[self ts_keyForField:field]];
    return [value isKindOfClass:[NSDate class]] ? value : nil;
}

#pragma mark - ICE

+ (nullable NSArray<NSString *> *)iceLabels {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:[self ts_keyForField:@"ice.labels"]];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

+ (nullable NSDate *)iceSentDate {
    return [self ts_dateForField:@"ice.sentAt"];
}

+ (void)saveIceLabels:(NSArray<NSString *> *)labels {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:labels ?: @[] forKey:[self ts_keyForField:@"ice.labels"]];
    [defaults setObject:[NSDate date] forKey:[self ts_keyForField:@"ice.sentAt"]];
}

#pragma mark - 排名趋势

+ (nullable NSArray<TSHsdGameRankingTrendModel *> *)rankingTrends {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:[self ts_keyForField:@"trends"]];
    if (![value isKindOfClass:[NSArray class]]) { return nil; }
    NSMutableArray<TSHsdGameRankingTrendModel *> *models = [NSMutableArray array];
    for (NSDictionary *dict in (NSArray *)value) {
        if (![dict isKindOfClass:[NSDictionary class]]) { continue; }
        TSHsdGameRankingTrendModel *model = [[TSHsdGameRankingTrendModel alloc] init];
        model.gameType = [dict[@"gameType"] integerValue];
        model.ranking = [dict[@"ranking"] integerValue];
        model.trend = [dict[@"trend"] integerValue];
        [models addObject:model];
    }
    return [models copy];
}

+ (nullable NSDate *)rankingTrendsSentDate {
    return [self ts_dateForField:@"trends.sentAt"];
}

+ (void)saveRankingTrends:(NSArray<TSHsdGameRankingTrendModel *> *)trends {
    NSMutableArray<NSDictionary *> *dicts = [NSMutableArray array];
    for (TSHsdGameRankingTrendModel *model in trends) {
        [dicts addObject:@{@"gameType": @(model.gameType), @"ranking": @(model.ranking), @"trend": @(model.trend)}];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dicts forKey:[self ts_keyForField:@"trends"]];
    [defaults setObject:[NSDate date] forKey:[self ts_keyForField:@"trends.sentAt"]];
}

@end
