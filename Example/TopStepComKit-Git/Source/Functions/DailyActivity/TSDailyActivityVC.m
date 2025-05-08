//
//  TSDailyActivityVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDailyActivityVC.h"

@interface TSDailyActivityVC ()

@end

@implementation TSDailyActivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"同步今日活动数据"],
        [TSValueModel valueWithName:@"同步历史活动数据"],

        [TSValueModel valueWithName:@"获取活动目标"],
        [TSValueModel valueWithName:@"设置活动目标"],
        
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self syncTodayValue];
    } else if (indexPath.row == 1) {
        [self syncHistoryValue];
    } else if (indexPath.row == 2) {
        [self getGoals];
    }  else if (indexPath.row == 3) {
        [self setGoals];
    }
}

- (void)syncTodayValue{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity] syncTodayDailyExerciseDataCompletion:^(TSDailyActivityValueModel * _Nullable dailyExerValues, NSError * _Nullable error) {
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"syncTodayValue error is %@",error.debugDescription);
            return;
        }
        TSLog(@"syncTodayValue dailyExerValues is : %@",dailyExerValues.debugDescription);
    }];

}


- (void)syncHistoryValue{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity] syncHistoryDataFormStartTime:0 completion:^(NSArray<TSDailyActivityValueModel *> * _Nullable dailyExerValues, NSError * _Nullable error) {
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"syncTodayValue error is %@",error.debugDescription);
            return;
        }
        for (TSDailyActivityValueModel *value in dailyExerValues) {
            TSLog(@"syncTodayValue dailyExerValues is : %@",dailyExerValues.debugDescription);
        }
    }];


}

- (void)getGoals{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] dailyActivity] getDailyExerciseGoalsWithCompletion:^(TSDailyActivityGoalsModel * _Nullable goalsModel, NSError * _Nullable error) {
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"getGoals error is %@",error.debugDescription);
            return;
        }
        TSLog(@"getGoals goalsModel is : %@",goalsModel.debugDescription);

    }];

}

- (void)setGoals{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    
    TSDailyActivityGoalsModel *goal = [TSDailyActivityGoalsModel new];
    goal.stepsGoal  = 10000;
    goal.caloriesGoal = 1000;
    goal.distanceGoal = 10000;
    goal.exerciseDurationGoal = 60;
    [[[TopStepComKit sharedInstance] dailyActivity] setDailyExerciseGoals:goal completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"getGoals success %d error: %@",isSuccess,error.debugDescription);
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
