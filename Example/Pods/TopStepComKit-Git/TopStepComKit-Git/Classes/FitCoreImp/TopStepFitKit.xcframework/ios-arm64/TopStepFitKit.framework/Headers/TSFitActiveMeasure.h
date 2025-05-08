//
//  TSFitActiveMeasure.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/3/5.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitActiveMeasure : TSFitKitBase

+ (void)startMeasureWithParam:(nonnull TSActivityMeasureParam *)measureParam completion:(nonnull TSCompletionBlock)completion ;

+ (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion ;

@end

NS_ASSUME_NONNULL_END
