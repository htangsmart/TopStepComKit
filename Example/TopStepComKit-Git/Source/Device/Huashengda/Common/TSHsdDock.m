//
//  TSHsdDock.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdDock.h"
#import "TSHsdViews.h"
#import "TSHsdDisplay.h"
#import "TSRootVC.h"

static const CGFloat kTSHsdDockBarHeight = 66.f;

@interface TSHsdDock ()
@property (nonatomic, strong) UIVisualEffectView *bar;
@property (nonatomic, strong) UIView *barTint;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *smallLabel;
@property (nonatomic, strong) TSHsdCTAButton *button;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIVisualEffectView *pill;
@property (nonatomic, strong) UIImageView *pillIcon;
@property (nonatomic, strong) UILabel *pillLabel;
@end

@implementation TSHsdDock

+ (CGFloat)barHeight { return kTSHsdDockBarHeight; }

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _buttonTitle = TSLocalizedString(@"hsd.save.to_watch");
    _buttonEnabled = YES;
    self.backgroundColor = [UIColor clearColor];

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
    _bar = [[UIVisualEffectView alloc] initWithEffect:blur];
    _bar.layer.cornerRadius = 26.f;
    _bar.clipsToBounds = YES;
    [self addSubview:_bar];
    _barTint = [[UIView alloc] init];
    _barTint.backgroundColor = [[TSHsdDisplay card] colorWithAlphaComponent:0.7f];
    [_bar.contentView addSubview:_barTint];

    _messageLabel = [[UILabel alloc] init];
    _messageLabel.font = [UIFont systemFontOfSize:13.5f weight:UIFontWeightSemibold];
    _messageLabel.textColor = [TSHsdDisplay ink];
    [_bar.contentView addSubview:_messageLabel];

    _smallLabel = [[UILabel alloc] init];
    _smallLabel.font = [UIFont systemFontOfSize:11.5f];
    _smallLabel.textColor = [TSHsdDisplay textSecondary];
    [_bar.contentView addSubview:_smallLabel];

    _button = [[TSHsdCTAButton alloc] init];
    __weak typeof(self) weakSelf = self;
    _button.onTap = ^{ if (weakSelf.onTap) { weakSelf.onTap(); } };
    [_bar.contentView addSubview:_button];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _spinner.hidesWhenStopped = YES;
    [_bar.contentView addSubview:_spinner];

    _pill = [[UIVisualEffectView alloc] initWithEffect:blur];
    _pill.layer.cornerRadius = 17.f;
    _pill.clipsToBounds = YES;
    [self addSubview:_pill];
    _pillIcon = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"wifi.slash", 12.f, UIImageSymbolWeightBold)];
    _pillIcon.tintColor = [TSHsdDisplay statusBad];
    _pillIcon.contentMode = UIViewContentModeCenter;
    [_pill.contentView addSubview:_pillIcon];
    _pillLabel = [[UILabel alloc] init];
    _pillLabel.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold];
    _pillLabel.textColor = [TSHsdDisplay textSecondary];
    [_pill.contentView addSubview:_pillLabel];

    // 浮起阴影
    self.layer.shadowColor = [UIColor colorWithRed:0x14/255.f green:0x17/255.f blue:0x26/255.f alpha:1].CGColor;
    self.layer.shadowOpacity = 0.18f;
    self.layer.shadowRadius = 18.f;
    self.layer.shadowOffset = CGSizeMake(0, 10.f);
    [self ts_apply];
    return self;
}

- (void)setState:(TSHsdDockState)state { _state = state; [self ts_apply]; }
- (void)setMessage:(nullable NSString *)message { _message = [message copy]; [self ts_apply]; }
- (void)setSmall:(nullable NSString *)small { _small = [small copy]; [self ts_apply]; }
- (void)setButtonTitle:(NSString *)buttonTitle { _buttonTitle = [buttonTitle copy]; [self ts_apply]; }
- (void)setButtonEnabled:(BOOL)buttonEnabled { _buttonEnabled = buttonEnabled; [self ts_apply]; }
- (void)setOfflineText:(nullable NSString *)offlineText { _offlineText = [offlineText copy]; [self ts_apply]; }

- (void)ts_apply {
    BOOL wasHidden = self.hidden;
    self.hidden = (self.state == TSHsdDockStateHidden);
    self.bar.hidden = (self.state == TSHsdDockStateOffline);
    self.pill.hidden = (self.state != TSHsdDockStateOffline);
    [self.spinner stopAnimating];

    switch (self.state) {
        case TSHsdDockStateDirty:
            self.messageLabel.text = self.message ?: TSLocalizedString(@"hsd.dock.dirty");
            self.smallLabel.text = self.small ?: TSLocalizedString(@"hsd.dock.dirty_small");
            self.button.enabled = self.buttonEnabled;
            break;
        case TSHsdDockStateSaving:
            self.messageLabel.text = self.message ?: TSLocalizedString(@"hsd.dock.saving");
            self.smallLabel.text = self.small ?: TSLocalizedString(@"hsd.dock.dirty_small");
            self.button.enabled = NO;
            [self.spinner startAnimating];
            break;
        case TSHsdDockStateWriteOnly:
            self.messageLabel.text = self.message ?: TSLocalizedString(@"hsd.dock.write_only");
            self.smallLabel.text = self.small ?: @"";
            self.button.enabled = self.buttonEnabled;
            break;
        case TSHsdDockStateOffline:
            self.pillLabel.text = self.offlineText ?: TSLocalizedString(@"hsd.dock.offline_save");
            break;
        case TSHsdDockStateHidden:
        default:
            break;
    }
    [self.button setTitle:self.buttonTitle symbol:nil];
    [self setNeedsLayout];
    if (wasHidden && !self.hidden) {
        // 从底部浮起（dockup）
        self.transform = CGAffineTransformMakeTranslation(0, 24.f);
        self.alpha = 0;
        [UIView animateWithDuration:0.28 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.6 options:0 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.alpha = 1;
        } completion:nil];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.bar.frame = CGRectMake(0, 0, w, kTSHsdDockBarHeight);
    self.barTint.frame = self.bar.bounds;
    CGSize bs = [self.button sizeThatFits:CGSizeZero];
    self.button.frame = CGRectMake(w - 10.f - bs.width, 10.f, bs.width, 46.f);
    self.spinner.center = CGPointMake(CGRectGetMinX(self.button.frame) - 16.f, kTSHsdDockBarHeight / 2.f);
    CGFloat textW = CGRectGetMinX(self.button.frame) - 12.f - 18.f - (self.spinner.isAnimating ? 28.f : 0);
    self.messageLabel.frame = CGRectMake(18.f, 15.f, textW, 18.f);
    self.smallLabel.frame = CGRectMake(18.f, 35.f, textW, 16.f);
    self.layer.shadowPath = self.bar.hidden ? nil : [UIBezierPath bezierPathWithRoundedRect:self.bar.frame cornerRadius:26.f].CGPath;

    CGFloat pw = ceil([self.pillLabel.text sizeWithAttributes:@{NSFontAttributeName: self.pillLabel.font}].width) + 14.f * 2 + 14.f + 7.f;
    self.pill.frame = CGRectMake((w - pw) / 2.f, kTSHsdDockBarHeight - 34.f, pw, 34.f);
    self.pillIcon.frame = CGRectMake(14.f, 10.f, 14.f, 14.f);
    self.pillLabel.frame = CGRectMake(35.f, 0, pw - 35.f - 14.f, 34.f);
}

@end
