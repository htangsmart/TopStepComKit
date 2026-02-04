//
//  UIView+Frame.m
//  TSFoundation
//
//  Created by 磐石 on 2024/7/30.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)


- (CGFloat)maxX{
    return CGRectGetMaxX(self.frame);
}
- (CGFloat)minX{
    return CGRectGetMinX(self.frame);
}

- (CGFloat)maxY{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)minY{
    return CGRectGetMinY(self.frame);
}

- (CGFloat)oriX{
    return CGRectGetMinX(self.frame);
}

- (CGFloat)oriY{
    return  CGRectGetMinY(self.frame);
}

- (void)setOriY:(CGFloat)oriY{
    self.frame =CGRectMake(self.oriX, oriY, self.width, self.height);
}

- (CGFloat)width{
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height{
    return CGRectGetHeight(self.frame);
}


- (CGSize)size{
    return self.frame.size;
}





@end
