//
//  TSWristWakeUpModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWristWakeUpModel (Fw)


+ (nullable NSDictionary *)fwWWUObjectWithModel:(nullable TSWristWakeUpModel *)model ;

+ (nullable TSWristWakeUpModel *)modelWithFwWWUObject:(nullable NSDictionary *)wwuObject ;

@end

NS_ASSUME_NONNULL_END
