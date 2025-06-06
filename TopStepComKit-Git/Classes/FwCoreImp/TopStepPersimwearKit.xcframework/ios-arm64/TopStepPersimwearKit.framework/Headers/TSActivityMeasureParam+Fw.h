//
//  TSActivityMeasureParam+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/14.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSActivityMeasureParam (Fw)

- (NSString *)monitorKey;
- (NSString *)monitorPoolName;

- (NSArray *)measureValueKeys;


- (NSDictionary *)startMeasureParam;
- (NSDictionary *)stopMeasureParam;

-(NSString *)errorDomain;

@end

NS_ASSUME_NONNULL_END
