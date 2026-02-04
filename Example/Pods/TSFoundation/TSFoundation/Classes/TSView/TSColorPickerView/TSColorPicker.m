//
//  TSColorPicker.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/6.
//

#import "TSColorPicker.h"
#import "TSColorPickerVC.h"
#import "TSWindow.h"

@implementation TSColorPicker

+ (void)presentColorPickerOnVC:(UIViewController *)superVC complete:(void (^)(UIColor * _Nonnull))complete{
    [self presentColorPickerOnVC:superVC displayView:nil complete:complete];
}

+ (void)presentColorPickerOnVC:(UIViewController *)superVC displayView:(UIView *)displayView complete:(void(^)(UIColor * pickColor))complete{
    
    TSColorPickerVC *colorVC =  [[TSColorPickerVC alloc]initWithPickColorBlock:complete displayView:displayView];
    colorVC.modalPresentationStyle = UIModalPresentationCustom;
    colorVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:colorVC animated:YES completion:^{}];
}


@end
