//
//  TSAlertAction.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertAction.h"
#import "TSFont.h"

@implementation TSAlertAction

- (UIFont *)actionFont{
    return _actionFont?_actionFont:[TSFont TSFontPingFangMediumWithSize:16];
}

- (UIColor *)actionBackCorlor{
    return _actionBackCorlor?_actionBackCorlor:[UIColor whiteColor];
}
@end
