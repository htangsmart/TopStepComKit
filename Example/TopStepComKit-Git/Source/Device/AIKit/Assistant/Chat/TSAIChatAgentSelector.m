//
//  TSAIChatAgentSelector.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/28.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatAgentSelector.h"

#import "TSRootVC.h"

#pragma mark - Entry

@implementation TSAIChatAgentEntry

+ (instancetype)entryWithAgentId:(NSString *)agentId
                       speakerId:(NSString *)speakerId
                     displayName:(NSString *)displayName {
    TSAIChatAgentEntry *entry = [[self alloc] init];
    entry.agentId     = [agentId copy];
    entry.speakerId   = [speakerId copy];
    entry.displayName = [displayName copy];
    return entry;
}

@end

#pragma mark - Selector

@interface TSAIChatAgentSelector ()

@property (nonatomic, strong) UILabel      *titleLabel;
@property (nonatomic, strong) UIButton     *customButton;
@property (nonatomic, strong) UIScrollView *chipScrollView;
@property (nonatomic, strong) UILabel      *idLabel;

@property (nonatomic, strong) NSMutableArray<UIButton *>           *chips;
@property (nonatomic, strong) NSMutableArray<TSAIChatAgentEntry *> *mutableEntries;
@property (nonatomic, strong, nullable, readwrite) TSAIChatAgentEntry *selectedEntry;

@end

@implementation TSAIChatAgentSelector

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TSColor_Card;
        self.layer.cornerRadius = TSRadius_MD;
        self.chips   = [NSMutableArray array];
        self.mutableEntries = [NSMutableArray array];
        [self addSubview:self.titleLabel];
        [self addSubview:self.customButton];
        [self addSubview:self.chipScrollView];
        [self addSubview:self.idLabel];
        [self setupLayoutConstraints];
    }
    return self;
}

#pragma mark - 布局约束

- (void)setupLayoutConstraints {
    self.titleLabel.translatesAutoresizingMaskIntoConstraints     = NO;
    self.customButton.translatesAutoresizingMaskIntoConstraints   = NO;
    self.chipScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.idLabel.translatesAutoresizingMaskIntoConstraints        = NO;

    CGFloat pad = TSSpacing_MD;

    [NSLayoutConstraint activateConstraints:@[
        // 标题（左上）
        [self.titleLabel.topAnchor      constraintEqualToAnchor:self.topAnchor      constant:pad],
        [self.titleLabel.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant:pad],
        [self.titleLabel.heightAnchor   constraintEqualToConstant:22.f],

        // 自定义按钮（右上）
        [self.customButton.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
        [self.customButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-pad],
        [self.customButton.widthAnchor    constraintEqualToConstant:80.f],
        [self.customButton.heightAnchor   constraintEqualToConstant:22.f],
        [self.titleLabel.trailingAnchor   constraintLessThanOrEqualToAnchor:self.customButton.leadingAnchor constant:-TSSpacing_SM],

        // chip 滚动区
        [self.chipScrollView.topAnchor      constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:TSSpacing_XS],
        [self.chipScrollView.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant:pad],
        [self.chipScrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-pad],
        [self.chipScrollView.heightAnchor   constraintEqualToConstant:36.f],

        // ID 副标题（底部）
        [self.idLabel.topAnchor      constraintEqualToAnchor:self.chipScrollView.bottomAnchor constant:2.f],
        [self.idLabel.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant:pad],
        [self.idLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-pad],
        [self.idLabel.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor   constant:-pad],
    ]];
}

#pragma mark - 公开方法

- (void)setEntries:(NSArray<TSAIChatAgentEntry *> *)entries {
    [self.mutableEntries removeAllObjects];
    if (entries.count > 0) {
        [self.mutableEntries addObjectsFromArray:entries];
    }
    [self rebuildChips];
}

- (void)setSelectedEntry:(nullable TSAIChatAgentEntry *)entry {
    _selectedEntry = entry;
    [self refreshChipStyles];
    [self refreshIdLabel];
}

- (void)appendCustomEntry:(TSAIChatAgentEntry *)entry {
    if (!entry) return;
    [self.mutableEntries addObject:entry];
    [self rebuildChips];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutChips];
}

/// chip 横向 frame 布局（外层用 AutoLayout，内部 chip 仍用 frame 拼接）
- (void)layoutChips {
    CGFloat x = 0.f;
    CGFloat gap = 6.f;
    CGFloat scrollH = CGRectGetHeight(self.chipScrollView.bounds);
    if (scrollH <= 0) scrollH = 36.f;
    CGFloat chipH = 28.f;
    for (UIButton *chip in self.chips) {
        CGSize fit = chip.intrinsicContentSize;
        CGFloat w = MAX(fit.width, 60.f);
        chip.frame = CGRectMake(x, (scrollH - chipH) / 2.f, w, chipH);
        x += w + gap;
    }
    self.chipScrollView.contentSize = CGSizeMake(MAX(x, CGRectGetWidth(self.chipScrollView.bounds)), scrollH);
}

#pragma mark - 私有方法

/// 销毁旧 chip 并按 entries 重建
- (void)rebuildChips {
    for (UIButton *chip in self.chips) {
        [chip removeFromSuperview];
    }
    [self.chips removeAllObjects];

    for (TSAIChatAgentEntry *entry in self.mutableEntries) {
        UIButton *chip = [UIButton buttonWithType:UIButtonTypeCustom];
        [chip setTitle:entry.displayName forState:UIControlStateNormal];
        chip.titleLabel.font = TSFont_Caption;
        chip.contentEdgeInsets = UIEdgeInsetsMake(4.f, 12.f, 4.f, 12.f);
        chip.layer.cornerRadius = 14.f;
        chip.layer.borderWidth = 1.f;
        chip.tag = [self.mutableEntries indexOfObject:entry];
        [chip addTarget:self
                 action:@selector(onChipTapped:)
       forControlEvents:UIControlEventTouchUpInside];
        [self.chipScrollView addSubview:chip];
        [self.chips addObject:chip];
    }
    [self refreshChipStyles];
    [self refreshIdLabel];
    [self setNeedsLayout];
}

/// 刷新 chip 选中态视觉
- (void)refreshChipStyles {
    for (UIButton *chip in self.chips) {
        NSInteger index = chip.tag;
        BOOL active = NO;
        if (self.selectedEntry && index >= 0 && index < (NSInteger)self.mutableEntries.count) {
            TSAIChatAgentEntry *entry = self.mutableEntries[index];
            active = ([entry.agentId isEqualToString:self.selectedEntry.agentId]
                      && [entry.speakerId isEqualToString:self.selectedEntry.speakerId]);
        }
        if (active) {
            chip.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.12f];
            [chip setTitleColor:TSColor_Primary forState:UIControlStateNormal];
            chip.layer.borderColor = [TSColor_Primary colorWithAlphaComponent:0.4f].CGColor;
        } else {
            chip.backgroundColor = TSColor_Background;
            [chip setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
            chip.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
}

/// 刷新底部 ID 副标题
- (void)refreshIdLabel {
    if (!self.selectedEntry) {
        self.idLabel.text = @"—";
    } else {
        NSString *speaker = self.selectedEntry.speakerId.length > 0
            ? self.selectedEntry.speakerId
            : @"(empty)";
        self.idLabel.text = [NSString stringWithFormat:@"%@ · %@",
                             self.selectedEntry.agentId, speaker];
    }
    [self setNeedsLayout];
}

#pragma mark - 事件

- (void)onChipTapped:(UIButton *)chip {
    NSInteger index = chip.tag;
    if (index < 0 || index >= (NSInteger)self.mutableEntries.count) return;
    TSAIChatAgentEntry *entry = self.mutableEntries[index];
    [self.delegate agentSelector:self didSelectEntry:entry];
}

- (void)onCustomTapped {
    [self.delegate agentSelectorDidRequestCustomEntry:self];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TSFont_H2;
        _titleLabel.textColor = TSColor_TextPrimary;
        _titleLabel.text = @"Agent";
    }
    return _titleLabel;
}

- (UIButton *)customButton {
    if (!_customButton) {
        _customButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_customButton setTitle:@"+ 自定义" forState:UIControlStateNormal];
        _customButton.titleLabel.font = TSFont_Caption;
        [_customButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _customButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_customButton addTarget:self
                          action:@selector(onCustomTapped)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _customButton;
}

- (UIScrollView *)chipScrollView {
    if (!_chipScrollView) {
        _chipScrollView = [[UIScrollView alloc] init];
        _chipScrollView.showsHorizontalScrollIndicator = NO;
        _chipScrollView.showsVerticalScrollIndicator = NO;
        _chipScrollView.alwaysBounceHorizontal = YES;
    }
    return _chipScrollView;
}

- (UILabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.font = [UIFont fontWithName:@"Menlo" size:11.f] ?: TSFont_Caption;
        _idLabel.textColor = TSColor_TextSecondary;
        _idLabel.numberOfLines = 0;
        _idLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _idLabel.text = @"—";
    }
    return _idLabel;
}

@end
