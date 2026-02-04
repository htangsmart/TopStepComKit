//
//  NSArray+TSArray.m
//  JieliJianKang
//
//  Created by 密码：0000 on 2024/4/22.
//

#import "NSArray+TSArray.h"

@implementation NSArray (TSArray)
- (NSArray *)_filter:(BOOL(^)(id))handle {
    if (!handle || !self) return self;
    
    NSMutableArray *arr = NSMutableArray.array;
    for (id obj in self) {
        if (handle(obj)) {
            [arr addObject:obj];
        }
    }
    return arr.copy;
}
@end
