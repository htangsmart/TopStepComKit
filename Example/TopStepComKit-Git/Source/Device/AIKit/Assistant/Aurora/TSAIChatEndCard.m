//
//  TSAIChatEndCard.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatEndCard.h"

#import "TSAIChatTheme.h"

@interface TSAIChatEndCard ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UILabel *roundsLabel;
@property (nonatomic, strong) UILabel *durationLabel;

@end

@implementation TSAIChatEndCard

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        TSAIChatApplyGlass(self, 20);
        TSAIChatApplyCardShadow(self.layer);

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"本次畅聊";
        _titleLabel.font = TSAIChatFont(14, UIFontWeightBold);
        _titleLabel.textColor = TSAIChatInkColor();
        [self addSubview:_titleLabel];

        _noteLabel = [[UILabel alloc] init];
        _noteLabel.text = @"记录不会保存";
        _noteLabel.font = TSAIChatFont(12, UIFontWeightRegular);
        _noteLabel.textColor = TSAIChatInk3Color();
        [self addSubview:_noteLabel];

        _roundsLabel = [[UILabel alloc] init];
        _roundsLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_roundsLabel];

        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold];
        _durationLabel.textColor = TSAIChatInk2Color();
        _durationLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_durationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.titleLabel.frame = CGRectMake(16, 14, width / 2, 18);
    self.noteLabel.frame = CGRectMake(16, 14 + 18 + 4, width / 2, 15);
    self.roundsLabel.frame = CGRectMake(width / 2, 12, width / 2 - 16, 22);
    self.durationLabel.frame = CGRectMake(width / 2, 12 + 22 + 3, width / 2 - 16, 15);
}

#pragma mark - 公开方法

+ (CGFloat)preferredHeight {
    return 14 + 18 + 4 + 15 + 14;
}

- (void)showWithRoundCount:(NSInteger)roundCount duration:(NSTimeInterval)duration {
    self.roundsLabel.attributedText = [[NSAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"%ld 轮", (long)roundCount]
            attributes:@{NSFontAttributeName: TSAIChatFont(18, UIFontWeightHeavy),
                         NSForegroundColorAttributeName: TSAIChatInkColor(),
                         NSKernAttributeName: @(-0.3)}];
    self.durationLabel.text = TSAIChatClockString(duration);
    self.hidden = NO;
    TSAIChatPopIn(self, 0.5, 0);
}

@end
