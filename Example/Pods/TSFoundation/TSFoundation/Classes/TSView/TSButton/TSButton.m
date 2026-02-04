//
//  TSButton.m
//  JieliJianKang
//
//  Created by luigi on 2024/3/26.
//

#import "TSButton.h"

@interface TSButton ()
@property (nonatomic, strong) CAGradientLayer * gradientLayer;
@end

@implementation TSButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.gradientLayer.frame = rect;
    [self bringSubviewToFront:self.titleLabel];
}

+ (instancetype)defaultGradientLayerButton {
    return [self createGradientLayerButtonWithColors:@[ TSHEXCOLOR(#24FFBD), TSHEXCOLOR(#46BAFF) ] locations:@[ @(0), @(1) ] gradientDirection:(TSGradientDirectionLeftToRight)];
}

+ (instancetype)createGradientLayerButtonWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations
                                  gradientDirection:(TSGradientDirection)direction {
    
    TSButton *btn = [[TSButton alloc] init];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectZero;
    
    //  创建渐变色数组，需要转换为CGColor颜色
    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [cgColors addObject:(__bridge id)obj.CGColor];
    }];
    gradientLayer.colors = cgColors;
    
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    CGPoint startPoint = CGPointMake(0, 0.5);
    CGPoint endPoint = CGPointMake(1, 0.5);
    
    switch (direction) {
        case TSGradientDirectionLeftToRight:
            startPoint = CGPointMake(0, 0.5);
            endPoint = CGPointMake(1, 0.5);
            break;
        case TSGradientDirectionTopToBottom:
            startPoint = CGPointMake(0.5, 0);
            endPoint = CGPointMake(0.5, 1);
            break;
        case TSGradientDirectionLeftTopToRightBottom:
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(1, 1);
            break;
        case TSGradientDirectionLeftBottomToRightTop:
            startPoint = CGPointMake(1, 1);
            endPoint = CGPointMake(0, 0);
            break;
            
        default:
            break;
    }
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = locations;
    [btn.layer insertSublayer:gradientLayer atIndex:0];
    btn.gradientLayer = gradientLayer;
    
    return btn;
}

- (void)initialization
{
    // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
    // 不能设为0，否则无效；也不能设置为小数点，否则无法像素对齐
    self.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 1, 0);
    
    self.imagePosition = UIRectEdgeLeft;//默认布局
    self.touchSize = CGSizeZero;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    //size存在空的情况
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    //默认布局不用处理
    if (self.imagePosition == UIRectEdgeLeft) {
        return;
    }
    //content的实际size
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    
    //垂直布局
    if (self.imagePosition & UIRectEdgeTop
        || self.imagePosition & UIRectEdgeBottom) {
        
        CGFloat imageLimitWidth = contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)];// 假设图片高度必定完整显示
        CGRect imageFrame = CGRectMakeWithSize(imageSize);
        
        CGSize titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) - imageSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.height = fminf(titleSize.height, titleLimitSize.height);
        CGRect titleFrame = CGRectMakeWithSize(titleSize);
        //到这里image和title都是扣除了偏移量后的实际size，frame重置为x/y=0
        
        
        switch (self.contentHorizontalAlignment) {//重置X坐标
            case UIControlContentHorizontalAlignmentLeft:
                imageFrame = CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left);
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                break;
            case UIControlContentHorizontalAlignmentCenter:
                imageFrame = CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left + CGFloatGetCenter(imageLimitWidth, imageSize.width));
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left + CGFloatGetCenter(titleLimitSize.width, titleSize.width));
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - imageSize.width);
                titleFrame = CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.titleEdgeInsets.right - titleSize.width);
                break;
            case UIControlContentHorizontalAlignmentFill://此时要铺满button，所以要重置width
                imageFrame = CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left);
                imageFrame = CGRectSetWidth(imageFrame, imageLimitWidth);
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                titleFrame = CGRectSetWidth(titleFrame, titleLimitSize.width);
                break;
            case UIControlContentHorizontalAlignmentLeading:
                
                break;
            case UIControlContentHorizontalAlignmentTrailing:
                
                break;
        }
        
        if (self.imagePosition & UIRectEdgeTop) {//重置Y坐标
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top);
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) + CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets);
                    CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + self.contentEdgeInsets.top;
                    imageFrame = CGRectSetY(imageFrame, minY + self.imageEdgeInsets.top);
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top);
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    titleFrame = CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame));
                    imageFrame = CGRectSetY(imageFrame, CGRectGetMinY(titleFrame) - self.titleEdgeInsets.top - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                    break;
                case UIControlContentVerticalAlignmentFill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top);
                    titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                    break;
            }
        } else {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                    imageFrame = CGRectSetY(imageFrame, CGRectGetMaxY(titleFrame) + self.titleEdgeInsets.bottom + self.imageEdgeInsets.top);
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets) + CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                    CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + self.contentEdgeInsets.top;
                    titleFrame = CGRectSetY(titleFrame, minY + self.titleEdgeInsets.top);
                    imageFrame = CGRectSetY(imageFrame, CGRectGetMaxY(titleFrame) + self.titleEdgeInsets.bottom + self.imageEdgeInsets.top);
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMinY(imageFrame) - self.imageEdgeInsets.top - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame));
                    
                    break;
                case UIControlContentVerticalAlignmentFill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                    titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                    titleFrame = CGRectSetHeight(titleFrame, CGRectGetMinY(imageFrame) - self.imageEdgeInsets.top - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                    break;
            }
        }
        
        self.imageView.frame = CGRectFlatted(imageFrame);
        self.titleLabel.frame = CGRectFlatted(titleFrame);
        
    } else if (self.imagePosition & UIRectEdgeRight) {//水平布局
        
        CGFloat imageLimitHeight = contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)];// 假设图片宽度必定完整显示，高度不超过按钮内容
        CGRect imageFrame = CGRectMakeWithSize(imageSize);
        
        CGSize titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - CGRectGetWidth(imageFrame) - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.height = fminf(titleSize.height, titleLimitSize.height);
        CGRect titleFrame = CGRectMakeWithSize(titleSize);
        
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                imageFrame = CGRectSetX(imageFrame, CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + self.imageEdgeInsets.left);
                break;
            case UIControlContentHorizontalAlignmentCenter: {
                CGFloat contentWidth = CGRectGetWidth(titleFrame) + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) + CGRectGetWidth(imageFrame) + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
                CGFloat minX = self.contentEdgeInsets.left + CGFloatGetCenter(contentSize.width, contentWidth);
                titleFrame = CGRectSetX(titleFrame, minX + self.titleEdgeInsets.left);
                imageFrame = CGRectSetX(imageFrame, CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + self.imageEdgeInsets.left);
            }
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame));
                titleFrame = CGRectSetX(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame));
                break;
            case UIControlContentHorizontalAlignmentFill:
                // 图片按自身大小显示，剩余空间由标题占满
                imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame));
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                titleFrame = CGRectSetWidth(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
                break;
            case UIControlContentHorizontalAlignmentLeading:
                
                break;
            case UIControlContentHorizontalAlignmentTrailing:
                
                break;
        }
        
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop:
                titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                break;
            case UIControlContentVerticalAlignmentCenter:
                titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets)));
                imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets)));
                break;
            case UIControlContentVerticalAlignmentBottom:
                titleFrame = CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame));
                imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                break;
            case UIControlContentVerticalAlignmentFill:
                titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                imageFrame = CGRectSetHeight(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetMinY(imageFrame));
                break;
        }
        
        self.imageView.frame = CGRectFlatted(imageFrame);
        self.titleLabel.frame = CGRectFlatted(titleFrame);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
    if (CGSizeEqualToSize(self.bounds.size, size)) {
        size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    
    CGSize resultSize = CGSizeZero;
    CGSize contentLimitSize = CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), size.height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    switch (self.imagePosition) {
        case UIRectEdgeTop:
        case UIRectEdgeBottom: {
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
            CGFloat imageLimitWidth = contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
            CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)];// 假设图片高度必定完整显示
            
            CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) - imageSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.height = fminf(titleSize.height, titleLimitSize.height);
            
            resultSize.width = UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets);
            resultSize.width += fmaxf(UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets) + imageSize.width, UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) + titleSize.width);
            resultSize.height = UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) + imageSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets) + titleSize.height;
        }
            break;
            
        case UIRectEdgeLeft:
        case UIRectEdgeRight: {
            if (self.imagePosition & UIRectEdgeLeft && self.titleLabel.numberOfLines == 1) {
                
                resultSize = [super sizeThatFits:size];
                
            } else {
                // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
                
                CGFloat imageLimitHeight = contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)];// 假设图片宽度必定完整显示，高度不超过按钮内容
                
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - imageSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fminf(titleSize.height, titleLimitSize.height);
                
                resultSize.width = UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets) + imageSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) + titleSize.width;
                resultSize.height = UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
                resultSize.height += fmaxf(UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) + imageSize.height, UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets) + titleSize.height);
            }
        }
            break;
        case UIRectEdgeNone:
            break;
        case UIRectEdgeAll:
            break;
    }
    return resultSize;
}

- (void)setImagePosition:(UIRectEdge)imagePosition
{
    _imagePosition = imagePosition;
    [self setNeedsLayout];
}


#pragma mark - 扩大按钮点击范围
// 重写此方法将按钮的点击范围扩大
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    
    // 扩大点击区域
    bounds = CGRectInset(bounds, -self.touchSize.width, -self.touchSize.height);
    
    // 若点击的点在新的bounds里面。就返回yes
    return CGRectContainsPoint(bounds, point);
}
@end
