//
//  TSSJBaseDataSync.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepSJWatchKit/TopStepSJWatchKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface TSSJBaseDataSync : TSSJKitBase


// 查询历史自动测量数据
+ (void)queryDataWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime completion:(void (^)(BOOL succeed, NSArray<TSHealthValueModel *> *_Nullable, NSError *_Nullable))completion;


@end

NS_ASSUME_NONNULL_END
