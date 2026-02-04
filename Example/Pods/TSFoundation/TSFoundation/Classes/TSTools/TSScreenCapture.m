//
//  TSScreenCapture.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/23.
//

#import "TSScreenCapture.h"

@implementation TSScreenCapture

//View生成图片
+ (UIImage *)screenshotForView:(UIView *)view frame:(CGRect)cutFrame {
    UIImage *image = nil;
    //判断View类型（一般不是滚动视图或者其子类的话内容不会超过一屏，当然如果超过了也可以通过修改frame来实现绘制）
    
    if ([view.class isSubclassOfClass:[UITableView class]]){

        UITableView *currentTableView = (UITableView *)view;
        CGRect oriFrame = currentTableView.frame;
        currentTableView.frame = CGRectMake(currentTableView.frame.origin.x, currentTableView.frame.origin.y, currentTableView.frame.size.width, currentTableView.contentSize.height);
        image = [self screenshotForView:currentTableView cutFrame:CGRectMake(0, 0, CGRectGetWidth(currentTableView.frame), currentTableView.contentSize.height)];
        currentTableView.frame = oriFrame;
        
    } else if ([view.class isSubclassOfClass:[UIScrollView class]]) {
        UIScrollView *scrView = (UIScrollView *)view;
        CGPoint tempContentOffset = scrView.contentOffset;
        CGRect tempFrame = scrView.frame;
        scrView.contentOffset = CGPointZero;
        scrView.frame = CGRectMake(0, 0, scrView.contentSize.width, scrView.contentSize.height);
        image = [self screenshotForView:scrView cutFrame:cutFrame];
        scrView.contentOffset = tempContentOffset;
        scrView.frame = tempFrame;
    } else {
        image = [self screenshotForView:view cutFrame:cutFrame];
    }
    return image;
}


+ (UIImage *)screenshotForView:(UIView *)view cutFrame:(CGRect)cutFrame {
    UIImage *image = nil;
    //下面方法,第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果,需要传NO,否则传YES。第三个参数就是屏幕密度了,关键就是第三个参数。
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!CGRectEqualToRect(cutFrame, CGRectZero)) {
        float x = cutFrame.origin.x * image.scale;
        float y = cutFrame.origin.y * image.scale;
        float width = cutFrame.size.width * image.scale;
        float height = cutFrame.size.height * image.scale;
        
        CGRect rect = CGRectMake(x, y, width, height);
        CGImageRef tailorImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
        UIImage *tailorImage = [UIImage imageWithCGImage:tailorImageRef];
        CGImageRelease(tailorImageRef);
        return tailorImage;
    }
    return image;
}


@end
