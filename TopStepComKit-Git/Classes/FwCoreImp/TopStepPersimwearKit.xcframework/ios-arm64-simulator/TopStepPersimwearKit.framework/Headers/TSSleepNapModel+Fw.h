//
//  TSSleepNapModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSSleepNapModel.h"

@class TSSleepConcreteModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepNapModel (Fw)

- (instancetype)initWithSleepItems:(NSArray<TSSleepConcreteModel *> *)sleepDetailItems;

@end

NS_ASSUME_NONNULL_END
