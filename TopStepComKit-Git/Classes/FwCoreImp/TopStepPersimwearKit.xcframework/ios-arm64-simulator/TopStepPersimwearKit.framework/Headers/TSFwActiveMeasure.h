//
//  TSFwActiveMeasure.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/14.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSActivityMeasureDataBlock)(NSDictionary *values);


@interface TSFwActiveMeasure : TSFwKitBase

- (void)startMeasureWithParam:(TSActivityMeasureParam *)measureParam dataBlock:(nullable TSActivityMeasureDataBlock)dataBlock completion:(TSCompletionBlock)completion ;

- (void)stopMeasureCompletion:(TSCompletionBlock)completion ;

@end

NS_ASSUME_NONNULL_END
