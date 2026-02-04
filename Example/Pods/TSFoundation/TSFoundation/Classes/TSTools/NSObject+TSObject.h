//
//  NSObject+TSObject.h
//  TSFoundation
//
//  Created by luigi on 2024/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TSObject)

/// 将object中相同的属性拷贝到newObject，object必须实现valueForUndefinedKey方法，newObject必须实现setValue: forUndefinedKey:方法
+ (void)copyPropertyFrom:(id)object to:(id)newObject;

@end

NS_ASSUME_NONNULL_END
