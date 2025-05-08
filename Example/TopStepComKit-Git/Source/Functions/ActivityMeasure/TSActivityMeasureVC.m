//
//  TSActivityMeasureVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/6.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSActivityMeasureVC.h"

@interface TSActivityMeasureVC ()

@end

@implementation TSActivityMeasureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//- (NSArray *)sourceArray{
//    return @[
//        [TSValueModel valueWithName:@"发起测量"],
//        [TSValueModel valueWithName:@"结束测量"]
//    ];
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0) {
//        [self startMeasure];
//    }else{
//        [self stopMeasure];
//    }
//}

//- (TSMeasureParam *)measureParam{
//    if ([[[TopStepComKit sharedInstance] activityMeasure] supportMultipleMeasurements]) {
//        return [self muitipleMeasureParam];
//    }
//    return [self singleMeasureParam];
//}
//
//- (TSMeasureParam *)singleMeasureParam{
//    TSMeasureParam *param = [TSMeasureParam new];
//    param.measureItem = TSMeasureItemTemperature;
//    param.maxMeasureDuration = 1;
//    param.interval = 5;
//    return param;
//}
//
//- (TSMeasureParam *)muitipleMeasureParam{
//    TSMeasureParam *param = [TSMeasureParam new];
//    param.measureItem = TSMeasureItemBloodOxygen|TSMeasureItemBloodPressure|TSMeasureItemHeartRate;
//    param.maxMeasureDuration = 1;
//    param.interval = 5;
//    return param;
//}
//
//
//- (void)startMeasure{
//    
//    __weak typeof(self)weakSelf = self;
////    [TSToast showLoadingOnView:self.view text:@"开始测量..."];
//    [[[TopStepComKit sharedInstance] activityMeasure] startMeasureWithParam:[self measureParam] dataBlock:^(NSArray<TSMeasureValue *> * _Nonnull values) {
//        for (TSMeasureValue *value in values) {
//            TSLog(@"values is %@",value.debugDescription);
//        }
//    } completion:^(BOOL isSuccess, NSError * _Nullable error) {
//        __strong typeof(weakSelf)strongSelf = weakSelf;
////        [TSToast dismissLoadingOnView:strongSelf.view];
//        if (!isSuccess) {
//            NSString *message = error?error.localizedDescription:@"测量错误";
//            [TSToast showLoadingOnView:strongSelf.view text:message dismissAfterDelay:1.5];
//            TSLog(@"measure finished %@",message);
//        }
//    }];
//    
//}
//
//- (void)stopMeasure{
////    [TSToast showLoadingOnView:self.view text:@"结束测量..."];
//    [[[TopStepComKit sharedInstance] activityMeasure] stopMeasureWithCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
//        TSLog(@"measure finished success ： %d  error :%@",isSuccess,error.debugDescription);
//    }];
//}


@end
