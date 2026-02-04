//
//  TSBezierPath.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/19.
//

#import "TSBezierPath.h"

@implementation TSBezierPath

+ (UIBezierPath *)bezierPathWithType:(TSBezierRoundType)roundType bounds:(CGRect)bounds cornerRadius:(CGFloat)cornerRadius{
    
    if (roundType == eTSBezierRoundMiddle) {
        return [UIBezierPath bezierPathWithRect:bounds];
    }
    UIRectCorner corners = UIRectCornerAllCorners;
    if (roundType == eTSBezierRoundAll) {
        corners = UIRectCornerAllCorners;
    }else if (roundType == eTSBezierRoundTop) {
        corners = (UIRectCornerTopLeft|UIRectCornerTopRight);
    }else {
        corners = (UIRectCornerBottomLeft|UIRectCornerBottomRight);
    }
    return [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
}

+ (UIBezierPath *)bezierPathWithRoundingCorners:(UIRectCorner)corners bounds:(CGRect)bounds cornerRadius:(CGSize)cornerRadius{
    
    return [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corners cornerRadii:cornerRadius];
}

+ (TSBezierRoundType)bezierRoundTypeAtIndexPath:(NSInteger)index totalCount:(NSInteger)totalCount{
    if (totalCount == 1) {return eTSBezierRoundAll;}
    if (totalCount>0 && index == 0) {return eTSBezierRoundTop;}
    if (totalCount>0 && index == totalCount-1) {return eTSBezierRoundBottom;}
    return eTSBezierRoundMiddle;
}

@end
