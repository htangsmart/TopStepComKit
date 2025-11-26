//
//  TSSportModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaSportRecord;
NS_ASSUME_NONNULL_BEGIN

@interface TSSportModel (Npk)


+(NSArray <NSDictionary *>*)sportDictionariesFromMetaSport:(NSArray<TSMetaSportRecord *>*)sportRecords;


- (TSSportModel *)initWithSummary:(TSSportSummaryModel *)summary;


@end

NS_ASSUME_NONNULL_END
