//
//  TSDataSyncVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/28.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDataSyncVC.h"

@interface TSDataSyncVC ()

@end

@implementation TSDataSyncVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerCallBack];
    
}

- (void)registerCallBack{
}



- (NSArray *)sourceArray{
    return @[
        [TSValueModel valueWithName:@"同步数据"],
        [TSValueModel valueWithName:@"获取静息心率"],
        [TSValueModel valueWithName:@"获取当日活动数据"]
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self beginSyncData];
    }else if (indexPath.row == 1){
        [self beginSyncRestHR];
    }else{
        [self beginSyncDailyExercise];
    }
}

- (void)beginSyncData{
    
    //[TSToast showLoadingOnView:self.view text:@"数据同步中..."];
    
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    TSDataSyncConfig *config = [[TSDataSyncConfig alloc]init];
    config.granularity = TSDataGranularityDay;
    config.startTime = 1771776000;//2026-02-23 00:00:00 Seven days ago
    config.endTime = nowTime;
    config.options = TSDataSyncOptionAll;// all data type,Of course, you can specify any specific data type you want
    
    [[[TopStepComKit sharedInstance] dataSync] syncDataWithConfig:config completion:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
        if (results) {
            TSLog(@"allDataModel %@",results.debugDescription);
        }
    }];
}

- (void)beginSyncRestHR{
    
//    __weak typeof(self)weakSelf = self;
//    //[TSToast showLoadingOnView:self.view text:@"获取静息心率..."];
//    [[[TopStepComKit sharedInstance] dataSync] syncHistoryRestingHeartRateCompletion:^(NSArray<TSHRValueItem *> * _Nonnull hrModes, NSError * _Nullable error) {
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        //[TSToast dismissLoadingOnView:strongSelf.view];
//        if (error) {
//            TSLog(@"syncRestingHeartRateCompletion error:%@",error);
//            return;
//        }
//        for (TSHRValueItem *hr in hrModes) {
//            TSLog(@"value is %@",hr.debugDescription);
//        }
//    }];
}

- (void)beginSyncDailyExercise{
    
//    __weak typeof(self)weakSelf = self;
//    //[TSToast showLoadingOnView:self.view text:@"获取每日活动数据..."];
//    [[[TopStepComKit sharedInstance]dataSync] syncTodayDailyExerciseDataCompletion:^(TSDailyActivityItem * _Nullable exerciseModel, NSError * _Nullable error) {
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        //[TSToast dismissLoadingOnView:strongSelf.view];
//        if (error) {
//            TSLog(@"syncTodayDailyExerciseDataCompletion error:%@",error);
//            return;
//        }
//        
//        TSLog(@"exerciseModel is %@",exerciseModel.debugDescription);
//    }];
}

@end
