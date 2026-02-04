//
//  NSBundle+TSFoundation.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/7.
//

#import "NSBundle+TSFoundation.h"

@implementation NSBundle (TSFoundation)

+ (NSBundle *)foundationBundle{
    static NSBundle *tsFoundationBundle = nil;
    if (!tsFoundationBundle) {
        NSBundle *mainBundle = [NSBundle bundleForClass:[TSLoading class]];
        NSString *resourcePath = [mainBundle pathForResource:@"TSFoundation" ofType:@"bundle"];
        tsFoundationBundle = [NSBundle bundleWithPath:resourcePath];
    }
    return tsFoundationBundle;
}


@end
