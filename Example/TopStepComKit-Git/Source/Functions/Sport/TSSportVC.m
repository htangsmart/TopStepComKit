//
//  TSSportVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSSportVC.h"

@interface TSSportVC ()

@end

@implementation TSSportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"同步运动数据"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self syncValue];
    }
}

- (void)syncValue{

    //[TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] sport] syncHistoryDataFormStartTime:0 completion:^(NSArray<TSSportModel *> * _Nullable sports, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        //[TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"syncValue error is %@",error.debugDescription);
            return;
        }
//        for (TSSportModel *sport in sports) {
//            TSLog(@"syncValue sport is : %@",sport.debugDescription);
//        }
    }];
}


@end
