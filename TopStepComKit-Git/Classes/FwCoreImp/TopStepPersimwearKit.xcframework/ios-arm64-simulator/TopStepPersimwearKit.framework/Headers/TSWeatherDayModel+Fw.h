//
//  TSWeatherDayModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherDayModel (Fw)

+ (NSDictionary *)fwWeatherDayDictFromWeatherModel:(TSWeatherDayModel *)weatherDayModel;

+ (NSArray<NSDictionary *> *)fwWeatherDayArrayFromWeatherModels:(NSArray<TSWeatherDayModel *> *)weatherDayModels;


@end

NS_ASSUME_NONNULL_END
