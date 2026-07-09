//
//  TSAITTSSpeakerSelector.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAITTSSpeakerSelector.h"

#import "TSRootVC.h"

#pragma mark - Entry

@implementation TSAITTSSpeakerEntry

+ (instancetype)entryWithId:(NSString *)speakerId displayName:(NSString *)displayName {
    TSAITTSSpeakerEntry *entry = [[self alloc] init];
    entry.speakerId = [speakerId copy];
    entry.displayName = [displayName copy];
    return entry;
}

@end

#pragma mark - Selector

@interface TSAITTSSpeakerSelector ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *customButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *chips;
@property (nonatomic, strong) NSArray<TSAITTSSpeakerEntry *> *entries;
@property (nonatomic, copy, nullable, readwrite) NSString *selectedSpeakerId;

@end

@implementation TSAITTSSpeakerSelector

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TSColor_Card;
        self.layer.cornerRadius = TSRadius_MD;
        self.chipsEnabled = YES;
        self.chips = [NSMutableArray array];
        [self addSubview:self.titleLabel];
        [self addSubview:self.customButton];
        [self addSubview:self.scrollView];
    }
    return self;
}

#pragma mark - 公开方法

- (void)setSpeakerEntries:(NSArray<TSAITTSSpeakerEntry *> *)entries {
    _entries = [entries copy];
    [self rebuildChips];
}

- (void)setSelectedSpeakerId:(nullable NSString *)speakerId {
    _selectedSpeakerId = [speakerId copy];
    [self refreshChipStyles];
}

- (void)setChipsEnabled:(BOOL)chipsEnabled {
    _chipsEnabled = chipsEnabled;
    [self refreshChipStyles];
    self.customButton.enabled = chipsEnabled;
    self.customButton.alpha = chipsEnabled ? 1.f : 0.4f;
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat pad = TSSpacing_SM;
    CGFloat headerH = 22.f;
    CGFloat customW = 80.f;

    self.titleLabel.frame = CGRectMake(pad, pad, width - pad * 2 - customW, headerH);
    self.customButton.frame = CGRectMake(width - pad - customW, pad, customW, headerH);

    CGFloat scrollY = pad + headerH + TSSpacing_XS;
    self.scrollView.frame = CGRectMake(pad, scrollY, width - pad * 2, height - scrollY - pad);
    [self layoutChips];
}

/// 重新计算 chip 横向布局
- (void)layoutChips {
    CGFloat x = 0.f;
    CGFloat gap = 6.f;
    CGFloat scrollH = CGRectGetHeight(self.scrollView.bounds);
    if (scrollH <= 0) scrollH = 28.f;
    CGFloat chipH = 28.f;
    for (UIButton *chip in self.chips) {
        [chip sizeToFit];
        CGFloat w = CGRectGetWidth(chip.bounds);
        chip.frame = CGRectMake(x, (scrollH - chipH) / 2.f, w, chipH);
        x += w + gap;
    }
    self.scrollView.contentSize = CGSizeMake(MAX(x, CGRectGetWidth(self.scrollView.bounds)), scrollH);
}

#pragma mark - 私有方法

/// 销毁旧 chip 并按 entries 重建
- (void)rebuildChips {
    for (UIButton *chip in self.chips) {
        [chip removeFromSuperview];
    }
    [self.chips removeAllObjects];

    for (TSAITTSSpeakerEntry *entry in self.entries) {
        UIButton *chip = [UIButton buttonWithType:UIButtonTypeCustom];
        [chip setTitle:entry.displayName forState:UIControlStateNormal];
        chip.titleLabel.font = TSFont_Caption;
        chip.contentEdgeInsets = UIEdgeInsetsMake(4.f, 12.f, 4.f, 12.f);
        chip.layer.cornerRadius = 14.f;
        chip.layer.borderWidth = 1.f;
        chip.accessibilityIdentifier = entry.speakerId;
        [chip addTarget:self action:@selector(onChipTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:chip];
        [self.chips addObject:chip];
    }
    [self refreshChipStyles];
    [self setNeedsLayout];
}

/// 刷新所有 chip 选中态视觉
- (void)refreshChipStyles {
    for (UIButton *chip in self.chips) {
        BOOL active = (self.selectedSpeakerId.length > 0
                       && [chip.accessibilityIdentifier isEqualToString:self.selectedSpeakerId]);
        if (active) {
            chip.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.12f];
            [chip setTitleColor:TSColor_Primary forState:UIControlStateNormal];
            chip.layer.borderColor = [TSColor_Primary colorWithAlphaComponent:0.4f].CGColor;
        } else {
            chip.backgroundColor = TSColor_Background;
            [chip setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
            chip.layer.borderColor = [UIColor clearColor].CGColor;
        }
        chip.enabled = self.chipsEnabled;
        chip.alpha = self.chipsEnabled ? 1.f : 0.4f;
    }
}

#pragma mark - 事件

/// chip 点击 = 通知 delegate；选中态由 delegate 写回
- (void)onChipTapped:(UIButton *)chip {
    NSString *speakerId = chip.accessibilityIdentifier;
    if (speakerId.length == 0) return;
    if ([speakerId isEqualToString:self.selectedSpeakerId]) return;
    [self.delegate speakerSelector:self didSelectSpeakerId:speakerId];
}

/// 「自定义…」按钮 = 通知 delegate 弹 alert
- (void)onCustomTapped {
    [self.delegate speakerSelectorDidRequestCustomSpeaker:self];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TSFont_H2;
        _titleLabel.textColor = TSColor_TextPrimary;
        _titleLabel.text = TSLocalizedString(@"ai_tts.speaker_section");
    }
    return _titleLabel;
}

- (UIButton *)customButton {
    if (!_customButton) {
        _customButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_customButton setTitle:TSLocalizedString(@"ai_tts.custom_speaker") forState:UIControlStateNormal];
        _customButton.titleLabel.font = TSFont_Caption;
        [_customButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _customButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_customButton addTarget:self action:@selector(onCustomTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customButton;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = YES;
    }
    return _scrollView;
}

@end
