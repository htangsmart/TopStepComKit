//
//  TSSleepSummaryModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSSleepSummaryModel.h"
NS_ASSUME_NONNULL_BEGIN

@class TSSleepItemModel;
@class TSSleepConcreteModel;

@interface TSSleepSummaryModel (Fw)

- (instancetype)initWithSleepItems:(NSArray<TSSleepItemModel *> *)sleepDetailItems;

- (instancetype)initWithSleepConcreteItems:(NSArray<TSSleepConcreteModel *> *)sleepConcreteItems;

@end

NS_ASSUME_NONNULL_END
