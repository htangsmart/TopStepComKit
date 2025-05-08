//
//  TSDailyExerciseGoalVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDailyExerciseGoalVC.h"

@interface TSDailyExerciseGoalVC ()

@end

@implementation TSDailyExerciseGoalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


- (NSArray *)sourceArray{
    return @[
        [TSValueModel valueWithName:@"设置运动目标"],
        [TSValueModel valueWithName:@"获取运动目标"],
        [TSValueModel valueWithName:@"同步今日运动数据"],
        [TSValueModel valueWithName:@"同步历史运动数据"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self setDailyExerciseGoals];
    }else if(indexPath.row ==1){
        [self getDailyExerciseGoals];
    }else if(indexPath.row ==2){
        [self syncTodayDailyExerciseValue];
    }else if(indexPath.row ==3){
        [self syncHistoryDailyExerciseValue];
    }
}

- (void)syncHistoryDailyExerciseValue{
    
    [[[TopStepComKit sharedInstance] dailyActivity] syncHistoryDataFormStartTime:0 completion:^(NSArray<TSDailyActivityValueModel *> * _Nullable dailyExerValues, NSError * _Nullable error) {
        TSLog(@"daily values :%@",dailyExerValues);
        TSLog(@"daily error :%@",error.localizedDescription);
    }];
}

- (void)syncTodayDailyExerciseValue{
    [[[TopStepComKit sharedInstance] dailyActivity] syncTodayDailyExerciseDataCompletion:^(TSDailyActivityValueModel * _Nullable dailyExerValues, NSError * _Nullable error) {
        TSLog(@"daily values :%@",dailyExerValues);
        TSLog(@"daily error :%@",error.localizedDescription);
    }];
}

- (TSDailyActivityGoalsModel *)exerciseGoal{
    
    TSDailyActivityGoalsModel *goal = [[TSDailyActivityGoalsModel alloc] init];
    goal.stepsGoal = 10000;
    goal.caloriesGoal = 300;
    goal.distanceGoal = 10000;
    goal.activityDurationGoal = 100;
    goal.exerciseDurationGoal = 100;
    goal.exerciseTimesGoal = 3;
    
    return goal;
}



- (void)setDailyExerciseGoals{
    TSDailyActivityGoalsModel *goal = [self exerciseGoal];
    TSLog(@"开始设置运动目标：\n"
          "- 步数目标：%ld步\n"
          "- 卡路里目标：%ld千卡\n"
          "- 距离目标：%ld米\n"
          "- 活动时长目标：%ld分钟\n"
          "- 运动时长目标：%ld分钟\n"
          "- 运动次数目标：%ld次",
          (long)goal.stepsGoal,
          (long)goal.caloriesGoal,
          (long)goal.distanceGoal,
          (long)goal.activityDurationGoal,
          (long)goal.exerciseDurationGoal,
          (long)goal.exerciseTimesGoal);
    
    [[[TopStepComKit sharedInstance] dailyActivity]setDailyExerciseGoals:goal completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            TSLog(@"设置运动目标成功");
            [TSToast showText:@"设置运动目标成功" onView:self.view dismissAfterDelay:1.0f];
        } else {
            NSString *errorMsg = error.localizedDescription ?: @"未知错误";
            TSLog(@"设置运动目标失败：%@", errorMsg);
            [TSToast showText:[NSString stringWithFormat:@"设置运动目标失败：%@", errorMsg]
                     onView:self.view
            dismissAfterDelay:1.0f];
        }
    }];
}

- (void)getDailyExerciseGoals{
    TSLog(@"开始获取运动目标");
    
    [[[TopStepComKit sharedInstance] dailyActivity]getDailyExerciseGoalsWithCompletion:^(TSDailyActivityGoalsModel * _Nullable goalsModel, NSError * _Nullable error) {
        if (goalsModel) {
            TSLog(@"获取运动目标成功：\n"
                  "- 步数目标：%ld步\n"
                  "- 卡路里目标：%ld千卡\n"
                  "- 距离目标：%ld米\n"
                  "- 活动时长目标：%ld分钟\n"
                  "- 运动时长目标：%ld分钟\n"
                  "- 运动次数目标：%ld次",
                  (long)goalsModel.stepsGoal,
                  (long)goalsModel.caloriesGoal,
                  (long)goalsModel.distanceGoal,
                  (long)goalsModel.activityDurationGoal,
                  (long)goalsModel.exerciseDurationGoal,
                  (long)goalsModel.exerciseTimesGoal);
            
            [TSToast showText:[NSString stringWithFormat:@"获取运动目标成功：%ld步", (long)goalsModel.stepsGoal]
                     onView:self.view
            dismissAfterDelay:1.0f];
        } else {
            NSString *errorMsg = error.localizedDescription ?: @"未知错误";
            TSLog(@"获取运动目标失败：%@", errorMsg);
            [TSToast showText:[NSString stringWithFormat:@"获取运动目标失败：%@", errorMsg]
                     onView:self.view
            dismissAfterDelay:1.0f];
        }
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
