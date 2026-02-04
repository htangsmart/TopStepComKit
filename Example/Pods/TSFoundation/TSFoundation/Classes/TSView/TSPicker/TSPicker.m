//
//  TSPicker.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/25.
//

#import "TSPicker.h"
#import "TSFont.h"
#import "TSChecker.h"
#import "TSColor.h"
@implementation TSPicker

+(void)presentPickerAlertOnVC:(UIViewController *)superVC pickerDataSource:(NSArray *)pickerDataSource confirm:(NSString *)confirmString confirmBlock:(void(^)(NSArray * actionValue))confirmBlock  cancel:(NSString *)cancelString cancelBlock:(void(^)(NSArray * actionValue))cancelBlock{
    
    if ([TSChecker isEmptyArray:pickerDataSource]) {return;}
    
    TSPickerConfiger *config = [[TSPickerConfiger alloc]init];
    config.dismissWhenTapBackground = YES;
    config.pickerViewCornerRadius = 24;
    
    TSPickerAction *sureAction = [[TSPickerAction alloc]init];
    sureAction.actionText = confirmString;
    sureAction.direction = eTSPickerActionDirectionRight;
    sureAction.actionTextCorlor = [TSColor colorwithHexString:@"#3FCCE2"];
    sureAction.actionFont = [TSFont TSFontPingFangRegularWithSize:16];
    sureAction.actionBlock = confirmBlock;


    TSPickerAction *cancelAction = [[TSPickerAction alloc]init];
    cancelAction.actionText = cancelString;
    cancelAction.direction = eTSPickerActionDirectionLeft;
    cancelAction.actionTextCorlor = [TSColor colorwithHexString:@"#999999"];
    cancelAction.actionFont = [TSFont TSFontPingFangRegularWithSize:16];
    cancelAction.actionBlock = cancelBlock;

    
    config.actions = @[cancelAction,sureAction];
    config.pickerDataArray = pickerDataSource;
    

    TSPickerViewController *alertVc = [[TSPickerViewController alloc]init];
    alertVc.configer = config;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];
    
}


+(void)presentDatePickerAlertOnVC:(UIViewController *)superVC 
                 pickerDataSource:(NSArray *)pickerDataSource
                          confirm:(NSString *)confirmString
                     confirmBlock:(void (^)(NSArray <TSPickerValue *>*))confirmBlock
                           cancel:(NSString *)cancelString
                      cancelBlock:(void (^)(NSArray <TSPickerValue *>*))cancelBlock
                 reloadComponents:(NSArray * (^)(NSArray * _Nonnull))reloadComponentsBlock{
    
    
    if ([TSChecker isEmptyArray:pickerDataSource]) {return;}
    
    TSPickerConfiger *config = [[TSPickerConfiger alloc]init];
    config.dismissWhenTapBackground = YES;
    config.pickerViewCornerRadius = 24;
    
    TSPickerAction *sureAction = [[TSPickerAction alloc]init];
    sureAction.actionText = confirmString;
    sureAction.direction = eTSPickerActionDirectionRight;
    sureAction.actionTextCorlor = [TSColor colorwithHexString:@"#3FCCE2"];
    sureAction.actionFont = [TSFont TSFontPingFangRegularWithSize:16];
    sureAction.actionBlock = confirmBlock;


    TSPickerAction *cancelAction = [[TSPickerAction alloc]init];
    cancelAction.actionText = cancelString;
    cancelAction.direction = eTSPickerActionDirectionLeft;
    cancelAction.actionTextCorlor = [TSColor colorwithHexString:@"#999999"];
    cancelAction.actionFont = [TSFont TSFontPingFangRegularWithSize:16];
    cancelAction.actionBlock = cancelBlock;

    
    config.actions = @[cancelAction,sureAction];
    config.pickerDataArray = pickerDataSource;
    config.dataRefreshBlock = reloadComponentsBlock;

    TSPickerViewController *alertVc = [[TSPickerViewController alloc]init];
    alertVc.configer = config;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];

    
}


@end
