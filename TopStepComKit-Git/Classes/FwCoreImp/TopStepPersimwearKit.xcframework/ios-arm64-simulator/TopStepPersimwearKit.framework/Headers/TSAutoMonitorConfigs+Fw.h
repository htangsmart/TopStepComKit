//
//  TSAutoMonitorConfigs+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/4/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorConfigs (Fw)

- (NSString *)autoMonitorCmd;

- (NSDictionary *)settingParam;

+ (TSAutoMonitorConfigs *)settingModelWithFwDict:(NSDictionary *)fwDict ;

@end

NS_ASSUME_NONNULL_END
