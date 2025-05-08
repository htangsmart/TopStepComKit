//
//  TSSleepSummaryModel+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSSleepItemModel;
@class TSSleepConcreteModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepSummaryModel (Fit)

- (instancetype)initWithSleepItems:(NSArray<TSSleepItemModel *> *)sleepDetailItems;

- (instancetype)initWithSleepConcreteItems:(NSArray<TSSleepConcreteModel *> *)sleepConcreteItems;

@end

NS_ASSUME_NONNULL_END
