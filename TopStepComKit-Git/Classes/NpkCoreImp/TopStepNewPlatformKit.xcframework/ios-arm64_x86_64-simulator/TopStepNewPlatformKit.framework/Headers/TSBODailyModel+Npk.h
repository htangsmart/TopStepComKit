//
//  TSBODailyModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/8.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSBODailyModel (Npk)

+ (NSArray<TSBODailyModel *> *)dailyModelsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

@end

NS_ASSUME_NONNULL_END
