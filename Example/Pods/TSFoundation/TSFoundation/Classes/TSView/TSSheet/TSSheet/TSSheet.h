//
//  TSSheet.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import <Foundation/Foundation.h>
#import "TSSheetAction.h"

NS_ASSUME_NONNULL_BEGIN


@interface TSSheet : NSObject


+(void)presentSheetOnVC:(UIViewController *)superVC actions:(NSArray<TSSheetAction *>*)actons cancel:(NSString *)cancelString cancelBlock:(void(^)(id actionValue))cancelBlock;

@end

NS_ASSUME_NONNULL_END
