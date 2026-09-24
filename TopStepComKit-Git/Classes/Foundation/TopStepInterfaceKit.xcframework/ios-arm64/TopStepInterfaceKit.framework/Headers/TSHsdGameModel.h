//
//  TSHsdGameModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSKitBaseModel.h"
#import "TSHsdDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Game record model
 * @chinese 游戏记录模型
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature.
 *      Returned by TSHuashengdaInterface.fetchGameTopRecordsWithType:completion:.
 * [CN]: 华盛达定制能力。
 *      由 TSHuashengdaInterface.fetchGameTopRecordsWithType:completion: 返回。
 */
@interface TSHsdGameRecordModel : NSObject <NSCopying>

/**
 * @brief Time the record was made
 * @chinese 记录产生的时间
 */
@property (nonatomic, strong) NSDate *date;

/**
 * @brief Game type
 * @chinese 游戏类型
 *
 * @discussion
 * [EN]: See TSHsdGameType.
 * [CN]: 见 TSHsdGameType。
 */
@property (nonatomic, assign) TSHsdGameType gameType;

/**
 * @brief Play duration
 * @chinese 游戏时长
 *
 * @discussion
 * [EN]: In seconds.
 * [CN]: 单位为秒。
 */
@property (nonatomic, assign) NSInteger duration;

/**
 * @brief Score
 * @chinese 得分
 */
@property (nonatomic, assign) NSInteger score;

/**
 * @brief Level reached
 * @chinese 等级
 */
@property (nonatomic, assign) NSInteger level;

@end

/**
 * @brief Game ranking trend model
 * @chinese 游戏排名趋势模型
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature.
 *      Written to the device with TSHuashengdaInterface.setGameRankingTrends:completion:,
 *      at most TSHsdGameRankingTrendMaxCount (30) items.
 * [CN]: 华盛达定制能力。
 *      通过 TSHuashengdaInterface.setGameRankingTrends:completion: 下发，最多 TSHsdGameRankingTrendMaxCount（30）条。
 */
@interface TSHsdGameRankingTrendModel : TSKitBaseModel <NSCopying>

/**
 * @brief Game type
 * @chinese 游戏类型
 *
 * @discussion
 * [EN]: See TSHsdGameType.
 * [CN]: 见 TSHsdGameType。
 */
@property (nonatomic, assign) TSHsdGameType gameType;

/**
 * @brief Ranking
 * @chinese 排名
 *
 * @discussion
 * [EN]: Valid range [0, TSHsdGameRankingMax (255)]; out-of-range values fail validation.
 * [CN]: 取值范围 [0, TSHsdGameRankingMax（255）]，越界时校验失败。
 */
@property (nonatomic, assign) NSInteger ranking;

/**
 * @brief Ranking trend
 * @chinese 排名趋势
 *
 * @discussion
 * [EN]: See TSHsdRankingTrend.
 * [CN]: 见 TSHsdRankingTrend。
 */
@property (nonatomic, assign) TSHsdRankingTrend trend;

@end

NS_ASSUME_NONNULL_END
