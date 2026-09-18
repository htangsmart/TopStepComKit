//
//  TSWeatherDay+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherDay (Fw)

+ (NSDictionary *)fwWeatherDayDictFromWeatherModel:(TSWeatherDay *)weatherDayModel;

+ (NSArray<NSDictionary *> *)fwWeatherDayArrayFromWeatherModels:(NSArray<TSWeatherDay *> *)weatherDayModels;


@end

NS_ASSUME_NONNULL_END
