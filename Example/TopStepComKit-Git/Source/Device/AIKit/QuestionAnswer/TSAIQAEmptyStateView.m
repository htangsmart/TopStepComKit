//
//  TSAIQAEmptyStateView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQAEmptyStateView.h"

#import "TSAIQATheme.h"

static const CGFloat kTSAIQAEmptyOrbSize = 84.0;
static const CGFloat kTSAIQAEmptySuggestionHeight = 46.0;
static const CGFloat kTSAIQAEmptySuggestionGap = 8.0;
static const NSInteger kTSAIQAEmptyChevronTag = 1001;

@interface TSAIQAEmptyStateView ()

// 光球
@property (nonatomic, strong) UIView *orbView;
@property (nonatomic, strong) UILabel *orbGlyphLabel;
// 标题与副标题
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
// 推荐问题按钮
@property (nonatomic, strong) NSMutableArray<UIButton *> *suggestionButtons;

@end

@implementation TSAIQAEmptyStateView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _suggestionButtons = [NSMutableArray array];
        _suggestionsEnabled = YES;
        [self addSubview:self.orbView];
        [self.orbView addSubview:self.orbGlyphLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat y = 36.0;
    self.orbView.frame = CGRectMake((width - kTSAIQAEmptyOrbSize) / 2.0, y, kTSAIQAEmptyOrbSize, kTSAIQAEmptyOrbSize);
    self.orbGlyphLabel.frame = self.orbView.bounds;
    y += kTSAIQAEmptyOrbSize + 18.0;
    self.titleLabel.frame = CGRectMake(20.0, y, width - 40.0, 26.0);
    y += 30.0;
    self.subtitleLabel.frame = CGRectMake(40.0, y, width - 80.0, 40.0);
    y += 52.0;
    for (UIButton *button in self.suggestionButtons) {
        button.frame = CGRectMake(20.0, y, width - 40.0, kTSAIQAEmptySuggestionHeight);
        UIView *chevron = [button viewWithTag:kTSAIQAEmptyChevronTag];
        chevron.frame = CGRectMake(CGRectGetWidth(button.bounds) - 32.0, 0, 20.0, kTSAIQAEmptySuggestionHeight);
        y += kTSAIQAEmptySuggestionHeight + kTSAIQAEmptySuggestionGap;
    }
}

#pragma mark - 公开方法

+ (CGFloat)heightForWidth:(CGFloat)width suggestionCount:(NSUInteger)count {
    (void)width;
    return 36.0 + kTSAIQAEmptyOrbSize + 18.0 + 30.0 + 52.0 +
           count * (kTSAIQAEmptySuggestionHeight + kTSAIQAEmptySuggestionGap) + 12.0;
}

- (void)setSuggestions:(NSArray<NSString *> *)suggestions {
    _suggestions = [suggestions copy];
    for (UIButton *button in self.suggestionButtons) {
        [button removeFromSuperview];
    }
    [self.suggestionButtons removeAllObjects];
    [suggestions enumerateObjectsUsingBlock:^(NSString *question, NSUInteger idx, BOOL *stop) {
        UIButton *button = [self makeSuggestionButtonWithTitle:question];
        button.tag = (NSInteger)idx;
        [self addSubview:button];
        [self.suggestionButtons addObject:button];
    }];
    [self setSuggestionsEnabled:self.suggestionsEnabled];
    [self setNeedsLayout];
}

- (void)setSuggestionsEnabled:(BOOL)suggestionsEnabled {
    _suggestionsEnabled = suggestionsEnabled;
    for (UIButton *button in self.suggestionButtons) {
        button.enabled = suggestionsEnabled;
        button.alpha = suggestionsEnabled ? 1.0 : 0.5;
    }
}

#pragma mark - 私有方法

/** 创建一条推荐问题按钮 */
- (UIButton *)makeSuggestionButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 14.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = TSAIQALineColor().CGColor;
    TSAIQAApplyCardShadow(button.layer);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // iOS 15 起建议改用 UIButtonConfiguration，此处保留旧属性以兼容自定义字体与标题设置
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 14.0, 0, 36.0);
#pragma clang diagnostic pop
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [button setTitleColor:TSAIQATextPrimaryColor() forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"✦  %@", title] forState:UIControlStateNormal];

    UILabel *chevron = [[UILabel alloc] init];
    chevron.text = @"›";
    chevron.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
    chevron.textColor = TSAIQATextTertiaryColor();
    chevron.textAlignment = NSTextAlignmentCenter;
    chevron.tag = kTSAIQAEmptyChevronTag;
    [button addSubview:chevron];

    [button addTarget:self action:@selector(onSuggestionTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - 事件

/** 点击推荐问题 */
- (void)onSuggestionTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index < 0 || index >= (NSInteger)self.suggestions.count) {
        return;
    }
    [self.delegate emptyStateView:self didSelectSuggestion:self.suggestions[(NSUInteger)index]];
}

#pragma mark - 属性（懒加载）

- (UIView *)orbView {
    if (!_orbView) {
        _orbView = [[UIView alloc] init];
        _orbView.backgroundColor = [UIColor colorWithRed:1.0 green:0xF0 / 255.0 blue:0xF6 / 255.0 alpha:1.0];
        _orbView.layer.cornerRadius = kTSAIQAEmptyOrbSize / 2.0;
        _orbView.layer.borderWidth = 1.0;
        _orbView.layer.borderColor = [TSAIQATintColor() colorWithAlphaComponent:0.15].CGColor;
        _orbView.layer.shadowColor = TSAIQATintColor().CGColor;
        _orbView.layer.shadowOpacity = 0.18;
        _orbView.layer.shadowRadius = 15.0;
        _orbView.layer.shadowOffset = CGSizeMake(0, 12.0);
    }
    return _orbView;
}

- (UILabel *)orbGlyphLabel {
    if (!_orbGlyphLabel) {
        _orbGlyphLabel = [[UILabel alloc] init];
        _orbGlyphLabel.text = @"?";
        _orbGlyphLabel.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightBold];
        _orbGlyphLabel.textColor = TSAIQATintColor();
        _orbGlyphLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _orbGlyphLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"问一个问题";
        _titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
        _titleLabel.textColor = TSAIQATextPrimaryColor();
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.text = @"单轮文本问答，答案流式返回。\n不依赖 Voice Chat 会话，也不占用音频路由。";
        _subtitleLabel.font = [UIFont systemFontOfSize:12.5];
        _subtitleLabel.textColor = TSAIQATextSecondaryColor();
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.numberOfLines = 2;
    }
    return _subtitleLabel;
}

@end
