//
//  TSAIInterpreterSessionStripView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterSessionStripView.h"

@interface TSAIInterpreterSessionStripView ()

/// 5 根电平柱容器
@property (nonatomic, strong) UIView *meterView;
/// 5 根电平柱
@property (nonatomic, strong) NSArray<UIView *> *meterBars;
/// 状态文字
@property (nonatomic, strong) UILabel *statusLabel;
/// taskId 短码标签
@property (nonatomic, strong) UILabel *taskIdLabel;

@end

@implementation TSAIInterpreterSessionStripView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        self.layer.cornerRadius = 12.0;
        [self addSubview:self.meterView];
        for (UIView *bar in self.meterBars) [self.meterView addSubview:bar];
        [self addSubview:self.statusLabel];
        [self addSubview:self.taskIdLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat innerW = CGRectGetWidth(self.bounds);
    CGFloat stripH = CGRectGetHeight(self.bounds);
    CGFloat meterW = 28.0, meterH = 16.0;
    self.meterView.frame = CGRectMake(10.0, (stripH - meterH) / 2.0, meterW, meterH);
    CGFloat barW = 3.0, gap = 3.0;
    for (NSUInteger i = 0; i < self.meterBars.count; i++) {
        self.meterBars[i].frame = CGRectMake((barW + gap) * i, meterH - 4.0, barW, 4.0);
        self.meterBars[i].layer.cornerRadius = barW / 2.0;
    }
    CGFloat statusX = CGRectGetMaxX(self.meterView.frame) + 8.0;
    CGFloat taskIdW = 130.0;
    self.statusLabel.frame = CGRectMake(statusX, 0, innerW - statusX - taskIdW - 12.0, stripH);
    self.taskIdLabel.frame = CGRectMake(innerW - taskIdW - 12.0, 0, taskIdW, stripH);
}

#pragma mark - 公开方法

- (void)setStatusText:(NSString *)text textColor:(UIColor *)color {
    self.statusLabel.text = text;
    if (color) self.statusLabel.textColor = color;
}

- (void)setTaskIdText:(NSString *)text {
    self.taskIdLabel.text = text ?: @"";
}

- (void)setActive:(BOOL)active {
    CGFloat meterH = MAX(CGRectGetHeight(self.meterView.bounds), 16.0);
    for (NSUInteger i = 0; i < self.meterBars.count; i++) {
        UIView *bar = self.meterBars[i];
        [bar.layer removeAnimationForKey:@"pulse"];
        bar.backgroundColor = active ? [UIColor systemGreenColor] : [UIColor systemGray4Color];
        if (!active) continue;
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        anim.fromValue = @(0.4);
        anim.toValue = @(meterH / 4.0);
        anim.duration = 0.55;
        anim.beginTime = CACurrentMediaTime() + i * 0.08;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [bar.layer addAnimation:anim forKey:@"pulse"];
    }
}

#pragma mark - 属性（懒加载）

- (UIView *)meterView {
    if (!_meterView) _meterView = [[UIView alloc] init];
    return _meterView;
}

- (NSArray<UIView *> *)meterBars {
    if (!_meterBars) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSUInteger i = 0; i < 5; i++) {
            UIView *bar = [[UIView alloc] init];
            bar.backgroundColor = [UIColor systemGray4Color];
            bar.layer.anchorPoint = CGPointMake(0.5, 1.0);
            [arr addObject:bar];
        }
        _meterBars = [arr copy];
    }
    return _meterBars;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
        _statusLabel.textColor = [UIColor secondaryLabelColor];
    }
    return _statusLabel;
}

- (UILabel *)taskIdLabel {
    if (!_taskIdLabel) {
        _taskIdLabel = [[UILabel alloc] init];
        _taskIdLabel.font = [UIFont monospacedSystemFontOfSize:11.0 weight:UIFontWeightRegular];
        _taskIdLabel.textColor = [UIColor tertiaryLabelColor];
        _taskIdLabel.textAlignment = NSTextAlignmentRight;
    }
    return _taskIdLabel;
}

@end
