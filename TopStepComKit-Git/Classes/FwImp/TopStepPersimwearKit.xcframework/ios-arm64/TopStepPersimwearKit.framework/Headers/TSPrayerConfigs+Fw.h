//
//  TSPrayerConfigs+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/12/12.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPrayerConfigs (Fw)

+ (nullable TSPrayerConfigs *)configWithFwDictionary:(NSDictionary *)dictionary ;

- (NSDictionary *)toDictionary ;


@end

NS_ASSUME_NONNULL_END
