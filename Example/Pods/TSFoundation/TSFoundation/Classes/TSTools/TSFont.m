//
//  TSFont.m
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/25.
//

#import "TSFont.h"

@implementation TSFont

/*
Font: PingFangHK-Regular
Font: PingFangHK-Ultralight
Font: PingFangHK-Thin
Font: PingFangHK-Light
Font: PingFangHK-Medium
Font: PingFangHK-Semibold
Font: PingFangSC-Regular
Font: PingFangSC-Ultralight
Font: PingFangSC-Thin
Font: PingFangSC-Light
Font: PingFangSC-Medium
Font: PingFangSC-Semibold
Font: PingFangTC-Regular
Font: PingFangTC-Ultralight
Font: PingFangTC-Thin
Font: PingFangTC-Light
Font: PingFangTC-Medium
Font: PingFangTC-Semibold
*/


+ (UIFont *)TSFontPingFangRegularWithSize:(CGFloat)fontSize{
    
    return [UIFont fontWithName:@"PingFangSC-Regular" size: fontSize];
}

+ (UIFont *)TSFontPingFangLightWithSize:(CGFloat)fontSize{
    
    return [UIFont fontWithName:@"PingFangSC-Light" size: fontSize];
}

+ (UIFont *)TSFontPingFangMediumWithSize:(CGFloat)fontSize{
    
    return [UIFont fontWithName:@"PingFangSC-Medium" size: fontSize];
}

+ (UIFont *)TSFontPingFangSemiboldWithSize:(CGFloat)fontSize{
    
    return [UIFont fontWithName:@"PingFangSC-Semibold" size: fontSize];
}


//2024-01-19 17:42:49.879212+0800 JieliJianKang[10753:2485737] DIN Alternate
//2024-01-19 17:42:49.879554+0800 JieliJianKang[10753:2485737]      (
//    ""
//)


+ (UIFont *)TSFontDINAlternateBoldWithSize:(CGFloat)fontSize{
    
    return [UIFont fontWithName:@"DINAlternate-Bold" size: fontSize];
}

@end
