//
//  TSAlertConfiger.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertConfiger.h"
#import "TSFont.h"
@implementation TSAlertConfiger


- (UIColor *)titleColor{
    return _titleColor?_titleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
}

- (UIColor *)contentColor{
    return _contentColor?_contentColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
}

- (UIFont *)titleFont{
    return _titleFont?_titleFont:[TSFont TSFontPingFangMediumWithSize:18];
}

- (UIFont *)contentFont{
    return _contentFont?_contentFont:[TSFont TSFontPingFangMediumWithSize:16];
}


@end
