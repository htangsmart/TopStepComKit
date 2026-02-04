//
//  TSSheet.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import "TSSheet.h"
#import "TSSheetViewController.h"
@implementation TSSheet


+(void)presentSheetOnVC:(UIViewController *)superVC actions:(NSArray<TSSheetAction *>*)actons cancel:(NSString *)cancelString cancelBlock:(void(^)(id actionValue))cancelBlock{

    
    TSSheetAction *cancelAction = [[TSSheetAction alloc]initWithActionName:cancelString actionBlock:cancelBlock];
    TSSheetViewController *alertVc = [[TSSheetViewController alloc]init];
    alertVc.actions = actons;
    alertVc.cancelAction = cancelAction;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];

}

@end
