//
//  TSWeatherHourModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherHourModel (Fw)

+ (NSArray<NSDictionary *> *)fwHourDictArrayWithArray:(NSArray <TSWeatherHourModel *> *)hourWeatherArray;

+ (NSDictionary *)fwHourWeatherDictFromHourWeatherModel:(TSWeatherHourModel *)hourWeatherModel;


@end

NS_ASSUME_NONNULL_END
