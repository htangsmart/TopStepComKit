//
//  TSEpoStatusCard.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSEpoStatusCard.h"
#import "TSBaseVC.h"

// 「即将过期」阈值（天）
static const NSInteger kExpiringDays = 2;
static const CGFloat   kPad          = 16.f;

@interface TSEpoStatusCard ()

@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIView   *dotView;
@property (nonatomic, strong) UILabel  *stateLabel;
@property (nonatomic, strong) UILabel  *metaLabel;
@property (nonatomic, strong) UILabel  *remainLabel;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation TSEpoStatusCard

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCardStyle];
        [self addSubview:self.titleLabel];
        [self addSubview:self.refreshButton];
        [self addSubview:self.dotView];
        [self addSubview:self.stateLabel];
        [self addSubview:self.metaLabel];
        [self addSubview:self.remainLabel];
        [self addSubview:self.clearButton];
        [self renderUnknown];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat innerW = w - kPad * 2;

    self.titleLabel.frame   = CGRectMake(kPad, 14.f, innerW - 60.f, 18.f);
    self.refreshButton.frame = CGRectMake(w - kPad - 60.f, 10.f, 60.f, 26.f);
    self.dotView.frame      = CGRectMake(kPad, 46.f, 11.f, 11.f);
    self.dotView.layer.cornerRadius = 5.5f;
    self.stateLabel.frame   = CGRectMake(kPad + 20.f, 40.f, innerW - 20.f, 24.f);
    self.metaLabel.frame    = CGRectMake(kPad, 72.f, innerW, 44.f);

    CGFloat footY = 124.f;
    self.remainLabel.frame  = CGRectMake(kPad, footY, innerW * 0.5f, 22.f);
    self.clearButton.frame  = CGRectMake(w - kPad - 90.f, footY, 90.f, 22.f);
}

#pragma mark - 公开方法

+ (CGFloat)cardHeightForWidth:(CGFloat)width {
    return 124.f + 22.f + 14.f;
}

/**
 * 依据 validDate 计算有效性并渲染
 */
- (void)renderWithInfo:(TSEpoTimeInfo *)info {
    if (!info) {
        [self renderUnknown];
        return;
    }

    NSTimeInterval remain = info.validTimestamp - [[NSDate date] timeIntervalSince1970];
    NSInteger remainDays = (NSInteger)floor(remain / 86400.f);

    UIColor *color; NSString *stateText; NSString *remainText;
    if (remain <= 0) {
        color = TSColor_Danger;
        stateText = TSLocalizedString(@"epo.state.expired");
        remainText = [NSString stringWithFormat:TSLocalizedString(@"epo.remain.expired_fmt"), (long)(-remainDays)];
    } else if (remainDays <= kExpiringDays) {
        color = TSColor_Warning;
        stateText = TSLocalizedString(@"epo.state.expiring");
        remainText = [NSString stringWithFormat:TSLocalizedString(@"epo.remain.fmt"), (long)remainDays];
    } else {
        color = TSColor_Success;
        stateText = TSLocalizedString(@"epo.state.valid");
        remainText = [NSString stringWithFormat:TSLocalizedString(@"epo.remain.fmt"), (long)remainDays];
    }

    self.dotView.backgroundColor = color;
    self.stateLabel.text = stateText;
    self.remainLabel.text = remainText;
    self.metaLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@",
                           TSLocalizedString(@"epo.valid_until"), [self formatDate:info.validDate],
                           TSLocalizedString(@"epo.last_update"), [self formatDate:info.updateDate]];
    self.clearButton.enabled = YES;
}

/**
 * 未知态（无数据/查询失败/已清除）
 */
- (void)renderUnknown {
    self.dotView.backgroundColor = TSColor_TextSecondary;
    self.stateLabel.text = TSLocalizedString(@"epo.state.unknown");
    self.remainLabel.text = TSLocalizedString(@"epo.remain.none");
    self.metaLabel.text = [NSString stringWithFormat:@"%@ --\n%@ --",
                           TSLocalizedString(@"epo.valid_until"), TSLocalizedString(@"epo.last_update")];
}

#pragma mark - 私有方法

- (void)setupCardStyle {
    self.backgroundColor = TSColor_Card;
    self.layer.cornerRadius = 12.f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.05f;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 6.f;
}

- (void)onRefreshTapped {
    if (self.onRefresh) self.onRefresh();
}

- (void)onClearTapped {
    if (self.onClear) self.onClear();
}

- (NSString *)formatDate:(NSDate *)date {
    if (!date) return @"--";
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    });
    return [formatter stringFromDate:date];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = TSLocalizedString(@"epo.status_title");
        _titleLabel.font = TSFont_Body;
        _titleLabel.textColor = TSColor_TextSecondary;
    }
    return _titleLabel;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setTitle:TSLocalizedString(@"epo.refresh") forState:UIControlStateNormal];
        [_refreshButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _refreshButton.titleLabel.font = TSFont_Body;
        _refreshButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_refreshButton addTarget:self action:@selector(onRefreshTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = TSColor_TextSecondary;
    }
    return _dotView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont systemFontOfSize:20.f weight:UIFontWeightSemibold];
        _stateLabel.textColor = TSColor_TextPrimary;
    }
    return _stateLabel;
}

- (UILabel *)metaLabel {
    if (!_metaLabel) {
        _metaLabel = [[UILabel alloc] init];
        _metaLabel.font = TSFont_Body;
        _metaLabel.textColor = TSColor_TextSecondary;
        _metaLabel.numberOfLines = 2;
    }
    return _metaLabel;
}

- (UILabel *)remainLabel {
    if (!_remainLabel) {
        _remainLabel = [[UILabel alloc] init];
        _remainLabel.font = TSFont_Body;
        _remainLabel.textColor = TSColor_TextPrimary;
    }
    return _remainLabel;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setTitle:TSLocalizedString(@"epo.clear") forState:UIControlStateNormal];
        [_clearButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
        _clearButton.titleLabel.font = TSFont_Body;
        _clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_clearButton addTarget:self action:@selector(onClearTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

@end
