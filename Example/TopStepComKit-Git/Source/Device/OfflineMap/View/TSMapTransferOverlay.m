//
//  TSMapTransferOverlay.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMapTransferOverlay.h"

#import "TSRootVC.h"

/// 进度环尺寸
static const CGFloat kTSRingSize = 96.f;
/// 进度环线宽
static const CGFloat kTSRingWidth = 6.f;

@interface TSMapTransferOverlay ()

// 卡片容器
@property (nonatomic, strong) UIView *card;
// 标题
@property (nonatomic, strong) UILabel *titleLabel;
// 百分比
@property (nonatomic, strong) UILabel *percentLabel;
// 提示
@property (nonatomic, strong) UILabel *hintLabel;
// 进度环背景层
@property (nonatomic, strong) CAShapeLayer *ringBg;
// 进度环前景层
@property (nonatomic, strong) CAShapeLayer *ringFg;

@end

@implementation TSMapTransferOverlay

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ts_buildUI];
    }
    return self;
}

#pragma mark - 公开方法

/// 展示覆盖层
- (void)showInView:(UIView *)view title:(NSString *)title hint:(NSString *)hint {
    self.frame = view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:self];

    self.titleLabel.text = title;
    self.hintLabel.text = hint;
    [self updateProgress:0];

    self.alpha = 0.f;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.f;
    }];
}

/// 更新进度
- (void)updateProgress:(NSInteger)progress {
    NSInteger clamped = MIN(100, MAX(0, progress));
    self.ringFg.strokeEnd = clamped / 100.f;
    self.percentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)clamped];
}

/// 更新标题与提示
- (void)updateTitle:(NSString *)title hint:(NSString *)hint {
    self.titleLabel.text = title;
    self.hintLabel.text = hint;
}

/// 关闭
- (void)dismiss {
    [UIView animateWithDuration:0.18 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 私有方法

/// 构建 UI
- (void)ts_buildUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];

    self.card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240.f, 200.f)];
    self.card.backgroundColor = TSColor_Card;
    self.card.layer.cornerRadius = 14.f;
    [self addSubview:self.card];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.f, 20.f, 240.f - 32.f, 22.f)];
    self.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    self.titleLabel.textColor = TSColor_TextPrimary;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.card addSubview:self.titleLabel];

    // 进度环
    CGFloat ringX = (240.f - kTSRingSize) / 2.f;
    CGFloat ringY = 56.f;
    UIView *ringContainer = [[UIView alloc] initWithFrame:CGRectMake(ringX, ringY, kTSRingSize, kTSRingSize)];
    [self.card addSubview:ringContainer];

    CGFloat radius = (kTSRingSize - kTSRingWidth) / 2.f;
    CGPoint center = CGPointMake(kTSRingSize / 2.f, kTSRingSize / 2.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:-M_PI_2
                                                      endAngle:(3 * M_PI_2)
                                                     clockwise:YES];

    self.ringBg = [CAShapeLayer layer];
    self.ringBg.path = path.CGPath;
    self.ringBg.fillColor = [UIColor clearColor].CGColor;
    self.ringBg.strokeColor = TSColor_Separator.CGColor;
    self.ringBg.lineWidth = kTSRingWidth;
    [ringContainer.layer addSublayer:self.ringBg];

    self.ringFg = [CAShapeLayer layer];
    self.ringFg.path = path.CGPath;
    self.ringFg.fillColor = [UIColor clearColor].CGColor;
    self.ringFg.strokeColor = TSColor_Primary.CGColor;
    self.ringFg.lineWidth = kTSRingWidth;
    self.ringFg.lineCap = kCALineCapRound;
    self.ringFg.strokeEnd = 0.f;
    [ringContainer.layer addSublayer:self.ringFg];

    self.percentLabel = [[UILabel alloc] initWithFrame:ringContainer.bounds];
    self.percentLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightSemibold];
    self.percentLabel.textColor = TSColor_TextPrimary;
    self.percentLabel.textAlignment = NSTextAlignmentCenter;
    self.percentLabel.text = @"0%";
    [ringContainer addSubview:self.percentLabel];

    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.f, ringY + kTSRingSize + 12.f, 240.f - 32.f, 16.f)];
    self.hintLabel.font = [UIFont systemFontOfSize:11.f];
    self.hintLabel.textColor = TSColor_TextSecondary;
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.numberOfLines = 0;
    [self.card addSubview:self.hintLabel];

    self.card.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    self.card.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
}

@end
