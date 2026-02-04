//
//  TSColor.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/12.
//

#import <Foundation/Foundation.h>
#import "ColorConst.h"

NS_ASSUME_NONNULL_BEGIN

#define TSHEXCOLOR(_hex_) [TSColor colorwithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#define TSHEXACOLOR(_hex_,a) [TSColor colorwithHexString:((__bridge NSString *)CFSTR(#_hex_)) alpha:a]

@interface TSColor : NSObject

+ (UIColor *)colorwithHexString:(NSString *)hexStr;

+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
