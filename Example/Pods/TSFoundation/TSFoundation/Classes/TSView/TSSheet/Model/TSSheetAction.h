//
//  TSSheetAction.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import <Foundation/Foundation.h>


typedef void(^TSSheetActionBlock)(id actionValue);

@interface TSSheetAction : NSObject

@property (nonatomic,strong) NSString * actionName;

@property (nonatomic,copy) TSSheetActionBlock actionBlock;

- (instancetype)initWithActionName:(NSString *)actionName actionBlock:(TSSheetActionBlock)actionBlock;


@end


