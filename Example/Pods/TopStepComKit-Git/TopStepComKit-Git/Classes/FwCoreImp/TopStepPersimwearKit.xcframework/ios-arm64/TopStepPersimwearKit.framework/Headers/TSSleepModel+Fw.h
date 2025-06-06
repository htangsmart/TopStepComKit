//
//  TSSleepModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSSleepModel.h"
@class TSSleepItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface TSSleepModel (Fw)

+ (NSArray<TSSleepModel *> *)sleepModelsFormSleepDetailItems:(NSArray <TSSleepItemModel *> *)sleepItems ;

@end

NS_ASSUME_NONNULL_END
