//
//  TSLoadingHUD.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSLoadingHUD.h"
#import "TSRootVC.h"
#import <objc/runtime.h>

/// 用于在父视图上查找已有 HUD 的关联对象 key
static const void *kTSLoadingHUDKey = &kTSLoadingHUDKey;

@interface TSLoadingHUD ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel                 *messageLabel;

@end

@implementation TSLoadingHUD

#pragma mark - 类方法

+ (void)showIn:(UIView *)view message:(nullable NSString *)message {
    // 先移除已有的 HUD
    [self hideIn:view];

    TSLoadingHUD *hud = [[self alloc] initWithMessage:message];
    hud.frame = view.bounds;
    [view addSubview:hud];

    // 保存引用以便后续移除
    objc_setAssociatedObject(view, kTSLoadingHUDKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 淡入动画
    hud.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        hud.alpha = 1;
    }];
}

+ (void)hideIn:(UIView *)view {
    TSLoadingHUD *hud = objc_getAssociatedObject(view, kTSLoadingHUDKey);
    if (!hud) { return; }

    objc_setAssociatedObject(view, kTSLoadingHUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView animateWithDuration:0.2 animations:^{
        hud.alpha = 0;
    } completion:^(BOOL finished) {
        [hud removeFromSuperview];
    }];
}

#pragma mark - 初始化

- (instancetype)initWithMessage:(nullable NSString *)message {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15f];

        // 毛玻璃卡片
        UIBlurEffect          *blur   = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
        UIVisualEffectView    *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.layer.cornerRadius    = TSRadius_LG;
        blurView.layer.masksToBounds   = YES;
        [self addSubview:blurView];

        // spinner
        UIActivityIndicatorViewStyle style;
        if (@available(iOS 13.0, *)) {
            style = UIActivityIndicatorViewStyleMedium;
        } else {
            style = UIActivityIndicatorViewStyleGray;
        }
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        [self.spinner startAnimating];
        [blurView.contentView addSubview:self.spinner];

        // 文字
        BOOL hasMessage = (message.length > 0);
        if (hasMessage) {
            self.messageLabel = [[UILabel alloc] init];
            self.messageLabel.text          = message;
            self.messageLabel.font          = TSFont_Caption;
            self.messageLabel.textColor     = TSColor_TextSecondary;
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
            self.messageLabel.numberOfLines = 2;
            [blurView.contentView addSubview:self.messageLabel];
        }

        // 布局
        CGFloat cardW  = hasMessage ? 120.f : 72.f;
        CGFloat cardH  = hasMessage ? 96.f  : 72.f;
        blurView.tag = 100;
        blurView.frame = CGRectMake(0, 0, cardW, cardH);

        CGFloat spinnerY = hasMessage ? TSSpacing_MD : (cardH - 20.f) * 0.5f;
        self.spinner.frame = CGRectMake((cardW - 20.f) * 0.5f, spinnerY, 20.f, 20.f);

        if (hasMessage) {
            CGFloat labelY = CGRectGetMaxY(self.spinner.frame) + TSSpacing_SM;
            self.messageLabel.frame = CGRectMake(TSSpacing_SM, labelY,
                                                 cardW - TSSpacing_SM * 2,
                                                 cardH - labelY - TSSpacing_SM);
        }

        // 将 blurView 居中（在 layoutSubviews 中重设）
        objc_setAssociatedObject(self, @"blurFrame", [NSValue valueWithCGRect:blurView.frame],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 更新遮罩层尺寸
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIVisualEffectView class]]) {
            CGFloat cardW = sub.frame.size.width;
            CGFloat cardH = sub.frame.size.height;
            sub.frame = CGRectMake(
                (CGRectGetWidth(self.bounds) - cardW) * 0.5f,
                (CGRectGetHeight(self.bounds) - cardH) * 0.5f,
                cardW, cardH
            );
        }
    }
}

@end
