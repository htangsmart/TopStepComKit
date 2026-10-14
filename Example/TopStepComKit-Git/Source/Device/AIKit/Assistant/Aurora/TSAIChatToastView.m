//
//  TSAIChatToastView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatToastView.h"

#import "TSAIChatTheme.h"

static const NSInteger kTSAIChatToastTag = 0x7A5A;

@interface TSAIChatToastView ()

// 文案
@property (nonatomic, strong) UILabel *textLabel;
// 自动消失定时器
@property (nonatomic, strong, nullable) NSTimer *dismissTimer;

@end

@implementation TSAIChatToastView

#pragma mark - 公开方法

+ (void)showText:(NSString *)text inView:(UIView *)view {
    if (!view || text.length == 0) return;
    TSAIChatToastView *existing = [view viewWithTag:kTSAIChatToastTag];
    [existing removeFromSuperview];

    TSAIChatToastView *toast = [[TSAIChatToastView alloc] init];
    toast.tag = kTSAIChatToastTag;
    toast.textLabel.text = text;
    CGSize textSize = [toast.textLabel sizeThatFits:CGSizeMake(CGRectGetWidth(view.bounds) - 64, 40)];
    CGFloat width = ceil(textSize.width) + 32;
    CGFloat height = ceil(textSize.height) + 18;
    toast.frame = CGRectMake((CGRectGetWidth(view.bounds) - width) / 2,
                             CGRectGetHeight(view.bounds) - 160 - height,
                             width, height);
    toast.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:toast];

    if (TSAIChatReduceMotion()) {
        toast.alpha = 1;
    } else {
        toast.alpha = 0;
        toast.transform = CGAffineTransformMakeTranslation(0, 10);
        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:0.62
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            toast.alpha = 1;
            toast.transform = CGAffineTransformIdentity;
        }
                         completion:nil];
    }
    toast.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:1.8
                                                          target:toast
                                                        selector:@selector(dismiss)
                                                        userInfo:nil
                                                         repeats:NO];
}

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIChatInkColor() colorWithAlphaComponent:0.90];
        self.layer.cornerRadius = 14;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.userInteractionEnabled = NO;
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = TSAIChatFont(12.5, UIFontWeightMedium);
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)dealloc {
    [_dismissTimer invalidate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectInset(self.bounds, 16, 9);
}

#pragma mark - 私有方法

/// 淡出并移除
- (void)dismiss {
    self.dismissTimer = nil;
    [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.25
                     animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, 6);
    }
                     completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
