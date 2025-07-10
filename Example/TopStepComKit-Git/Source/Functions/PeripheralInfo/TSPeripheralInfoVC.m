//
//  TSPeripheralInfoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/6/22.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralInfoVC.h"

@interface TSPeripheralInfoVC ()

@end

@implementation TSPeripheralInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}



- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"获取设备信息"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self getPeripheralInfo];
    }

}


- (void)getPeripheralInfo{
    
    if (![[TopStepComKit sharedInstance] connectedPeripheral]) {
        TSLog(@"未能获取到外设");
        return;
    }
    TSLog(@"get current Peripheral info: %@", [[[TopStepComKit sharedInstance] connectedPeripheral] debugDescription]);

}


@end
