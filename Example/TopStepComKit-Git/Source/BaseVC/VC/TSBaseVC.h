//
//  TSBaseVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/10.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSTableViewCell.h"
#import "TSValueModel.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "UIViewController+Nav.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSBaseVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * sourceTableview;

@property (nonatomic,strong) NSArray * sourceArray;


- (NSString *)cellNameAtIndexPath:(NSIndexPath *)cellIndexPath;

- (void)showAlertWithMsg:(NSString *)errorMsg ;

@end

NS_ASSUME_NONNULL_END
