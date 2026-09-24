//
//  TSHsdLocalCache.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Local cache for write-only features
 * @chinese 只写能力（ICE 0x59、排名趋势 0x67）的本地缓存（产品方案 §3.4）
 *
 * @discussion
 * [CN]: 协议没有读取指令，App 缓存上次发送的内容与时间；按当前连接设备的 mac / uuid 分 key，切换设备即失效。
 */
@interface TSHsdLocalCache : NSObject

/// 当前设备的缓存 key（mac 优先，其次 uuid；未连接时为 "unknown"）
+ (NSString *)peripheralKey;

#pragma mark - ICE

+ (nullable NSArray<NSString *> *)iceLabels;
+ (nullable NSDate *)iceSentDate;
+ (void)saveIceLabels:(NSArray<NSString *> *)labels;

#pragma mark - 排名趋势

+ (nullable NSArray<TSHsdGameRankingTrendModel *> *)rankingTrends;
+ (nullable NSDate *)rankingTrendsSentDate;
+ (void)saveRankingTrends:(NSArray<TSHsdGameRankingTrendModel *> *)trends;

@end

NS_ASSUME_NONNULL_END
