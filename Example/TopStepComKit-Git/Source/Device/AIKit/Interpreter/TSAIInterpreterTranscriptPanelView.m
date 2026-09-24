//
//  TSAIInterpreterTranscriptPanelView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterTranscriptPanelView.h"

#import "TSAIInterpreterUtteranceUI.h"
#import "TSRootVC.h"

/// 头部高度
static const CGFloat kPanelHeaderHeight = 36.0;
/// 表格顶部 / 底部内边距
static const CGFloat kPanelTableInsetTop = 6.0;
static const CGFloat kPanelTableInsetBottom = 14.0;
/// 「回到最新」胶囊尺寸与距底部距离
static const CGFloat kPanelJumpHeight = 28.0;
static const CGFloat kPanelJumpBottomGap = 10.0;
/// 判定「已在底部」的容差
static const CGFloat kPanelBottomTolerance = 24.0;
/// cell 复用标识
static NSString *const kPanelLineCellIdentifier = @"TSAIInterpreterLineCell";

@interface TSAIInterpreterTranscriptPanelView () <UITableViewDataSource, UITableViewDelegate>

/// 头部容器
@property (nonatomic, strong) UIView *headerView;
/// 头部色点（源 indigo / 目标 blue）
@property (nonatomic, strong) UIView *dotView;
/// 头部标题（原文 / 译文）
@property (nonatomic, strong) UILabel *titleLabel;
/// 头部语言名
@property (nonatomic, strong) UILabel *languageLabel;
/// 头部右侧文字（句数 / TTS 徽标）
@property (nonatomic, strong) UILabel *trailingLabel;
/// 放大 / 还原按钮
@property (nonatomic, strong) UIButton *expandButton;
/// 头部底部分割线
@property (nonatomic, strong) UIView *headerSeparator;
/// 字幕行表
@property (nonatomic, strong) UITableView *tableView;
/// 空态占位
@property (nonatomic, strong) UILabel *placeholderLabel;
/// 「回到最新」胶囊
@property (nonatomic, strong) UIButton *jumpButton;
/// 是否跟随最新行（用户上滑后为 NO）
@property (nonatomic, assign) BOOL followsLatest;
/// 「回到最新」胶囊当前的目标可见状态（避免动画中反复切换出错）
@property (nonatomic, assign) BOOL jumpVisible;

@end

@implementation TSAIInterpreterTranscriptPanelView

#pragma mark - 生命周期

- (instancetype)initWithRole:(TSAIInterpreterLineRole)role {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _role = role;
        _pairedIndex = NSNotFound;
        _followsLatest = YES;
        self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        self.layer.cornerRadius = 16.0;
        self.clipsToBounds = YES;

        [self addSubview:self.tableView];
        [self addSubview:self.placeholderLabel];
        [self addSubview:self.headerView];
        [self.headerView addSubview:self.dotView];
        [self.headerView addSubview:self.titleLabel];
        [self.headerView addSubview:self.languageLabel];
        [self.headerView addSubview:self.trailingLabel];
        [self.headerView addSubview:self.expandButton];
        [self.headerView addSubview:self.headerSeparator];
        [self addSubview:self.jumpButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    self.headerView.frame = CGRectMake(0, 0, width, kPanelHeaderHeight);
    [self layoutHeaderContents];

    CGFloat tableY = kPanelHeaderHeight;
    self.tableView.frame = CGRectMake(0, tableY, width, MAX(height - tableY, 0));
    self.placeholderLabel.frame = CGRectInset(self.tableView.frame, 24.0, 8.0);

    CGSize jumpSize = [self.jumpButton sizeThatFits:CGSizeMake(width, kPanelJumpHeight)];
    CGFloat jumpW = jumpSize.width + 24.0;
    self.jumpButton.frame = CGRectMake((width - jumpW) / 2.0,
                                       height - kPanelJumpBottomGap - kPanelJumpHeight,
                                       jumpW, kPanelJumpHeight);
    self.jumpButton.layer.cornerRadius = kPanelJumpHeight / 2.0;
}

#pragma mark - 公开方法

- (void)setTitle:(NSString *)title languageText:(NSString *)languageText {
    self.titleLabel.text = title;
    self.languageLabel.text = languageText;
    [self setNeedsLayout];
}

- (void)setTrailingText:(NSString *)text color:(UIColor *)color {
    self.trailingLabel.text = text;
    self.trailingLabel.textColor = color;
    self.trailingLabel.hidden = (text.length == 0);
    [self setNeedsLayout];
}

- (void)setPlaceholderText:(NSString *)text {
    self.placeholderLabel.text = text;
}

- (void)reloadData {
    [self.tableView reloadData];
    [self refreshPlaceholder];
    [self refreshJumpButtonVisibility];
    if (self.followsLatest) {
        [self scrollToLatestAnimated:NO];
    }
}

- (void)insertRowAtPosition:(NSUInteger)position {
    NSUInteger rows = (NSUInteger)[self.tableView numberOfRowsInSection:0];
    // 数据源必须恰好比表格多一项，否则退回整体刷新，避免 insertRows 断言
    if (position > rows || self.utterances.count != rows + 1) {
        [self reloadData];
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    [self refreshPlaceholder];
    if (self.followsLatest) {
        [self scrollToLatestAnimated:NO];
    }
    [self refreshJumpButtonVisibility];
}

- (void)reloadRowAtPosition:(NSUInteger)position {
    NSUInteger rows = (NSUInteger)[self.tableView numberOfRowsInSection:0];
    if (position >= rows || self.utterances.count != rows) {
        [self reloadData];
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    if (self.followsLatest) {
        [self scrollToLatestAnimated:NO];
    }
    [self refreshJumpButtonVisibility];
}

- (void)scrollToUtteranceIndex:(NSInteger)utteranceIndex {
    NSInteger position = [self positionForUtteranceIndex:utteranceIndex];
    if (position == NSNotFound) return;
    // 用户主动定位到某句后暂停跟随，避免下一条流式回调立刻把视图拉回底部
    BOOL isLast = (position == (NSInteger)self.utterances.count - 1);
    self.followsLatest = isLast;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0]
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:YES];
    [self refreshJumpButtonVisibility];
}

#pragma mark - 属性 setter

- (void)setUtterances:(NSArray<TSAIInterpreterUtteranceUI *> *)utterances {
    _utterances = utterances;
    [self reloadData];
}

- (void)setShowAudio:(BOOL)showAudio {
    if (_showAudio == showAudio) return;
    _showAudio = showAudio;
    // 行高会变化，需要整体刷新
    [self.tableView reloadData];
}

- (void)setHighlightsLatest:(BOOL)highlightsLatest {
    if (_highlightsLatest == highlightsLatest) return;
    _highlightsLatest = highlightsLatest;
    [self rebindVisibleCells];
}

- (void)setPairedIndex:(NSInteger)pairedIndex {
    if (_pairedIndex == pairedIndex) return;
    _pairedIndex = pairedIndex;
    [self rebindVisibleCells];
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    [self applyExpandGlyphToButton:self.expandButton expanded:expanded];
}

#pragma mark - 私有方法 - 布局

/// 头部：色点 · 标题 · 语言 ·········· 右侧文字 · 放大按钮
- (void)layoutHeaderContents {
    CGFloat width = CGRectGetWidth(self.headerView.bounds);
    CGFloat height = CGRectGetHeight(self.headerView.bounds);
    CGFloat buttonSize = 28.0;

    self.expandButton.frame = CGRectMake(width - 8.0 - buttonSize, (height - buttonSize) / 2.0,
                                         buttonSize, buttonSize);
    self.dotView.frame = CGRectMake(14.0, (height - 6.0) / 2.0, 6.0, 6.0);

    CGFloat x = CGRectGetMaxX(self.dotView.frame) + 6.0;
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(width, height)];
    self.titleLabel.frame = CGRectMake(x, 0, ceil(titleSize.width), height);
    x = CGRectGetMaxX(self.titleLabel.frame) + 6.0;

    CGFloat trailingMaxW = 140.0;
    CGSize trailingSize = self.trailingLabel.hidden
        ? CGSizeZero
        : [self.trailingLabel sizeThatFits:CGSizeMake(trailingMaxW, height)];
    CGFloat trailingW = MIN(ceil(trailingSize.width), trailingMaxW);
    CGFloat trailingX = CGRectGetMinX(self.expandButton.frame) - 4.0 - trailingW;
    self.trailingLabel.frame = CGRectMake(trailingX, 0, trailingW, height);

    CGFloat languageMaxW = trailingX - 8.0 - x;
    self.languageLabel.frame = CGRectMake(x, 0, MAX(languageMaxW, 0), height);

    self.headerSeparator.frame = CGRectMake(0, height - 0.5, width, 0.5);
}

#pragma mark - 私有方法 - 数据与状态

/// 根据 utterance index 找到数组位置，找不到返回 NSNotFound
- (NSInteger)positionForUtteranceIndex:(NSInteger)utteranceIndex {
    for (NSUInteger i = 0; i < self.utterances.count; i++) {
        if (self.utterances[i].index == utteranceIndex) return (NSInteger)i;
    }
    return NSNotFound;
}

/// 直接重绑可见 cell，避免 reload 造成闪烁（行高不变时使用）
- (void)rebindVisibleCells {
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        TSAIInterpreterLineCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell) [self bindCell:cell atRow:indexPath.row];
    }
}

/// 绑定第 row 行：最新句 = 数组末位且会话进行中；配对句 = pairedIndex 命中
- (void)bindCell:(TSAIInterpreterLineCell *)cell atRow:(NSInteger)row {
    if (row < 0 || row >= (NSInteger)self.utterances.count) return;
    TSAIInterpreterUtteranceUI *utterance = self.utterances[row];
    BOOL isLatest = self.highlightsLatest && (row == (NSInteger)self.utterances.count - 1);
    BOOL isPaired = (self.pairedIndex != NSNotFound) && (utterance.index == self.pairedIndex);
    [cell bindWithUtterance:utterance
                       role:self.role
                  showAudio:self.showAudio
                   isLatest:isLatest
                   isPaired:isPaired];
}

- (void)refreshPlaceholder {
    self.placeholderLabel.hidden = (self.utterances.count > 0);
}

/// 滚到最后一行（无行时忽略）
- (void)scrollToLatestAnimated:(BOOL)animated {
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    if (rows <= 0) return;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:animated];
}

/// 当前是否滚动到了底部（含容差）
- (BOOL)isScrolledToBottom {
    UITableView *table = self.tableView;
    CGFloat visibleBottom = table.contentOffset.y + CGRectGetHeight(table.bounds);
    CGFloat contentBottom = table.contentSize.height + table.contentInset.bottom;
    return visibleBottom >= contentBottom - kPanelBottomTolerance;
}

/// 内容超出一屏且不在底部时显示胶囊
- (void)refreshJumpButtonVisibility {
    UITableView *table = self.tableView;
    BOOL overflow = table.contentSize.height > CGRectGetHeight(table.bounds);
    BOOL shouldShow = overflow && !self.followsLatest;
    if (self.jumpVisible == shouldShow) return;
    self.jumpVisible = shouldShow;
    if (shouldShow) {
        self.jumpButton.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{ self.jumpButton.alpha = 1.0; }];
    } else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{ self.jumpButton.alpha = 0.0; }
                         completion:^(BOOL finished) {
            // 动画期间若又被要求显示，则保留
            if (!weakSelf.jumpVisible) weakSelf.jumpButton.hidden = YES;
        }];
    }
}

/// 用户主动滚动时更新跟随状态
- (void)updateFollowStateFromUserScroll {
    self.followsLatest = [self isScrolledToBottom];
    [self refreshJumpButtonVisibility];
}

/// 放大 / 还原按钮图标
- (void)applyExpandGlyphToButton:(UIButton *)button expanded:(BOOL)expanded {
    NSString *symbolName = expanded ? @"arrow.down.right.and.arrow.up.left"
                                    : @"arrow.up.left.and.arrow.down.right";
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:12.0
                                                                                      weight:UIImageSymbolWeightSemibold];
    [button setImage:[UIImage systemImageNamed:symbolName withConfiguration:cfg]
            forState:UIControlStateNormal];
}

#pragma mark - 私有方法 - 按钮事件

- (void)onJumpButtonTap {
    self.followsLatest = YES;
    [self scrollToLatestAnimated:YES];
    [self refreshJumpButtonVisibility];
}

- (void)onExpandButtonTap {
    if ([self.delegate respondsToSelector:@selector(transcriptPanelDidTapExpand:)]) {
        [self.delegate transcriptPanelDidTapExpand:self];
    }
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.utterances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSAIInterpreterLineCell *cell = [tableView dequeueReusableCellWithIdentifier:kPanelLineCellIdentifier];
    if (!cell) {
        cell = [[TSAIInterpreterLineCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:kPanelLineCellIdentifier];
    }
    [self bindCell:cell atRow:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= (NSInteger)self.utterances.count) return 0;
    return [TSAIInterpreterLineCell heightForUtterance:self.utterances[indexPath.row]
                                                  role:self.role
                                             showAudio:self.showAudio
                                             cellWidth:CGRectGetWidth(tableView.bounds)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= (NSInteger)self.utterances.count) return;
    if ([self.delegate respondsToSelector:@selector(transcriptPanel:didSelectUtteranceIndex:)]) {
        [self.delegate transcriptPanel:self didSelectUtteranceIndex:self.utterances[indexPath.row].index];
    }
}

#pragma mark - UIScrollViewDelegate

/// 只在用户手势驱动时更新跟随状态，程序滚动不算
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
        [self updateFollowStateFromUserScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [self updateFollowStateFromUserScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateFollowStateFromUserScroll];
}

#pragma mark - 属性（懒加载）

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    }
    return _headerView;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.layer.cornerRadius = 3.0;
        _dotView.backgroundColor = (self.role == TSAIInterpreterLineRoleTarget)
            ? [UIColor systemBlueColor] : [UIColor systemIndigoColor];
    }
    return _dotView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [UIColor labelColor];
    }
    return _titleLabel;
}

- (UILabel *)languageLabel {
    if (!_languageLabel) {
        _languageLabel = [[UILabel alloc] init];
        _languageLabel.font = [UIFont systemFontOfSize:12.0];
        _languageLabel.textColor = [UIColor tertiaryLabelColor];
        _languageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _languageLabel;
}

- (UILabel *)trailingLabel {
    if (!_trailingLabel) {
        _trailingLabel = [[UILabel alloc] init];
        _trailingLabel.font = (self.role == TSAIInterpreterLineRoleTarget)
            ? [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold]
            : [UIFont monospacedSystemFontOfSize:11.0 weight:UIFontWeightRegular];
        _trailingLabel.textColor = [UIColor tertiaryLabelColor];
        _trailingLabel.textAlignment = NSTextAlignmentRight;
        _trailingLabel.hidden = YES;
    }
    return _trailingLabel;
}

- (UIButton *)expandButton {
    if (!_expandButton) {
        _expandButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _expandButton.tintColor = [UIColor tertiaryLabelColor];
        _expandButton.layer.cornerRadius = 8.0;
        _expandButton.accessibilityLabel = TSLocalizedString(@"ai_interpreter.panel_expand");
        [_expandButton addTarget:self action:@selector(onExpandButtonTap)
                forControlEvents:UIControlEventTouchUpInside];
        [self applyExpandGlyphToButton:_expandButton expanded:_expanded];
    }
    return _expandButton;
}

- (UIView *)headerSeparator {
    if (!_headerSeparator) {
        _headerSeparator = [[UIView alloc] init];
        _headerSeparator.backgroundColor = [UIColor separatorColor];
    }
    return _headerSeparator;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(kPanelTableInsetTop, 0, kPanelTableInsetBottom, 0);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.allowsSelection = YES;
    }
    return _tableView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.numberOfLines = 0;
        _placeholderLabel.font = [UIFont systemFontOfSize:13.0];
        _placeholderLabel.textColor = [UIColor tertiaryLabelColor];
        _placeholderLabel.userInteractionEnabled = NO;
    }
    return _placeholderLabel;
}

- (UIButton *)jumpButton {
    if (!_jumpButton) {
        _jumpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _jumpButton.backgroundColor = [UIColor labelColor];
        _jumpButton.tintColor = [UIColor systemBackgroundColor];
        _jumpButton.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
        [_jumpButton setTitle:TSLocalizedString(@"ai_interpreter.panel_jump_latest")
                     forState:UIControlStateNormal];
        _jumpButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _jumpButton.layer.shadowOpacity = 0.18;
        _jumpButton.layer.shadowRadius = 8.0;
        _jumpButton.layer.shadowOffset = CGSizeMake(0, 4);
        _jumpButton.hidden = YES;
        [_jumpButton addTarget:self action:@selector(onJumpButtonTap)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _jumpButton;
}

@end
