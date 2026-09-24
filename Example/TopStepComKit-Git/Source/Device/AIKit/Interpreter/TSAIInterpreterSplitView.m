//
//  TSAIInterpreterSplitView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterSplitView.h"

#import "TSAIInterpreterTranscriptPanelView.h"
#import "TSAIInterpreterUtteranceUI.h"
#import "TSRootVC.h"

/// 分隔条可见高度与手势热区高度
static const CGFloat kSplitDividerHeight = 18.0;
static const CGFloat kSplitDividerHitHeight = 28.0;
/// 分隔条握把尺寸（常态 / 拖动中）
static const CGFloat kSplitGripWidth = 44.0;
static const CGFloat kSplitGripWidthActive = 60.0;
static const CGFloat kSplitGripHeight = 5.0;
/// 源面板占比：默认 / 最小 / 最大 / 放大
static const CGFloat kSplitRatioDefault = 0.48;
static const CGFloat kSplitRatioMin = 0.25;
static const CGFloat kSplitRatioMax = 0.75;
static const CGFloat kSplitRatioExpanded = 0.78;
/// 比例持久化 key
static NSString *const kSplitRatioDefaultsKey = @"TSAIInterpreterSplitRatio";
/// 比例切换动画时长
static const NSTimeInterval kSplitAnimationDuration = 0.25;

@interface TSAIInterpreterSplitView () <TSAIInterpreterTranscriptPanelViewDelegate>

/// 上方源面板
@property (nonatomic, strong) TSAIInterpreterTranscriptPanelView *sourcePanel;
/// 下方目标面板
@property (nonatomic, strong) TSAIInterpreterTranscriptPanelView *targetPanel;
/// 分隔条容器（仅承载握把）
@property (nonatomic, strong) UIView *dividerView;
/// 分隔条握把
@property (nonatomic, strong) UIView *gripView;
/// 分隔条手势热区（比可见高度更高，便于拖动）
@property (nonatomic, strong) UIView *dividerHitView;
/// 源面板占比（0~1）
@property (nonatomic, assign) CGFloat ratio;
/// 拖动开始时的占比
@property (nonatomic, assign) CGFloat panStartRatio;
/// 当前放大的面板（nil 表示无）
@property (nonatomic, weak, nullable) TSAIInterpreterTranscriptPanelView *expandedPanel;
/// 放大前的占比，用于还原
@property (nonatomic, assign) CGFloat ratioBeforeExpand;

@end

@implementation TSAIInterpreterSplitView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _ratio = [self loadPersistedRatio];
        _ratioBeforeExpand = _ratio;
        [self addSubview:self.sourcePanel];
        [self addSubview:self.targetPanel];
        [self addSubview:self.dividerView];
        [self.dividerView addSubview:self.gripView];
        [self addSubview:self.dividerHitView];
        [self setupPanelTexts];
        [self setupDividerGestures];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat available = MAX(height - kSplitDividerHeight, 0);
    CGFloat sourceHeight = round(available * self.ratio);

    self.sourcePanel.frame = CGRectMake(0, 0, width, sourceHeight);
    self.dividerView.frame = CGRectMake(0, sourceHeight, width, kSplitDividerHeight);
    self.targetPanel.frame = CGRectMake(0, sourceHeight + kSplitDividerHeight,
                                        width, MAX(height - sourceHeight - kSplitDividerHeight, 0));

    CGFloat gripW = CGRectGetWidth(self.gripView.bounds) > 0 ? CGRectGetWidth(self.gripView.bounds) : kSplitGripWidth;
    self.gripView.frame = CGRectMake((width - gripW) / 2.0, (kSplitDividerHeight - kSplitGripHeight) / 2.0,
                                     gripW, kSplitGripHeight);
    self.dividerHitView.frame = CGRectMake(0, CGRectGetMidY(self.dividerView.frame) - kSplitDividerHitHeight / 2.0,
                                           width, kSplitDividerHitHeight);
}

#pragma mark - 公开方法

- (void)setSourceLanguageText:(NSString *)text {
    [self.sourcePanel setTitle:TSLocalizedString(@"ai_interpreter.panel_source_title") languageText:text];
}

- (void)setTargetLanguageText:(NSString *)text {
    [self.targetPanel setTitle:TSLocalizedString(@"ai_interpreter.panel_target_title") languageText:text];
}

- (void)setTargetBadgeText:(NSString *)text {
    [self.targetPanel setTrailingText:text color:[UIColor systemGreenColor]];
}

- (void)reloadAllData {
    [self setPairedIndexOnBothPanels:NSNotFound];
    [self.sourcePanel reloadData];
    [self.targetPanel reloadData];
    [self refreshSourceCount];
}

- (void)insertUtteranceAtPosition:(NSUInteger)position {
    [self.sourcePanel insertRowAtPosition:position];
    [self.targetPanel insertRowAtPosition:position];
    [self refreshSourceCount];
}

- (void)reloadUtteranceAtPosition:(NSUInteger)position {
    [self.sourcePanel reloadRowAtPosition:position];
    [self.targetPanel reloadRowAtPosition:position];
}

#pragma mark - 属性 setter

- (void)setUtterances:(NSArray<TSAIInterpreterUtteranceUI *> *)utterances {
    _utterances = utterances;
    self.sourcePanel.utterances = utterances;
    self.targetPanel.utterances = utterances;
    [self refreshSourceCount];
}

- (void)setShowAudio:(BOOL)showAudio {
    _showAudio = showAudio;
    self.targetPanel.showAudio = showAudio;
}

- (void)setHighlightsLatest:(BOOL)highlightsLatest {
    _highlightsLatest = highlightsLatest;
    self.sourcePanel.highlightsLatest = highlightsLatest;
    self.targetPanel.highlightsLatest = highlightsLatest;
}

#pragma mark - 私有方法 - 搭建

- (void)setupPanelTexts {
    [self setSourceLanguageText:nil];
    [self setTargetLanguageText:nil];
    [self.sourcePanel setPlaceholderText:TSLocalizedString(@"ai_interpreter.panel_source_empty")];
    [self.targetPanel setPlaceholderText:TSLocalizedString(@"ai_interpreter.panel_target_empty")];
}

- (void)setupDividerGestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onDividerPan:)];
    pan.maximumNumberOfTouches = 1;
    [self.dividerHitView addGestureRecognizer:pan];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(onDividerDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.dividerHitView addGestureRecognizer:doubleTap];
}

#pragma mark - 私有方法 - 比例

/// 读取持久化的占比，非法或缺省时用默认值
- (CGFloat)loadPersistedRatio {
    NSNumber *stored = [[NSUserDefaults standardUserDefaults] objectForKey:kSplitRatioDefaultsKey];
    if (![stored isKindOfClass:[NSNumber class]]) return kSplitRatioDefault;
    CGFloat value = stored.doubleValue;
    if (value < kSplitRatioMin || value > kSplitRatioMax) return kSplitRatioDefault;
    return value;
}

- (void)persistRatio {
    [[NSUserDefaults standardUserDefaults] setDouble:self.ratio forKey:kSplitRatioDefaultsKey];
}

/// 限制在 [min, max]
- (CGFloat)clampedRatio:(CGFloat)ratio {
    return MIN(kSplitRatioMax, MAX(kSplitRatioMin, ratio));
}

/// 切换占比并布局；animated 时带动画
- (void)applyRatio:(CGFloat)ratio animated:(BOOL)animated {
    self.ratio = ratio;
    [self setNeedsLayout];
    if (!animated) {
        [self layoutIfNeeded];
        return;
    }
    [UIView animateWithDuration:kSplitAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self layoutIfNeeded]; }
                     completion:nil];
}

/// 拖动中的握把样式（变蓝、变宽）
- (void)setGripActive:(BOOL)active {
    CGFloat gripW = active ? kSplitGripWidthActive : kSplitGripWidth;
    CGFloat width = CGRectGetWidth(self.dividerView.bounds);
    [UIView animateWithDuration:0.15 animations:^{
        self.gripView.backgroundColor = active ? [UIColor systemBlueColor] : [UIColor systemFillColor];
        self.gripView.frame = CGRectMake((width - gripW) / 2.0, (kSplitDividerHeight - kSplitGripHeight) / 2.0,
                                         gripW, kSplitGripHeight);
    }];
}

/// 清除放大状态（不改比例）
- (void)clearExpandedState {
    self.expandedPanel.expanded = NO;
    self.expandedPanel = nil;
}

- (void)refreshSourceCount {
    NSUInteger count = self.utterances.count;
    NSString *text = count > 0
        ? [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.panel_count_fmt"), (unsigned long)count]
        : nil;
    [self.sourcePanel setTrailingText:text color:[UIColor tertiaryLabelColor]];
}

- (void)setPairedIndexOnBothPanels:(NSInteger)index {
    self.sourcePanel.pairedIndex = index;
    self.targetPanel.pairedIndex = index;
}

#pragma mark - 私有方法 - 手势

- (void)onDividerPan:(UIPanGestureRecognizer *)pan {
    CGFloat available = MAX(CGRectGetHeight(self.bounds) - kSplitDividerHeight, 1.0);
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartRatio = self.ratio;
            [self clearExpandedState];
            [self setGripActive:YES];
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat delta = [pan translationInView:self].y / available;
            [self applyRatio:[self clampedRatio:self.panStartRatio + delta] animated:NO];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self setGripActive:NO];
            [self persistRatio];
            break;
        default:
            break;
    }
}

/// 双击分隔条：还原默认比例
- (void)onDividerDoubleTap {
    [self clearExpandedState];
    [self applyRatio:kSplitRatioDefault animated:YES];
    [self persistRatio];
}

#pragma mark - TSAIInterpreterTranscriptPanelViewDelegate

/// 点击某行：两面板同 index 行一起高亮并滚入视野；再点同一行取消
- (void)transcriptPanel:(TSAIInterpreterTranscriptPanelView *)panel
 didSelectUtteranceIndex:(NSInteger)utteranceIndex {
    BOOL clearing = (self.sourcePanel.pairedIndex == utteranceIndex);
    NSInteger newIndex = clearing ? NSNotFound : utteranceIndex;
    [self setPairedIndexOnBothPanels:newIndex];
    if (clearing) return;
    TSAIInterpreterTranscriptPanelView *other = (panel == self.sourcePanel) ? self.targetPanel : self.sourcePanel;
    [other scrollToUtteranceIndex:utteranceIndex];
    [panel scrollToUtteranceIndex:utteranceIndex];
}

/// 放大 / 还原：放大到 78%，再点回到放大前的比例
- (void)transcriptPanelDidTapExpand:(TSAIInterpreterTranscriptPanelView *)panel {
    if (self.expandedPanel == panel) {
        [self clearExpandedState];
        [self applyRatio:self.ratioBeforeExpand animated:YES];
        return;
    }
    if (self.expandedPanel == nil) {
        self.ratioBeforeExpand = self.ratio;
    }
    [self clearExpandedState];
    self.expandedPanel = panel;
    panel.expanded = YES;
    CGFloat target = (panel == self.sourcePanel) ? kSplitRatioExpanded : (1.0 - kSplitRatioExpanded);
    [self applyRatio:target animated:YES];
}

#pragma mark - 属性（懒加载）

- (TSAIInterpreterTranscriptPanelView *)sourcePanel {
    if (!_sourcePanel) {
        _sourcePanel = [[TSAIInterpreterTranscriptPanelView alloc] initWithRole:TSAIInterpreterLineRoleSource];
        _sourcePanel.delegate = self;
    }
    return _sourcePanel;
}

- (TSAIInterpreterTranscriptPanelView *)targetPanel {
    if (!_targetPanel) {
        _targetPanel = [[TSAIInterpreterTranscriptPanelView alloc] initWithRole:TSAIInterpreterLineRoleTarget];
        _targetPanel.delegate = self;
    }
    return _targetPanel;
}

- (UIView *)dividerView {
    if (!_dividerView) {
        _dividerView = [[UIView alloc] init];
        _dividerView.backgroundColor = [UIColor clearColor];
        _dividerView.userInteractionEnabled = NO;
    }
    return _dividerView;
}

- (UIView *)gripView {
    if (!_gripView) {
        _gripView = [[UIView alloc] init];
        _gripView.backgroundColor = [UIColor systemFillColor];
        _gripView.layer.cornerRadius = kSplitGripHeight / 2.0;
    }
    return _gripView;
}

- (UIView *)dividerHitView {
    if (!_dividerHitView) {
        _dividerHitView = [[UIView alloc] init];
        _dividerHitView.backgroundColor = [UIColor clearColor];
    }
    return _dividerHitView;
}

@end
