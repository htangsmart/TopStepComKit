//
//  TSSleepConcreteModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSSleepConcreteModel.h"

@class TSSleepItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepConcreteModel (Fw)

- (instancetype)initWithSleepItems:(NSArray<TSSleepItemModel *> *)sleepDetailItems;

@end

NS_ASSUME_NONNULL_END
