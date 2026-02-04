//
//  NSArray+TSArray.h
//  JieliJianKang
//
//  Created by 密码：0000 on 2024/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (TSArray)

- (NSArray *)_filter:(BOOL(^)(id))handle;

@end

NS_ASSUME_NONNULL_END
