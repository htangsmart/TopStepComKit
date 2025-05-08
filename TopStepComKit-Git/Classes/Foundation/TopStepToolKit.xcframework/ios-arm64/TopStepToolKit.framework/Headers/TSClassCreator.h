//
//  TSClassCreator.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSClassCreator : NSObject

+ (id)createInstanceWithProtocol:(Protocol *)protocol prefix:(NSString *)prefix;

+ (NSString *)classNameFormProtocol:(Protocol *)protocol prefix:(NSString *)prefix;


// test
@end

NS_ASSUME_NONNULL_END
