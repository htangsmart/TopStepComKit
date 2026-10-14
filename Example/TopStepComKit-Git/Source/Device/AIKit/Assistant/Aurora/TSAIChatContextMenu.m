//
//  TSAIChatContextMenu.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatContextMenu.h"

#import "TSAIChatTheme.h"

@interface TSAIChatContextMenu ()

// 全屏点击拦截层
@property (nonatomic, strong) UIControl *dimmer;
// 动作回调
@property (nonatomic, copy, nullable) void (^handler)(TSAIChatContextMenuAction action);

@end

@implementation TSAIChatContextMenu

#pragma mark - 公开方法

+ (instancetype)showAboveBubble:(UIView *)bubble
                         inView:(UIView *)hostView
                     alignRight:(BOOL)alignRight
                        handler:(void (^)(TSAIChatContextMenuAction))handler {
    TSAIChatContextMenu *menu = [[TSAIChatContextMenu alloc] initWithFrame:CGRectZero];
    menu.handler = handler;

    menu.dimmer = [[UIControl alloc] initWithFrame:hostView.bounds];
    menu.dimmer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [menu.dimmer addTarget:menu action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [hostView addSubview:menu.dimmer];
    [hostView addSubview:menu];

    CGRect bubbleFrame = [bubble convertRect:bubble.bounds toView:hostView];
    CGFloat width = CGRectGetWidth(menu.bounds);
    CGFloat height = CGRectGetHeight(menu.bounds);
    CGFloat x = alignRight ? CGRectGetMaxX(bubbleFrame) - width : CGRectGetMinX(bubbleFrame);
    x = MAX(8, MIN(CGRectGetWidth(hostView.bounds) - width - 8, x));
    CGFloat y = CGRectGetMinY(bubbleFrame) - 58;
    if (y < 8) y = CGRectGetMaxY(bubbleFrame) + 8;
    menu.frame = CGRectMake(x, y, width, height);

    if (TSAIChatReduceMotion()) {
        menu.alpha = 1;
    } else {
        menu.alpha = 0;
        menu.transform = CGAffineTransformMakeScale(0.85, 0.85);
        [UIView animateWithDuration:0.2
                              delay:0
             usingSpringWithDamping:0.62
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            menu.alpha = 1;
            menu.transform = CGAffineTransformIdentity;
        }
                         completion:nil];
    }
    return menu;
}

- (void)dismiss {
    [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.15
                     animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }
                     completion:^(BOOL finished) {
        [self.dimmer removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIChatInkColor() colorWithAlphaComponent:0.94];
        self.layer.cornerRadius = 16;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        TSAIChatApplyFloatShadow(self.layer);

        NSArray<NSString *> *titles = @[@"播放", @"复制", @"删除"];
        NSArray<NSString *> *symbols = @[@"play.fill", @"doc.on.doc", @"trash"];
        CGFloat x = 6;
        for (NSInteger index = 0; index < 3; index++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = index;
            UIColor *color = index == TSAIChatContextMenuActionDelete ? TSAIChatHexColor(0xFF9BB0) : [UIColor whiteColor];
            button.frame = CGRectMake(x, 6, 54, 16 + 4 + 13 + 14);
            button.layer.cornerRadius = 11;
            button.layer.cornerCurve = kCACornerCurveContinuous;
            button.tintColor = color;

            UIImageView *icon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(symbols[index], 13, UIImageSymbolWeightSemibold)];
            icon.tintColor = color;
            icon.contentMode = UIViewContentModeScaleAspectFit;
            icon.frame = CGRectMake((54 - 16) / 2, 7, 16, 16);
            icon.userInteractionEnabled = NO;
            [button addSubview:icon];

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 7 + 16 + 4, 54, 13)];
            label.text = titles[index];
            label.font = TSAIChatFont(10.5, UIFontWeightSemibold);
            label.textColor = color;
            label.textAlignment = NSTextAlignmentCenter;
            label.userInteractionEnabled = NO;
            [button addSubview:label];

            [button addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(onButtonDown:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(onButtonUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
            [self addSubview:button];
            x += 54 + 2;
        }
        self.bounds = CGRectMake(0, 0, x + 4, 6 + 47 + 6);
    }
    return self;
}

#pragma mark - 事件

- (void)onButtonTapped:(UIButton *)button {
    void (^handler)(TSAIChatContextMenuAction) = self.handler;
    [self dismiss];
    if (handler) handler((TSAIChatContextMenuAction)button.tag);
}

- (void)onButtonDown:(UIButton *)button {
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
}

- (void)onButtonUp:(UIButton *)button {
    button.backgroundColor = [UIColor clearColor];
}

@end
