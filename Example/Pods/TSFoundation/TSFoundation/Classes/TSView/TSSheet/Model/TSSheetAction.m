//
//  TSSheetAction.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import "TSSheetAction.h"

@implementation TSSheetAction

- (instancetype)initWithActionName:(NSString *)actionName actionBlock:(TSSheetActionBlock)actionBlock{
    self = [super init];
    if (self) {
        _actionName = actionName;
        _actionBlock = actionBlock;
    }
    
    return self;
}

@end
