//
//  TSBezierPath.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSBezierRoundType) {
    eTSBezierRoundAll = 0,
    eTSBezierRoundTop,
    eTSBezierRoundMiddle,
    eTSBezierRoundBottom,

};



@interface TSBezierPath : NSObject

+ (TSBezierRoundType)bezierRoundTypeAtIndexPath:(NSInteger)index totalCount:(NSInteger)totalCount;


+ (UIBezierPath *)bezierPathWithType:(TSBezierRoundType)roundType bounds:(CGRect)bounds cornerRadius:(CGFloat)cornerRadius;

+ (UIBezierPath *)bezierPathWithRoundingCorners:(UIRectCorner)corners bounds:(CGRect)bounds cornerRadius:(CGSize)cornerRadius;



@end

NS_ASSUME_NONNULL_END
