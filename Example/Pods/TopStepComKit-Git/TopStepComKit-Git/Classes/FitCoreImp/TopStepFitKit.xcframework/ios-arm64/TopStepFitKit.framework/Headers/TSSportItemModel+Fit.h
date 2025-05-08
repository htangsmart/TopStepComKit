//
//  TSSportItemModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/3/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudSportsItemObject;
NS_ASSUME_NONNULL_BEGIN

@interface TSSportItemModel (Fit)

+ (NSDictionary *)sportDetailItemDictWithSoprtId:(NSTimeInterval)sportId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime sportItemObject:(FitCloudSportsItemObject *)item ;

+ (NSArray <TSSportItemModel *> *)sportDetailItemArrayWithDBDicts:(NSArray<NSDictionary *> *)dbDicts;

+ (TSSportItemModel *)sportDetailItemWithDBDict:(NSDictionary *)dbDict;

@end

NS_ASSUME_NONNULL_END
