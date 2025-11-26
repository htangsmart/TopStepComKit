//
//  TSSportSummaryModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSportSummaryModel (Npk)

/// 从 TSSportRecordTable 查询结果构建 TSSportSummaryModel 数组
+ (TSSportSummaryModel *)summaryFromDictionary:(NSDictionary *)dict ;

@end

NS_ASSUME_NONNULL_END
