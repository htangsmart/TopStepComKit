//
//  UIImage+Bundle.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/7.
//

#import "UIImage+Bundle.h"
#import "TSChecker.h"
@implementation UIImage (Bundle)


+(UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle{
    if (bundle == nil) {return nil;}
    if ([TSChecker isEmptyString:name]) {return nil;}
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
