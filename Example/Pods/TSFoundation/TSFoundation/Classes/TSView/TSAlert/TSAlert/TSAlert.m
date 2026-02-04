//
//  TSAlert.m
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/28.
//

#import "TSAlert.h"
#import "TSFont.h"
#import "TSColor.h"

#import "TSBaseAlertVC.h"
#import "TSAlertInputVC.h"
#import "TSAlertContentVC.h"
#import "TSAlertListVC.h"

@implementation TSAlert


+ (void)alertOnVC:(UIViewController *)presentVC WithTitle:(NSString *)title content:(NSString *)content confirmTitle:(NSString *)confirmTitle confirm:(void(^)(void))confirmBlock cancelTitle:(NSString *)cancelTitle cancel:(void(^)(void))cancelBlock{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
        
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (confirmBlock) { confirmBlock(); }
    }];
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) { cancelBlock(); }
    }];
    [alertController addAction:cancelAction];
    
    [presentVC presentViewController:alertController animated:YES completion:nil];
}


+ (void)alertAlbumSheetOnVC:(UIViewController *)presentVC tabkePhotoTitle:(NSString *)tabkePhotoTitle takePhotoBlock:(void(^)(void))takePhotoBlock albumTitle:(NSString *)albumTitle albumBlock:(void(^)(void))albumBlock cancelTitle:(NSString *)cancelTitle cancelBlock:(void(^)(void))cancelBlock {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:tabkePhotoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        takePhotoBlock();
    }];
    [alertController addAction:photoAction];
    
    
    UIAlertAction *ablumAction = [UIAlertAction actionWithTitle:albumTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        albumBlock();
    }];
    [alertController addAction:ablumAction];

    
    UIAlertAction *cacelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        cancelBlock();
    }];
    [alertController addAction:cacelAction];

    [presentVC presentViewController:alertController animated:YES completion:nil];
    
}


+(void)presentAlertOnVC:(UIViewController *)superVC alertTitle:(NSString *)alertTiltle alertContent:(NSString *)alertContent confirm:(NSString *)confirmString confirmBlock:(void(^)(id actionValue))confirmBlock{
    
    
    TSAlertConfiger *config = [[TSAlertConfiger alloc]init];
    config.alerViewCornerRadius = 24;
    config.dismissWhenTapBackground = YES;
    config.alertType = eTSAlertTypeShowText;

    config.title = alertTiltle;
    config.titleFont = [TSFont TSFontPingFangMediumWithSize:16];
    config.titleColor = [TSColor colorwithHexString:@"#333333"];
    config.titleTextAlignment = NSTextAlignmentCenter;
    
    config.content = alertContent;
    config.contentFont = [TSFont TSFontPingFangRegularWithSize:16];
    config.contentColor = [TSColor colorwithHexString:@"#333333"];
    config.contentTextAlignment = NSTextAlignmentLeft;
    config.contentCornerRadius = 25;
    
    TSAlertAction *sureAction = [[TSAlertAction alloc]init];
    sureAction.actionString = confirmString;
    sureAction.actionStringCorlor = [TSColor colorwithHexString:@"#FFFFFF"];
    sureAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    sureAction.actionBackCorlor = [TSColor colorwithHexString:@"#0072DB"];
//    sureAction.isGradientColor = YES;
//    sureAction.gradientBeginCorlor = [TSColor colorwithHexString:@"#24FFBD"];
//    sureAction.gradientEndCorlor = [TSColor colorwithHexString:@"#46BAFF"];
    sureAction.actionCornerRadius = 10;
    sureAction.actionBlock = confirmBlock;

    config.actions = @[sureAction];


    TSBaseAlertVC *alertVc = [[TSAlertContentVC alloc]init];
    alertVc.configer = config;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];
}


+(void)presentAlertOnVC:(UIViewController *)superVC alertTitle:(NSString *)alertTiltle alertContent:(NSString *)alertContent confirm:(NSString *)confirmString confirmBlock:(void(^)(id actionValue))confirmBlock cancel:(NSString *)cancelString cancelBlock:(void(^)(id actionValue))cancelBlock{
    
    TSAlertConfiger *config = [[TSAlertConfiger alloc]init];
    config.alerViewCornerRadius = 24;
    config.dismissWhenTapBackground = NO;
    config.alertType = eTSAlertTypeShowText;

    config.title = alertTiltle;
    config.titleFont = [TSFont TSFontPingFangMediumWithSize:18];
    config.titleColor = [TSColor colorwithHexString:@"#333333"];
    config.titleTextAlignment = NSTextAlignmentCenter;
    
    config.content = alertContent;
    config.contentFont = [TSFont TSFontPingFangRegularWithSize:16];
    config.contentColor = [TSColor colorwithHexString:@"#333333"];
    config.contentTextAlignment = NSTextAlignmentCenter;

    
    TSAlertAction *sureAction = [[TSAlertAction alloc]init];
    sureAction.actionString = confirmString;
    sureAction.actionStringCorlor = [TSColor colorwithHexString:@"#FFFFFF"];
    sureAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    sureAction.actionBackCorlor = [TSColor colorwithHexString:@"#0072DB"];
//    sureAction.isGradientColor = YES;
//    sureAction.gradientBeginCorlor = [TSColor colorwithHexString:@"#24FFBD"];
//    sureAction.gradientEndCorlor = [TSColor colorwithHexString:@"#46BAFF"];
    sureAction.actionCornerRadius = 10;
    sureAction.actionBlock = confirmBlock;


    TSAlertAction *cancelAction = [[TSAlertAction alloc]init];
    cancelAction.actionString = cancelString;
    cancelAction.actionStringCorlor = [TSColor colorwithHexString:@"#999999"];
    cancelAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    cancelAction.actionBackCorlor = [TSColor colorwithHexString:@"#F2F2F2"];
    cancelAction.actionCornerRadius = 10;
    cancelAction.actionBlock = cancelBlock;

    config.actions = @[cancelAction,sureAction];


    TSBaseAlertVC *alertVc = [[TSAlertContentVC alloc]init];
    alertVc.configer = config;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];
    
}


+(void)presentInputAlertOnVC:(UIViewController *)superVC alertTitle:(NSString *)alertTiltle alertContent:(NSString *)alertContent confirm:(NSString *)confirmString confirmBlock:(void(^)(id actionValue))confirmBlock cancel:(NSString *)cancelString cancelBlock:(void(^)(id actionValue))cancelBlock valueVerifyBlock:(TSAlertError*(^)(id actionValue))valueVerifyBlock{
    
    TSAlertConfiger *config = [[TSAlertConfiger alloc]init];
    config.alerViewCornerRadius = 24;
    config.dismissWhenTapBackground = YES;
    config.alertType = eTSAlertTypeInputView;

    config.title = alertTiltle;
    config.titleFont = [TSFont TSFontPingFangMediumWithSize:18];
    config.titleColor = [TSColor colorwithHexString:@"#333333"];
    config.titleTextAlignment = NSTextAlignmentCenter;
    
    config.content = alertContent;
    config.contentFont = [TSFont TSFontPingFangRegularWithSize:16];
    config.contentColor = [TSColor colorwithHexString:@"#333333"];
    config.contentBackgroundColor = [TSColor colorwithHexString:@"#F4F4F4"];
    config.contentTextAlignment = NSTextAlignmentCenter;
    config.contentCornerRadius = 25;
    config.keyboardType = UIKeyboardTypeNumberPad;
    
    TSAlertAction *sureAction = [[TSAlertAction alloc]init];
    sureAction.actionString = confirmString;
    sureAction.actionStringCorlor = [TSColor colorwithHexString:@"#FFFFFF"];
    sureAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    sureAction.actionBackCorlor = [TSColor colorwithHexString:@"#0072DB"];
//    sureAction.isGradientColor = YES;
//    sureAction.gradientBeginCorlor = [TSColor colorwithHexString:@"#24FFBD"];
//    sureAction.gradientEndCorlor = [TSColor colorwithHexString:@"#46BAFF"];
    sureAction.actionCornerRadius = 10;
    sureAction.actionBlock = confirmBlock;
    sureAction.valueVerifyBlock = valueVerifyBlock;

    TSAlertAction *cancelAction = [[TSAlertAction alloc]init];
    cancelAction.actionString = cancelString;
    cancelAction.actionStringCorlor = [TSColor colorwithHexString:@"#999999"];
    cancelAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    cancelAction.actionBackCorlor = [TSColor colorwithHexString:@"#F2F2F2"];
    cancelAction.actionCornerRadius = 10;
    cancelAction.actionBlock = cancelBlock;

    config.actions = @[cancelAction,sureAction];

    TSBaseAlertVC *alertVc = [[TSAlertInputVC alloc]init];
    alertVc.configer = config;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];
    
}

+ (void)presentInputAlertOnVC:(UIViewController *)superVC
                   alertTitle:(NSString *)alertTiltle
                 alertContent:(NSString *)alertContent
                      confirm:(NSString *)confirmString
                 confirmBlock:(void(^)(id actionValue))confirmBlock
                       cancel:(NSString *)cancelString
                  cancelBlock:(void(^)(id actionValue))cancelBlock
             valueVerifyBlock:(TSAlertError*(^)(id actionValue))valueVerifyBlock
                     alertSet:(nullable TSAlertConfiger * (^)(TSAlertConfiger *configer))alertSet {
    
    TSAlertConfiger *config = [[TSAlertConfiger alloc]init];
    config.alerViewCornerRadius = 24;
    config.dismissWhenTapBackground = YES;
    config.alertType = eTSAlertTypeInputView;

    config.title = alertTiltle;
    config.titleFont = [TSFont TSFontPingFangMediumWithSize:18];
    config.titleColor = [TSColor colorwithHexString:@"#333333"];
    config.titleTextAlignment = NSTextAlignmentCenter;
    
    config.content = alertContent;
    config.contentFont = [TSFont TSFontPingFangRegularWithSize:16];
    config.contentColor = [TSColor colorwithHexString:@"#333333"];
    config.contentBackgroundColor = [TSColor colorwithHexString:@"#F4F4F4"];
    config.contentTextAlignment = NSTextAlignmentCenter;
    config.contentCornerRadius = 25;
    config.keyboardType = UIKeyboardTypeNumberPad;
    
    TSAlertAction *sureAction = [[TSAlertAction alloc]init];
    sureAction.actionString = confirmString;
    sureAction.actionStringCorlor = [TSColor colorwithHexString:@"#FFFFFF"];
    sureAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    sureAction.actionBackCorlor = [TSColor colorwithHexString:@"#0072DB"];
//    sureAction.isGradientColor = YES;
//    sureAction.gradientBeginCorlor = [TSColor colorwithHexString:@"#24FFBD"];
//    sureAction.gradientEndCorlor = [TSColor colorwithHexString:@"#46BAFF"];
    sureAction.actionCornerRadius = 10;
    sureAction.actionBlock = confirmBlock;
    sureAction.valueVerifyBlock = valueVerifyBlock;

    TSAlertAction *cancelAction = [[TSAlertAction alloc]init];
    cancelAction.actionString = cancelString;
    cancelAction.actionStringCorlor = [TSColor colorwithHexString:@"#999999"];
    cancelAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    cancelAction.actionBackCorlor = [TSColor colorwithHexString:@"#F2F2F2"];
    cancelAction.actionCornerRadius = 10;
    cancelAction.actionBlock = cancelBlock;

    config.actions = @[cancelAction,sureAction];

    if (alertSet) { config = alertSet(config); }

    TSBaseAlertVC *alertVc = [[TSAlertInputVC alloc]init];
    alertVc.configer = config;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];
}

+(void)presentMusicAlertOnVC:(UIViewController *)superVC alertTitle:(NSString *)alertTiltle itemArray:(NSArray *)itemArray confirm:(NSString *)confirmString confirmBlock:(void (^)(id))confirmBlock cancel:(NSString *)cancelString cancelBlock:(void (^)(id))cancelBlock{
    
    
    TSAlertConfiger *config = [[TSAlertConfiger alloc]init];
    config.alerViewCornerRadius = 24;
    config.dismissWhenTapBackground = NO;
    config.alertType = eTSAlertTypeShowText;
    config.cellHeight = 54;
    config.alertItemArray = itemArray;
    
    
    config.title = alertTiltle;
    config.titleFont = [TSFont TSFontPingFangRegularWithSize:16];
    config.titleColor = [TSColor colorwithHexString:@"#333333"];
    config.titleTextAlignment = NSTextAlignmentCenter;
    
    config.contentCornerRadius = 12;

    TSAlertAction *sureAction = [[TSAlertAction alloc]init];
    sureAction.actionString = confirmString;
    sureAction.actionStringCorlor = [TSColor colorwithHexString:@"#FFFFFF"];
    sureAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    sureAction.actionBackCorlor = [TSColor colorwithHexString:@"#0072DB"];
//    sureAction.isGradientColor = YES;
//    sureAction.gradientBeginCorlor = [TSColor colorwithHexString:@"#24FFBD"];
//    sureAction.gradientEndCorlor = [TSColor colorwithHexString:@"#46BAFF"];
    sureAction.actionCornerRadius = 10;
    sureAction.actionBlock = confirmBlock;

    TSAlertAction *cancelAction = [[TSAlertAction alloc]init];
    cancelAction.actionString = cancelString;
    cancelAction.actionStringCorlor = [TSColor colorwithHexString:@"#999999"];
    cancelAction.actionFont = [TSFont TSFontPingFangMediumWithSize:16];
    cancelAction.actionBackCorlor = [TSColor colorwithHexString:@"#F2F2F2"];
    cancelAction.actionCornerRadius = 10;
    cancelAction.actionBlock = cancelBlock;

    config.actions = @[cancelAction,sureAction];

    TSBaseAlertVC *alertVc = [[TSAlertListVC alloc]init];
    alertVc.configer = config;
    alertVc.modalPresentationStyle = UIModalPresentationCustom;
    alertVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [superVC presentViewController:alertVc animated:YES completion:^{
        
    }];

    
}


@end
